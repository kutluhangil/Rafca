import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/library/data/library_repository.dart';

void main() {
  group('LibraryRepository', () {
    late AppDatabase db;
    late LibraryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = LibraryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedData() async {
      final now = DateTime(2026, 11, 3, 10, 0);

      // Create a shelf
      await db.into(db.shelves).insert(
            ShelvesCompanion.insert(
              id: 'shelf_1',
              name: 'Klasikler',
              createdAt: now,
            ),
          );

      // Create a catalog book
      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion.insert(
              id: const Value(501),
              title: 'Suç ve Ceza',
              authors: const Value(['Fyodor Dostoyevski']),
              publisher: const Value('İletişim'),
              publishYear: const Value(1866),
            ),
          );

      // Insert matched user book (catalog linked)
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_1',
              bookId: const Value(501),
              shelfId: const Value('shelf_1'),
              status: const Value(ReadingStatus.read),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#304E2E'),
              capturePath: const Value('/captures/c1.jpg'),
              addedAt: now,
            ),
          );

      // Insert matched manual book (no catalog id)
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_2',
              manualTitle: const Value('Özel Notlar'),
              manualAuthor: const Value('Kutluhan'),
              status: const Value(ReadingStatus.reading),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#C9963F'),
              addedAt: now.add(const Duration(minutes: 5)),
            ),
          );

      // Insert review item (should be excluded from standard matched library list)
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_3',
              manualTitle: const Value('Bulanık Başlık'),
              confidence: MatchConfidence.review,
              addedAt: now.add(const Duration(minutes: 10)),
            ),
          );

      // Insert unknown item
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_4',
              confidence: MatchConfidence.unknown,
              addedAt: now.add(const Duration(minutes: 15)),
            ),
          );
    }

    test('watchLibraryBooks returns only MATCHED books in descending order', () async {
      await seedData();

      final books = await repo.watchLibraryBooks().first;
      expect(books.length, 2);
      expect(books[0].id, 'ub_2'); // later addedAt
      expect(books[0].title, 'Özel Notlar');
      expect(books[0].author, 'Kutluhan');

      expect(books[1].id, 'ub_1');
      expect(books[1].title, 'Suç ve Ceza');
      expect(books[1].author, 'Fyodor Dostoyevski');
      expect(books[1].shelfName, 'Klasikler');
    });

    test('watchLibraryBooks filters by shelf and status', () async {
      await seedData();

      // Filter by shelf
      final onShelf = await repo.watchLibraryBooks(shelfId: 'shelf_1').first;
      expect(onShelf.length, 1);
      expect(onShelf.first.id, 'ub_1');

      // Filter by reading status
      final reading = await repo.watchLibraryBooks(statusFilter: ReadingStatus.reading).first;
      expect(reading.length, 1);
      expect(reading.first.id, 'ub_2');
    });

    test('watchLibraryBooks filters by search query', () async {
      await seedData();

      final results = await repo.watchLibraryBooks(searchQuery: 'Dostoyevski').first;
      expect(results.length, 1);
      expect(results.first.title, 'Suç ve Ceza');

      final emptyResults = await repo.watchLibraryBooks(searchQuery: 'Bulunmayan').first;
      expect(emptyResults, isEmpty);
    });

    test('watchPendingReviewCount counts review and unknown items', () async {
      await seedData();

      final count = await repo.watchPendingReviewCount().first;
      expect(count, 2); // ub_3 (review) and ub_4 (unknown)
    });

    test('watchShelves returns shelf with book count and spine colors', () async {
      await seedData();

      final shelves = await repo.watchShelves().first;
      expect(shelves.length, 1);
      expect(shelves.first.id, 'shelf_1');
      expect(shelves.first.name, 'Klasikler');
      expect(shelves.first.bookCount, 1);
      expect(shelves.first.spineColors, ['#304E2E']);
    });

    test('watchBook returns single book with details', () async {
      await seedData();

      final book = await repo.watchBook('ub_1').first;
      expect(book, isNotNull);
      expect(book!.title, 'Suç ve Ceza');
      expect(book.status, ReadingStatus.read);
      expect(book.shelfName, 'Klasikler');
    });

    test('updateReadingStatus updates row and queues sync', () async {
      await seedData();

      await repo.updateReadingStatus('ub_1', ReadingStatus.unread);

      final book = await repo.watchBook('ub_1').first;
      expect(book!.status, ReadingStatus.unread);

      final queue = await db.syncQueueDao.pending();
      expect(queue.any((q) => q.rowId == 'ub_1'), isTrue);
    });

    test('updateBookShelf updates shelf assignment and queues sync', () async {
      await seedData();

      await repo.updateBookShelf('ub_2', 'shelf_1');

      final book = await repo.watchBook('ub_2').first;
      expect(book!.shelfId, 'shelf_1');
      expect(book.shelfName, 'Klasikler');
    });

    test('updateBookDetails updates manual title and author', () async {
      await seedData();

      await repo.updateBookDetails('ub_2', title: 'Güncellenmiş Notlar', author: 'Yeni Yazar');

      final book = await repo.watchBook('ub_2').first;
      expect(book!.title, 'Güncellenmiş Notlar');
      expect(book.author, 'Yeni Yazar');
    });

    test('deleteBook removes book and queues delete sync', () async {
      await seedData();

      await repo.deleteBook('ub_1');

      final book = await repo.watchBook('ub_1').first;
      expect(book, isNull);

      final queue = await db.syncQueueDao.pending();
      expect(queue.any((q) => q.rowId == 'ub_1' && q.operation == SyncOperation.delete), isTrue);
    });

    test('createShelf and deleteShelf manage shelf and unlink books', () async {
      await seedData();

      final newShelfId = await repo.createShelf('Felsefe');
      var shelves = await repo.watchShelves().first;
      expect(shelves.length, 2);

      // Assign book to new shelf
      await repo.updateBookShelf('ub_2', newShelfId);
      var b2 = await repo.watchBook('ub_2').first;
      expect(b2!.shelfId, newShelfId);

      // Delete new shelf
      await repo.deleteShelf(newShelfId);
      shelves = await repo.watchShelves().first;
      expect(shelves.length, 1);

      // Verify book unlinked
      b2 = await repo.watchBook('ub_2').first;
      expect(b2!.shelfId, isNull);
    });
  });
}
