import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../../design/components/confidence_badge.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../models/review_models.dart';

/// Bottom sheet allowing user to review multiple candidate editions or manually fix a spine.
///
/// Implements SPINE_BLUEPRINT.md 9 (FAZ 7) & review_correct_spine mockup.
class ReviewBottomSheet extends StatelessWidget {
  const ReviewBottomSheet({
    super.key,
    required this.item,
    required this.onSelectAlternative,
    required this.onSearchManually,
    required this.onDiscard,
  });

  final ReviewItem item;
  final ValueChanged<ReviewCandidateBook> onSelectAlternative;
  final VoidCallback onSearchManually;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: semantic.surfaceRaised,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SpineRadius.sheet),
        ),
        border: Border(
          top: BorderSide(
            color: semantic.topEdgeGlow,
            width: SpineBorders.hairline,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: SpineSpacing.pageMargin),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Drag Handle
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: SpineSpacing.sm),
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(SpineRadius.chip),
                  ),
                ),
              ),

              // 2. Header and Confidence Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.confidence == MatchConfidence.review
                              ? 'Eseri İncele'
                              : 'Bilinmeyen Sırt',
                          style: SpineTypography.headlineSmall,
                        ),
                        const SizedBox(height: SpineSpacing.xs),
                        Text(
                          item.confidence == MatchConfidence.review
                              ? 'Bu sırt için birden fazla olası baskı bulundu.'
                              : 'Katalogda doğrudan eşleşme bulunamadı.',
                          style: SpineTypography.bodySmall.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ConfidenceBadge(
                    level: switch (item.confidence) {
                      MatchConfidence.matched => ConfidenceLevel.matched,
                      MatchConfidence.review => ConfidenceLevel.review,
                      MatchConfidence.unknown => ConfidenceLevel.unknown,
                    },
                    label: item.confidence.name,
                  ),
                ],
              ),
              const SizedBox(height: SpineSpacing.base),

              // 3. Captured Spine Segment Preview with Corner Brackets
              Stack(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(SpineRadius.card),
                      border: Border.all(
                        color: semantic.hairline,
                        width: SpineBorders.hairline,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: File(item.cropPath).existsSync()
                        ? Image.file(
                            File(item.cropPath),
                            fit: BoxFit.contain,
                          )
                        : Center(
                            child: Text(
                              item.rawText.isEmpty ? 'SIRT GÖRSELİ' : item.rawText,
                              style: SpineTypography.labelMono,
                            ),
                          ),
                  ),
                  // Corner brackets
                  Positioned(
                    top: 6,
                    left: 6,
                    child: _Bracket(corner: _Corner.topLeft, color: semantic.brass),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: _Bracket(corner: _Corner.topRight, color: semantic.brass),
                  ),
                  Positioned(
                    bottom: 6,
                    left: 6,
                    child: _Bracket(corner: _Corner.bottomLeft, color: semantic.brass),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 6,
                    child: _Bracket(corner: _Corner.bottomRight, color: semantic.brass),
                  ),
                ],
              ),

              const SizedBox(height: SpineSpacing.lg),

              // 4. Candidate List
              Text(
                'DOĞRU BASKIYI SEÇİN',
                style: SpineTypography.metadataCaps.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: SpineSpacing.sm),

              if (item.alternatives.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: SpineSpacing.md),
                  child: Text(
                    'Öneri bulunamadı. Lütfen manuel arayın.',
                    style: SpineTypography.bodyMedium.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...item.alternatives.map((alt) => _CandidateCard(
                      candidate: alt,
                      onTap: () {
                        onSelectAlternative(alt);
                        Navigator.of(context).pop();
                      },
                    )),

              const SizedBox(height: SpineSpacing.base),
              const Divider(),
              const SizedBox(height: SpineSpacing.sm),

              // 5. Secondary Actions
              PrimaryButton(
                label: 'Manuel Ara',
                variant: SpineButtonVariant.secondary,
                onPressed: () {
                  Navigator.of(context).pop();
                  onSearchManually();
                },
              ),
              const SizedBox(height: SpineSpacing.sm),

              TextButton(
                onPressed: () {
                  onDiscard();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Kitap Değil / Not a book',
                  style: SpineTypography.bodySmall.copyWith(
                    color: scheme.error,
                  ),
                ),
              ),
              const SizedBox(height: SpineSpacing.base),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Corner { topLeft, topRight, bottomLeft, bottomRight }

class _Bracket extends StatelessWidget {
  const _Bracket({required this.corner, required this.color});

  final _Corner corner;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const size = 12.0;
    const thickness = 2.0;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _BracketPainter(corner: corner, color: color, thickness: thickness),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  _BracketPainter({
    required this.corner,
    required this.color,
    required this.thickness,
  });

  final _Corner corner;
  final Color color;
  final double thickness;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke;

    final path = Path();
    switch (corner) {
      case _Corner.topLeft:
        path.moveTo(0, size.height);
        path.lineTo(0, 0);
        path.lineTo(size.width, 0);
        break;
      case _Corner.topRight:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomLeft:
        path.moveTo(0, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        break;
      case _Corner.bottomRight:
        path.moveTo(0, size.height);
        path.lineTo(size.width, size.height);
        path.lineTo(size.width, 0);
        break;
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) => false;
}

class _CandidateCard extends StatelessWidget {
  const _CandidateCard({
    required this.candidate,
    required this.onTap,
  });

  final ReviewCandidateBook candidate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: SpineSpacing.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpineRadius.card),
        child: Container(
          padding: const EdgeInsets.all(SpineSpacing.md),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SpineRadius.card),
            border: Border.all(
              color: semantic.hairline,
              width: SpineBorders.hairline,
            ),
          ),
          child: Row(
            children: [
              // Cover thumbnail placeholder or image
              Container(
                width: 44,
                height: 64,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(SpineRadius.thumbnail),
                  border: Border.all(
                    color: semantic.hairline,
                    width: SpineBorders.hairline,
                  ),
                ),
                child: candidate.coverUrl != null
                    ? Image.network(
                        candidate.coverUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.book_outlined,
                          size: 20,
                        ),
                      )
                    : const Icon(
                        Icons.book_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: SpineSpacing.md),

              // Metadata
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      candidate.title,
                      style: SpineTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpineSpacing.xs),
                    Text(
                      candidate.author,
                      style: SpineTypography.bodySmall.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: SpineSpacing.xs),
                    Row(
                      children: [
                        if (candidate.publishYear != null)
                          Text(
                            '${candidate.publishYear}',
                            style: SpineTypography.labelMono.copyWith(
                              color: scheme.outline,
                            ),
                          ),
                        if (candidate.publishYear != null &&
                            candidate.publisher != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '•',
                              style: SpineTypography.labelMono.copyWith(
                                color: scheme.outline,
                              ),
                            ),
                          ),
                        if (candidate.publisher != null)
                          Expanded(
                            child: Text(
                              candidate.publisher!,
                              style: SpineTypography.labelMono.copyWith(
                                color: scheme.outline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right,
                color: semantic.brass,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
