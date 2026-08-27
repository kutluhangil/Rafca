import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertShelf(String id) {
    return database.into(database.shelves).insert(
          ShelvesCompanion.insert(
            id: id,
            name: 'Salon',
            createdAt: DateTime(2026, 8, 27),
          ),
        );
  }

  Future<Shelf> readShelf(String id) {
    return (database.select(database.shelves)
          ..where((row) => row.id.equals(id)))
        .getSingle();
  }

  group('schema', () {
    test('a locally created row starts out pending', () async {
      await insertShelf('shelf-1');

      expect((await readShelf('shelf-1')).pendingSync, isTrue);
    });

    test('authors survive the round trip, empty list included', () async {
      await database.into(database.catalogBooks).insert(
            CatalogBooksCompanion.insert(
              id: Value(1),
              title: 'Tutunamayanlar',
              authors: const Value(['Oğuz Atay', 'Başkası']),
            ),
          );
      await database.into(database.catalogBooks).insert(
            CatalogBooksCompanion.insert(id: Value(2), title: 'Anonim'),
          );

      final books = await database.select(database.catalogBooks).get();

      expect(
        books.firstWhere((book) => book.id == 1).authors,
        ['Oğuz Atay', 'Başkası'],
      );
      expect(books.firstWhere((book) => book.id == 2).authors, isEmpty);
    });

    test('a user book cannot point at a shelf that is not there', () async {
      expect(
        () => database.into(database.userBooks).insert(
              UserBooksCompanion.insert(
                id: 'book-1',
                confidence: MatchConfidence.review,
                addedAt: DateTime(2026, 8, 27),
                shelfId: const Value('missing-shelf'),
                manualTitle: const Value('Elde yazılmış'),
              ),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });

  group('SyncQueueDao', () {
    test('enqueue leaves one entry and a pending row', () async {
      await insertShelf('shelf-1');
      await database.syncQueueDao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );

      final queued = await database.syncQueueDao.pending();

      expect(queued, hasLength(1));
      expect(queued.single.entity, SyncEntity.shelf);
      expect(queued.single.operation, SyncOperation.upsert);
      expect((await readShelf('shelf-1')).pendingSync, isTrue);
    });

    test('enqueuing the same row twice collapses to one entry', () async {
      await insertShelf('shelf-1');
      final dao = database.syncQueueDao;

      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );
      await dao.markFailed((await dao.pending()).single.id, 'no network');
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.delete,
      );

      final queued = await dao.pending();

      expect(queued, hasLength(1));
      expect(queued.single.operation, SyncOperation.delete);
      expect(queued.single.attempts, 0);
      expect(queued.single.lastError, null);
    });

    test('the same row id in two entities is two entries', () async {
      await insertShelf('same-id');
      await database.into(database.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'same-id',
              confidence: MatchConfidence.matched,
              addedAt: DateTime(2026, 8, 27),
              manualTitle: const Value('Elde yazılmış'),
            ),
          );
      final dao = database.syncQueueDao;

      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'same-id',
        operation: SyncOperation.upsert,
      );
      await dao.enqueue(
        entity: SyncEntity.userBook,
        rowId: 'same-id',
        operation: SyncOperation.upsert,
      );

      expect(await dao.pending(), hasLength(2));
    });

    test('markSynced drops the entry and clears the flag', () async {
      await insertShelf('shelf-1');
      final dao = database.syncQueueDao;
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );

      await dao.markSynced((await dao.pending()).single.id);

      expect(await dao.pending(), isEmpty);
      expect((await readShelf('shelf-1')).pendingSync, isFalse);
    });

    test('markFailed keeps the entry queued and the row pending', () async {
      await insertShelf('shelf-1');
      final dao = database.syncQueueDao;
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );

      final entryId = (await dao.pending()).single.id;
      await dao.markFailed(entryId, 'SocketException: no route to host');
      await dao.markFailed(entryId, 'SocketException: no route to host');

      final queued = await dao.pending();

      expect(queued.single.attempts, 2);
      expect(queued.single.lastError, contains('no route to host'));
      expect((await readShelf('shelf-1')).pendingSync, isTrue);
    });

    test('completing an entry twice is reported, not ignored', () async {
      await insertShelf('shelf-1');
      final dao = database.syncQueueDao;
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );
      final entryId = (await dao.pending()).single.id;
      await dao.markSynced(entryId);

      expect(
        () => dao.markSynced(entryId),
        throwsA(isA<StateError>()),
      );
    });

    test('a deleted row can still be queued for deletion', () async {
      await insertShelf('shelf-1');
      final dao = database.syncQueueDao;

      await (database.delete(database.shelves)
            ..where((row) => row.id.equals('shelf-1')))
          .go();
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.delete,
      );

      expect((await dao.pending()).single.operation, SyncOperation.delete);

      await dao.markSynced((await dao.pending()).single.id);

      expect(await dao.pending(), isEmpty);
    });

    test('pending() is ordered oldest first', () async {
      await insertShelf('shelf-1');
      await insertShelf('shelf-2');
      final dao = database.syncQueueDao;

      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-1',
        operation: SyncOperation.upsert,
      );
      await dao.enqueue(
        entity: SyncEntity.shelf,
        rowId: 'shelf-2',
        operation: SyncOperation.upsert,
      );

      expect(
        (await dao.pending()).map((entry) => entry.rowId),
        ['shelf-1', 'shelf-2'],
      );
    });
  });
}
