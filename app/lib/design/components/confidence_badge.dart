import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// How sure Rafça is that a spine was identified.
///
/// The three bands come from SPINE_BLUEPRINT.md 8.4. This enum is the
/// presentation side of them; Faz 5 owns the scoring that decides which band a
/// candidate lands in.
enum ConfidenceLevel {
  /// Scored above the match threshold. Nothing is asked of the user.
  matched,

  /// Scored in between. The user has to choose, and the app says so.
  review,

  /// Scored below the floor, or nothing came back at all.
  unknown;

  /// The band colour for the current theme.
  Color color(BuildContext context) {
    final colors = context.spineColors;
    return switch (this) {
      ConfidenceLevel.matched => colors.matched,
      ConfidenceLevel.review => colors.review,
      ConfidenceLevel.unknown => colors.unknown,
    };
  }
}

/// A 3px bar and a monospace label saying how a spine was resolved.
///
/// SPINE_BLUEPRINT.md 4.5: uncertain results are never hidden behind a second
/// screen, so this badge appears on the card itself and reads the same in
/// every context it turns up in.
///
/// [label] is supplied by the caller rather than derived from [level] so that
/// Faz 8 can localise it. The uppercasing is not the caller's job — DESIGN.md
/// makes UPPERCASE the signal that a string is machine output, so it is
/// applied here where it cannot be forgotten.
class ConfidenceBadge extends StatelessWidget {
  const ConfidenceBadge({required this.level, required this.label, super.key});

  /// Which band the spine landed in.
  final ConfidenceLevel level;

  /// The text to show, in the user's language. Uppercased for display.
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = level.color(context);

    return Semantics(
      label: label,
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: SpineBorders.confidenceBar, color: color),
            const SizedBox(width: SpineSpacing.sm),
            Text(
              uppercaseForLocale(label, Localizations.maybeLocaleOf(context)),
              style: SpineTypography.metadataCaps.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
