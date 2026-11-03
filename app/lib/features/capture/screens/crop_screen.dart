import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/router/app_router.dart';
import '../../../design/adaptive/adaptive_scaffold.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../preprocessing/preprocessor.dart';
import '../widgets/quad_clipper.dart';

/// Shelf boundary quad selection & perspective warp screen (SPINE_BLUEPRINT.md 7.2).
class CropScreen extends ConsumerStatefulWidget {
  const CropScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<CropScreen> createState() => _CropScreenState();
}

class _CropScreenState extends ConsumerState<CropScreen> {
  QuadPoints? _quad;
  Size? _imagePixelSize;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadImageDimensions();
  }

  Future<void> _loadImageDimensions() async {
    final file = File(widget.imagePath);
    if (!file.existsSync()) return;

    final bytes = await file.readAsBytes();
    final decoded = await compute(img.decodeImage, bytes);
    if (decoded != null && mounted) {
      setState(() {
        _imagePixelSize = Size(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
      });
    }
  }

  Future<void> _confirmCrop(Size viewportSize) async {
    if (_quad == null || _imagePixelSize == null) return;
    setState(() => _isProcessing = true);

    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final decoded = await compute(img.decodeImage, bytes);
      if (decoded == null) throw StateError('Görüntü çözülemedi');

      // Map viewport coordinates back to source image pixels
      final scaleX = _imagePixelSize!.width / viewportSize.width;
      final scaleY = _imagePixelSize!.height / viewportSize.height;

      final mappedCorners = [
        math.Point<double>(_quad!.topLeft.dx * scaleX, _quad!.topLeft.dy * scaleY),
        math.Point<double>(_quad!.topRight.dx * scaleX, _quad!.topRight.dy * scaleY),
        math.Point<double>(_quad!.bottomRight.dx * scaleX, _quad!.bottomRight.dy * scaleY),
        math.Point<double>(_quad!.bottomLeft.dx * scaleX, _quad!.bottomLeft.dy * scaleY),
      ];

      const preprocessor = CapturePreprocessor();
      var warped = preprocessor.warpPerspective(decoded, mappedCorners);
      warped = preprocessor.capMaxDimension(warped, maxSide: 4000);

      // Save cropped result to temp file
      final tempDir = await getTemporaryDirectory();
      final warpedPath = p.join(
        tempDir.path,
        'warped_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(warpedPath).writeAsBytes(img.encodeJpg(warped, quality: 92));

      if (!mounted) return;

      // Navigate to processing screen
      unawaited(
        context.push(
          '${Routes.captureProcessing}?imagePath=${Uri.encodeComponent(warpedPath)}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kırpma hatası: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      title: l10n?.adjustCrop ?? 'Rafı Sınırla',
      largeTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final viewportSize = Size(constraints.maxWidth, constraints.maxHeight - 120);

          // Initialise default quad if not yet set (inset by 10% from margins)
          _quad ??= QuadPoints(
            topLeft: Offset(viewportSize.width * 0.08, viewportSize.height * 0.15),
            topRight: Offset(viewportSize.width * 0.92, viewportSize.height * 0.15),
            bottomRight: Offset(viewportSize.width * 0.92, viewportSize.height * 0.85),
            bottomLeft: Offset(viewportSize.width * 0.08, viewportSize.height * 0.85),
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: SpineSpacing.sm),
                child: Text(
                  (l10n?.dragCorners ?? 'KÖŞELERİ SÜRÜKLEYEREK RAFI BELİRLEYİN').toUpperCase(),
                  style: SpineTypography.metadataCaps.copyWith(
                    color: semantic.brass,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Stack(
                    children: [
                      // Source Image preview
                      SizedBox(
                        width: viewportSize.width,
                        height: viewportSize.height,
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.fill,
                        ),
                      ),
                      // Interactive 4-corner Quad Editor
                      QuadEditor(
                        size: viewportSize,
                        initialQuad: _quad!,
                        onChanged: (newQuad) {
                          _quad = newQuad;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SpineSpacing.base),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: l10n?.retry ?? 'Yeniden Çek',
                      variant: SpineButtonVariant.secondary,
                      onPressed: _isProcessing ? null : () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: SpineSpacing.base),
                  Expanded(
                    child: PrimaryButton(
                      label: _isProcessing
                          ? (l10n?.processing ?? 'İşleniyor...')
                          : (l10n?.scanButton ?? 'Kırp ve Tara'),
                      variant: SpineButtonVariant.primary,
                      onPressed: _isProcessing
                          ? null
                          : () => _confirmCrop(viewportSize),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpineSpacing.base),
            ],
          );
        },
      ),
    );
  }
}
