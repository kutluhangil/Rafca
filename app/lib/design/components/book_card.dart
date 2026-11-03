import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import 'confidence_badge.dart';
import 'mono_label.dart';

/// One book in the library.
///
/// Layout from the `library_populated` mockup: the spine crop is flush to the
/// left edge with no padding of its own, the confidence bar runs the full
/// height of that edge, and the text column carries badge, title, author, a
/// hairline rule and a metadata footer.
///
/// The card never hides its confidence (SPINE_BLUEPRINT.md 4.5), which is why
/// [level] is required and there is no variant without it.
class BookCard extends StatelessWidget {
  const BookCard({
    required this.title,
    required this.level,
    required this.levelLabel,
    this.author,
    this.crop,
    this.footer,
    this.trailingFooter,
    this.onTap,
    this.onMore,
    this.moreTooltip,
    this.titleIsPlaceholder = false,
    super.key,
  });

  /// The book's title, or a stand-in when nothing was matched.
  final String title;

  /// Which confidence band this result landed in.
  final ConfidenceLevel level;

  /// The badge's text, already localised.
  final String levelLabel;

  /// The author. Null when unknown.
  final String? author;

  /// The spine crop. Null draws an empty frame — a card with no crop is still
  /// a card, because a failed scan has to stay visible.
  final Widget? crop;

  /// Footer metadata: an edition, a publisher, a confidence value. Rendered as
  /// machine output.
  final String? footer;

  /// Optional trailing footer widget — a bookmark toggle, a retry action.
  final Widget? trailingFooter;

  /// Opens the book. Null makes the card inert.
  final VoidCallback? onTap;

  /// Opens the overflow menu. Null hides the affordance entirely rather than
  /// showing a dead control.
  final VoidCallback? onMore;

  /// Accessible name for the overflow control, already localised. Required
  /// whenever [onMore] is set.
  final String? moreTooltip;

  /// Renders the title in italics at reduced opacity, for a placeholder like
  /// "Unknown Title" that is not the book's real name.
  final bool titleIsPlaceholder;

  @override
  Widget build(BuildContext context) {
    assert(
      onMore == null || moreTooltip != null,
      'An overflow control needs an accessible name.',
    );

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = context.spineColors;
    final radius = BorderRadius.circular(SpineRadius.card);

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: radius,
        border: Border.all(
          color: colors.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: SpineBorders.confidenceBar,
                    color: level.color(context),
                  ),
                  if (crop != null)
                    SizedBox(width: _cropWidth, child: crop)
                  else
                    const SizedBox(width: SpineSpacing.xs),
                  Expanded(
                    child: _Details(card: this, theme: theme),
                  ),
                ],
              ),
            ),
            // DESIGN.md, "Elevation & Depth": a 1px inner stroke of 10% white
            // along the top edge, standing in for light catching the top of a
            // book. Drawn as a line inside the clip rather than a BoxShadow,
            // because Flutter has no inset shadow and an outset one would put
            // the highlight under the card instead of on it.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: SpineBorders.hairline,
              child: ColoredBox(color: colors.topEdgeGlow),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return card;

    return Semantics(
      button: true,
      label: title,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          splashColor: scheme.primary.withValues(alpha: 0.06),
          highlightColor: scheme.primary.withValues(alpha: 0.04),
          child: card,
        ),
      ),
    );
  }

  /// A third of the mockup's card, floored so the crop stays readable when the
  /// card is narrow.
  static const _cropWidth = 104.0;
}

class _Details extends StatelessWidget {
  const _Details({required this.card, required this.theme});

  final BookCard card;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final scheme = theme.colorScheme;
    final colors = context.spineColors;

    final titleStyle = theme.textTheme.headlineSmall!.copyWith(
      color: card.titleIsPlaceholder
          ? scheme.onSurface.withValues(alpha: 0.7)
          : scheme.onSurface,
      fontStyle: card.titleIsPlaceholder ? FontStyle.italic : FontStyle.normal,
      height: 1.15,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SpineSpacing.lg,
        SpineSpacing.base,
        SpineSpacing.base,
        SpineSpacing.base,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ConfidenceBadge(
                        level: card.level,
                        label: card.levelLabel,
                      ),
                    ),
                    if (card.onMore != null)
                      _MoreButton(
                        onPressed: card.onMore!,
                        tooltip: card.moreTooltip!,
                      ),
                  ],
                ),
                const SizedBox(height: SpineSpacing.xs),
                Text(
                  card.title,
                  style: titleStyle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (card.author != null) ...[
                  const SizedBox(height: SpineSpacing.xs),
                  Text(
                    card.author!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (card.footer != null || card.trailingFooter != null) ...[
            const SizedBox(height: SpineSpacing.xs),
            Container(
              margin: const EdgeInsets.only(bottom: SpineSpacing.xs),
              height: SpineBorders.hairline,
              color: colors.hairline,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (card.footer != null)
                  Expanded(
                    child: MonoLabel(
                      card.footer!,
                      style: MonoLabelStyle.data,
                      color: scheme.outline,
                    ),
                  )
                else
                  const Spacer(),
                if (card.trailingFooter != null) card.trailingFooter!,
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({required this.onPressed, required this.tooltip});

  final VoidCallback onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: SpineSpacing.xl,
      height: SpineSpacing.lg,
      child: IconButton(
        onPressed: onPressed,
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        icon: Icon(Icons.more_vert, color: scheme.onSurfaceVariant),
        style: ButtonStyle(
          animationDuration: context.motion(SpineMotion.stateChange),
        ),
      ),
    );
  }
}
