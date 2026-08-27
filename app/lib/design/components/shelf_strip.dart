import 'package:flutter/material.dart';

import '../motion/motion.dart';
import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// One book's place in a [ShelfStrip].
///
/// [width] is a share, not a measurement: the bars are laid out with
/// [Flexible] so a strip fills whatever width it is given at any screen size.
/// The number that goes here is the spine's pixel width in the capture, which
/// makes the strip a true scale drawing of the physical shelf.
@immutable
class ShelfStripBar {
  const ShelfStripBar({
    required this.color,
    required this.width,
    this.height = 1.0,
    this.semanticLabel,
  }) : assert(width > 0, 'A spine with no width is not on the shelf.'),
       assert(
         height > 0 && height <= 1,
         'height is a fraction of the strip, from just visible to full bleed.',
       );

  /// Dominant colour of the spine crop, extracted in Faz 6.
  final Color color;

  /// Relative width of this spine against its neighbours.
  final double width;

  /// Relative height, for shelves photographed with books of differing size.
  /// Bars are anchored to the bottom, the way books stand on a shelf.
  final double height;

  /// What a screen reader announces for this bar — normally the book's title.
  final String? semanticLabel;
}

/// How much room a [ShelfStrip] takes.
enum ShelfStripVariant {
  /// 40px, pinned under the app bar. The strip as a wayfinding device.
  compact(height: 40),

  /// 96px, full width above the library. The strip as the product's portrait
  /// of your shelf.
  hero(height: 96),

  /// 96px of outlined bars and nothing else, for a library with no books yet.
  /// It is a promise of what the screen will look like, not a spinner.
  empty(height: 96);

  const ShelfStripVariant({required this.height});

  /// Height in logical pixels.
  final double height;
}

/// Rafça's signature component: a horizontal strip of vertical coloured bars,
/// one per book, in shelf order.
///
/// SPINE_BLUEPRINT.md 4.4 makes this the product's visual identity and asks
/// for it on at least four screens. Each bar's colour is the dominant colour
/// of that book's spine crop, so the strip is recognisably *your* shelf rather
/// than a generic chart.
///
/// The entry animation runs bars from the baseline up, 12ms apart
/// (SPINE_BLUEPRINT.md 4.7). Under reduce-motion the stagger disappears and
/// the strip simply fades in.
class ShelfStrip extends StatefulWidget {
  const ShelfStrip({
    required this.bars,
    this.variant = ShelfStripVariant.compact,
    this.onBarTap,
    this.emptyBarCount = 9,
    super.key,
  });

  /// The books, in the order they stand on the shelf. Ignored by
  /// [ShelfStripVariant.empty], which draws placeholders instead.
  final List<ShelfStripBar> bars;

  /// How tall the strip is and whether it is filled or outlined.
  final ShelfStripVariant variant;

  /// Tapping a bar scrolls the library to that volume (SPINE_BLUEPRINT.md 4.4).
  /// Null makes the strip decorative, and it stops being a tap target.
  final void Function(int index)? onBarTap;

  /// How many outline bars the empty variant draws.
  final int emptyBarCount;

  @override
  State<ShelfStrip> createState() => _ShelfStripState();
}

class _ShelfStripState extends State<ShelfStrip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _restart();
  }

  @override
  void didUpdateWidget(ShelfStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A shelf that gains books animates the new arrangement in rather than
    // snapping, which is also what makes an added scan read as an addition.
    if (oldWidget.bars.length != widget.bars.length ||
        oldWidget.variant != widget.variant) {
      _restart();
    }
  }

  /// The whole strip is one timeline: bar n starts at n * stagger and runs for
  /// the bar duration. Driving it from a single controller keeps the 12ms
  /// spacing exact no matter how many books are on the shelf.
  void _restart() {
    final motion = context.motion;
    _controller
      ..duration =
          motion(SpineMotion.shelfStripBar) +
          motion.stagger(SpineMotion.shelfStripStagger) *
              (_barCount - 1).clamp(0, double.infinity).toInt()
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _barCount => widget.variant == ShelfStripVariant.empty
      ? widget.emptyBarCount
      : widget.bars.length;

  /// The slice of the shared timeline belonging to bar [index].
  Animation<double> _barAnimation(int index, SpineMotionData motion) {
    final total = _controller.duration?.inMicroseconds ?? 0;
    if (_barCount <= 1 || total == 0) return _controller;

    final stagger = motion
        .stagger(SpineMotion.shelfStripStagger)
        .inMicroseconds;
    final span = motion(SpineMotion.shelfStripBar).inMicroseconds;
    final begin = (stagger * index) / total;
    final end = (stagger * index + span) / total;

    return CurvedAnimation(
      parent: _controller,
      curve: Interval(
        begin.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: motion.curve(SpineMotion.enter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final motion = context.motion;
    final isEmpty = widget.variant == ShelfStripVariant.empty;
    final count = _barCount;

    if (count == 0) return SizedBox(height: widget.variant.height);

    return SizedBox(
      height: widget.variant.height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var index = 0; index < count; index++)
            Flexible(
              flex: isEmpty
                  ? _emptyWidths[index % _emptyWidths.length]
                  : (widget.bars[index].width * 1000).round(),
              child: _Bar(
                animation: _barAnimation(index, motion),
                reduceMotion: motion.reduceMotion,
                heightFactor: isEmpty
                    ? _emptyHeights[index % _emptyHeights.length]
                    : widget.bars[index].height,
                color: isEmpty ? null : widget.bars[index].color,
                outline: isEmpty ? context.spineColors.hairline : null,
                label: isEmpty ? null : widget.bars[index].semanticLabel,
                onTap: widget.onBarTap == null || isEmpty
                    ? null
                    : () => widget.onBarTap!(index),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widths and heights for the empty state's placeholder bars.
///
/// Fixed rather than random: the empty library is the first screen a new user
/// sees, and a silhouette that reshuffles on every rebuild reads as a loading
/// state instead of a promise.
const _emptyWidths = [6, 3, 4, 8, 3, 5, 2, 7, 4, 3, 6, 5];
const _emptyHeights = [
  0.55,
  0.80,
  0.65,
  0.95,
  0.60,
  0.85,
  0.50,
  0.75,
  0.90,
  0.60,
  0.70,
  0.82,
];

class _Bar extends StatelessWidget {
  const _Bar({
    required this.animation,
    required this.reduceMotion,
    required this.heightFactor,
    required this.color,
    required this.outline,
    required this.label,
    required this.onTap,
  });

  final Animation<double> animation;
  final bool reduceMotion;
  final double heightFactor;
  final Color? color;
  final Color? outline;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget bar = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        border: outline == null
            ? null
            : Border.all(color: outline!, width: SpineBorders.hairline),
        borderRadius: outline == null
            ? null
            : const BorderRadius.vertical(top: Radius.circular(2)),
      ),
      child: const SizedBox.expand(),
    );

    bar = FractionallySizedBox(
      alignment: Alignment.bottomCenter,
      heightFactor: heightFactor,
      child: bar,
    );

    // Reduce-motion gets a crossfade; everything else grows from the baseline,
    // which is how a book is put on a shelf.
    bar = reduceMotion
        ? FadeTransition(opacity: animation, child: bar)
        : ScaleTransition(
            scale: animation,
            alignment: Alignment.bottomCenter,
            child: bar,
          );

    if (onTap != null) {
      bar = Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: bar,
        ),
      );
    } else if (label != null) {
      bar = Semantics(label: label, child: bar);
    }

    return bar;
  }
}
