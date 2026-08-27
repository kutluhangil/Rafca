import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// The two button weights DESIGN.md defines.
enum SpineButtonVariant {
  /// Brass fill, ink text, no shadow. One per screen — the thing the screen
  /// exists to do.
  primary,

  /// Transparent with a hairline border and brass text. Everything else.
  secondary,
}

/// Rafça's button.
///
/// DESIGN.md ("Buttons"): brass on ink for primary, hairline-bordered
/// transparent for secondary, 12px radius for both so they never read as
/// cards, and no shadow in either case — depth in this design is luminance and
/// hairlines, never a drop shadow.
///
/// The label is mono uppercase because these buttons commit an action on
/// machine output ("ADD 8 MATCHED BOOKS"), which is the same register as the
/// confidence badges they sit under.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.variant = SpineButtonVariant.primary,
    this.icon,
    this.expand = true,
    super.key,
  });

  /// The label, already localised. Uppercased for display.
  final String label;

  /// Null disables the button.
  final VoidCallback? onPressed;

  /// Which weight this button carries.
  final SpineButtonVariant variant;

  /// Optional leading glyph.
  final IconData? icon;

  /// Whether the button fills the width it is given. Bottom-docked actions do;
  /// buttons inside a row do not.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.spineColors;
    final enabled = onPressed != null;

    final (background, foreground, border) = switch (variant) {
      SpineButtonVariant.primary => (
        colors.brass,
        colors.onBrass,
        colors.brass,
      ),
      SpineButtonVariant.secondary => (
        Colors.transparent,
        scheme.primary,
        colors.hairline,
      ),
    };

    final style = ButtonStyle(
      backgroundColor: WidgetStatePropertyAll(
        enabled ? background : background.withValues(alpha: 0.38),
      ),
      foregroundColor: WidgetStatePropertyAll(
        enabled ? foreground : foreground.withValues(alpha: 0.38),
      ),
      overlayColor: WidgetStatePropertyAll(foreground.withValues(alpha: 0.08)),
      side: WidgetStatePropertyAll(
        BorderSide(
          color: enabled ? border : border.withValues(alpha: 0.38),
          width: SpineBorders.hairline,
        ),
      ),
      shape: const WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(SpineRadius.button)),
        ),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(
          horizontal: SpineSpacing.lg,
          vertical: SpineSpacing.base,
        ),
      ),
      textStyle: WidgetStatePropertyAll(SpineTypography.metadataCaps),
      // Depth is hairlines and luminance, never a shadow.
      elevation: const WidgetStatePropertyAll(0),
      shadowColor: const WidgetStatePropertyAll(Colors.transparent),
      animationDuration: context.motion(SpineMotion.stateChange),
      minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
      tapTargetSize: MaterialTapTargetSize.padded,
    );

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: SpineSpacing.sm),
        ],
        Flexible(
          child: Text(
            uppercaseForLocale(label, Localizations.maybeLocaleOf(context)),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return TextButton(onPressed: onPressed, style: style, child: content);
  }
}
