import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/analytics/models/analytics_models.dart';
import 'package:rafca/features/analytics/screens/archivist_wrapped_screen.dart';
import 'package:rafca/features/analytics/widgets/wrapped_card.dart';
import 'package:rafca/features/share/services/share_service.dart';
import 'package:rafca/l10n/app_localizations.dart';

class _MockShareService extends ShareService {
  _MockShareService();

  Uint8List? capturedBytes;
  String? sharedText;
  String? sharedSubject;

  @override
  Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    return Uint8List.fromList([1, 2, 3, 4]);
  }

  @override
  Future<void> shareImage(
    Uint8List pngBytes, {
    String? text,
    String? subject,
  }) async {
    capturedBytes = pngBytes;
    sharedText = text;
    sharedSubject = subject;
  }

  @override
  Future<void> shareText(String text, {String? subject}) async {
    sharedText = text;
    sharedSubject = subject;
  }
}

void main() {
  group('WrappedCard & ArchivistWrappedBottomSheet', () {
    const sampleAnalytics = CollectionAnalytics(
      totalBooks: 42,
      estimatedShelfMeters: 1.18,
      readingProgress: ReadingProgressSummary(
        readCount: 28,
        readingCount: 8,
        unreadCount: 6,
        total: 42,
      ),
      colorSpectrum: [
        ColorSpectrumEntry(
          family: ColorFamily.brass,
          count: 24,
          percentage: 57.1,
          paletteHexes: ['#C9963F'],
        ),
        ColorSpectrumEntry(
          family: ColorFamily.forest,
          count: 18,
          percentage: 42.9,
          paletteHexes: ['#304E2E'],
        ),
      ],
      dominantColor: ColorFamily.brass,
      uniqueAuthorsCount: 15,
      topAuthor: 'Fyodor Dostoyevski',
      topAuthorCount: 5,
      uniquePublishersCount: 8,
      topPublisher: 'İletişim Yayınları',
      topPublisherCount: 9,
      earliestPublishYear: 1866,
      earliestBookTitle: 'Suç ve Ceza',
      activeLoansCount: 2,
      archetype: ArchivistArchetype.grandArchivist,
      representativeSpineColors: ['#C9963F', '#304E2E'],
    );

    Widget wrap(Widget child, [WidgetTester? tester]) {
      if (tester != null) {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
      }
      return MaterialApp(
        theme: SpineTheme.dark,
        locale: const Locale('tr'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets('WrappedCard renders story format with all archival metrics', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrap(
          const WrappedCard(
            analytics: sampleAnalytics,
            format: WrappedCardFormat.story,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('RAFÇA'), findsOneWidget);
      expect(find.text('42 KİTAP'), findsOneWidget);
      expect(find.text('1.18 METRE FİZİKSEL RAF'), findsOneWidget);
      expect(find.text('RENK SPEKTRUMU & AURA'), findsOneWidget);
      expect(find.textContaining('Fyodor Dostoyevski'), findsOneWidget);
      expect(find.textContaining('İletişim Yayınları'), findsOneWidget);
      expect(find.text('BÜYÜK ARŞİV MUHAFIZI'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('WrappedCard renders square format without extra story metrics', (tester) async {
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        wrap(
          const WrappedCard(
            analytics: sampleAnalytics,
            format: WrappedCardFormat.square,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('42 KİTAP'), findsOneWidget);
      expect(find.text('1.18 METRE FİZİKSEL RAF'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    testWidgets('ArchivistWrappedBottomSheet toggles format and triggers share actions', (
      tester,
    ) async {
      addTearDown(() => tester.view.resetPhysicalSize());
      final mockShare = _MockShareService();

      await tester.pumpWidget(
        wrap(
          ArchivistWrappedBottomSheet(
            analytics: sampleAnalytics,
            shareService: mockShare,
          ),
          tester,
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial title & format
      expect(find.text('ARŞİV ÖZETİ'), findsOneWidget);
      expect(find.text('9:16'), findsOneWidget);
      expect(find.text('1:1'), findsOneWidget);

      // Toggle to 1:1
      await tester.tap(find.text('1:1'));
      await tester.pumpAndSettle();

      // Trigger Share Image
      await tester.tap(find.widgetWithText(PrimaryButton, 'GÖRSELİ PAYLAŞ'));
      await tester.pumpAndSettle();

      expect(mockShare.capturedBytes, isNotNull);
      expect(mockShare.sharedText, contains('42 Cilt Arşiv'));

      // Trigger Share Text
      await tester.tap(find.widgetWithText(PrimaryButton, 'METİN PAYLAŞ'));
      await tester.pumpAndSettle();

      expect(mockShare.sharedText, contains('1.18 Metre Fiziksel Raf Genişliği'));

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });
  });
}
