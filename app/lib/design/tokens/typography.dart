import 'package:flutter/material.dart';

/// Type scale for Rafça, from the `typography` block in DESIGN.md.
///
/// Literata and Inter are variable fonts, so weight is applied with
/// [FontVariation] on the `wght` axis rather than with [FontWeight] alone —
/// a variable face declared once in `pubspec.yaml` would otherwise render at
/// its default weight and let the engine synthesise the rest. [FontWeight] is
/// still set so that accessibility tooling and text scaling see the intent.
///
/// Both families also carry an optical size axis, which is set from the point
/// size so that a 48px headline is drawn with headline-grade contrast and an
/// 11px label is not.
/// Uppercases [text] the way [locale] expects.
///
/// Dart's [String.toUpperCase] is not locale-aware: it maps `i` to `I` and
/// leaves `ı` alone, which is wrong in Turkish, where `i` uppercases to `İ`
/// and `ı` to `I`. Rafça falls back to Turkish and uppercases every mono
/// string and every button label, so the mapping lives here rather than being
/// rediscovered at each call site.
String uppercaseForLocale(String text, Locale? locale) {
  final language = locale?.languageCode;
  if (language != 'tr' && language != 'az') return text.toUpperCase();
  return text.replaceAll('i', 'İ').replaceAll('ı', 'I').toUpperCase();
}

abstract final class SpineTypography {
  const SpineTypography._();

  static const literata = 'Literata';
  static const inter = 'Inter';
  static const mono = 'IBMPlexMono';

  /// Axis ranges published with the two variable faces. Values outside these
  /// are clamped rather than passed through, because an out-of-range axis is
  /// silently ignored by the shaper and the text renders at the default.
  static const _literataOpszRange = (min: 7.0, max: 72.0);
  static const _interOpszRange = (min: 14.0, max: 32.0);

  static TextStyle _literata({
    required double size,
    required double height,
    required int weight,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: literata,
      fontSize: size,
      height: height / size,
      letterSpacing: letterSpacing,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation(
          'opsz',
          size.clamp(_literataOpszRange.min, _literataOpszRange.max),
        ),
      ],
    );
  }

  static TextStyle _inter({
    required double size,
    required double height,
    required int weight,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: inter,
      fontSize: size,
      height: height / size,
      letterSpacing: letterSpacing,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [
        FontVariation('wght', weight.toDouble()),
        FontVariation(
          'opsz',
          size.clamp(_interOpszRange.min, _interOpszRange.max),
        ),
      ],
    );
  }

  static TextStyle _mono({
    required double size,
    required double height,
    required FontWeight weight,
    required double letterSpacing,
  }) {
    return TextStyle(
      fontFamily: mono,
      fontSize: size,
      height: height / size,
      letterSpacing: letterSpacing,
      fontWeight: weight,
    );
  }

  /// Welcome and hero headings.
  static final displayLarge = _literata(
    size: 48,
    height: 56,
    weight: 700,
    letterSpacing: -0.96,
  );

  /// Screen titles.
  static final headlineMedium = _literata(
    size: 32,
    height: 40,
    weight: 500,
    letterSpacing: -0.32,
  );

  /// Book titles in a card, section headings.
  static final headlineSmall = _literata(size: 24, height: 32, weight: 500);

  static final bodyLarge = _inter(size: 18, height: 28, weight: 400);
  static final bodyMedium = _inter(size: 16, height: 24, weight: 400);
  static final bodySmall = _inter(size: 14, height: 20, weight: 500);

  /// Machine output: confidence values, ISBNs, status badges, the scan log.
  ///
  /// Always rendered UPPERCASE. That is not decoration — it is the signal that
  /// the string came from the system and not from a person (DESIGN.md,
  /// "Archival Metadata").
  static final metadataCaps = _mono(
    size: 11,
    height: 16,
    weight: FontWeight.w600,
    letterSpacing: 1.1,
  );

  /// Mono data that is read rather than scanned, such as `CONF: 0.98`.
  static final labelMono = _mono(
    size: 12,
    height: 16,
    weight: FontWeight.w400,
    letterSpacing: 0,
  );

  /// The Material text theme, wired to the scale above.
  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: displayLarge.copyWith(color: onSurface),
      headlineMedium: headlineMedium.copyWith(color: onSurface),
      headlineSmall: headlineSmall.copyWith(color: onSurface),
      titleMedium: headlineSmall.copyWith(color: onSurface, fontSize: 20),
      bodyLarge: bodyLarge.copyWith(color: onSurface),
      bodyMedium: bodyMedium.copyWith(color: onSurface),
      bodySmall: bodySmall.copyWith(color: onSurfaceVariant),
      labelLarge: labelMono.copyWith(color: onSurface),
      labelMedium: metadataCaps.copyWith(color: onSurfaceVariant),
      labelSmall: metadataCaps.copyWith(color: onSurfaceVariant),
    );
  }
}
