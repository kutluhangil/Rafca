import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/review/models/review_models.dart';
import 'package:rafca/features/review/widgets/review_bottom_sheet.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: SpineTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('ReviewBottomSheet', () {
    testWidgets('renders candidates and calls onSelectAlternative',
        (tester) async {
      ReviewCandidateBook? selected;
      var manualSearchCalled = false;
      var discardCalled = false;

      const item = ReviewItem(
        id: 'c1',
        cropPath: '/non_existent_crop.jpg',
        spineColor: '#8C2D19',
        rawText: 'TUTUNAMAYANLAR OĞUZ ATAY',
        confidence: MatchConfidence.review,
        confidenceScore: 0.75,
        alternatives: [
          ReviewCandidateBook(
            id: 201,
            title: 'Tutunamayanlar',
            author: 'Oğuz Atay',
            publisher: 'İletişim Yayınları',
            publishYear: 1972,
            score: 0.85,
          ),
          ReviewCandidateBook(
            id: 202,
            title: 'Tehlikeli Oyunlar',
            author: 'Oğuz Atay',
            publisher: 'İletişim Yayınları',
            score: 0.65,
          ),
        ],
      );

      await tester.pumpWidget(
        _wrap(
          ReviewBottomSheet(
            item: item,
            onSelectAlternative: (book) => selected = book,
            onSearchManually: () => manualSearchCalled = true,
            onDiscard: () => discardCalled = true,
          ),
        ),
      );

      expect(find.text('Eseri İncele'), findsOneWidget);
      expect(find.text('Tutunamayanlar'), findsOneWidget);
      expect(find.text('Tehlikeli Oyunlar'), findsOneWidget);
      expect(find.text('TUTUNAMAYANLAR OĞUZ ATAY'), findsOneWidget);

      // Tap on first alternative
      await tester.tap(find.text('Tutunamayanlar'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected?.id, 201);
      expect(manualSearchCalled, isFalse);
      expect(discardCalled, isFalse);
    });

    testWidgets('calls onSearchManually when secondary button is tapped',
        (tester) async {
      var manualSearchCalled = false;

      const item = ReviewItem(
        id: 'c2',
        cropPath: '/crop.jpg',
        spineColor: '#12100E',
        rawText: '',
        confidence: MatchConfidence.unknown,
        confidenceScore: 0.1,
      );

      await tester.pumpWidget(
        _wrap(
          ReviewBottomSheet(
            item: item,
            onSelectAlternative: (_) {},
            onSearchManually: () => manualSearchCalled = true,
            onDiscard: () {},
          ),
        ),
      );

      expect(find.text('Bilinmeyen Sırt'), findsOneWidget);
      expect(find.text('Öneri bulunamadı. Lütfen manuel arayın.'), findsOneWidget);

      // Tap "Manuel Ara" button
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(manualSearchCalled, isTrue);
    });

    testWidgets('calls onDiscard when "Kitap Değil" is tapped',
        (tester) async {
      var discardCalled = false;

      const item = ReviewItem(
        id: 'c3',
        cropPath: '/crop.jpg',
        spineColor: '#12100E',
        rawText: 'NOT A BOOK',
        confidence: MatchConfidence.review,
        confidenceScore: 0.4,
      );

      await tester.pumpWidget(
        _wrap(
          ReviewBottomSheet(
            item: item,
            onSelectAlternative: (_) {},
            onSearchManually: () {},
            onDiscard: () => discardCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Kitap Değil / Not a book'));
      await tester.pumpAndSettle();

      expect(discardCalled, isTrue);
    });
  });
}
