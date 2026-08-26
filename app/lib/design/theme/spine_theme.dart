import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Builds the two Rafça themes.
///
/// Dark is the primary experience; light is a derived companion (see
/// [SpineColors]). Both are assembled by hand rather than through
/// [ColorScheme.fromSeed], because DESIGN.md already fixes every role and a
/// seeded scheme would quietly move them.
abstract final class SpineTheme {
  const SpineTheme._();

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        scheme: _darkScheme,
        semantic: SpineSemanticColors.dark,
      );

  static ThemeData get light => _build(
        brightness: Brightness.light,
        scheme: _lightScheme,
        semantic: SpineSemanticColors.light,
      );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: SpineColors.darkPrimary,
    onPrimary: SpineColors.darkOnPrimary,
    primaryContainer: SpineColors.darkPrimaryContainer,
    onPrimaryContainer: SpineColors.darkOnPrimaryContainer,
    inversePrimary: SpineColors.darkInversePrimary,
    secondary: SpineColors.darkSecondary,
    onSecondary: SpineColors.darkOnSecondary,
    secondaryContainer: SpineColors.darkSecondaryContainer,
    onSecondaryContainer: SpineColors.darkOnSecondaryContainer,
    tertiary: SpineColors.darkTertiary,
    onTertiary: SpineColors.darkOnTertiary,
    tertiaryContainer: SpineColors.darkTertiaryContainer,
    onTertiaryContainer: SpineColors.darkOnTertiaryContainer,
    error: SpineColors.darkError,
    onError: SpineColors.darkOnError,
    errorContainer: SpineColors.darkErrorContainer,
    onErrorContainer: SpineColors.darkOnErrorContainer,
    surface: SpineColors.darkSurface,
    onSurface: SpineColors.darkOnSurface,
    onSurfaceVariant: SpineColors.darkOnSurfaceVariant,
    surfaceDim: SpineColors.darkSurfaceDim,
    surfaceBright: SpineColors.darkSurfaceBright,
    surfaceContainerLowest: SpineColors.darkSurfaceContainerLowest,
    surfaceContainerLow: SpineColors.darkSurfaceContainerLow,
    surfaceContainer: SpineColors.darkSurfaceContainer,
    surfaceContainerHigh: SpineColors.darkSurfaceContainerHigh,
    surfaceContainerHighest: SpineColors.darkSurfaceContainerHighest,
    inverseSurface: SpineColors.darkInverseSurface,
    onInverseSurface: SpineColors.darkInverseOnSurface,
    outline: SpineColors.darkOutline,
    outlineVariant: SpineColors.darkOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: SpineColors.lightPrimary,
    onPrimary: SpineColors.lightOnPrimary,
    primaryContainer: SpineColors.lightPrimaryContainer,
    onPrimaryContainer: SpineColors.lightOnPrimaryContainer,
    inversePrimary: SpineColors.lightInversePrimary,
    secondary: SpineColors.lightSecondary,
    onSecondary: SpineColors.lightOnSecondary,
    secondaryContainer: SpineColors.lightSecondaryContainer,
    onSecondaryContainer: SpineColors.lightOnSecondaryContainer,
    tertiary: SpineColors.lightTertiary,
    onTertiary: SpineColors.lightOnTertiary,
    tertiaryContainer: SpineColors.lightTertiaryContainer,
    onTertiaryContainer: SpineColors.lightOnTertiaryContainer,
    error: SpineColors.lightError,
    onError: SpineColors.lightOnError,
    errorContainer: SpineColors.lightErrorContainer,
    onErrorContainer: SpineColors.lightOnErrorContainer,
    surface: SpineColors.lightSurface,
    onSurface: SpineColors.lightOnSurface,
    onSurfaceVariant: SpineColors.lightOnSurfaceVariant,
    surfaceDim: SpineColors.lightSurfaceDim,
    surfaceBright: SpineColors.lightSurfaceBright,
    surfaceContainerLowest: SpineColors.lightSurfaceContainerLowest,
    surfaceContainerLow: SpineColors.lightSurfaceContainerLow,
    surfaceContainer: SpineColors.lightSurfaceContainer,
    surfaceContainerHigh: SpineColors.lightSurfaceContainerHigh,
    surfaceContainerHighest: SpineColors.lightSurfaceContainerHighest,
    inverseSurface: SpineColors.lightInverseSurface,
    onInverseSurface: SpineColors.lightInverseOnSurface,
    outline: SpineColors.lightOutline,
    outlineVariant: SpineColors.lightOutlineVariant,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme scheme,
    required SpineSemanticColors semantic,
  }) {
    final textTheme = SpineTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );
    final hairline = BorderSide(
      color: semantic.hairline,
      width: SpineBorders.hairline,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: textTheme,
      fontFamily: SpineTypography.inter,
      splashFactory: InkSparkle.splashFactory,
      extensions: [semantic],

      // No shadows anywhere. Depth is luminance layering plus a hairline
      // border (DESIGN.md, "Elevation & Depth"), so every elevation that
      // Material would paint is zeroed and replaced with a border.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.headlineSmall,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpineRadius.card),
          side: hairline,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: semantic.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpineRadius.card),
          side: hairline,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: semantic.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(SpineRadius.sheet),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: semantic.hairline,
        thickness: SpineBorders.hairline,
        space: SpineBorders.hairline,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primaryContainer,
          foregroundColor: scheme.onPrimaryContainer,
          elevation: 0,
          textStyle: SpineTypography.metadataCaps,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpineRadius.button),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          elevation: 0,
          textStyle: SpineTypography.metadataCaps,
          minimumSize: const Size.fromHeight(52),
          side: hairline,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SpineRadius.button),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: SpineTypography.metadataCaps,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        selectedColor: scheme.secondaryContainer,
        side: hairline,
        elevation: 0,
        pressElevation: 0,
        labelStyle: textTheme.bodySmall!,
        shape: const StadiumBorder(),
      ),
      // Minimalist fields: no fill, a bottom rule that thickens to brass on
      // focus (DESIGN.md, "Input Fields").
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          vertical: SpineSpacing.md,
        ),
        labelStyle: SpineTypography.metadataCaps.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        hintStyle: textTheme.bodyMedium!.copyWith(
          color: scheme.onSurfaceVariant,
        ),
        enabledBorder: UnderlineInputBorder(borderSide: hairline),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: scheme.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: scheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.bodySmall),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: semantic.surfaceRaised,
        contentTextStyle: textTheme.bodyMedium,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpineRadius.button),
          side: hairline,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
      ),
    );
  }
}
