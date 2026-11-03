import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design/adaptive/adaptive_sheet.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../models/share_models.dart';
import '../services/share_service.dart';
import 'share_card.dart';

/// Modal bottom sheet for sharing a collection card per Image 13.
class ShareBottomSheet extends StatefulWidget {
  const ShareBottomSheet({
    super.key,
    required this.data,
    this.shareService = const ShareService(),
  });

  final ShareCollectionData data;
  final ShareService shareService;

  static Future<void> show(
    BuildContext context, {
    required ShareCollectionData data,
    ShareService shareService = const ShareService(),
  }) {
    return showAdaptiveSheet<void>(
      context: context,
      builder: (ctx) => ShareBottomSheet(
        data: data,
        shareService: shareService,
      ),
    );
  }

  @override
  State<ShareBottomSheet> createState() => _ShareBottomSheetState();
}

class _ShareBottomSheetState extends State<ShareBottomSheet> {
  final _boundaryKey = GlobalKey();
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
          text: l10n?.shareTextSummary(widget.data.bookCount) ??
              'Rafça: ${widget.data.bookCount} kitap',
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareText() async {
    final l10n = AppLocalizations.of(context);
    final summary = l10n?.shareTextSummary(widget.data.bookCount) ??
        'Rafça Kütüphanem: ${widget.data.bookCount} kitap';
    await widget.shareService.shareText('$summary\n#Rafça #NocturnalArchivist');
  }

  Future<void> _copyText() async {
    final l10n = AppLocalizations.of(context);
    final summary = l10n?.shareTextSummary(widget.data.bookCount) ??
        'Rafça Kütüphanem: ${widget.data.bookCount} kitap';
    await Clipboard.setData(ClipboardData(text: summary));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.success ?? 'Kopyalandı'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: SpineSpacing.md),
          // Share card visual inside repaint boundary
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: RepaintBoundary(
                key: _boundaryKey,
                child: ShareCard(data: widget.data),
              ),
            ),
          ),
          const SizedBox(height: SpineSpacing.xl),

          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ShareActionItem(
                icon: Icons.share_rounded,
                label: l10n?.shareStory ?? 'Paylaş',
                isLoading: _isExporting,
                onTap: _shareImage,
              ),
              _ShareActionItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: l10n?.shareMessage ?? 'Metin',
                onTap: _shareText,
              ),
              _ShareActionItem(
                icon: Icons.link_rounded,
                label: l10n?.shareLink ?? 'Kopyala',
                onTap: _copyText,
              ),
            ],
          ),
          const SizedBox(height: SpineSpacing.lg),

          // Main Export Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SpineSpacing.lg),
            child: PrimaryButton(
              label: _isExporting
                  ? (l10n?.processing ?? 'İşleniyor...')
                  : (l10n?.saveImage ?? 'GÖRSELİ PAYLAŞ'),
              onPressed: _isExporting ? null : _shareImage,
            ),
          ),
          const SizedBox(height: SpineSpacing.lg),
        ],
      ),
    );
  }
}

class _ShareActionItem extends StatelessWidget {
  const _ShareActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.spineColors;

    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(SpineSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: semantic.hairline,
                  width: 1,
                ),
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : Icon(icon, color: semantic.brass, size: 22),
            ),
            const SizedBox(height: SpineSpacing.xs),
            Text(
              label,
              style: SpineTypography.labelMono.copyWith(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
