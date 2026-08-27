import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/theme_mode_controller.dart';
import '../../design/adaptive/adaptive_scaffold.dart';
import '../../design/components/primary_button.dart';
import '../../design/tokens/colors.dart';
import '../../design/tokens/spacing.dart';
import '../../design/tokens/typography.dart';

/// Faz 1 placeholder. Proves the theme engine, the router and the adaptive
/// shell are wired; the real home is the library screen built in Faz 8.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeControllerProvider);
    final scheme = Theme.of(context).colorScheme;
    final semantic = context.spineColors;

    return AdaptiveScaffold(
      title: 'Rafça',
      actions: [
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THEME: ${mode.name.toUpperCase()}',
            style: SpineTypography.metadataCaps.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpineSpacing.base),
          Text('Nocturnal Archivist', style: SpineTypography.headlineSmall),
          const SizedBox(height: SpineSpacing.sm),
          Text(
            'Faz 1 iskeleti. Tema motoru, yönlendirme ve adaptive kabuk bağlı.',
            style: SpineTypography.bodyMedium.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SpineSpacing.lg),
          Row(
            children: [
              _SwatchDot(color: semantic.matched, label: 'MATCHED'),
              const SizedBox(width: SpineSpacing.md),
              _SwatchDot(color: semantic.review, label: 'REVIEW'),
              const SizedBox(width: SpineSpacing.md),
              _SwatchDot(color: semantic.unknown, label: 'UNKNOWN'),
            ],
          ),
          const SizedBox(height: SpineSpacing.lg),
          PrimaryButton(
            label: 'Design gallery',
            variant: SpineButtonVariant.secondary,
            expand: false,
            onPressed: () => context.push(Routes.gallery),
          ),
          const SizedBox(height: SpineSpacing.xxl),
        ],
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: SpineBorders.confidenceBar, height: 16, color: color),
        const SizedBox(width: SpineSpacing.sm),
        Text(label, style: SpineTypography.metadataCaps.copyWith(color: color)),
      ],
    );
  }
}
