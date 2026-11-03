import 'package:flutter/material.dart';

import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';

/// Roll & pitch spirit-level indicator from SPINE_BLUEPRINT.md 7.1.
///
/// Both angles must be within +/-7 degrees for the shutter to enable.
class LevelIndicator extends StatelessWidget {
  const LevelIndicator({
    super.key,
    required this.roll,
    required this.pitch,
    this.maxTiltDegrees = 7.0,
    this.label,
  });

  final double roll;
  final double pitch;
  final double maxTiltDegrees;
  final String? label;

  bool get isLeveled =>
      roll.abs() <= maxTiltDegrees && pitch.abs() <= maxTiltDegrees;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final color = isLeveled ? semantic.matched : semantic.unknown;
    final defaultLabel = isLeveled
        ? 'PARALEL / LEVEL'
        : 'RAFA PARALEL TUTUN / HOLD PARALLEL';
    final text = label ?? defaultLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SpineSpacing.md,
            vertical: SpineSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(SpineRadius.chip),
            border: Border.all(
              color: color,
              width: SpineBorders.hairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLeveled ? Icons.check_circle_outline : Icons.screen_rotation_outlined,
                size: 14,
                color: color,
              ),
              const SizedBox(width: SpineSpacing.sm),
              Text(
                uppercaseForLocale(text, Localizations.maybeLocaleOf(context)),
                style: SpineTypography.metadataCaps.copyWith(color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
