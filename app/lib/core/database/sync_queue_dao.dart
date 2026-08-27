import 'package:drift/drift.dart';

import 'app_database.dart';
import 'tables.dart';

part 'sync_queue_dao.g.dart';

/// The outbox side of local-first sync (SPINE_BLUEPRINT.md 6.2).
///
/// Rafça writes to SQLite and returns; nothing in the UI waits on a server.
/// What the server still owes is recorded here, and a later phase drains it.
/// This class owns the invariant that makes the two representations safe to
/// keep at once: a queue entry and its row's `pending_sync` flag are always
/// written in the same transaction, so a screen showing "not synced" and the
/// drainer's work list can never disagree.
@DriftAccessor(tables: [Shelves, UserBooks, Scans, SyncQueueEntries])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.attachedDatabase);

  /// Records that [rowId] in [entity] needs [operation] applied on the server.
  ///
  /// Enqueuing the same row twice replaces the earlier entry rather than adding
  /// one: the queue holds operations, not payloads, so a second edit is already
  /// covered by the first entry's eventual read of the row. Replacing also
  /// clears [SyncQueueEntry.attempts] and [SyncQueueEntry.lastError], because a
  /// changed row is a new attempt, not a continuation of a failed one.
  Future<void> enqueue({
    required SyncEntity entity,
    required String rowId,
    required SyncOperation operation,
    DateTime? at,
  }) {
    final now = at ?? DateTime.now();
    return transaction(() async {
      await into(syncQueueEntries).insert(
        SyncQueueEntriesCompanion.insert(
          entity: entity,
          rowId: rowId,
          operation: operation,
          enqueuedAt: now,
        ),
        onConflict: DoUpdate(
          (_) => SyncQueueEntriesCompanion(
            operation: Value(operation),
            enqueuedAt: Value(now),
            attempts: const Value(0),
            lastError: const Value(null),
          ),
          target: [syncQueueEntries.entity, syncQueueEntries.rowId],
        ),
      );
      await _setPendingSync(entity: entity, rowId: rowId, pending: true);
    });
  }

  /// Everything the server still owes, oldest first.
  Future<List<SyncQueueEntry>> pending() {
    return (select(syncQueueEntries)
          ..orderBy([(entry) => OrderingTerm.asc(entry.id)]))
        .get();
  }

  /// Drops [entryId] and clears its row's flag, after the server accepted it.
  Future<void> markSynced(int entryId) {
    return transaction(() async {
      final entry = await _require(entryId);
      await (delete(syncQueueEntries)
            ..where((queued) => queued.id.equals(entryId)))
          .go();
      await _setPendingSync(
        entity: entry.entity,
        rowId: entry.rowId,
        pending: false,
      );
    });
  }

  /// Records a failed push. The entry stays queued and the row stays pending.
  ///
  /// [error] is stored verbatim: a queue that stopped draining has to be able
  /// to say why without anyone having to reproduce it.
  Future<void> markFailed(int entryId, String error) {
    return transaction(() async {
      final entry = await _require(entryId);
      await (update(syncQueueEntries)
            ..where((queued) => queued.id.equals(entryId)))
          .write(
        SyncQueueEntriesCompanion(
          attempts: Value(entry.attempts + 1),
          lastError: Value(error),
        ),
      );
    });
  }

  Future<SyncQueueEntry> _require(int entryId) async {
    final entry = await (select(syncQueueEntries)
          ..where((queued) => queued.id.equals(entryId)))
        .getSingleOrNull();
    if (entry == null) {
      throw StateError(
        'Sync queue entry $entryId does not exist. It was either already '
        'completed or never enqueued; completing an entry twice means the '
        'drainer lost track of what it leased.',
      );
    }
    return entry;
  }

  /// A [SyncOperation.delete] leaves no row to flag, so an update that matches
  /// nothing is the expected outcome there, not a failure.
  Future<void> _setPendingSync({
    required SyncEntity entity,
    required String rowId,
    required bool pending,
  }) async {
    final flag = Value(pending);
    switch (entity) {
      case SyncEntity.shelf:
        await (update(shelves)..where((row) => row.id.equals(rowId)))
            .write(ShelvesCompanion(pendingSync: flag));
      case SyncEntity.userBook:
        await (update(userBooks)..where((row) => row.id.equals(rowId)))
            .write(UserBooksCompanion(pendingSync: flag));
      case SyncEntity.scan:
        await (update(scans)..where((row) => row.id.equals(rowId)))
            .write(ScansCompanion(pendingSync: flag));
    }
  }
}
