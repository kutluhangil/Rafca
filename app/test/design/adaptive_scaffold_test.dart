import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/adaptive/adaptive_platform.dart';
import 'package:rafca/design/adaptive/adaptive_scaffold.dart';
import 'package:rafca/design/theme/spine_theme.dart';

Widget _harness() => MaterialApp(
  theme: SpineTheme.dark,
  home: const AdaptiveScaffold(title: 'Kütüphane', body: Text('content')),
);

/// Pumps the harness as [platform] and restores the override before the body
/// ends — `testWidgets` asserts that no foundation debug variable is left set,
/// and that check runs before `tearDown`.
Future<void> _pumpAs(WidgetTester tester, TargetPlatform platform) async {
  debugDefaultTargetPlatformOverride = platform;
  await tester.pumpWidget(_harness());
  await tester.pumpAndSettle();
}

void main() {
  group('AdaptivePlatform', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('follows Cupertino conventions on Apple platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(AdaptivePlatform.current, AdaptivePlatform.cupertino);
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(AdaptivePlatform.current, AdaptivePlatform.cupertino);
    });

    test('follows Material conventions everywhere else', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(AdaptivePlatform.current, AdaptivePlatform.material);
    });
  });

  group('AdaptiveScaffold', () {
    testWidgets('builds a Material large app bar on Android', (tester) async {
      await _pumpAs(tester, TargetPlatform.android);
      debugDefaultTargetPlatformOverride = null;

      expect(find.byType(SliverAppBar), findsOneWidget);
      expect(find.byType(CupertinoSliverNavigationBar), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('builds a Cupertino navigation bar on iOS', (tester) async {
      await _pumpAs(tester, TargetPlatform.iOS);
      debugDefaultTargetPlatformOverride = null;

      expect(find.byType(CupertinoSliverNavigationBar), findsOneWidget);
      expect(find.byType(SliverAppBar), findsNothing);
      expect(find.text('content'), findsOneWidget);
    });

    testWidgets('shows the same title on both platforms', (tester) async {
      await _pumpAs(tester, TargetPlatform.android);
      final onAndroid = find.text('Kütüphane').evaluate().isNotEmpty;

      await _pumpAs(tester, TargetPlatform.iOS);
      final onIos = find.text('Kütüphane').evaluate().isNotEmpty;
      debugDefaultTargetPlatformOverride = null;

      expect(onAndroid, isTrue);
      expect(onIos, isTrue);
    });
  });
}
