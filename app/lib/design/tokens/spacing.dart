/// Spacing and shape tokens.
///
/// Scale from SPINE_BLUEPRINT.md 4.3, which matches the `spacing` block in
/// DESIGN.md. Everything sits on a 4px baseline grid.
abstract final class SpineSpacing {
  const SpineSpacing._();

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const base = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  /// Outer page margin on mobile. DESIGN.md asks for a gallery-like 24px.
  static const pageMargin = lg;

  /// Minimum gap between two distinct content sections.
  static const sectionGap = xl;
}

/// Corner radii. Deliberately varied rather than one global value: the shape
/// language is what keeps this from reading as a consumer app (DESIGN.md,
/// "Shapes").
abstract final class SpineRadius {
  const SpineRadius._();

  /// Cards and containers.
  static const card = 14.0;

  /// Sheets and overlays — top corners only, so an emerging sheet reads as a
  /// binding rather than a floating pill.
  static const sheet = 24.0;

  /// Buttons: distinct from cards, still tactile.
  static const button = 12.0;

  /// Chips are always fully rounded.
  static const chip = 999.0;

  /// The thumbnail of a spine crop inside a book card.
  static const thumbnail = 8.0;
}

/// Border widths. Depth comes from hairlines, not shadows.
abstract final class SpineBorders {
  const SpineBorders._();

  static const hairline = 1.0;

  /// The leading bar on a confidence badge (SPINE_BLUEPRINT.md 4.5).
  static const confidenceBar = 3.0;
}
