import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/tables.dart';
import '../models/review_models.dart';

class ReviewStateNotifier extends StateNotifier<ReviewBatch> {
  ReviewStateNotifier(super.initialState);

  /// Selects an alternative book edition, promoting the item to MATCHED.
  void selectAlternative(String itemId, ReviewCandidateBook book) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId)
            item.copyWith(
              selectedBook: book,
              confidence: MatchConfidence.matched,
              confidenceScore: 0.95,
            )
          else
            item,
      ],
    );
  }

  /// Sets manual title and author, promoting the item to MATCHED.
  void setManualEntry(String itemId, String title, String author) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId)
            item.copyWith(
              manualTitle: title.trim(),
              manualAuthor: author.trim(),
              selectedBook: null,
              confidence: MatchConfidence.matched,
              confidenceScore: 1.0,
            )
          else
            item,
      ],
    );
  }

  /// Discards the item from the scan results ("Not a book").
  void discardItem(String itemId) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (item.id == itemId)
            item.copyWith(isDiscarded: true)
          else
            item,
      ],
    );
  }

  /// Persists all active MATCHED books into local Drift SQLite and queues for sync.
  Future<int> saveMatchedToLibrary(AppDatabase db) async {
    final toSave = state.matchedItems;
    if (toSave.isEmpty) return 0;

    final now = DateTime.now();

    await db.transaction(() async {
      // 1. Record the scan entry
      await db.into(db.scans).insert(
            ScansCompanion(
              id: Value(state.scanId),
              detectedCount: Value(state.items.length),
              matchedCount: Value(toSave.length),
              capturePath: Value(state.sourceImagePath),
              createdAt: Value(now),
              pendingSync: const Value(true),
            ),
          );
      await db.syncQueueDao.enqueue(
        entity: SyncEntity.scan,
        rowId: state.scanId,
        operation: SyncOperation.upsert,
      );

      // 2. Insert catalog entries and user books
      for (final item in toSave) {
        int? catalogBookId;

        if (item.selectedBook != null) {
          final b = item.selectedBook!;
          catalogBookId = b.id;

          // Upsert catalog book mirror
          await db.into(db.catalogBooks).insert(
                CatalogBooksCompanion(
                  id: Value(b.id),
                  title: Value(b.title),
                  authors: Value([b.author]),
                  publisher: Value(b.publisher),
                  publishYear: Value(b.publishYear),
                  coverUrl: Value(b.coverUrl),
                ),
                mode: InsertMode.insertOrReplace,
              );
        }

        final userBookId = '${state.scanId}_${item.id}';
        await db.into(db.userBooks).insert(
              UserBooksCompanion(
                id: Value(userBookId),
                bookId: Value(catalogBookId),
                manualTitle: Value(item.manualTitle),
                manualAuthor: Value(item.manualAuthor),
                status: const Value(ReadingStatus.unread),
                confidence: const Value(MatchConfidence.matched),
                spineColor: Value(item.spineColor),
                capturePath: Value(item.cropPath),
                addedAt: Value(now),
                pendingSync: const Value(true),
              ),
              mode: InsertMode.insertOrReplace,
            );

        await db.syncQueueDao.enqueue(
          entity: SyncEntity.userBook,
          rowId: userBookId,
          operation: SyncOperation.upsert,
        );
      }
    });

    return toSave.length;
  }
}

final reviewControllerProvider = StateNotifierProvider.autoDispose
    .family<ReviewStateNotifier, ReviewBatch, ReviewBatch>(
  (ref, initial) => ReviewStateNotifier(initial),
);
