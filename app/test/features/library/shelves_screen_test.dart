import 'package:drift/drift.dart' hide Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/library/screens/shelves_screen.dart';
import 'package:rafca/l10n/app_localizations.dart';

void main() {
  group('ShelvesScreen', () {
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
          locale: const Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('renders empty shelves state', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const ShelvesScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Henüz raf oluşturulmadı.'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('renders populated shelves with cards and volume counts', (tester) async {
      final now = DateTime.now();

      await db.into(db.shelves).insert(
            ShelvesCompanion.insert(
              id: 'sh_hist',
              name: 'Tarih',
              createdAt: now,
            ),
          );

      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_sh1',
              shelfId: const Value('sh_hist'),
              confidence: MatchConfidence.matched,
              spineColor: const Value('#304E2E'),
              addedAt: now,
            ),
          );

      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const ShelvesScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Tarih'), findsOneWidget);
      expect(find.text('1 Kitap'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('create shelf dialog adds new shelf', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(const ShelvesScreen(), tester));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Tap button to create shelf
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(find.descendant(of: find.byType(AlertDialog), matching: find.text('Yeni Raf Oluştur')), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Felsefe');
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(of: find.byType(AlertDialog), matching: find.byType(PrimaryButton)));
      await tester.pumpAndSettle();

      final shelves = await db.select(db.shelves).get();
      expect(shelves.length, 1);
      expect(shelves.first.name, 'Felsefe');

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
