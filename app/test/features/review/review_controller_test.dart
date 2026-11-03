import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/review/models/review_models.dart';
import 'package:rafca/features/review/state/review_controller.dart';

void main() {
  group('ReviewBatch and ReviewStateNotifier', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    ReviewBatch createSampleBatch() {
      return const ReviewBatch(
        scanId: 'scan_123',
        sourceImagePath: '/path/to/shelf.jpg',
        items: [
          ReviewItem(
            id: 'c1',
            cropPath: '/path/crop_1.jpg',
            spineColor: '#8C2D19',
            rawText: 'KARA KİTAP\nORHAN PAMUK',
            confidence: MatchConfidence.matched,
            confidenceScore: 0.95,
            selectedBook: ReviewCandidateBook(
              id: 101,
              title: 'Kara Kitap',
              author: 'Orhan Pamuk',
              publisher: 'İletişim Yayınları',
              publishYear: 1990,
              score: 0.95,
            ),
          ),
          ReviewItem(
            id: 'c2',
            cropPath: '/path/crop_2.jpg',
            spineColor: '#1A365D',
            rawText: 'TUTUNAMAYANLAR',
            confidence: MatchConfidence.review,
            confidenceScore: 0.72,
            alternatives: [
              ReviewCandidateBook(
                id: 102,
                title: 'Tutunamayanlar',
                author: 'Oğuz Atay',
                publisher: 'İletişim Yayınları',
                publishYear: 1972,
                score: 0.72,
              ),
              ReviewCandidateBook(
                id: 103,
                title: 'Tehlikeli Oyunlar',
                author: 'Oğuz Atay',
                score: 0.60,
              ),
            ],
          ),
          ReviewItem(
            id: 'c3',
            cropPath: '/path/crop_3.jpg',
            spineColor: '#2D3748',
            rawText: '???',
            confidence: MatchConfidence.unknown,
            confidenceScore: 0.20,
          ),
        ],
      );
    }

    test('initial batch groups items correctly', () {
      final batch = createSampleBatch();
      expect(batch.items.length, 3);
      expect(batch.activeItems.length, 3);
      expect(batch.matchedItems.length, 1);
      expect(batch.reviewItems.length, 1);
      expect(batch.unknownItems.length, 1);
      expect(batch.totalIssuesCount, 2);
    });

    test('selectAlternative promotes review item to matched', () {
      final initial = createSampleBatch();
      final notifier = ReviewStateNotifier(initial);

      final alt = initial.items[1].alternatives.first;
      notifier.selectAlternative('c2', alt);

      final updated = notifier.state;
      expect(updated.matchedItems.length, 2);
      expect(updated.reviewItems.length, 0);
      expect(updated.unknownItems.length, 1);
      expect(updated.totalIssuesCount, 1);

      final item2 = updated.items.firstWhere((i) => i.id == 'c2');
      expect(item2.confidence, MatchConfidence.matched);
      expect(item2.selectedBook?.title, 'Tutunamayanlar');
      expect(item2.confidenceScore, 0.95);
    });

    test('setManualEntry promotes unknown item to matched with score 1.0', () {
      final initial = createSampleBatch();
      final notifier = ReviewStateNotifier(initial);

      notifier.setManualEntry('c3', 'Saatleri Ayarlama Enstitüsü', 'Ahmet Hamdi Tanpınar');

      final updated = notifier.state;
      expect(updated.matchedItems.length, 2);
      expect(updated.unknownItems.length, 0);
      expect(updated.totalIssuesCount, 1);

      final item3 = updated.items.firstWhere((i) => i.id == 'c3');
      expect(item3.confidence, MatchConfidence.matched);
      expect(item3.manualTitle, 'Saatleri Ayarlama Enstitüsü');
      expect(item3.manualAuthor, 'Ahmet Hamdi Tanpınar');
      expect(item3.selectedBook, isNull);
      expect(item3.confidenceScore, 1.0);
    });

    test('discardItem marks item as discarded and removes from active', () {
      final initial = createSampleBatch();
      final notifier = ReviewStateNotifier(initial);

      notifier.discardItem('c3');

      final updated = notifier.state;
      expect(updated.items.length, 3);
      expect(updated.activeItems.length, 2);
      expect(updated.unknownItems.length, 0);
      expect(updated.totalIssuesCount, 1); // Only c2 review left
    });

    test('saveMatchedToLibrary writes scan, catalogBooks, userBooks and enqueues sync', () async {
      final initial = createSampleBatch();
      final notifier = ReviewStateNotifier(initial);

      // Save 1 matched item
      final count = await notifier.saveMatchedToLibrary(db);
      expect(count, 1);

      // Verify Scan row
      final scans = await db.select(db.scans).get();
      expect(scans.length, 1);
      expect(scans.first.id, 'scan_123');
      expect(scans.first.detectedCount, 3);
      expect(scans.first.matchedCount, 1);
      expect(scans.first.pendingSync, isTrue);

      // Verify CatalogBooks row
      final catalogBooks = await db.select(db.catalogBooks).get();
      expect(catalogBooks.length, 1);
      expect(catalogBooks.first.id, 101);
      expect(catalogBooks.first.title, 'Kara Kitap');
      expect(catalogBooks.first.authors, ['Orhan Pamuk']);

      // Verify UserBooks row
      final userBooks = await db.select(db.userBooks).get();
      expect(userBooks.length, 1);
      expect(userBooks.first.id, 'scan_123_c1');
      expect(userBooks.first.bookId, 101);
      expect(userBooks.first.spineColor, '#8C2D19');
      expect(userBooks.first.pendingSync, isTrue);

      // Verify Sync Queue
      final queue = await db.syncQueueDao.pending();
      expect(queue.length, 2); // 1 scan + 1 userBook
      expect(queue.any((q) => q.entity == SyncEntity.scan && q.rowId == 'scan_123'), isTrue);
      expect(queue.any((q) => q.entity == SyncEntity.userBook && q.rowId == 'scan_123_c1'), isTrue);
    });

    test('saveMatchedToLibrary with manual entries writes null bookId and manual columns', () async {
      final batch = const ReviewBatch(
        scanId: 'scan_manual',
        sourceImagePath: '/img.jpg',
        items: [
          ReviewItem(
            id: 'c1',
            cropPath: '/crop.jpg',
            spineColor: '#123456',
            rawText: 'ÖZEL KİTAP',
            confidence: MatchConfidence.matched,
            confidenceScore: 1.0,
            manualTitle: 'Özel Kitap',
            manualAuthor: 'Özel Yazar',
          ),
        ],
      );

      final notifier = ReviewStateNotifier(batch);
      final count = await notifier.saveMatchedToLibrary(db);
      expect(count, 1);

      final userBooks = await db.select(db.userBooks).get();
      expect(userBooks.length, 1);
      expect(userBooks.first.bookId, isNull);
      expect(userBooks.first.manualTitle, 'Özel Kitap');
      expect(userBooks.first.manualAuthor, 'Özel Yazar');
    });

    test('saveMatchedToLibrary returns 0 when no items are matched', () async {
      final batch = const ReviewBatch(
        scanId: 'scan_empty',
        sourceImagePath: '/img.jpg',
        items: [
          ReviewItem(
            id: 'c1',
            cropPath: '/crop.jpg',
            spineColor: '#123456',
            rawText: '',
            confidence: MatchConfidence.unknown,
            confidenceScore: 0.1,
          ),
        ],
      );

      final notifier = ReviewStateNotifier(batch);
      final count = await notifier.saveMatchedToLibrary(db);
      expect(count, 0);

      final scans = await db.select(db.scans).get();
      expect(scans, isEmpty);
    });
  });
}
