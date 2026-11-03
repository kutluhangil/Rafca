import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:spine_clustering/spine_clustering.dart';

import '../../../core/database/tables.dart';
import '../../../core/router/app_router.dart';
import '../../../design/adaptive/adaptive_scaffold.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../review/models/review_models.dart';
import '../scan/scan_controller.dart';
import '../widgets/spine_overlay.dart';

/// Processing / Scanning screen per SPINE_BLUEPRINT.md 4.7 and FAZ 6.
///
/// Runs OCR across 4 rotations, clusters spines, animates rectangles and logs progress.
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  final ScanController _scanController = ScanController();

  double _progress = 0.0;
  final List<String> _logs = ['TARAMA BAŞLATILIYOR...'];
  List<SpineCandidate> _detectedCandidates = const [];
  ScanResult? _scanResult;
  bool _isDone = false;
  String? _errorMessage;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _loadImageSize();
    _startScan();
  }

  Future<void> _loadImageSize() async {
    final file = File(widget.imagePath);
    if (!file.existsSync()) return;
    final bytes = await file.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded != null && mounted) {
      setState(() {
        _imageSize = Size(decoded.width.toDouble(), decoded.height.toDouble());
      });
    }
  }

  Future<void> _startScan() async {
    try {
      final result = await _scanController.runScan(
        imagePath: widget.imagePath,
        onProgress: (progress, log, {detectedSoFar}) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _logs.add(log);
            if (_logs.length > 5) {
              _logs.removeRange(0, _logs.length - 5);
            }
            if (detectedSoFar != null) {
              _detectedCandidates = detectedSoFar;
            }
          });
        },
      );

      if (mounted) {
        setState(() {
          _progress = 1.0;
          _isDone = true;
          _scanResult = result;
          _detectedCandidates = result.candidates;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  ReviewBatch _createReviewBatch(ScanResult result) {
    final scanId = 'scan_${DateTime.now().millisecondsSinceEpoch}';
    final items = <ReviewItem>[];

    for (final candidate in result.candidates) {
      final cropPath = result.cropPaths[candidate.id] ?? '';
      final spineColor = result.dominantColors[candidate.id] ?? '#12100E';
      final rawText = candidate.rawTextForward.trim();
      final lines = rawText
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      if (lines.isEmpty) {
        items.add(
          ReviewItem(
            id: candidate.id,
            cropPath: cropPath,
            spineColor: spineColor,
            rawText: '',
            confidence: MatchConfidence.unknown,
            confidenceScore: 0.1,
          ),
        );
      } else {
        final title = lines.first;
        final author = lines.length > 1 ? lines[1] : 'Bilinmeyen Yazar';
        double avgConfidence = 0.85;
        final confs = candidate.elements
            .map((e) => e.confidence)
            .whereType<double>()
            .toList();
        if (confs.isNotEmpty) {
          avgConfidence = confs.reduce((a, b) => a + b) / confs.length;
        }
        final confidenceScore = avgConfidence.clamp(0.0, 1.0);
        final isMatched = confidenceScore >= 0.80;

        final book = ReviewCandidateBook(
          id: candidate.id.hashCode.abs(),
          title: title,
          author: author,
          score: confidenceScore,
        );

        items.add(
          ReviewItem(
            id: candidate.id,
            cropPath: cropPath,
            spineColor: spineColor,
            rawText: rawText,
            confidence:
                isMatched ? MatchConfidence.matched : MatchConfidence.review,
            confidenceScore: confidenceScore,
            selectedBook: isMatched ? book : null,
            alternatives: isMatched ? const [] : [book],
          ),
        );
      }
    }

    return ReviewBatch(
      scanId: scanId,
      sourceImagePath: widget.imagePath,
      items: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return AdaptiveScaffold(
      title: l10n?.processingTitle ?? 'İşleniyor',
      largeTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => context.pop(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final previewHeight = constraints.maxHeight * 0.45;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: SpineSpacing.sm),

              // 1. Hero Image Frame with Animated Spine Overlays
              SizedBox(
                height: previewHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(SpineRadius.card),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'capturedFrame_${widget.imagePath}',
                        child: Image.file(
                          File(widget.imagePath),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (_detectedCandidates.isNotEmpty && _imageSize != null)
                        LayoutBuilder(
                          builder: (context, innerConstraints) {
                            return SpineOverlay(
                              candidates: _detectedCandidates,
                              originalImageSize: _imageSize!,
                              viewportSize: Size(
                                innerConstraints.maxWidth,
                                innerConstraints.maxHeight,
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: SpineSpacing.lg),

              // 2. Progress Percentage & Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isDone
                        ? (l10n?.processingComplete ?? 'ANALİZ TAMAMLANDI').toUpperCase()
                        : (l10n?.processing ?? 'TARAMA DEVAM EDİYOR').toUpperCase(),
                    style: SpineTypography.metadataCaps.copyWith(
                      color: semantic.brass,
                    ),
                  ),
                  Text(
                    '% ${(_progress * 100).round()}',
                    style: SpineTypography.metadataCaps.copyWith(
                      color: semantic.brass,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SpineSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(SpineRadius.chip),
                child: LinearProgressIndicator(
                  value: _progress,
                  backgroundColor: scheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(semantic.brass),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: SpineSpacing.lg),

              // 3. Monospace Archival Log Terminal
              Container(
                padding: const EdgeInsets.all(SpineSpacing.base),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(SpineRadius.card),
                  border: Border.all(
                    color: semantic.hairline,
                    width: SpineBorders.hairline,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İŞLEM GÜNLÜĞÜ / ARCHIVAL LOG',
                      style: SpineTypography.metadataCaps.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const Divider(height: SpineSpacing.base),
                    if (_errorMessage != null)
                      Text(
                        'HATA: $_errorMessage',
                        style: SpineTypography.metadataCaps.copyWith(
                          color: semantic.unknown,
                        ),
                      )
                    else
                      for (final line in _logs)
                        Padding(
                          padding: const EdgeInsets.only(bottom: SpineSpacing.xs),
                          child: Row(
                            children: [
                              Text(
                                '> ',
                                style: SpineTypography.metadataCaps.copyWith(
                                  color: semantic.brass,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  line,
                                  style: SpineTypography.metadataCaps.copyWith(
                                    color: scheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                  ],
                ),
              ),

              const Spacer(),

              // 4. Bottom action
              if (_isDone) ...[
                Text(
                  l10n?.bookCount(_detectedCandidates.length).toUpperCase() ??
                      '${_detectedCandidates.length} KİTAP SIRTI BULUNDU',
                  style: SpineTypography.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: SpineSpacing.md),
                PrimaryButton(
                  label: l10n?.scanResultsTitle ?? 'Sonuçları Görüntüle',
                  variant: SpineButtonVariant.primary,
                  onPressed: () {
                    if (_scanResult != null) {
                      final batch = _createReviewBatch(_scanResult!);
                      context.pushReplacement(Routes.reviewResults, extra: batch);
                    } else {
                      context.pop();
                    }
                  },
                ),
              ] else if (_errorMessage != null) ...[
                PrimaryButton(
                  label: 'Yeniden Dene',
                  variant: SpineButtonVariant.secondary,
                  onPressed: () {
                    setState(() {
                      _errorMessage = null;
                      _progress = 0.0;
                    });
                    _startScan();
                  },
                ),
              ],
              const SizedBox(height: SpineSpacing.base),
            ],
          );
        },
      ),
    );
  }
}
