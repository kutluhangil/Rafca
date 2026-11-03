import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/library/data/library_repository.dart';
import 'package:rafca/features/library/models/library_models.dart';

void main() {
  group('Faz 11: Physical Shelf Twin & Lending Tracker Tests', () {
    late AppDatabase db;
    late LibraryRepository repo;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = LibraryRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('shelf position ordering sorts books by 1-based physical shelf order', () async {
      final now = DateTime(2026, 11, 3, 10, 0);

      // Book 1: shelf position 3
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_pos3',
              manualTitle: const Value('Üçüncü Kitap'),
              manualAuthor: const Value('Yazar C'),
              confidence: MatchConfidence.matched,
              shelfPosition: const Value(3),
              addedAt: now,
            ),
          );

      // Book 2: shelf position 1
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_pos1',
              manualTitle: const Value('Birinci Kitap'),
              manualAuthor: const Value('Yazar A'),
              confidence: MatchConfidence.matched,
              shelfPosition: const Value(1),
              addedAt: now.add(const Duration(minutes: 1)),
            ),
          );

      // Book 3: shelf position 2
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_pos2',
              manualTitle: const Value('İkinci Kitap'),
              manualAuthor: const Value('Yazar B'),
              confidence: MatchConfidence.matched,
              shelfPosition: const Value(2),
              addedAt: now.add(const Duration(minutes: 2)),
            ),
          );

      final books = await repo
          .watchLibraryBooks(sortOption: BookSortOption.shelfPositionAsc)
          .first;

      expect(books.length, 3);
      expect(books[0].id, 'ub_pos1');
      expect(books[0].shelfPosition, 1);
      expect(books[1].id, 'ub_pos2');
      expect(books[1].shelfPosition, 2);
      expect(books[2].id, 'ub_pos3');
      expect(books[2].shelfPosition, 3);
    });

    test('loanBook creates active loan and marks book.isOnLoan as true', () async {
      final now = DateTime(2026, 11, 3, 10, 0);
      final dueDate = now.add(const Duration(days: 14));

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_loan_1',
              manualTitle: const Value('Dune'),
              manualAuthor: const Value('Frank Herbert'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      // Initially not on loan
      var book = await repo.watchBook('ub_loan_1').first;
      expect(book, isNotNull);
      expect(book!.isOnLoan, isFalse);
      expect(book.activeLoan, isNull);

      // Loan the book
      final loanId = await repo.loanBook(
        userBookId: 'ub_loan_1',
        borrowerName: 'Canan Can',
        borrowerContact: '+90 555 123 4567',
        dueDate: dueDate,
        notes: '2 hafta sonra sınavdan sonra iade edecek',
      );

      expect(loanId, isNotEmpty);

      // Verify book is now on loan
      book = await repo.watchBook('ub_loan_1').first;
      expect(book!.isOnLoan, isTrue);
      expect(book.activeLoan, isNotNull);
      expect(book.activeLoan!.borrowerName, 'Canan Can');
      expect(book.activeLoan!.borrowerContact, '+90 555 123 4567');
      expect(book.activeLoan!.dueDate, dueDate);
      expect(book.activeLoan!.notes, '2 hafta sonra sınavdan sonra iade edecek');

      // Verify sync queue enqueued SyncEntity.loan
      final queueEntries = await db.select(db.syncQueueEntries).get();
      final loanSync = queueEntries.where((e) => e.entity == SyncEntity.loan);
      expect(loanSync.length, 1);
      expect(loanSync.first.rowId, loanId);
    });

    test('onLoanFilter isolates only books currently on loan', () async {
      final now = DateTime(2026, 11, 3, 10, 0);

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_free',
              manualTitle: const Value('Kütüphanedeki Kitap'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_loaned',
              manualTitle: const Value('Ödünçteki Kitap'),
              confidence: MatchConfidence.matched,
              addedAt: now.add(const Duration(minutes: 1)),
            ),
          );

      await repo.loanBook(
        userBookId: 'ub_loaned',
        borrowerName: 'Ahmet Yılmaz',
      );

      // Filter on loan
      final onLoanBooks = await repo.watchLibraryBooks(onLoanFilter: true).first;
      expect(onLoanBooks.length, 1);
      expect(onLoanBooks.first.id, 'ub_loaned');
      expect(onLoanBooks.first.activeLoan!.borrowerName, 'Ahmet Yılmaz');

      // No filter returns both
      final allBooks = await repo.watchLibraryBooks().first;
      expect(allBooks.length, 2);
    });

    test('returnBook closes loan and resets isOnLoan to false', () async {
      final now = DateTime(2026, 11, 3, 10, 0);

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_return_test',
              manualTitle: const Value('Simyacı'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      final loanId = await repo.loanBook(
        userBookId: 'ub_return_test',
        borrowerName: 'Mehmet Demir',
      );

      // Verify active
      var book = await repo.watchBook('ub_return_test').first;
      expect(book!.isOnLoan, isTrue);

      // Return the book
      await repo.returnBook(loanId);

      // Verify no longer active
      book = await repo.watchBook('ub_return_test').first;
      expect(book!.isOnLoan, isFalse);
      expect(book.activeLoan, isNull);

      // Verify historical loan still exists in db
      final loans = await repo.watchLoans(activeOnly: false).first;
      expect(loans.length, 1);
      expect(loans.first.id, loanId);
      expect(loans.first.returnedAt, isNotNull);

      // Active only returns 0
      final activeLoans = await repo.watchLoans(activeOnly: true).first;
      expect(activeLoans.isEmpty, isTrue);
    });

    test('clearAllData wipes bookLoans alongside other tables', () async {
      final now = DateTime(2026, 11, 3, 10, 0);

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_wipe',
              manualTitle: const Value('Silinecek Kitap'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      await repo.loanBook(
        userBookId: 'ub_wipe',
        borrowerName: 'Test Kişi',
      );

      expect((await db.select(db.bookLoans).get()).isNotEmpty, isTrue);
      expect((await db.select(db.userBooks).get()).isNotEmpty, isTrue);

      await repo.clearAllData();

      expect((await db.select(db.bookLoans).get()).isEmpty, isTrue);
      expect((await db.select(db.userBooks).get()).isEmpty, isTrue);
      expect((await db.select(db.syncQueueEntries).get()).isEmpty, isTrue);
    });
  });
}
