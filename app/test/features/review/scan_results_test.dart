import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/review/models/review_models.dart';
import 'package:rafca/features/review/screens/scan_results_screen.dart';

void main() {
  group('ScanResultsScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    ReviewBatch createBatch() {
      return const ReviewBatch(
        scanId: 'scan_results_test',
        sourceImagePath: '/path/test_shelf.jpg',
        items: [
          ReviewItem(
            id: 'c1',
            cropPath: '/crop_1.jpg',
            spineColor: '#8C2D19',
            rawText: 'KARA KİTAP\nORHAN PAMUK',
            confidence: MatchConfidence.matched,
            confidenceScore: 0.95,
            selectedBook: ReviewCandidateBook(
              id: 301,
              title: 'Kara Kitap',
              author: 'Orhan Pamuk',
              publisher: 'İletişim Yayınları',
              score: 0.95,
            ),
          ),
          ReviewItem(
            id: 'c2',
            cropPath: '/crop_2.jpg',
            spineColor: '#1A365D',
            rawText: 'TUTUNAMAYANLAR',
            confidence: MatchConfidence.review,
            confidenceScore: 0.72,
            alternatives: [
              ReviewCandidateBook(
                id: 302,
                title: 'Tutunamayanlar',
                author: 'Oğuz Atay',
                score: 0.72,
              ),
            ],
          ),
          ReviewItem(
            id: 'c3',
            cropPath: '/crop_3.jpg',
            spineColor: '#2D3748',
            rawText: '',
            confidence: MatchConfidence.unknown,
            confidenceScore: 0.1,
          ),
        ],
      );
    }

    Widget buildTestWidget(ReviewBatch batch) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: SpineTheme.dark,
          home: ScanResultsScreen(initialBatch: batch),
        ),
      );
    }

    testWidgets('renders all groups and counts correctly', (tester) async {
      final batch = createBatch();

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(batch));
      await tester.pumpAndSettle();

      expect(find.text('Tarama Sonuçları'), findsAtLeastNWidgets(1));
      expect(find.textContaining('KAYNAK GÖRSEL'), findsOneWidget);

      // Section Headers
      expect(find.textContaining('Eşleşen Kitaplar'), findsOneWidget);
      expect(find.textContaining('İnceleme Gerekenler'), findsOneWidget);
      expect(find.textContaining('Tanınamayanlar'), findsOneWidget);

      // Cards
      expect(find.text('Kara Kitap'), findsOneWidget);
      expect(find.text('Orhan Pamuk'), findsOneWidget);

      // Bottom bar actions
      expect(find.text('2 SORUNU İNCELE'), findsOneWidget);
      expect(find.text('1 KİTABI EKLE'), findsOneWidget);
    });

    testWidgets('tapping "SORUNU İNCELE" opens bottom sheet', (tester) async {
      final batch = createBatch();

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(batch));
      await tester.pumpAndSettle();

      final reviewIssuesButton = find.widgetWithText(PrimaryButton, '2 SORUNU İNCELE');
      expect(reviewIssuesButton, findsOneWidget);

      await tester.tap(reviewIssuesButton);
      await tester.pumpAndSettle();

      // Bottom sheet should now be open
      expect(find.text('Eseri İncele'), findsOneWidget);
      expect(find.text('Tutunamayanlar'), findsOneWidget);
    });

    testWidgets('tapping "1 KİTABI EKLE" saves matched books into database', (tester) async {
      final batch = createBatch();

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(batch));
      await tester.pumpAndSettle();

      final addBooksButton = find.widgetWithText(PrimaryButton, '1 KİTABI EKLE');
      expect(addBooksButton, findsOneWidget);

      await tester.tap(addBooksButton);
      await tester.pumpAndSettle();

      // Verify db insertion
      final userBooks = await db.select(db.userBooks).get();
      expect(userBooks.length, 1);
      expect(userBooks.first.id, 'scan_results_test_c1');

      final scans = await db.select(db.scans).get();
      expect(scans.length, 1);
      expect(scans.first.id, 'scan_results_test');
    });
  });
}
