import 'package:flutter/material.dart';

/// Motion constants for Rafça, from SPINE_BLUEPRINT.md 4.7.
///
/// Every animation in the app reads its duration and curve from here. That is
/// not tidiness: the spec has two global rules — nothing exceeds 400ms, and
/// reduce-motion collapses everything to a 120ms crossfade — and neither can
/// be enforced if call sites invent their own numbers.
///
/// Read them through [SpineMotionX.motion] rather than touching the raw
/// constants, so the reduce-motion collapse happens exactly once.
abstract final class SpineMotion {
  const SpineMotion._();

  /// The ceiling from SPINE_BLUEPRINT.md 4.7. Asserted, not clamped: a
  /// duration over the ceiling is a spec violation to fix, not to paper over.
  static const ceiling = Duration(milliseconds: 400);

  /// What every duration becomes when the platform asks for reduced motion.
  static const reduced = Duration(milliseconds: 120);

  /// ShelfStrip entry: each bar scales up from the baseline.
  static const shelfStripBar = Duration(milliseconds: 260);

  /// Delay between two neighbouring ShelfStrip bars.
  static const shelfStripStagger = Duration(milliseconds: 12);

  /// One spine rectangle being stroked onto the capture during segmentation.
  static const segmentationPerSpine = Duration(milliseconds: 120);

  /// The captured frame flying into the processing screen.
  static const captureHero = Duration(milliseconds: 320);

  /// A row of the result list fading and sliding into place.
  static const resultRow = Duration(milliseconds: 220);

  /// Delay between two neighbouring result rows.
  static const resultRowStagger = Duration(milliseconds: 30);

  /// Distance a result row travels while fading in.
  static const resultRowOffset = 12.0;

  /// The one-shot pulse when a candidate resolves to MATCHED.
  ///
  /// REVIEW deliberately has no counterpart: SPINE_BLUEPRINT.md 4.7 leaves it
  /// static so that unfinished business does not blend into ambient movement.
  static const matchedPulse = Duration(milliseconds: 400);

  /// Ordinary surface changes: hover, selection, colour swaps.
  static const stateChange = Duration(milliseconds: 160);

  static const enter = Curves.easeOutCubic;
  static const transform = Curves.easeInOutCubic;
  static const exit = Curves.easeInCubic;
}

/// The motion values that apply to a given [BuildContext].
///
/// Resolved once from [MediaQueryData.disableAnimations] so that a widget can
/// animate without asking whether it is allowed to.
@immutable
class SpineMotionData {
  const SpineMotionData._({required this.reduceMotion});

  /// Reads the platform's reduce-motion setting.
  factory SpineMotionData.of(BuildContext context) {
    return SpineMotionData._(
      reduceMotion: MediaQuery.maybeDisableAnimationsOf(context) ?? false,
    );
  }

  /// True when the platform asks for reduced motion.
  final bool reduceMotion;

  /// The duration to actually use for [duration].
  ///
  /// Under reduce-motion every animation becomes the same short crossfade, so
  /// nothing travels and nothing scales.
  Duration call(Duration duration) {
    assert(
      duration <= SpineMotion.ceiling,
      'SPINE_BLUEPRINT.md 4.7 caps animations at '
      '${SpineMotion.ceiling.inMilliseconds}ms; got '
      '${duration.inMilliseconds}ms.',
    );
    return reduceMotion ? SpineMotion.reduced : duration;
  }

  /// The stagger to actually use. Reduce-motion drops staggers entirely, so a
  /// list appears at once rather than marching in.
  Duration stagger(Duration duration) =>
      reduceMotion ? Duration.zero : duration;

  /// The curve to actually use. Reduce-motion flattens easing to linear,
  /// because a crossfade with an entry curve still reads as movement.
  Curve curve(Curve curve) => reduceMotion ? Curves.linear : curve;

  /// A distance to actually travel. Reduce-motion means "do not travel".
  double offset(double offset) => reduceMotion ? 0 : offset;

  @override
  bool operator ==(Object other) =>
      other is SpineMotionData && other.reduceMotion == reduceMotion;

  @override
  int get hashCode => reduceMotion.hashCode;
}

/// Reads the resolved motion values off the ambient media query.
extension SpineMotionX on BuildContext {
  SpineMotionData get motion => SpineMotionData.of(this);
}
