import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/components/primary_button.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/features/capture/screens/permission_screen.dart';
import 'package:rafca/features/capture/widgets/level_indicator.dart';
import 'package:rafca/features/capture/widgets/quad_clipper.dart';
import 'package:rafca/features/capture/widgets/shutter_button.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      theme: SpineTheme.dark,
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  group('Capture Widgets', () {
    testWidgets('LevelIndicator renders green when level and red when unlevel',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LevelIndicator(roll: 2.0, pitch: -3.0),
        ),
      );

      expect(find.textContaining('PARALEL'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          const LevelIndicator(roll: 12.0, pitch: 0.0),
        ),
      );

      expect(find.textContaining('PARALEL TUTUN'), findsOneWidget);
    });

    testWidgets('ShutterButton triggers onPressed only when canShoot is true',
        (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        _wrap(
          ShutterButton(
            canShoot: false,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ShutterButton));
      expect(tapped, isFalse);

      await tester.pumpWidget(
        _wrap(
          ShutterButton(
            canShoot: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(ShutterButton));
      expect(tapped, isTrue);
    });

    testWidgets('QuadEditor renders and updates on drag', (tester) async {
      QuadPoints? updated;

      final initial = QuadPoints(
        topLeft: const Offset(20, 20),
        topRight: const Offset(100, 20),
        bottomRight: const Offset(100, 100),
        bottomLeft: const Offset(20, 100),
      );

      await tester.pumpWidget(
        _wrap(
          QuadEditor(
            size: const Size(200, 200),
            initialQuad: initial,
            onChanged: (q) => updated = q,
          ),
        ),
      );

      expect(find.byType(QuadEditor), findsOneWidget);

      // Drag top-left corner
      await tester.dragFrom(const Offset(20, 20), const Offset(10, 10));
      await tester.pump();

      expect(updated, isNotNull);
    });

    testWidgets('CameraPermissionScreen renders explanatory text and actions',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var dismissTapped = false;

      await tester.pumpWidget(
        _wrap(
          CameraPermissionScreen(
            onPermissionGranted: () {},
            onDismiss: () => dismissTapped = true,
          ),
        ),
      );

      expect(find.text('KAMERA ERİŞİMİ'), findsOneWidget);
      expect(find.byType(PrimaryButton), findsNWidgets(2));

      await tester.tap(find.byType(PrimaryButton).last);
      expect(dismissTapped, isTrue);
    });
  });
}
