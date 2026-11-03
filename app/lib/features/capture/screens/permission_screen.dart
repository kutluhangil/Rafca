import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../design/adaptive/adaptive_scaffold.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../state/capture_notifier.dart';

/// Camera permission prompt screen based on camera_permission mockup.
class CameraPermissionScreen extends ConsumerWidget {
  const CameraPermissionScreen({
    super.key,
    required this.onPermissionGranted,
    this.onDismiss,
  });

  final VoidCallback onPermissionGranted;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return AdaptiveScaffold(
      title: 'Rafça',
      largeTitle: false,
      leading: onDismiss != null
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: onDismiss,
            )
          : null,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: SpineSpacing.xxl),
              // Camera archivist icon container
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: semantic.brass,
                    width: SpineBorders.hairline,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 44,
                  color: semantic.brass,
                ),
              ),
              const SizedBox(height: SpineSpacing.xl),

              Text(
                'KAMERA ERİŞİMİ',
                style: SpineTypography.metadataCaps.copyWith(
                  color: semantic.brass,
                ),
              ),
              const SizedBox(height: SpineSpacing.sm),

              Text(
                'Kitap Sırtlarını Tara',
                style: SpineTypography.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpineSpacing.md),

              Text(
                'Fiziksel kütüphaneni dijitalleştirmek için raf fotoğrafı çekmen gerekir. '
                'Fotoğraflar cihazında kalır; eşleştirme için yalnızca okunan metin gönderilir.',
                style: SpineTypography.bodyMedium.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SpineSpacing.xxl),

              PrimaryButton(
                label: 'Kamerayı Etkinleştir',
                variant: SpineButtonVariant.primary,
                onPressed: () async {
                  final granted = await ref
                      .read(captureControllerProvider.notifier)
                      .requestPermission();
                  if (granted) {
                    onPermissionGranted();
                  }
                },
              ),
              if (onDismiss != null) ...[
                const SizedBox(height: SpineSpacing.md),
                PrimaryButton(
                  label: 'Şimdi Değil',
                  variant: SpineButtonVariant.secondary,
                  onPressed: onDismiss,
                ),
              ],
              const SizedBox(height: SpineSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
