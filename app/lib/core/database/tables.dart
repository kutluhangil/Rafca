import 'dart:convert';

import 'package:drift/drift.dart';

/// How sure the matcher was about a spine (SPINE_BLUEPRINT.md 8.4).
///
/// This is the stored, domain-level band. `ConfidenceLevel` in the design layer
/// is its presentation twin; the two are deliberately separate types so that
/// `core/` never has to import `design/`. Faz 7 maps between them at the edge
/// where a row becomes a card.
enum MatchConfidence { matched, review, unknown }

/// Where the reader is with a book. Mirrors the `status` check constraint on
/// `user_books` in `supabase/migrations/20260827090200_user_data.sql`.
enum ReadingStatus { unread, reading, read }

/// Which mirrored table a queued sync operation belongs to.
enum SyncEntity { shelf, userBook, scan, loan }

/// What the server has to be told about a row.
///
/// There is no separate insert: the server side is an upsert on the row's id,
/// which is what makes a retried push safe.
enum SyncOperation { upsert, delete }

/// `text[]` on the server, a JSON array on the device.
///
/// SQLite has no array type. JSON keeps the round trip lossless, including the
/// empty list, which a delimiter-joined string cannot distinguish from a list
/// holding one empty string.
class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) =>
      (jsonDecode(fromDb) as List<dynamic>).cast<String>();

  @override
  String toSql(List<String> value) => jsonEncode(value);
}

/// The rows of `books_index` this device has actually seen.
///
/// Not a full copy of the catalogue — Faz 4 loads over a million rows into
/// Postgres and none of that belongs on a phone. A row lands here when a match
/// resolves to it, so that the library still renders titles, authors and covers
/// with no network (SPINE_BLUEPRINT.md 3.1).
class CatalogBooks extends Table {
  /// `books_index.id`. Server-assigned, so this table is never written to
  /// before a match has come back.
  IntColumn get id => integer()();

  TextColumn get olKey => text().nullable()();
  TextColumn get isbn13 => text().nullable()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get authors =>
      text().map(const StringListConverter()).withDefault(const Constant('[]'))();
  TextColumn get publisher => text().nullable()();
  IntColumn get publishYear => integer().nullable()();
  TextColumn get language => text().nullable()();
  TextColumn get coverUrl => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Mirror of `shelves`.
///
/// `user_id` is absent on purpose. A first-run user scans a shelf before any
/// account exists — anonymous sign-in needs a network round trip, local-first
/// does not — so at insert time there is no user id to store. The push stamps
/// `auth.uid()` when the row finally leaves the device.
@DataClassName('Shelf')
class Shelves extends Table {
  /// Generated on the device so the row keeps its identity through the sync.
  TextColumn get id => text()();

  TextColumn get name => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();

  /// True while this row differs from what the server has.
  ///
  /// The queue in [SyncQueueEntries] is what the drainer walks; this flag is
  /// what a screen reads to show a row as not yet synced. [SyncQueueDao] writes
  /// both in one transaction so they cannot disagree.
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Mirror of `user_books`, plus the on-device crop.
class UserBooks extends Table {
  TextColumn get id => text()();

  /// Null for a hand-typed book that is not in the catalogue.
  IntColumn get bookId =>
      integer().nullable().references(CatalogBooks, #id)();

  TextColumn get manualTitle => text().nullable()();
  TextColumn get manualAuthor => text().nullable()();
  TextColumn get shelfId => text().nullable().references(Shelves, #id)();
  TextColumn get status => textEnum<ReadingStatus>()
      .withDefault(Constant(ReadingStatus.unread.name))();
  TextColumn get confidence => textEnum<MatchConfidence>()();

  /// `#RRGGBB`, the colour `ShelfStrip` draws this spine with.
  TextColumn get spineColor => text().nullable()();

  /// Path to the spine crop under `ApplicationDocumentsDirectory/spine/captures/`.
  ///
  /// Device-only, and it has no column on the server: images never sync
  /// (SPINE_BLUEPRINT.md 5). The one exception, "Enhance", uploads a single
  /// crop for one request and stores nothing.
  TextColumn get capturePath => text().nullable()();

  /// Left-to-right position of this book along the physical shelf (1-based index).
  /// Derived from `SpineCandidate.bbox.left` during scan review.
  IntColumn get shelfPosition => integer().nullable()();

  DateTimeColumn get addedAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Mirror of `scans`, plus the shelf photo it came from.
class Scans extends Table {
  TextColumn get id => text()();
  IntColumn get detectedCount => integer().nullable()();
  IntColumn get matchedCount => integer().nullable()();

  /// The raw shelf photo. Device-only, for the same reason as
  /// [UserBooks.capturePath] — this is the "PROOF OF CAPTURE" image, read from
  /// the local file and never uploaded.
  TextColumn get capturePath => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Book loan tracking record (Faz 11 — Ödünç Takipçisi).
/// Stores borrower name, contact, loan date, due date, return date, and notes.
@DataClassName('BookLoan')
class BookLoans extends Table {
  TextColumn get id => text()();
  TextColumn get userBookId => text().references(UserBooks, #id)();
  TextColumn get borrowerName => text()();
  TextColumn get borrowerContact => text().nullable()();
  DateTimeColumn get loanedAt => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  DateTimeColumn get returnedAt => dateTime().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get pendingSync => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// The outbox. One pending operation per row, in the order it was raised.
///
/// The queue stores the operation, not the payload: the drainer reads the
/// current state of the row when it pushes. That is why repeated edits of one
/// row collapse into a single entry — [uniqueKeys] enforces it — and why a
/// push that is retried after a later edit sends the newer value rather than a
/// stale snapshot.
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entity => textEnum<SyncEntity>()();

  /// Primary key of the row in the mirrored table.
  TextColumn get rowId => text()();

  TextColumn get operation => textEnum<SyncOperation>()();
  DateTimeColumn get enqueuedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();

  /// The last failure, kept verbatim so a stuck queue can be explained rather
  /// than guessed at.
  TextColumn get lastError => text().nullable()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {entity, rowId},
      ];
}
