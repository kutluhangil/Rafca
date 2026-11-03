import 'package:drift/drift.dart' hide isNull, isNotNull, Column;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/core/localization/locale_controller.dart';
import 'package:rafca/core/theme/theme_mode_controller.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/settings/screens/settings_screen.dart';
import 'package:rafca/features/settings/services/export_service.dart';
import 'package:rafca/l10n/app_localizations.dart';

class _FakeExportService extends ExportService {
  String? lastExportedContent;
  String? lastFilename;

  @override
  Future<void> shareExport(
    String content, {
    required String filename,
    required String mimeType,
    String? subject,
  }) async {
    lastExportedContent = content;
    lastFilename = filename;
  }
}

void main() {
  group('SettingsScreen', () {
    late AppDatabase db;
    late _FakeExportService fakeExportService;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      fakeExportService = _FakeExportService();
    });

    tearDown(() async {
      await db.close();
    });

    Widget wrap(Widget child, [WidgetTester? tester, Locale locale = const Locale('tr')]) {
      if (tester != null) {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
      }
      return ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: MaterialApp(
          theme: SpineTheme.dark,
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('renders all settings sections and options', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(SettingsScreen(exportService: fakeExportService), tester));
      await tester.pumpAndSettle();

      expect(find.text('Ayarlar'), findsOneWidget);
      expect(find.text('GÖRÜNÜM'), findsOneWidget);
      expect(find.text('DİL / LANGUAGE'), findsOneWidget);
      expect(find.text('BULUT VE YEDEKLEME'), findsOneWidget);
      expect(find.text('VERİ YÖNETİMİ'), findsOneWidget);
      expect(find.text('HAKKINDA & GİZLİLİK'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('theme mode selection updates ThemeModeController', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: SpineTheme.dark,
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(exportService: fakeExportService),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(themeModeControllerProvider), ThemeMode.system);

      // Tap 'Koyu Gece (Dark)'
      await tester.tap(find.text('Koyu Gece (Dark)'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeControllerProvider), ThemeMode.dark);

      // Tap 'Gündüz (Light)'
      await tester.tap(find.text('Gündüz (Light)'));
      await tester.pumpAndSettle();
      expect(container.read(themeModeControllerProvider), ThemeMode.light);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('language selection updates LocaleController', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: Consumer(
            builder: (context, ref, _) {
              final activeLocale = ref.watch(localeControllerProvider) ?? const Locale('tr');
              return MaterialApp(
                theme: SpineTheme.dark,
                locale: activeLocale,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: SettingsScreen(exportService: fakeExportService),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(localeControllerProvider), isNull);

      // Tap English
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(container.read(localeControllerProvider), const Locale('en'));

      // In English locale, Turkish button label becomes 'Turkish'
      await tester.tap(find.text('Turkish'));
      await tester.pumpAndSettle();
      expect(container.read(localeControllerProvider), const Locale('tr'));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('toggles cloud sync switch', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: SpineTheme.dark,
            locale: const Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(exportService: fakeExportService),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(container.read(cloudSyncEnabledProvider), isFalse);

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(container.read(cloudSyncEnabledProvider), isTrue);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('export CSV and JSON invokes export service', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());

      // Seed a book
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_exp1',
              manualTitle: const Value('Puslu Kıtalar Atlası'),
              manualAuthor: const Value('İhsan Oktay Anar'),
              confidence: MatchConfidence.matched,
              addedAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(wrap(SettingsScreen(exportService: fakeExportService), tester));
      await tester.pumpAndSettle();

      // Tap CSV export
      await tester.tap(find.text('CSV Olarak Dışa Aktar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeExportService.lastFilename, 'rafca_library.csv');
      expect(fakeExportService.lastExportedContent, contains('Puslu Kıtalar Atlası'));

      // Tap JSON export
      await tester.tap(find.text('JSON Olarak Dışa Aktar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeExportService.lastFilename, 'rafca_library.json');
      expect(fakeExportService.lastExportedContent, contains('İhsan Oktay Anar'));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('privacy statement dialog opens with principles', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(wrap(SettingsScreen(exportService: fakeExportService), tester));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gizlilik Sözleşmesi'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.textContaining('Fotoğraflar ve sırt kırpımları yalnızca cihazınızda saklanır'), findsOneWidget);

      await tester.tap(find.byType(PrimaryButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('clear library dialog cancels and confirms deletion', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());

      // Seed a book
      await db.into(db.userBooks).insert(
            UserBooksCompanion.insert(
              id: 'ub_clr',
              manualTitle: const Value('Beyaz Kale'),
              confidence: MatchConfidence.matched,
              addedAt: DateTime.now(),
            ),
          );

      await tester.pumpWidget(wrap(SettingsScreen(exportService: fakeExportService), tester));
      await tester.pumpAndSettle();

      // Tap reset library
      await tester.tap(find.text('Kütüphaneyi Sıfırla'));
      await tester.pumpAndSettle();

      expect(find.text('Kütüphaneyi Sıfırla?'), findsOneWidget);

      // Cancel
      await tester.tap(find.text('İPTAL'));
      await tester.pumpAndSettle();

      var books = await (db.select(db.userBooks)).get();
      expect(books.length, 1);

      // Tap again and confirm
      await tester.tap(find.text('Kütüphaneyi Sıfırla'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('SİL'));
      await tester.pumpAndSettle();

      books = await (db.select(db.userBooks)).get();
      expect(books, isEmpty);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
