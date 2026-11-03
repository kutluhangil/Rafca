import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../models/library_models.dart';

class LibraryRepository {
  LibraryRepository(this._db);

  final AppDatabase _db;

  /// Watch all books in the library. By default, orders by `addedAt` descending.
  Stream<List<LibraryBook>> watchLibraryBooks({
    String? shelfId,
    ReadingStatus? statusFilter,
    MatchConfidence? confidenceFilter,
    String? searchQuery,
  }) {
    final query = _db.select(_db.userBooks).join([
      leftOuterJoin(
        _db.catalogBooks,
        _db.catalogBooks.id.equalsExp(_db.userBooks.bookId),
      ),
      leftOuterJoin(
        _db.shelves,
        _db.shelves.id.equalsExp(_db.userBooks.shelfId),
      ),
    ]);

    // BluePrint §8: UNKNOWN and REVIEW items stay in the pending review banner
    // and are not mixed with confirmed library books unless explicitly filtered.
    query.where(
      confidenceFilter != null
          ? _db.userBooks.confidence.equalsValue(confidenceFilter)
          : _db.userBooks.confidence.equalsValue(MatchConfidence.matched),
    );

    if (shelfId != null) {
      query.where(_db.userBooks.shelfId.equals(shelfId));
    }

    if (statusFilter != null) {
      query.where(_db.userBooks.status.equalsValue(statusFilter));
    }

    query.orderBy([OrderingTerm.desc(_db.userBooks.addedAt)]);

    return query.watch().map((rows) => _mapRows(rows, searchQuery));
  }

  List<LibraryBook> _mapRows(List<TypedResult> rows, [String? searchQuery]) {
    final list = <LibraryBook>[];

    for (final row in rows) {
      final userBook = row.readTable(_db.userBooks);
      final catalogBook = row.readTableOrNull(_db.catalogBooks);
      final shelf = row.readTableOrNull(_db.shelves);

      final title = catalogBook?.title ?? userBook.manualTitle ?? 'Bilinmeyen Eser';
      final author = (catalogBook?.authors.isNotEmpty ?? false)
          ? catalogBook!.authors.first
          : (userBook.manualAuthor ?? 'Bilinmeyen Yazar');

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.toLowerCase().trim();
        final matchesTitle = title.toLowerCase().contains(q);
        final matchesAuthor = author.toLowerCase().contains(q);
        final matchesPub = (catalogBook?.publisher ?? '').toLowerCase().contains(q);
        if (!matchesTitle && !matchesAuthor && !matchesPub) {
          continue;
        }
      }

      list.add(
        LibraryBook(
          id: userBook.id,
          catalogBookId: userBook.bookId,
          title: title,
          author: author,
          publisher: catalogBook?.publisher,
          publishYear: catalogBook?.publishYear,
          coverUrl: catalogBook?.coverUrl,
          status: userBook.status,
          confidence: userBook.confidence,
          spineColor: userBook.spineColor,
          capturePath: userBook.capturePath,
          shelfId: userBook.shelfId,
          shelfName: shelf?.name,
          addedAt: userBook.addedAt,
        ),
      );
    }

    return list;
  }

  /// Watch count of items pending review or correction (BLUEPRINT §8).
  Stream<int> watchPendingReviewCount() {
    final countExp = _db.userBooks.id.count();
    final query = _db.selectOnly(_db.userBooks)
      ..addColumns([countExp])
      ..where(
        _db.userBooks.confidence.equalsValue(MatchConfidence.review) |
            _db.userBooks.confidence.equalsValue(MatchConfidence.unknown),
      );

    return query.watchSingle().map((row) => row.read(countExp) ?? 0);
  }

  /// Watch shelves with book count and representative spine colors.
  Stream<List<LibraryShelf>> watchShelves() {
    return _db.select(_db.shelves).watch().asyncMap((shelvesList) async {
      final result = <LibraryShelf>[];

      for (final shelf in shelvesList) {
        final books = await (_db.select(_db.userBooks)
              ..where((u) => u.shelfId.equals(shelf.id)))
            .get();

        final colors = books
            .map((b) => b.spineColor)
            .whereType<String>()
            .take(10)
            .toList();

        result.add(
          LibraryShelf(
            id: shelf.id,
            name: shelf.name,
            sortOrder: shelf.sortOrder,
            createdAt: shelf.createdAt,
            bookCount: books.length,
            spineColors: colors,
          ),
        );
      }

      return result;
    });
  }

  /// Watch a single book by its userBook ID.
  Stream<LibraryBook?> watchBook(String userBookId) {
    final query = _db.select(_db.userBooks).join([
      leftOuterJoin(
        _db.catalogBooks,
        _db.catalogBooks.id.equalsExp(_db.userBooks.bookId),
      ),
      leftOuterJoin(
        _db.shelves,
        _db.shelves.id.equalsExp(_db.userBooks.shelfId),
      ),
    ])..where(_db.userBooks.id.equals(userBookId));

    return query.watchSingleOrNull().map((row) {
      if (row == null) return null;
      final userBook = row.readTable(_db.userBooks);
      final catalogBook = row.readTableOrNull(_db.catalogBooks);
      final shelf = row.readTableOrNull(_db.shelves);

      return LibraryBook(
        id: userBook.id,
        catalogBookId: userBook.bookId,
        title: catalogBook?.title ?? userBook.manualTitle ?? 'Bilinmeyen Eser',
        author: (catalogBook?.authors.isNotEmpty ?? false)
            ? catalogBook!.authors.first
            : (userBook.manualAuthor ?? 'Bilinmeyen Yazar'),
        publisher: catalogBook?.publisher,
        publishYear: catalogBook?.publishYear,
        coverUrl: catalogBook?.coverUrl,
        status: userBook.status,
        confidence: userBook.confidence,
        spineColor: userBook.spineColor,
        capturePath: userBook.capturePath,
        shelfId: userBook.shelfId,
        shelfName: shelf?.name,
        addedAt: userBook.addedAt,
      );
    });
  }

  /// Updates reading status of a book and enqueues sync.
  Future<void> updateReadingStatus(String userBookId, ReadingStatus status) async {
    await _db.transaction(() async {
      await (_db.update(_db.userBooks)..where((u) => u.id.equals(userBookId))).write(
        UserBooksCompanion(
          status: Value(status),
          pendingSync: const Value(true),
        ),
      );
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.userBook,
        rowId: userBookId,
        operation: SyncOperation.upsert,
      );
    });
  }

  /// Assigns or unassigns a book to a shelf.
  Future<void> updateBookShelf(String userBookId, String? shelfId) async {
    await _db.transaction(() async {
      await (_db.update(_db.userBooks)..where((u) => u.id.equals(userBookId))).write(
        UserBooksCompanion(
          shelfId: Value(shelfId),
          pendingSync: const Value(true),
        ),
      );
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.userBook,
        rowId: userBookId,
        operation: SyncOperation.upsert,
      );
    });
  }

  /// Updates manual book details.
  Future<void> updateBookDetails(
    String userBookId, {
    required String title,
    required String author,
  }) async {
    await _db.transaction(() async {
      await (_db.update(_db.userBooks)..where((u) => u.id.equals(userBookId))).write(
        UserBooksCompanion(
          manualTitle: Value(title.trim()),
          manualAuthor: Value(author.trim()),
          pendingSync: const Value(true),
        ),
      );
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.userBook,
        rowId: userBookId,
        operation: SyncOperation.upsert,
      );
    });
  }

  /// Deletes a book from the user's library and enqueues sync delete.
  Future<void> deleteBook(String userBookId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.userBooks)..where((u) => u.id.equals(userBookId))).go();
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.userBook,
        rowId: userBookId,
        operation: SyncOperation.delete,
      );
    });
  }

  /// Creates a new shelf and enqueues sync.
  Future<String> createShelf(String name) async {
    final id = 'shelf_${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();

    await _db.transaction(() async {
      await _db.into(_db.shelves).insert(
            ShelvesCompanion(
              id: Value(id),
              name: Value(name.trim()),
              createdAt: Value(now),
              pendingSync: const Value(true),
            ),
          );
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.shelf,
        rowId: id,
        operation: SyncOperation.upsert,
      );
    });

    return id;
  }

  /// Deletes a shelf, unlinks its books, and enqueues sync delete.
  Future<void> deleteShelf(String shelfId) async {
    await _db.transaction(() async {
      // Unlink books from this shelf
      await (_db.update(_db.userBooks)..where((u) => u.shelfId.equals(shelfId))).write(
        const UserBooksCompanion(shelfId: Value(null)),
      );
      // Delete shelf
      await (_db.delete(_db.shelves)..where((s) => s.id.equals(shelfId))).go();
      await _db.syncQueueDao.enqueue(
        entity: SyncEntity.shelf,
        rowId: shelfId,
        operation: SyncOperation.delete,
      );
    });
  }

  /// Fetches all books in the library once (for export).
  Future<List<LibraryBook>> getAllBooks({String? shelfId}) async {
    final query = _db.select(_db.userBooks).join([
      leftOuterJoin(
        _db.catalogBooks,
        _db.catalogBooks.id.equalsExp(_db.userBooks.bookId),
      ),
      leftOuterJoin(
        _db.shelves,
        _db.shelves.id.equalsExp(_db.userBooks.shelfId),
      ),
    ]);

    query.where(_db.userBooks.confidence.equalsValue(MatchConfidence.matched));

    if (shelfId != null) {
      query.where(_db.userBooks.shelfId.equals(shelfId));
    }

    query.orderBy([OrderingTerm.desc(_db.userBooks.addedAt)]);
    final rows = await query.get();
    return _mapRows(rows);
  }

  /// Completely wipes local library data (userBooks, shelves, scans, syncQueue).
  Future<void> clearAllData() async {
    await _db.transaction(() async {
      await _db.delete(_db.userBooks).go();
      await _db.delete(_db.shelves).go();
      await _db.delete(_db.scans).go();
      await _db.delete(_db.syncQueueEntries).go();
    });
  }
}

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LibraryRepository(db);
});

final libraryBooksProvider = StreamProvider.autoDispose.family<List<LibraryBook>, ({String? shelfId, ReadingStatus? statusFilter, String? search})>(
  (ref, params) {
    final repo = ref.watch(libraryRepositoryProvider);
    return repo.watchLibraryBooks(
      shelfId: params.shelfId,
      statusFilter: params.statusFilter,
      searchQuery: params.search,
    );
  },
);

final libraryShelvesProvider = StreamProvider.autoDispose<List<LibraryShelf>>((ref) {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.watchShelves();
});

final pendingReviewCountProvider = StreamProvider.autoDispose<int>((ref) {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.watchPendingReviewCount();
});
