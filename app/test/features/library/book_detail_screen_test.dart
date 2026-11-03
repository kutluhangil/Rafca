import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/library/screens/book_detail_screen.dart';

void main() {
  group('BookDetailScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Widget wrap(Widget child) {
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: SpineTheme.dark,
          home: child,
        ),
      );
    }

    testWidgets('renders book detail and Proof of Capture', (tester) async {
      final now = DateTime.now();

      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion.insert(
              id: const Value(801),
              title: 'Rüzgarın Gölgesi',
              authors: const Value(['Carlos Ruiz Zafón']),
              publisher: const Value('Everest Yayınları'),
              publishYear: const Value(2001),
            ),
          );

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'bd_1',
              bookId: const Value(801),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#C9963F'),
              addedAt: now,
            ),
          );

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrap(const BookDetailScreen(userBookId: 'bd_1')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Rüzgarın Gölgesi'), findsWidgets);
      expect(find.text('Carlos Ruiz Zafón'), findsWidgets);
      expect(find.text('Everest Yayınları'), findsOneWidget);
      expect(find.text('2001'), findsOneWidget);
      expect(find.textContaining('PROOF OF CAPTURE'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('edit details dialog updates title', (tester) async {
      final now = DateTime.now();

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'bd_edit',
              manualTitle: const Value('Eski Başlık'),
              manualAuthor: const Value('Eski Yazar'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrap(const BookDetailScreen(userBookId: 'bd_edit')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Eski Başlık'), findsWidgets);

      // Tap Edit button
      await tester.tap(find.widgetWithText(PrimaryButton, 'DÜZENLE'));
      await tester.pumpAndSettle();

      expect(find.text('Kitap Detaylarını Düzenle'), findsOneWidget);

      // Change title
      final titleField = find.widgetWithText(TextField, 'Eski Başlık');
      await tester.enterText(titleField, 'Yeni Başlık');
      await tester.pumpAndSettle();

      // Tap Save
      await tester.tap(find.widgetWithText(PrimaryButton, 'KAYDET'));
      await tester.pumpAndSettle();

      // Verify update
      final updated = await (db.select(db.userBooks)..where((u) => u.id.equals('bd_edit'))).getSingle();
      expect(updated.manualTitle, 'Yeni Başlık');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('delete book removes book from database', (tester) async {
      final now = DateTime.now();

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'bd_del',
              manualTitle: const Value('Silinecek Kitap'),
              confidence: MatchConfidence.matched,
              addedAt: now,
            ),
          );

      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(wrap(const BookDetailScreen(userBookId: 'bd_del')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap Kaldır / Remove button
      await tester.tap(find.widgetWithText(PrimaryButton, 'KALDIR'));
      await tester.pumpAndSettle();

      expect(find.text('Kitabı Sil'), findsOneWidget);

      // Confirm delete
      await tester.tap(find.text('Kaldır / Remove'));
      await tester.pumpAndSettle();

      final exists = await (db.select(db.userBooks)..where((u) => u.id.equals('bd_del'))).getSingleOrNull();
      expect(exists, isNull);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
