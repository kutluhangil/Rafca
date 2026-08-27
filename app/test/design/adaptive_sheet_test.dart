import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/adaptive/adaptive_sheet.dart';
import 'package:rafca/design/components/confidence_badge.dart';
import 'package:rafca/design/theme/spine_theme.dart';

Widget _host(void Function(BuildContext) onReady) {
  return MaterialApp(
    locale: const Locale('tr'),
    supportedLocales: const [Locale('tr'), Locale('en')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    theme: SpineTheme.dark,
    home: Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () => onReady(context),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

/// Opens the sheet as [platform] and restores the override before the body
/// ends — `testWidgets` asserts that no foundation debug variable is left set,
/// and that check runs before `tearDown`.
Future<void> _openAs(
  WidgetTester tester,
  TargetPlatform platform,
  WidgetBuilder body,
) async {
  debugDefaultTargetPlatformOverride = platform;
  await tester.pumpWidget(
    _host(
      (context) => showAdaptiveSheet<void>(context: context, builder: body),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  debugDefaultTargetPlatformOverride = null;
}

void main() {
  tearDown(() => debugDefaultTargetPlatformOverride = null);

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    group('showAdaptiveSheet on ${platform.name}', () {
      testWidgets('opens and shows its body', (tester) async {
        await _openAs(
          tester,
          platform,
          (context) => const AdaptiveSheetBody(
            title: 'Eşleşmeyi incele',
            subtitle: 'Bu sırt için birden fazla baskı bulundu.',
            trailing: ConfidenceBadge(
              level: ConfidenceLevel.review,
              label: 'incele',
            ),
            child: Text('içerik'),
          ),
        );

        expect(find.text('Eşleşmeyi incele'), findsOneWidget);
        expect(find.text('içerik'), findsOneWidget);
        expect(find.text('İNCELE'), findsOneWidget);
      });

      testWidgets('sheet content always has a Material ancestor', (
        tester,
      ) async {
        await _openAs(tester, platform, (context) => const Text('içerik'));

        // Without one, Text falls back to the debug style and an InkWell in
        // the sheet has nothing to paint on. The Cupertino branch provides no
        // Material of its own, so the sheet has to.
        expect(
          find.ancestor(
            of: find.text('içerik'),
            matching: find.byType(Material),
          ),
          findsWidgets,
        );
      });
    });
  }
}
