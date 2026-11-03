import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/ar_lens/models/ar_lens_models.dart';
import 'package:rafca/features/ar_lens/widgets/ar_overlay_widget.dart';

void main() {
  group('ArOverlayWidget', () {
    final testItems = [
      const ArDetectedItem(
        id: 'item_1',
        rawText: 'KARA KİTAP',
        normalizedRect: Rect.fromLTWH(0.1, 0.2, 0.2, 0.5),
        status: ArBookStatus.ownedRead,
        matchedTitle: 'Kara Kitap',
      ),
      const ArDetectedItem(
        id: 'item_2',
        rawText: 'KÜRK MANTOLU MADONNA',
        normalizedRect: Rect.fromLTWH(0.4, 0.2, 0.2, 0.5),
        status: ArBookStatus.ownedUnread,
        matchedTitle: 'Kürk Mantolu Madonna',
      ),
      const ArDetectedItem(
        id: 'item_3',
        rawText: 'DUNE',
        normalizedRect: Rect.fromLTWH(0.7, 0.2, 0.2, 0.5),
        status: ArBookStatus.notOwned,
        matchedTitle: 'Dune',
      ),
    ];

    Widget createWidget({
      required List<ArDetectedItem> items,
      ValueChanged<ArDetectedItem>? onTap,
      bool isProcessing = false,
    }) {
      return MaterialApp(
        theme: SpineTheme.dark,
        home: Scaffold(
          body: SizedBox(
            width: 800,
            height: 600,
            child: ArOverlayWidget(
              items: items,
              onTapItem: onTap,
              isProcessing: isProcessing,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all HUD badges and status pill', (tester) async {
      await tester.pumpWidget(createWidget(items: testItems));
      await tester.pumpAndSettle();

      expect(find.text('KÜTÜPHANEDE (OKUNDU)'), findsOneWidget);
      expect(find.text('OKUNACAK'), findsOneWidget);
      expect(find.text('LİSTEYE EKLE'), findsOneWidget);
      expect(find.text('CANLI AR LENSİ'), findsOneWidget);
    });

    testWidgets('shows TARANIYOR when isProcessing is true', (tester) async {
      await tester.pumpWidget(createWidget(items: testItems, isProcessing: true));
      await tester.pumpAndSettle();

      expect(find.text('TARANIYOR'), findsOneWidget);
    });

    testWidgets('tapping on badge triggers onTapItem callback', (tester) async {
      ArDetectedItem? tappedItem;

      await tester.pumpWidget(
        createWidget(
          items: testItems,
          onTap: (item) => tappedItem = item,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('LİSTEYE EKLE'));
      await tester.pumpAndSettle();

      expect(tappedItem, isNotNull);
      expect(tappedItem!.id, equals('item_3'));
      expect(tappedItem!.status, equals(ArBookStatus.notOwned));
    });
  });
}
