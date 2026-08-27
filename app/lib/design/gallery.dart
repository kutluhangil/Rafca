import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/theme_mode_controller.dart';
import 'adaptive/adaptive_sheet.dart';
import 'components/book_card.dart';
import 'components/confidence_badge.dart';
import 'components/mono_label.dart';
import 'components/primary_button.dart';
import 'components/shelf_strip.dart';
import 'components/spine_crop_view.dart';
import 'tokens/colors.dart';
import 'tokens/spacing.dart';
import 'tokens/typography.dart';

/// Every Rafça component, one at a time, in both themes.
///
/// This is the Faz 2 acceptance surface (SPINE_BLUEPRINT.md): if a component
/// cannot be seen here on its own and read correctly in dark and light, it is
/// not finished. It is also where reduce-motion is checked, since the 120ms
/// collapse is invisible in a screenshot and easy to regress.
///
/// A developer screen, not a product screen: its strings are deliberately not
/// localised, because it never ships to a user and the ARB files exist to
/// describe the product's language, not this scaffold's.
class DesignGalleryScreen extends ConsumerStatefulWidget {
  const DesignGalleryScreen({super.key});

  @override
  ConsumerState<DesignGalleryScreen> createState() =>
      _DesignGalleryScreenState();
}

class _DesignGalleryScreenState extends ConsumerState<DesignGalleryScreen> {
  /// Forces reduce-motion on regardless of the platform setting, so the
  /// collapse can be checked on a machine that has animations enabled.
  bool _forceReduceMotion = false;

  /// Bumped to remount the animated components and replay their entries.
  int _replayToken = 0;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeControllerProvider);
    final media = MediaQuery.of(context);

    return MediaQuery(
      data: _forceReduceMotion
          ? media.copyWith(disableAnimations: true)
          : media,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Design gallery'),
          actions: [
            IconButton(
              onPressed: () => setState(() => _replayToken++),
              icon: const Icon(Icons.replay),
              tooltip: 'Replay entry animations',
            ),
            IconButton(
              onPressed: () =>
                  setState(() => _forceReduceMotion = !_forceReduceMotion),
              icon: Icon(
                _forceReduceMotion
                    ? Icons.motion_photos_off
                    : Icons.motion_photos_on,
              ),
              tooltip: _forceReduceMotion
                  ? 'Reduce motion: forced on'
                  : 'Reduce motion: platform setting',
            ),
            IconButton(
              onPressed: () =>
                  ref.read(themeModeControllerProvider.notifier).cycle(),
              icon: Icon(switch (mode) {
                ThemeMode.system => Icons.brightness_auto_outlined,
                ThemeMode.dark => Icons.dark_mode_outlined,
                ThemeMode.light => Icons.light_mode_outlined,
              }),
              tooltip: 'Theme: ${mode.name}',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: SpineSpacing.xxl),
          children: [
            _Section(
              title: 'ShelfStrip — compact (40px)',
              note: 'Pinned under an app bar. Bars enter 12ms apart.',
              fullBleed: true,
              child: ShelfStrip(
                key: ValueKey('compact-$_replayToken'),
                bars: _demoBars,
                onBarTap: (index) => _announce(context, 'Bar $index'),
              ),
            ),
            _Section(
              title: 'ShelfStrip — hero (96px)',
              note: 'Full width above the library.',
              fullBleed: true,
              child: ShelfStrip(
                key: ValueKey('hero-$_replayToken'),
                bars: _demoBars,
                variant: ShelfStripVariant.hero,
                onBarTap: (index) => _announce(context, 'Bar $index'),
              ),
            ),
            _Section(
              title: 'ShelfStrip — empty',
              note: 'Outline bars only. A promise, not a spinner.',
              fullBleed: true,
              child: ShelfStrip(
                key: ValueKey('empty-$_replayToken'),
                bars: const [],
                variant: ShelfStripVariant.empty,
              ),
            ),
            const _Section(
              title: 'ConfidenceBadge',
              note: '3px bar plus mono label. Never hidden behind a tap.',
              child: Wrap(
                spacing: SpineSpacing.lg,
                runSpacing: SpineSpacing.md,
                children: [
                  ConfidenceBadge(
                    level: ConfidenceLevel.matched,
                    label: 'Matched',
                  ),
                  ConfidenceBadge(
                    level: ConfidenceLevel.review,
                    label: 'Review',
                  ),
                  ConfidenceBadge(
                    level: ConfidenceLevel.unknown,
                    label: 'Unknown',
                  ),
                ],
              ),
            ),
            _Section(
              title: 'BookCard',
              note:
                  'Crop flush left, confidence bar on the edge, hairline '
                  'rule above the footer.',
              child: Column(
                children: [
                  BookCard(
                    title: 'The Secret History',
                    author: 'Donna Tartt',
                    level: ConfidenceLevel.matched,
                    levelLabel: 'Matched',
                    footer: '1992 edition',
                    crop: const _SpineSwatch(color: Color(0xFF304E2E)),
                    trailingFooter: Icon(
                      Icons.bookmark_border,
                      size: 18,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    onTap: () => _announce(context, 'The Secret History'),
                    onMore: () => _announce(context, 'Overflow menu'),
                    moreTooltip: 'More actions',
                  ),
                  const SizedBox(height: SpineSpacing.base),
                  BookCard(
                    title: 'Unknown Title',
                    author: 'Unknown Author',
                    titleIsPlaceholder: true,
                    level: ConfidenceLevel.review,
                    levelLabel: 'Review',
                    footer: 'conf: 0.45',
                    crop: const _SpineSwatch(color: Color(0xFF7F5700)),
                    onTap: () => _announce(context, 'Resolve'),
                    onMore: () => _announce(context, 'Overflow menu'),
                    moreTooltip: 'More actions',
                  ),
                  const SizedBox(height: SpineSpacing.base),
                  BookCard(
                    title: 'Scan Failed',
                    author: 'Blurry image',
                    level: ConfidenceLevel.unknown,
                    levelLabel: 'Unknown',
                    footer: 'conf: 0.12',
                    onTap: () => _announce(context, 'Rescan'),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'SpineCropView',
              note: 'Brass corner brackets say which region was read.',
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: SpineCropView(
                      image: null,
                      placeholder: _SpineSwatch(color: Color(0xFF4F4537)),
                      semanticLabel: 'Spine crop with brackets',
                    ),
                  ),
                  const SizedBox(width: SpineSpacing.base),
                  const Expanded(
                    child: SpineCropView(
                      image: null,
                      brackets: false,
                      placeholder: _SpineSwatch(color: Color(0xFFADD0A7)),
                      semanticLabel: 'Spine crop, thumbnail',
                    ),
                  ),
                  const SizedBox(width: SpineSpacing.base),
                  const Expanded(child: SpineCropView(image: null)),
                ],
              ),
            ),
            _Section(
              title: 'MonoLabel',
              note:
                  'Always uppercase — the signal that a string is machine '
                  'output. Turkish İ handled explicitly.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  MonoLabel('Source capture — 12 items detected'),
                  SizedBox(height: SpineSpacing.sm),
                  MonoLabel('conf: 0.98', style: MonoLabelStyle.data),
                  SizedBox(height: SpineSpacing.sm),
                  MonoLabel(
                    'isbn: 978-0-14-118776-1',
                    style: MonoLabelStyle.data,
                  ),
                ],
              ),
            ),
            _Section(
              title: 'PrimaryButton',
              note:
                  'Brass fill for the one action; hairline outline for the '
                  'rest. No shadow in either.',
              child: Column(
                children: [
                  PrimaryButton(
                    label: 'Add 8 matched books',
                    onPressed: () => _announce(context, 'Added'),
                  ),
                  const SizedBox(height: SpineSpacing.md),
                  PrimaryButton(
                    label: 'Review 2 issues',
                    variant: SpineButtonVariant.secondary,
                    onPressed: () => _announce(context, 'Reviewing'),
                  ),
                  const SizedBox(height: SpineSpacing.md),
                  PrimaryButton(
                    label: 'Search manually',
                    icon: Icons.search,
                    variant: SpineButtonVariant.secondary,
                    onPressed: () => _openSheet(context),
                  ),
                  const SizedBox(height: SpineSpacing.md),
                  const PrimaryButton(label: 'Disabled', onPressed: null),
                ],
              ),
            ),
            _Section(
              title: 'AdaptiveSheet',
              note:
                  'Material bottom sheet on Android, detented sheet on '
                  'Apple. 24px on the top corners only.',
              child: PrimaryButton(
                label: 'Open review sheet',
                onPressed: () => _openSheet(context),
              ),
            ),
            const _Section(
              title: 'Type scale',
              note:
                  'Literata for headings, Inter for body, IBM Plex Mono for '
                  'machine output.',
              child: _TypeSpecimen(),
            ),
            const _Section(
              title: 'Palette',
              note:
                  'Depth is luminance layering plus a hairline, never a '
                  'shadow.',
              child: _PaletteSpecimen(),
            ),
          ],
        ),
      ),
    );
  }

  void _announce(BuildContext context, String what) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(content: Text(what), duration: const Duration(seconds: 1)),
      );
  }

  Future<void> _openSheet(BuildContext context) {
    return showAdaptiveSheet<void>(
      context: context,
      builder: (context) => AdaptiveSheetBody(
        title: 'Review Match',
        subtitle: 'We found multiple editions for this spine.',
        trailing: const ConfidenceBadge(
          level: ConfidenceLevel.review,
          label: 'Review',
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SpineCropView(
              image: null,
              aspectRatio: 16 / 9,
              placeholder: _SpineSwatch(color: Color(0xFF373432)),
              semanticLabel: 'The spine being reviewed',
            ),
            const SizedBox(height: SpineSpacing.lg),
            const MonoLabel('Select correct edition'),
            const SizedBox(height: SpineSpacing.md),
            BookCard(
              title: 'Dune',
              author: 'Frank Herbert',
              level: ConfidenceLevel.matched,
              levelLabel: 'Matched',
              footer: '1965 ed. · Chilton Books',
              crop: const _SpineSwatch(color: Color(0xFFDE8B4E)),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stand-in spine crops. The real ones arrive in Faz 6 from the capture; this
/// is a painted gradient so the gallery needs no bundled fixtures.
class _SpineSwatch extends StatelessWidget {
  const _SpineSwatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            Color.lerp(color, const Color(0xFF000000), 0.55)!,
            color,
          ],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    this.note,
    this.fullBleed = false,
  });

  final String title;
  final String? note;
  final Widget child;

  /// The ShelfStrip is edge to edge by design, so it skips the page margin.
  final bool fullBleed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: SpineSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SpineSpacing.pageMargin,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MonoLabel(title),
                if (note != null) ...[
                  const SizedBox(height: SpineSpacing.xs),
                  Text(
                    note!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
                const SizedBox(height: SpineSpacing.base),
              ],
            ),
          ),
          if (fullBleed)
            child
          else
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: SpineSpacing.pageMargin,
              ),
              child: child,
            ),
        ],
      ),
    );
  }
}

class _TypeSpecimen extends StatelessWidget {
  const _TypeSpecimen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good evening.', style: SpineTypography.displayLarge),
        Text('Your Collection', style: SpineTypography.headlineMedium),
        Text('The Secret History', style: SpineTypography.headlineSmall),
        const SizedBox(height: SpineSpacing.sm),
        Text(
          'Your archival shelves await curation.',
          style: SpineTypography.bodyLarge.copyWith(color: scheme.onSurface),
        ),
        Text(
          'Begin your archival journey by capturing the physical volumes on '
          'your shelves.',
          style: SpineTypography.bodyMedium.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        Text(
          'Donna Tartt',
          style: SpineTypography.bodySmall.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PaletteSpecimen extends StatelessWidget {
  const _PaletteSpecimen();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.spineColors;

    return Wrap(
      spacing: SpineSpacing.sm,
      runSpacing: SpineSpacing.sm,
      children: [
        _Swatch('surface', scheme.surface),
        _Swatch('container low', scheme.surfaceContainerLow),
        _Swatch('container high', scheme.surfaceContainerHigh),
        _Swatch('raised', colors.surfaceRaised),
        _Swatch('primary', scheme.primary),
        _Swatch('brass', colors.brass),
        _Swatch('hairline', colors.hairline),
        _Swatch('matched', colors.matched),
        _Swatch('review', colors.review),
        _Swatch('unknown', colors.unknown),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 104,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: SpineSpacing.xxl,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
              border: Border.all(
                color: context.spineColors.hairline,
                width: SpineBorders.hairline,
              ),
            ),
          ),
          const SizedBox(height: SpineSpacing.xs),
          MonoLabel(name, style: MonoLabelStyle.data),
        ],
      ),
    );
  }
}

/// Demo bars: widths and colours standing in for a scanned shelf.
const _demoBars = [
  ShelfStripBar(color: Color(0xFF304E2E), width: 2, semanticLabel: 'Book 1'),
  ShelfStripBar(color: Color(0xFFC9963F), width: 5, semanticLabel: 'Book 2'),
  ShelfStripBar(color: Color(0xFF9C8F7E), width: 1, semanticLabel: 'Book 3'),
  ShelfStripBar(
    color: Color(0xFF7F5700),
    width: 8,
    height: 0.92,
    semanticLabel: 'Book 4',
  ),
  ShelfStripBar(color: Color(0xFF4F4537), width: 3, semanticLabel: 'Book 5'),
  ShelfStripBar(
    color: Color(0xFFFFB4AB),
    width: 2,
    height: 0.85,
    semanticLabel: 'Book 6',
  ),
  ShelfStripBar(color: Color(0xFFADD0A7), width: 10, semanticLabel: 'Book 7'),
  ShelfStripBar(color: Color(0xFF373432), width: 4, semanticLabel: 'Book 8'),
  ShelfStripBar(color: Color(0xFFC9963F), width: 1, semanticLabel: 'Book 9'),
  ShelfStripBar(
    color: Color(0xFF19371A),
    width: 6,
    height: 0.96,
    semanticLabel: 'Book 10',
  ),
  ShelfStripBar(color: Color(0xFF9C8F7E), width: 7, semanticLabel: 'Book 11'),
  ShelfStripBar(color: Color(0xFF304E2E), width: 3, semanticLabel: 'Book 12'),
];
