import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/share/models/share_models.dart';
import 'package:rafca/features/share/services/share_service.dart';
import 'package:rafca/features/share/widgets/share_bottom_sheet.dart';
import 'package:rafca/features/share/widgets/share_card.dart';
import 'package:rafca/l10n/app_localizations.dart';

class _FakeShareService extends ShareService {
  String? lastSharedText;
  Uint8List? lastSharedBytes;
  String? lastSharedImageText;

  @override
  Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    return Uint8List.fromList([0, 1, 2, 3]);
  }

  @override
  Future<void> shareImage(Uint8List imageBytes, {String? text, String? subject}) async {
    lastSharedBytes = imageBytes;
    lastSharedImageText = text;
  }

  @override
  Future<void> shareText(String text, {String? subject}) async {
    lastSharedText = text;
  }
}

void main() {
  group('ShareBottomSheet', () {
    late _FakeShareService fakeShareService;
    final testData = ShareCollectionData(
      title: 'Rafça',
      subtitle: 'Sonbahar Koleksiyonu',
      bookCount: 42,
      spineColors: const ['#8B2500', '#C5A059'],
      categories: const ['ROMAN', 'FELSEFE'],
      captureDate: DateTime(2026, 11, 1),
    );

    setUp(() {
      fakeShareService = _FakeShareService();
    });

    Widget wrap(Widget child, [WidgetTester? tester, Locale locale = const Locale('tr')]) {
      if (tester != null) {
        tester.view.physicalSize = const Size(800, 1200);
        tester.view.devicePixelRatio = 1.0;
      }
      return MaterialApp(
        theme: SpineTheme.dark,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    testWidgets('renders share card and action buttons in Turkish', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        wrap(
          ShareBottomSheet(
            data: testData,
            shareService: fakeShareService,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShareCard), findsOneWidget);
      expect(find.text('Hikaye'), findsOneWidget);
      expect(find.text('Mesaj'), findsOneWidget);
      expect(find.text('Bağlantı'), findsOneWidget);
      expect(find.text('GÖRSELİ KAYDET'), findsOneWidget);
    });

    testWidgets('triggers text share on action tap', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        wrap(
          ShareBottomSheet(
            data: testData,
            shareService: fakeShareService,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mesaj'));
      await tester.pumpAndSettle();

      expect(fakeShareService.lastSharedText, contains('Rafça Kütüphanem: 42 kitap'));
      expect(fakeShareService.lastSharedText, contains('#Rafça #NocturnalArchivist'));
    });

    testWidgets('triggers image export on primary button tap', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        wrap(
          ShareBottomSheet(
            data: testData,
            shareService: fakeShareService,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('GÖRSELİ KAYDET'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      expect(fakeShareService.lastSharedBytes, isNotNull);
      expect(fakeShareService.lastSharedImageText, contains('Rafça Kütüphanem: 42 kitap'));
    });

    testWidgets('renders properly with English locale', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      await tester.pumpWidget(
        wrap(
          ShareBottomSheet(
            data: testData,
            shareService: fakeShareService,
          ),
          tester,
          const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShareCard), findsOneWidget);
      expect(find.text('Story'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Link'), findsOneWidget);
      expect(find.text('SAVE IMAGE'), findsOneWidget);
    });
  });
}
