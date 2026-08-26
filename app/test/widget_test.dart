import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/app/rafca_app.dart';
import 'package:rafca/core/theme/theme_mode_controller.dart';

void main() {
  testWidgets('app boots and renders the home screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: RafcaApp()));
    await tester.pumpAndSettle();

    expect(find.text('Rafça'), findsWidgets);
    expect(find.text('MATCHED'), findsOneWidget);
  });

  testWidgets('the theme toggle cycles system, dark, light', (tester) async {
    late WidgetRef ref;
    await tester.pumpWidget(
      ProviderScope(
        child: Consumer(
          builder: (context, widgetRef, _) {
            ref = widgetRef;
            return const RafcaApp();
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(ref.read(themeModeControllerProvider), ThemeMode.system);

    await tester.tap(find.byIcon(Icons.brightness_auto_outlined));
    await tester.pumpAndSettle();
    expect(ref.read(themeModeControllerProvider), ThemeMode.dark);

    await tester.tap(find.byIcon(Icons.dark_mode_outlined));
    await tester.pumpAndSettle();
    expect(ref.read(themeModeControllerProvider), ThemeMode.light);

    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();
    expect(ref.read(themeModeControllerProvider), ThemeMode.system);
  });
}
