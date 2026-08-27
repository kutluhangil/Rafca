import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/design/theme/spine_theme.dart';
import 'package:rafca/design/tokens/colors.dart';
import 'package:rafca/design/tokens/typography.dart';

void main() {
  group('SpineTheme.dark', () {
    final theme = SpineTheme.dark;

    test('carries the DESIGN.md palette, not a seeded approximation', () {
      // These are the values the shipped mockups were rendered from. A seeded
      // ColorScheme would move them, which is why the scheme is written out.
      expect(theme.colorScheme.surface, const Color(0xFF151311));
      expect(theme.colorScheme.primary, const Color(0xFFF5BD62));
      expect(theme.colorScheme.primaryContainer, const Color(0xFFC9963F));
      expect(theme.colorScheme.onSurfaceVariant, const Color(0xFFD3C4B2));
      expect(theme.colorScheme.outlineVariant, const Color(0xFF4F4537));
    });

    test('exposes the confidence colours as a theme extension', () {
      final semantic = theme.extension<SpineSemanticColors>();
      expect(semantic, isNotNull);
      expect(semantic!.matched, const Color(0xFFC8ECC1));
      expect(semantic.review, const Color(0xFFF5BD62));
      expect(semantic.unknown, const Color(0xFFFFB4AB));
    });

    test('paints no shadows anywhere — depth is hairlines and luminance', () {
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
      expect(theme.cardTheme.elevation, 0);
      expect(theme.dialogTheme.elevation, 0);
      expect(theme.bottomSheetTheme.elevation, 0);
      expect(theme.bottomSheetTheme.modalElevation, 0);
      expect(theme.chipTheme.elevation, 0);
      expect(theme.snackBarTheme.elevation, 0);
    });

    test(
      'suppresses Material 3 surface tint, which would wash the palette',
      () {
        expect(theme.appBarTheme.surfaceTintColor, Colors.transparent);
        expect(theme.cardTheme.surfaceTintColor, Colors.transparent);
        expect(theme.bottomSheetTheme.surfaceTintColor, Colors.transparent);
      },
    );

    test('sheets round only their top corners', () {
      final shape = theme.bottomSheetTheme.shape! as RoundedRectangleBorder;
      expect(
        shape.borderRadius,
        const BorderRadius.vertical(top: Radius.circular(24)),
      );
    });

    test('input fields have no fill and a bottom rule only', () {
      expect(theme.inputDecorationTheme.filled, isFalse);
      expect(
        theme.inputDecorationTheme.enabledBorder,
        isA<UnderlineInputBorder>(),
      );
      final focused =
          theme.inputDecorationTheme.focusedBorder! as UnderlineInputBorder;
      expect(focused.borderSide.color, theme.colorScheme.primary);
      expect(focused.borderSide.width, greaterThan(1));
    });
  });

  group('SpineTheme.light', () {
    final theme = SpineTheme.light;

    test('uses the parchment ground', () {
      expect(theme.colorScheme.surface, const Color(0xFFF5F0E8));
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    test('darkens the brass so it survives on a light ground', () {
      expect(theme.colorScheme.primary, const Color(0xFF7F5700));
      expect(theme.colorScheme.primary, isNot(SpineColors.darkPrimary));
    });

    test('also carries the confidence extension', () {
      expect(theme.extension<SpineSemanticColors>(), isNotNull);
    });

    test('paints no shadows either', () {
      expect(theme.cardTheme.elevation, 0);
      expect(theme.appBarTheme.elevation, 0);
    });
  });

  group('SpineTypography', () {
    test('drives variable font weight through the wght axis', () {
      // Literata and Inter are declared once each in pubspec.yaml. Without an
      // explicit axis value they would render at their default weight and the
      // engine would fake the rest.
      final wght = SpineTypography.displayLarge.fontVariations!.firstWhere(
        (v) => v.axis == 'wght',
      );
      expect(wght.value, 700);
      expect(SpineTypography.displayLarge.fontWeight, FontWeight.w700);
    });

    test('sets optical size from the point size', () {
      final opsz = SpineTypography.displayLarge.fontVariations!.firstWhere(
        (v) => v.axis == 'opsz',
      );
      expect(opsz.value, 48);
    });

    test('clamps optical size into the axis range the face publishes', () {
      // Inter's opsz axis stops at 32; an unclamped 48 would be ignored and
      // the style would silently fall back to the default instance.
      final opsz = SpineTypography.bodyLarge.fontVariations!.firstWhere(
        (v) => v.axis == 'opsz',
      );
      expect(opsz.value, greaterThanOrEqualTo(14));
      expect(opsz.value, lessThanOrEqualTo(32));
    });

    test('metadata caps are letterspaced mono, as system output must be', () {
      expect(SpineTypography.metadataCaps.fontFamily, 'IBMPlexMono');
      expect(SpineTypography.metadataCaps.letterSpacing, closeTo(1.1, 0.001));
      expect(SpineTypography.metadataCaps.fontSize, 11);
    });

    test('line heights come out of the DESIGN.md scale', () {
      // display-lg is 48/56 in DESIGN.md.
      expect(SpineTypography.displayLarge.height, closeTo(56 / 48, 0.0001));
      expect(SpineTypography.bodyMedium.height, closeTo(24 / 16, 0.0001));
    });
  });
}
