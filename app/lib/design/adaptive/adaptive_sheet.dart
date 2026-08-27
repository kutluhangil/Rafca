import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'adaptive_platform.dart';

/// Opens Rafça's bottom sheet, using each platform's own idiom.
///
/// SPINE_BLUEPRINT.md 4.6: Android gets a Material bottom sheet with a drag
/// handle, Apple platforms get a detented sheet with a grabber. Feature code
/// calls this and never asks which platform it is on.
///
/// The shape is the same on both: 24px on the top corners only, so the sheet
/// reads as a binding coming out of the bottom edge rather than a floating
/// card (DESIGN.md, "Shapes").
Future<T?> showAdaptiveSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isDismissible = true,
  bool useSafeArea = true,
}) {
  final scheme = Theme.of(context).colorScheme;
  final colors = context.spineColors;

  if (AdaptivePlatform.current.isCupertino) {
    return showCupertinoSheet<T>(
      context: context,
      useNestedNavigation: false,
      // The sheet hands down the controller that drives its detents. Publishing
      // it as the primary controller is what lets a scrollable inside the sheet
      // pull it between medium and large instead of scrolling under a stuck
      // sheet.
      scrollableBuilder: (context, controller) => PrimaryScrollController(
        controller: controller,
        child: _SheetSurface(
          background: colors.surfaceRaised,
          hairline: colors.hairline,
          glow: colors.topEdgeGlow,
          child: builder(context),
        ),
      ),
    );
  }

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: useSafeArea,
    // The theme's bottomSheetTheme paints a surface, a shape and a drag
    // handle of its own. Left on, they would sit behind [_SheetSurface] and
    // the sheet would show two rounded tops and two handles. The chrome has
    // one owner, and it is [_SheetSurface] — that is what gives Android and
    // Apple the same hairline and the same top-edge glow.
    backgroundColor: Colors.transparent,
    elevation: 0,
    shape: null,
    showDragHandle: false,
    barrierColor: scheme.scrim.withValues(alpha: 0.6),
    builder: (context) => _SheetSurface(
      background: colors.surfaceRaised,
      hairline: colors.hairline,
      glow: colors.topEdgeGlow,
      showHandle: isDismissible,
      child: builder(context),
    ),
  );
}

/// The sheet's chrome: raised surface, hairline outline, top-edge glow and,
/// on Android, the drag handle.
class _SheetSurface extends StatelessWidget {
  const _SheetSurface({
    required this.background,
    required this.hairline,
    required this.glow,
    required this.child,
    this.showHandle = false,
  });

  final Color background;
  final Color hairline;
  final Color glow;
  final Widget child;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    const radius = BorderRadius.vertical(
      top: Radius.circular(SpineRadius.sheet),
    );

    // The Cupertino sheet has no Material ancestor of its own, and Rafça's
    // content is Material — text would fall back to the debug style and an
    // InkWell inside the sheet would have nothing to paint on. Transparent so
    // the surface colour above still shows through.
    return Material(
      type: MaterialType.transparency,
      child: _surface(background, hairline, radius),
    );
  }

  Widget _surface(Color background, Color hairline, BorderRadius radius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: Border.all(color: hairline, width: SpineBorders.hairline),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showHandle) _DragHandle(color: hairline),
                Flexible(child: child),
              ],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: SpineBorders.hairline,
              child: ColoredBox(color: glow),
            ),
          ],
        ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SpineSpacing.md),
      child: Container(
        width: SpineSpacing.xxl,
        height: SpineSpacing.xs,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(SpineRadius.chip),
        ),
      ),
    );
  }
}

/// A titled sheet body, matching the `review_correct_spine` mockup.
///
/// Kept separate from [showAdaptiveSheet] so a sheet can also be built from
/// scratch when a screen needs something other than title, subtitle, content.
class AdaptiveSheetBody extends StatelessWidget {
  const AdaptiveSheetBody({
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    super.key,
  });

  /// The sheet's heading, already localised.
  final String title;

  /// One line explaining why the sheet is open.
  final String? subtitle;

  /// Shown opposite the title — normally a [ConfidenceBadge].
  final Widget? trailing;

  /// The sheet's content.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final motion = context.motion;

    return AnimatedPadding(
      duration: motion(SpineMotion.stateChange),
      curve: motion.curve(SpineMotion.transform),
      // Keeps the content clear of the keyboard when a sheet holds a field.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          SpineSpacing.lg,
          SpineSpacing.sm,
          SpineSpacing.lg,
          SpineSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(title, style: theme.textTheme.headlineMedium),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: SpineSpacing.base),
                  Padding(
                    padding: const EdgeInsets.only(top: SpineSpacing.sm),
                    child: trailing,
                  ),
                ],
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: SpineSpacing.sm),
              Text(
                subtitle!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: SpineSpacing.lg),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
