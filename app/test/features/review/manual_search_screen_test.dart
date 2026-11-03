import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/capture/barcode/barcode_lookup_service.dart';
import 'package:rafca/features/review/models/review_models.dart';
import 'package:rafca/features/review/screens/manual_search_screen.dart';
import 'package:rafca/l10n/app_localizations.dart';

void main() {
  group('ManualSearchScreen', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    Widget createWidget({
      String initialQuery = '',
      required void Function(ReviewCandidateBook?, String?, String?) onSelected,
    }) {
      final router = GoRouter(
        initialLocation: '/search',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Root')),
            routes: [
              GoRoute(
                path: 'search',
                builder: (context, state) => ManualSearchScreen(
                  initialQuery: initialQuery,
                  onBookSelected: onSelected,
                ),
              ),
            ],
          ),
        ],
      );

      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          theme: SpineTheme.dark,
          locale: const Locale('tr'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );
    }

    testWidgets('renders search field with barcode scan button', (tester) async {
      await tester.pumpWidget(
        createWidget(onSelected: (_, __, ___) {}),
      );
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      expect(find.text('Özel Kitap Girişi'), findsOneWidget);
    });

    testWidgets('entering valid ISBN performs lookup and shows candidate', (tester) async {
      // Seed book with ISBN in database
      await db.into(db.catalogBooks).insert(
            CatalogBooksCompanion(
              id: const Value(555),
              isbn13: const Value('9786051850016'),
              title: const Value('Kürk Mantolu Madonna'),
              authors: const Value(['Sabahattin Ali']),
              publisher: const Value('YKY'),
              publishYear: const Value(2020),
            ),
          );

      ReviewCandidateBook? selectedBook;

      await tester.pumpWidget(
        createWidget(
          onSelected: (book, _, __) {
            selectedBook = book;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Enter ISBN
      await tester.enterText(find.byType(TextField), '978-605-185-001-6');
      await tester.pumpAndSettle();

      // Should display book title and author
      expect(find.text('Kürk Mantolu Madonna'), findsOneWidget);
      expect(find.textContaining('Sabahattin Ali'), findsOneWidget);

      // Tap on candidate book item
      await tester.tap(find.text('Kürk Mantolu Madonna'));
      await tester.pumpAndSettle();

      expect(selectedBook, isNotNull);
      expect(selectedBook!.id, equals(555));
      expect(selectedBook!.title, equals('Kürk Mantolu Madonna'));
    });

    testWidgets('toggles custom book manual entry form', (tester) async {
      String? customTitle;
      String? customAuthor;

      await tester.pumpWidget(
        createWidget(
          onSelected: (_, title, author) {
            customTitle = title;
            customAuthor = author;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Özel Kitap Girişi"
      await tester.tap(find.text('Özel Kitap Girişi'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Kitap Adı'), findsOneWidget);
      expect(find.textContaining('Yazar'), findsOneWidget);

      // Enter manual book details
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(1), 'Özel Kitap');
      await tester.enterText(textFields.at(2), 'Bilinmeyen Yazar');
      await tester.pumpAndSettle();

      // Tap submit button (PrimaryButton)
      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();

      expect(customTitle, equals('Özel Kitap'));
      expect(customAuthor, equals('Bilinmeyen Yazar'));
    });
  });
}
