import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/theme_mode_controller.dart';
import '../../../design/components/primary_button.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../library/data/library_repository.dart';
import '../services/export_service.dart';

/// State provider for cloud sync toggle.
final cloudSyncEnabledProvider = StateProvider<bool>((ref) => false);

/// Settings screen per SPINE_BLUEPRINT.md Faz 9.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({
    super.key,
    this.exportService = const ExportService(),
  });

  final ExportService exportService;

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isExporting = false;

  Future<void> _exportCsv() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final repo = ref.read(libraryRepositoryProvider);
      final books = await repo.getAllBooks();
      final csv = widget.exportService.generateCsv(books);
      await widget.exportService.shareExport(
        csv,
        filename: 'rafca_library.csv',
        mimeType: 'text/csv',
        subject: 'Rafça Library Export (CSV)',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportJson() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);

    try {
      final repo = ref.read(libraryRepositoryProvider);
      final books = await repo.getAllBooks();
      final json = widget.exportService.generateJson(books);
      await widget.exportService.shareExport(
        json,
        filename: 'rafca_library.json',
        mimeType: 'application/json',
        subject: 'Rafça Library Export (JSON)',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _showClearLibraryDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.clearLibraryConfirmTitle ?? 'Kütüphaneyi Sıfırla?'),
        content: Text(
          l10n?.clearLibraryConfirmMessage ??
              'Bu işlem tüm yerel verilerinizi kalıcı olarak silecektir. Bu işlem geri alınamaz!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'İPTAL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'SİL'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(libraryRepositoryProvider).clearAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.libraryCleared ?? 'Kütüphane temizlendi.')),
        );
      }
    }
  }

  void _showPrivacyDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.privacyStatement ?? 'Gizlilik Sözleşmesi'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n?.privacyContent ??
                    'Fotoğraflar ve sırt kırpımları yalnızca cihazınızda saklanır. Sunucuya yalnızca OCR ile okunan düz metin gönderilir — o da yalnızca eşleştirme için.',
                style: SpineTypography.bodyMedium,
              ),
              const SizedBox(height: SpineSpacing.md),
              Text(
                '• Kameralar yalnızca raf analizi anında kullanılır; video kaydı tutulmaz.\n'
                '• Ham görüntüler buluta aktarılmaz.\n'
                '• Eşleştirme servisi açık kaynaklı ve yerel önceliklidir.',
                style: SpineTypography.bodyMedium.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          PrimaryButton(
            label: l10n?.close ?? 'KAPAT',
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final semantic = context.spineColors;
    final themeMode = ref.watch(themeModeControllerProvider);
    final currentLocale = ref.watch(localeControllerProvider);
    final cloudSyncEnabled = ref.watch(cloudSyncEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.settingsTitle ?? 'Ayarlar',
          style: SpineTypography.headlineMedium,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: SpineSpacing.md, vertical: SpineSpacing.md),
        children: [
          // Section: Appearance
          _SectionHeader(title: l10n?.appearanceSection ?? 'Görünüm'),
          Card(
            margin: const EdgeInsets.only(bottom: SpineSpacing.lg),
            child: Padding(
              padding: const EdgeInsets.all(SpineSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.themeLabel ?? 'Tema',
                    style: SpineTypography.metadataCaps,
                  ),
                  const SizedBox(height: SpineSpacing.sm),
                  SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n?.themeDark ?? 'Koyu'),
                        icon: const Icon(Icons.dark_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n?.themeLight ?? 'Açık'),
                        icon: const Icon(Icons.light_mode_outlined),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n?.themeSystem ?? 'Sistem'),
                        icon: const Icon(Icons.brightness_auto_outlined),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selected) {
                      ref.read(themeModeControllerProvider.notifier).set(selected.first);
                    },
                  ),
                ],
              ),
            ),
          ),

          // Section: Language
          _SectionHeader(title: l10n?.languageSection ?? 'Dil / Language'),
          Card(
            margin: const EdgeInsets.only(bottom: SpineSpacing.lg),
            child: Padding(
              padding: const EdgeInsets.all(SpineSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.languageLabel ?? 'Uygulama Dili',
                    style: SpineTypography.metadataCaps,
                  ),
                  const SizedBox(height: SpineSpacing.sm),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'tr',
                        label: Text(l10n?.langTurkish ?? 'Türkçe'),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n?.langEnglish ?? 'English'),
                      ),
                      ButtonSegment(
                        value: 'system',
                        label: Text(l10n?.langSystem ?? 'Sistem'),
                      ),
                    ],
                    selected: {
                      if (currentLocale == null)
                        'system'
                      else if (currentLocale.languageCode == 'tr')
                        'tr'
                      else
                        'en'
                    },
                    onSelectionChanged: (selected) {
                      final val = selected.first;
                      if (val == 'system') {
                        ref.read(localeControllerProvider.notifier).setLanguage(RafcaLanguage.system);
                      } else if (val == 'tr') {
                        ref.read(localeControllerProvider.notifier).setLanguage(RafcaLanguage.turkish);
                      } else {
                        ref.read(localeControllerProvider.notifier).setLanguage(RafcaLanguage.english);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          // Section: Cloud Sync
          _SectionHeader(title: l10n?.syncSection ?? 'Bulut ve Yedekleme'),
          Card(
            margin: const EdgeInsets.only(bottom: SpineSpacing.lg),
            child: SwitchListTile(
              title: Text(
                l10n?.cloudSync ?? 'Bulut Senkronizasyonu',
                style: SpineTypography.bodyLarge,
              ),
              subtitle: Text(
                l10n?.cloudSyncSubtitle ?? 'Değişiklikleri şifreli Supabase bulutuna yedekle',
                style: SpineTypography.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              value: cloudSyncEnabled,
              activeThumbColor: semantic.brass,
              onChanged: (val) {
                ref.read(cloudSyncEnabledProvider.notifier).state = val;
              },
            ),
          ),

          // Section: Data Management
          _SectionHeader(title: l10n?.dataSection ?? 'Veri Yönetimi'),
          Card(
            margin: const EdgeInsets.only(bottom: SpineSpacing.lg),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.table_chart_outlined, color: semantic.brass),
                  title: Text(l10n?.exportCsv ?? 'CSV Olarak Dışa Aktar'),
                  subtitle: Text(l10n?.exportCsvSubtitle ?? 'Elektronik tablo formatında indir'),
                  trailing: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportCsv,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.code_rounded, color: semantic.brass),
                  title: Text(l10n?.exportJson ?? 'JSON Olarak Dışa Aktar'),
                  subtitle: Text(l10n?.exportJsonSubtitle ?? 'Tam veri dökümü'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _isExporting ? null : _exportJson,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
                  title: Text(
                    l10n?.clearLibrary ?? 'Kütüphaneyi Sıfırla',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  subtitle: Text(l10n?.clearLibrarySubtitle ?? 'Tüm verileri sil'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showClearLibraryDialog,
                ),
              ],
            ),
          ),

          // Section: About & Privacy
          _SectionHeader(title: l10n?.aboutSection ?? 'Hakkında & Gizlilik'),
          Card(
            margin: const EdgeInsets.only(bottom: SpineSpacing.xxl),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.security_outlined, color: semantic.brass),
                  title: Text(l10n?.privacyStatement ?? 'Gizlilik Sözleşmesi'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showPrivacyDialog,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.auto_stories_outlined, color: semantic.brass),
                  title: const Text('Rafça'),
                  subtitle: Text(l10n?.nocturnalArchivist ?? 'Nocturnal Archivist Tasarım Sistemi'),
                  trailing: Text(
                    'v1.0.0',
                    style: SpineTypography.metadataCaps,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: SpineSpacing.xs, bottom: SpineSpacing.xs),
      child: Text(
        uppercaseForLocale(title, Localizations.maybeLocaleOf(context)),
        style: SpineTypography.metadataCaps.copyWith(
          color: context.spineColors.brass,
          fontSize: 11,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
