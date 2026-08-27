import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/components/book_card.dart';
import 'package:rafca/design/components/confidence_badge.dart';
import 'package:rafca/design/components/mono_label.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/components/shelf_strip.dart';
import 'package:rafca/design/components/spine_crop_view.dart';
import 'package:rafca/design/motion/motion.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/design/tokens/colors.dart';

/// Hosts a component under a real Rafça theme.
Widget _host(
  Widget child, {
  Brightness brightness = Brightness.dark,
  bool reduceMotion = false,
  Locale locale = const Locale('tr'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [Locale('tr'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: brightness == Brightness.dark ? SpineTheme.dark : SpineTheme.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
      child: child!,
    ),
    home: Scaffold(body: Center(child: child)),
  );
}

const _bars = [
  ShelfStripBar(color: Color(0xFF304E2E), width: 2, semanticLabel: 'One'),
  ShelfStripBar(color: Color(0xFFC9963F), width: 5, semanticLabel: 'Two'),
  ShelfStripBar(color: Color(0xFFADD0A7), width: 3, semanticLabel: 'Three'),
];

void main() {
  group('ShelfStrip', () {
    testWidgets('each variant is the height SPINE_BLUEPRINT.md 4.4 asks for', (
      tester,
    ) async {
      for (final variant in ShelfStripVariant.values) {
        await tester.pumpWidget(
          _host(ShelfStrip(bars: _bars, variant: variant)),
        );
        await tester.pumpAndSettle();

        expect(
          tester.getSize(find.byType(ShelfStrip)).height,
          variant.height,
          reason: '${variant.name} should be ${variant.height}px tall',
        );
      }
    });

    testWidgets('bar widths are proportional to the spines they stand for', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(SizedBox(width: 300, child: ShelfStrip(bars: _bars))),
      );
      await tester.pumpAndSettle();

      final widths = tester
          .widgetList<Flexible>(find.byType(Flexible))
          .map((flexible) => flexible.flex)
          .toList();

      // 2 : 5 : 3, in the order the books stand on the shelf.
      expect(widths, [2000, 5000, 3000]);
    });

    testWidgets('bars enter one after another, not all at once', (
      tester,
    ) async {
      await tester.pumpWidget(_host(ShelfStrip(bars: _bars)));

      // Just after the first bar's own animation would have finished, the last
      // bar is still behind it — that gap is the 12ms stagger.
      await tester.pump(SpineMotion.shelfStripBar);
      final scales = tester
          .widgetList<ScaleTransition>(
            find.descendant(
              of: find.byType(ShelfStrip),
              matching: find.byType(ScaleTransition),
            ),
          )
          .map((transition) => transition.scale.value)
          .toList();

      expect(scales.first, 1.0);
      expect(scales.last, lessThan(1.0));
      await tester.pumpAndSettle();
    });

    testWidgets('reduce-motion crossfades instead of growing', (tester) async {
      await tester.pumpWidget(
        _host(ShelfStrip(bars: _bars), reduceMotion: true),
      );

      final inStrip = find.descendant(
        of: find.byType(ShelfStrip),
        matching: find.byType(ScaleTransition),
      );
      final fades = find.descendant(
        of: find.byType(ShelfStrip),
        matching: find.byType(FadeTransition),
      );
      expect(inStrip, findsNothing);
      expect(fades, findsNWidgets(_bars.length));

      // And it is over within the collapsed budget, stagger included.
      await tester.pump(SpineMotion.reduced);
      final opacities = tester
          .widgetList<FadeTransition>(fades)
          .map((transition) => transition.opacity.value);
      expect(opacities.every((value) => value == 1.0), isTrue);
    });

    testWidgets('the empty variant draws placeholders and takes no taps', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        _host(
          ShelfStrip(
            bars: const [],
            variant: ShelfStripVariant.empty,
            emptyBarCount: 5,
            onBarTap: (_) => taps++,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Flexible), findsNWidgets(5));
      await tester.tap(find.byType(ShelfStrip), warnIfMissed: false);
      expect(taps, 0);
    });

    testWidgets('a tapped bar reports its index', (tester) async {
      int? tapped;
      await tester.pumpWidget(
        _host(
          SizedBox(
            width: 300,
            child: ShelfStrip(bars: _bars, onBarTap: (index) => tapped = index),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Two'));
      expect(tapped, 1);
    });
  });

  group('ConfidenceBadge', () {
    testWidgets('takes its colour from the band, in both themes', (
      tester,
    ) async {
      for (final brightness in Brightness.values) {
        final expected = brightness == Brightness.dark
            ? SpineSemanticColors.dark
            : SpineSemanticColors.light;

        for (final (level, colour) in [
          (ConfidenceLevel.matched, expected.matched),
          (ConfidenceLevel.review, expected.review),
          (ConfidenceLevel.unknown, expected.unknown),
        ]) {
          await tester.pumpWidget(
            _host(
              ConfidenceBadge(level: level, label: 'band'),
              brightness: brightness,
            ),
          );
          // MaterialApp crossfades between themes, so a colour read on the
          // first frame is still the previous theme's.
          await tester.pumpAndSettle();

          final bar = tester.widget<Container>(
            find.descendant(
              of: find.byType(ConfidenceBadge),
              matching: find.byType(Container),
            ),
          );
          expect((bar.color), colour);

          final text = tester.widget<Text>(
            find.descendant(
              of: find.byType(ConfidenceBadge),
              matching: find.byType(Text),
            ),
          );
          expect(text.style?.color, colour);
        }
      }
    });

    testWidgets('renders its label uppercase', (tester) async {
      await tester.pumpWidget(
        _host(
          const ConfidenceBadge(
            level: ConfidenceLevel.matched,
            label: 'eşleşti',
          ),
        ),
      );

      expect(find.text('EŞLEŞTİ'), findsOneWidget);
    });
  });

  group('MonoLabel', () {
    testWidgets('uppercases Turkish i as İ, not I', (tester) async {
      await tester.pumpWidget(_host(const MonoLabel('isbn bilgisi')));
      expect(find.text('İSBN BİLGİSİ'), findsOneWidget);
    });

    testWidgets('uppercases English i as I', (tester) async {
      await tester.pumpWidget(
        _host(const MonoLabel('isbn info'), locale: const Locale('en')),
      );
      expect(find.text('ISBN INFO'), findsOneWidget);
    });

    testWidgets('uppercases Turkish dotless ı as I', (tester) async {
      await tester.pumpWidget(_host(const MonoLabel('kırpım')));
      expect(find.text('KIRPIM'), findsOneWidget);
    });
  });

  group('PrimaryButton', () {
    testWidgets('fills with brass and never casts a shadow', (tester) async {
      for (final brightness in Brightness.values) {
        final expected = brightness == Brightness.dark
            ? SpineSemanticColors.dark
            : SpineSemanticColors.light;

        await tester.pumpWidget(
          _host(
            PrimaryButton(label: 'ekle', onPressed: () {}),
            brightness: brightness,
          ),
        );
        await tester.pumpAndSettle();

        final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
        const enabledOnly = <WidgetState>{};
        expect(style.backgroundColor?.resolve(enabledOnly), expected.brass);
        expect(style.foregroundColor?.resolve(enabledOnly), expected.onBrass);
        expect(style.elevation?.resolve(enabledOnly), 0);
      }
    });

    testWidgets('the secondary variant is transparent with a hairline', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          PrimaryButton(
            label: 'incele',
            variant: SpineButtonVariant.secondary,
            onPressed: () {},
          ),
        ),
      );

      final style = tester.widget<TextButton>(find.byType(TextButton)).style!;
      expect(style.backgroundColor?.resolve({}), Colors.transparent);
      expect(style.side?.resolve({})?.color, SpineSemanticColors.dark.hairline);
    });

    testWidgets('a null callback disables the button', (tester) async {
      await tester.pumpWidget(
        _host(const PrimaryButton(label: 'ekle', onPressed: null)),
      );
      expect(tester.widget<TextButton>(find.byType(TextButton)).enabled, false);
    });
  });

  group('BookCard', () {
    testWidgets('shows its confidence without being opened', (tester) async {
      await tester.pumpWidget(
        _host(
          const BookCard(
            title: 'The Secret History',
            author: 'Donna Tartt',
            level: ConfidenceLevel.review,
            levelLabel: 'incele',
            footer: '1992',
          ),
        ),
      );

      expect(find.byType(ConfidenceBadge), findsOneWidget);
      expect(find.text('İNCELE'), findsOneWidget);
      expect(find.text('The Secret History'), findsOneWidget);
      expect(find.text('Donna Tartt'), findsOneWidget);
      expect(find.text('1992'), findsOneWidget);
    });

    testWidgets('a card with no crop still renders', (tester) async {
      await tester.pumpWidget(
        _host(
          const BookCard(
            title: 'Scan Failed',
            level: ConfidenceLevel.unknown,
            levelLabel: 'bilinmiyor',
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Scan Failed'), findsOneWidget);
    });

    testWidgets('an overflow control without a name is a programming error', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          BookCard(
            title: 'Dune',
            level: ConfidenceLevel.matched,
            levelLabel: 'eşleşti',
            onMore: () {},
          ),
        ),
      );

      expect(tester.takeException(), isAssertionError);
    });
  });

  group('SpineCropView', () {
    testWidgets('brackets are drawn by default and can be turned off', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const SizedBox(width: 120, child: SpineCropView(image: null))),
      );
      expect(find.byType(CustomPaint), findsWidgets);

      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 120,
            child: SpineCropView(image: null, brackets: false),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the aspect ratio it is given', (tester) async {
      await tester.pumpWidget(
        _host(
          const SizedBox(
            width: 120,
            child: SpineCropView(image: null, aspectRatio: 3 / 4),
          ),
        ),
      );

      final size = tester.getSize(find.byType(SpineCropView));
      expect(size.width / size.height, closeTo(3 / 4, 0.01));
    });
  });

  group('motion', () {
    testWidgets('reduce-motion collapses every duration to 120ms', (
      tester,
    ) async {
      late SpineMotionData motion;
      await tester.pumpWidget(
        _host(
          Builder(
            builder: (context) {
              motion = context.motion;
              return const SizedBox.shrink();
            },
          ),
          reduceMotion: true,
        ),
      );

      expect(motion(SpineMotion.matchedPulse), SpineMotion.reduced);
      expect(motion(SpineMotion.captureHero), SpineMotion.reduced);
      expect(motion.stagger(SpineMotion.resultRowStagger), Duration.zero);
      expect(motion.offset(SpineMotion.resultRowOffset), 0);
      expect(motion.curve(SpineMotion.enter), Curves.linear);
    });

    test('no constant exceeds the 400ms ceiling', () {
      const durations = [
        SpineMotion.shelfStripBar,
        SpineMotion.shelfStripStagger,
        SpineMotion.segmentationPerSpine,
        SpineMotion.captureHero,
        SpineMotion.resultRow,
        SpineMotion.resultRowStagger,
        SpineMotion.matchedPulse,
        SpineMotion.stateChange,
      ];

      for (final duration in durations) {
        expect(duration, lessThanOrEqualTo(SpineMotion.ceiling));
      }
    });
  });
}
