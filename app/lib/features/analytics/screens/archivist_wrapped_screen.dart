import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design/adaptive/adaptive_sheet.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../share/services/share_service.dart';
import '../models/analytics_models.dart';
import '../widgets/wrapped_card.dart';

/// Modal bottom sheet for viewing and sharing the Archivist Wrapped summary.
class ArchivistWrappedBottomSheet extends StatefulWidget {
  const ArchivistWrappedBottomSheet({
    super.key,
    required this.analytics,
    this.shareService = const ShareService(),
  });

  final CollectionAnalytics analytics;
  final ShareService shareService;

  static Future<void> show(
    BuildContext context, {
    required CollectionAnalytics analytics,
    ShareService shareService = const ShareService(),
  }) {
    return showAdaptiveSheet<void>(
      context: context,
      builder: (ctx) => ArchivistWrappedBottomSheet(
        analytics: analytics,
        shareService: shareService,
      ),
    );
  }

  @override
  State<ArchivistWrappedBottomSheet> createState() => _ArchivistWrappedBottomSheetState();
}

class _ArchivistWrappedBottomSheetState extends State<ArchivistWrappedBottomSheet> {
  final _boundaryKey = GlobalKey();
  WrappedCardFormat _format = WrappedCardFormat.story;
  bool _isExporting = false;

  Future<void> _shareImage() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final bytes = await widget.shareService.capturePng(_boundaryKey);
      if (bytes != null && mounted) {
        final l10n = AppLocalizations.of(context);
        await widget.shareService.shareImage(
          bytes,
          text: _buildSummaryText(l10n),
          subject: l10n?.archivistWrappedTitle ?? 'Rafça Arşiv Özeti',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareText() async {
    final l10n = AppLocalizations.of(context);
    final summary = _buildSummaryText(l10n);
    await widget.shareService.shareText(summary);
  }

  Future<void> _copyText() async {
    final l10n = AppLocalizations.of(context);
    final summary = _buildSummaryText(l10n);
    await Clipboard.setData(ClipboardData(text: summary));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.success ?? 'Metin panoya kopyalandı.'),
          backgroundColor: SpineColors.darkMatched,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _buildSummaryText(AppLocalizations? l10n) {
    final a = widget.analytics;
    final lines = [
      '📚 Rafça Kütüphane Özeti',
      '• ${a.totalBooks} Cilt Arşiv',
      '• ${a.estimatedShelfMeters} Metre Fiziksel Raf Genişliği',
      '• Karakter: ${a.dominantColor.defaultLabel} (%${a.colorSpectrum.isNotEmpty ? a.colorSpectrum.first.percentage.toStringAsFixed(0) : "100"})',
      if (a.topAuthor != null) '• Baş Yazar: ${a.topAuthor} (${a.topAuthorCount} Cilt)',
      if (a.topPublisher != null) '• Baş Yayınevi: ${a.topPublisher} (${a.topPublisherCount} Cilt)',
      if (a.earliestPublishYear != null)
        '• En Eski Eser: ${a.earliestBookTitle} (${a.earliestPublishYear})',
      '• Okuma Oranı: %${a.readingProgress.readRatio.toStringAsFixed(0)} Okundu',
      if (a.activeLoansCount > 0) '• Ödünç Verilen: ${a.activeLoansCount} Kitap',
      '',
      'Kişisel Kitaplık Arşiviniz · https://rafca.app',
      '#Rafça #NocturnalArchivist #ArchivistWrapped',
    ];
    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final semantic = context.spineColors;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SpineSpacing.pageMargin,
          vertical: SpineSpacing.base,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: SpineSpacing.md),
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title & Format Toggle Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  uppercaseForLocale(
                    l10n?.archivistWrappedTitle ?? 'Arşiv Özeti',
                    Localizations.maybeLocaleOf(context),
                  ),
                  style: SpineTypography.metadataCaps.copyWith(
                    color: semantic.brass,
                    fontSize: 13,
                    letterSpacing: 2.0,
                  ),
                ),
                // Story / Square toggle
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(SpineRadius.chip),
                    border: Border.all(
                      color: semantic.hairline,
                      width: SpineBorders.hairline,
                    ),
                  ),
                  child: Row(
                    children: [
                      _FormatChip(
                        label: '9:16',
                        icon: Icons.smartphone,
                        isSelected: _format == WrappedCardFormat.story,
                        onTap: () => setState(() => _format = WrappedCardFormat.story),
                      ),
                      _FormatChip(
                        label: '1:1',
                        icon: Icons.crop_square,
                        isSelected: _format == WrappedCardFormat.square,
                        onTap: () => setState(() => _format = WrappedCardFormat.square),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpineSpacing.lg),

            // Card preview inside RepaintBoundary
            Center(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: WrappedCard(
                    analytics: widget.analytics,
                    format: _format,
                  ),
                ),
              ),
            ),
            const SizedBox(height: SpineSpacing.xl),

            // Action Buttons
            PrimaryButton(
              label: _isExporting
                  ? (l10n?.exporting ?? 'DIŞA AKTARILIYOR...')
                  : (l10n?.shareImage ?? 'GÖRSELİ PAYLAŞ'),
              variant: SpineButtonVariant.primary,
              icon: Icons.share_outlined,
              onPressed: _isExporting ? null : _shareImage,
            ),
            const SizedBox(height: SpineSpacing.sm),

            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: l10n?.shareText ?? 'METİN PAYLAŞ',
                    variant: SpineButtonVariant.secondary,
                    icon: Icons.text_snippet_outlined,
                    onPressed: _shareText,
                  ),
                ),
                const SizedBox(width: SpineSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: l10n?.copyText ?? 'METNİ KOPYALA',
                    variant: SpineButtonVariant.secondary,
                    icon: Icons.copy_outlined,
                    onPressed: _copyText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: SpineSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final semantic = context.spineColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SpineRadius.chip),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? semantic.brass.withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(SpineRadius.chip),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: isSelected ? semantic.brass : Colors.white60,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: SpineTypography.labelMono.copyWith(
                  color: isSelected ? semantic.brass : Colors.white60,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
