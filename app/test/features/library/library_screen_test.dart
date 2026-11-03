import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/design/components/book_card.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/library/screens/library_screen.dart';

void main() {
  group('LibraryScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Widget wrap(Widget child, [WidgetTester? tester]) {
      if (tester != null) {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
      }
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: SpineTheme.dark,
          home: Scaffold(body: child),
        ),
      );
    }

    testWidgets('renders empty state when library has no books', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const LibraryScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('İyi akşamlar.'), findsOneWidget);
      expect(find.text('Kütüphane sessiz.'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('renders populated state with ShelfStrip, cards and counts', (tester) async {
      final now = DateTime.now();

      // Seed 2 matched books
      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion.insert(
              id: const Value(701),
              title: 'Tutunamayanlar',
              authors: const Value(['Oğuz Atay']),
            ),
          );
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_p1',
              bookId: const Value(701),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#304E2E'),
              addedAt: now,
            ),
          );

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_p2',
              manualTitle: const Value('Tehlikeli Oyunlar'),
              manualAuthor: const Value('Oğuz Atay'),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#C9963F'),
              addedAt: now.add(const Duration(seconds: 1)),
            ),
          );

      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const LibraryScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Koleksiyonunuz'), findsOneWidget);
      expect(find.text('2 CİLT'), findsOneWidget);
      expect(find.text('Tutunamayanlar'), findsOneWidget);
      expect(find.text('Tehlikeli Oyunlar'), findsOneWidget);
      expect(find.text('Oğuz Atay'), findsNWidgets(2));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('renders pending reviews banner when unreviewed items exist', (tester) async {
      final now = DateTime.now();

      // Seed 1 matched book + 1 review book
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_m',
              manualTitle: const Value('Onaylı Kitap'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_r',
              manualTitle: const Value('İnceleme Bekleyen'),
              confidence: MatchConfidence.review,
              addedAt: now,
            ),
          );

      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const LibraryScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Populated catalog shows matched book
      expect(find.text('Onaylı Kitap'), findsOneWidget);

      // Pending banner appears with count 1
      expect(find.textContaining('1 BEKLEYEN ÖĞE'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('search filters list of books in real time', (tester) async {
      final now = DateTime.now();

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'b1',
              manualTitle: const Value('Körlük'),
              manualAuthor: const Value('Jose Saramago'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'b2',
              manualTitle: const Value('Görmek'),
              manualAuthor: const Value('Jose Saramago'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const LibraryScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Körlük'), findsOneWidget);
      expect(find.text('Görmek'), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Körlük');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.widgetWithText(BookCard, 'Körlük'), findsOneWidget);
      expect(find.text('Görmek'), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
