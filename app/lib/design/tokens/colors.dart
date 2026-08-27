import 'package:flutter/material.dart';

/// Colour tokens for Rafça.
///
/// Authority for the dark palette is
/// `stitch_spine_book_scanner_app/nocturnal_archivist/DESIGN.md`, which is the
/// file the shipped mockups were rendered from. Where it disagrees with
/// SPINE_BLUEPRINT.md 4.1, DESIGN.md wins; the blueprint quotes an earlier
/// draft of the same palette.
///
/// The names are Material 3 role names because DESIGN.md is already expressed
/// in them, which lets [ColorScheme] be built by hand with no guessing.
abstract final class SpineColors {
  const SpineColors._();

  // --- Dark, the primary experience (DESIGN.md verbatim) -------------------

  static const darkSurface = Color(0xFF151311);
  static const darkSurfaceDim = Color(0xFF151311);
  static const darkSurfaceBright = Color(0xFF3C3936);
  static const darkSurfaceContainerLowest = Color(0xFF100E0C);
  static const darkSurfaceContainerLow = Color(0xFF1D1B19);
  static const darkSurfaceContainer = Color(0xFF221F1D);
  static const darkSurfaceContainerHigh = Color(0xFF2C2927);
  static const darkSurfaceContainerHighest = Color(0xFF373432);
  static const darkOnSurface = Color(0xFFE8E1DD);
  static const darkOnSurfaceVariant = Color(0xFFD3C4B2);
  static const darkInverseSurface = Color(0xFFE8E1DD);
  static const darkInverseOnSurface = Color(0xFF33302D);
  static const darkOutline = Color(0xFF9C8F7E);
  static const darkOutlineVariant = Color(0xFF4F4537);

  static const darkPrimary = Color(0xFFF5BD62);
  static const darkOnPrimary = Color(0xFF432C00);
  static const darkPrimaryContainer = Color(0xFFC9963F);
  static const darkOnPrimaryContainer = Color(0xFF4B3100);
  static const darkInversePrimary = Color(0xFF7F5700);

  static const darkSecondary = Color(0xFFADD0A7);
  static const darkOnSecondary = Color(0xFF19371A);
  static const darkSecondaryContainer = Color(0xFF304E2E);
  static const darkOnSecondaryContainer = Color(0xFF9CBE96);

  static const darkTertiary = Color(0xFFFFB785);
  static const darkOnTertiary = Color(0xFF502400);
  static const darkTertiaryContainer = Color(0xFFDE8B4E);
  static const darkOnTertiaryContainer = Color(0xFF582900);

  static const darkError = Color(0xFFFFB4AB);
  static const darkOnError = Color(0xFF690005);
  static const darkErrorContainer = Color(0xFF93000A);
  static const darkOnErrorContainer = Color(0xFFFFDAD6);

  /// Confidence badge colours, from the Stitch Tailwind config that produced
  /// the mockups: `badge-matched`, `badge-review`, `badge-unrecognized`.
  static const darkMatched = Color(0xFFC8ECC1);
  static const darkReview = Color(0xFFF5BD62);
  static const darkUnknown = Color(0xFFFFB4AB);

  // --- Light -------------------------------------------------------------
  //
  // Stitch only produced a dark theme. This palette is derived from it: the
  // parchment ground comes from SPINE_BLUEPRINT.md 4.1, and every accent is
  // the M3 light-mode partner of the dark token above it, which is why
  // `lightPrimary` is DESIGN.md's `inverse-primary` and `lightPrimaryContainer`
  // is its `primary-fixed`. Anything here is open to revision the first time a
  // light mockup exists; the dark values are not.

  static const lightSurface = Color(0xFFF5F0E8);
  static const lightSurfaceDim = Color(0xFFDED8CE);
  static const lightSurfaceBright = Color(0xFFFFFBF5);
  static const lightSurfaceContainerLowest = Color(0xFFFFFFFF);
  static const lightSurfaceContainerLow = Color(0xFFEFE9DF);
  static const lightSurfaceContainer = Color(0xFFE9E2D6);
  static const lightSurfaceContainerHigh = Color(0xFFE2DACC);
  static const lightSurfaceContainerHighest = Color(0xFFDBD2C2);
  static const lightOnSurface = Color(0xFF221F1D);
  static const lightOnSurfaceVariant = Color(0xFF514A3F);
  static const lightInverseSurface = Color(0xFF33302D);
  static const lightInverseOnSurface = Color(0xFFF5F0E8);
  static const lightOutline = Color(0xFF857A6B);
  static const lightOutlineVariant = Color(0xFFC8BEAE);

  static const lightPrimary = Color(0xFF7F5700);
  static const lightOnPrimary = Color(0xFFFFFFFF);
  static const lightPrimaryContainer = Color(0xFFFFDEAE);
  static const lightOnPrimaryContainer = Color(0xFF281900);
  static const lightInversePrimary = Color(0xFFF5BD62);

  static const lightSecondary = Color(0xFF304E2E);
  static const lightOnSecondary = Color(0xFFFFFFFF);
  static const lightSecondaryContainer = Color(0xFFC8ECC1);
  static const lightOnSecondaryContainer = Color(0xFF042107);

  static const lightTertiary = Color(0xFF723700);
  static const lightOnTertiary = Color(0xFFFFFFFF);
  static const lightTertiaryContainer = Color(0xFFFFDCC6);
  static const lightOnTertiaryContainer = Color(0xFF301400);

  static const lightError = Color(0xFF93000A);
  static const lightOnError = Color(0xFFFFFFFF);
  static const lightErrorContainer = Color(0xFFFFDAD6);
  static const lightOnErrorContainer = Color(0xFF410002);

  static const lightMatched = Color(0xFF2F5D2C);
  static const lightReview = Color(0xFF8A5A00);
  static const lightUnknown = Color(0xFF93000A);
}

/// Colours the app needs that Material's [ColorScheme] has no role for.
///
/// Depth in this design comes from luminance layering and hairline borders,
/// never from shadows (DESIGN.md, "Elevation & Depth"), so the border and
/// raised-surface tones are first-class tokens rather than opacity guesses at
/// the call site.
@immutable
class SpineSemanticColors extends ThemeExtension<SpineSemanticColors> {
  const SpineSemanticColors({
    required this.matched,
    required this.review,
    required this.unknown,
    required this.hairline,
    required this.surfaceRaised,
    required this.topEdgeGlow,
    required this.brass,
    required this.onBrass,
  });

  /// MATCHED badge and its 3px leading bar.
  final Color matched;

  /// REVIEW badge. Static by design — SPINE_BLUEPRINT.md 4.7 gives it no
  /// animation so that it reads as unfinished business.
  final Color review;

  /// UNKNOWN badge.
  final Color unknown;

  /// The 1px border that does the work a shadow would.
  final Color hairline;

  /// Modals and active sheets sit on this, one step above a card.
  final Color surfaceRaised;

  /// 1px inner stroke on the top edge of a raised element, simulating light
  /// catching the top of a book.
  final Color topEdgeGlow;

  /// The gold-leaf accent: primary button fills, crop brackets, focus rings.
  ///
  /// Not a [ColorScheme] role because the two themes take it from opposite
  /// ends of the ramp. Dark uses `primaryContainer` (#C9963F), the brass the
  /// mockups fill buttons with. Light cannot: its `primaryContainer` is the
  /// pale #FFDEAE, which on a parchment ground gives a primary action almost
  /// no separation from the page. Light therefore takes the deep #7F5700,
  /// which still reads as brass but carries the weight the role needs.
  final Color brass;

  /// What sits on [brass].
  final Color onBrass;

  static const dark = SpineSemanticColors(
    matched: SpineColors.darkMatched,
    review: SpineColors.darkReview,
    unknown: SpineColors.darkUnknown,
    hairline: SpineColors.darkOutlineVariant,
    surfaceRaised: SpineColors.darkSurfaceContainerHigh,
    topEdgeGlow: Color(0x1AFFFFFF),
    brass: SpineColors.darkPrimaryContainer,
    onBrass: SpineColors.darkOnPrimaryContainer,
  );

  static const light = SpineSemanticColors(
    matched: SpineColors.lightMatched,
    review: SpineColors.lightReview,
    unknown: SpineColors.lightUnknown,
    hairline: SpineColors.lightOutlineVariant,
    surfaceRaised: SpineColors.lightSurfaceContainerLowest,
    topEdgeGlow: Color(0x14000000),
    brass: SpineColors.lightPrimary,
    onBrass: SpineColors.lightOnPrimary,
  );

  @override
  SpineSemanticColors copyWith({
    Color? matched,
    Color? review,
    Color? unknown,
    Color? hairline,
    Color? surfaceRaised,
    Color? topEdgeGlow,
    Color? brass,
    Color? onBrass,
  }) {
    return SpineSemanticColors(
      matched: matched ?? this.matched,
      review: review ?? this.review,
      unknown: unknown ?? this.unknown,
      hairline: hairline ?? this.hairline,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      topEdgeGlow: topEdgeGlow ?? this.topEdgeGlow,
      brass: brass ?? this.brass,
      onBrass: onBrass ?? this.onBrass,
    );
  }

  @override
  SpineSemanticColors lerp(SpineSemanticColors? other, double t) {
    if (other == null) return this;
    return SpineSemanticColors(
      matched: Color.lerp(matched, other.matched, t)!,
      review: Color.lerp(review, other.review, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      topEdgeGlow: Color.lerp(topEdgeGlow, other.topEdgeGlow, t)!,
      brass: Color.lerp(brass, other.brass, t)!,
      onBrass: Color.lerp(onBrass, other.onBrass, t)!,
    );
  }
}

/// Reads the Rafça semantic colours off the ambient theme.
extension SpineSemanticColorsX on BuildContext {
  SpineSemanticColors get spineColors =>
      Theme.of(this).extension<SpineSemanticColors>()!;
}
