import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../core/router/app_router.dart';
import '../../../design/adaptive/adaptive_scaffold.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../l10n/app_localizations.dart';
import '../../library/data/library_repository.dart';
import '../../review/models/review_models.dart';
import '../barcode/barcode_engine.dart';
import '../barcode/barcode_lookup_service.dart';
import '../barcode/isbn_validator.dart';
import '../state/capture_notifier.dart';
import '../state/capture_state.dart';
import '../widgets/level_indicator.dart';
import '../widgets/shutter_button.dart';
import 'permission_screen.dart';

/// Camera modes: Shelf spine scanning (default) or ISBN barcode fallback.
enum CameraCaptureMode {
  spine,
  barcode,
}

/// Live camera view with spirit leveling, alignment guidelines, barcode scanner, and capture gating.
///
/// Implements SPINE_BLUEPRINT.md 7.1 and FAZ 6 & FAZ 13.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({
    super.key,
    this.initialMode = CameraCaptureMode.spine,
  });

  final CameraCaptureMode initialMode;

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  BarcodeEngine? _barcodeEngine;
  late CameraCaptureMode _captureMode;
  bool _isInit = false;
  bool _isPermissionChecked = false;
  bool _hasPermission = false;
  bool _isProcessingBarcode = false;
  String? _initError;

  // Stability tracker over 300ms window
  final List<({DateTime time, double mag})> _recentAccels = [];

  @override
  void initState() {
    super.initState();
    _captureMode = widget.initialMode;
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInit();
  }

  Future<void> _checkPermissionAndInit() async {
    if (kIsWeb) {
      setState(() {
        _isPermissionChecked = true;
        _hasPermission = false;
        _initError = 'Kamera web ortamında desteklenmemektedir (cihaz gerekir).';
      });
      return;
    }

    final granted =
        await ref.read(captureControllerProvider.notifier).checkPermission();

    setState(() {
      _isPermissionChecked = true;
      _hasPermission = granted;
    });

    if (granted) {
      await _initCamera();
      _startSensors();
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _initError = 'Kullanılabilir kamera bulunamadı.');
        return;
      }

      // Prefer back camera
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        camera,
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }

      // Flash off by default (blueprint 7.1)
      await controller.setFlashMode(FlashMode.off);

      setState(() {
        _cameraController = controller;
        _isInit = true;
      });
    } catch (e) {
      setState(() => _initError = 'Kamera başlatılamadı: $e');
    }
  }

  void _startSensors() {
    _accelSub = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      final mag = math.sqrt(
        event.x * event.x + event.y * event.y + event.z * event.z,
      );

      _recentAccels.add((time: now, mag: mag));
      _recentAccels.removeWhere(
        (e) => now.difference(e.time).inMilliseconds > 300,
      );

      var isStable = true;
      if (_recentAccels.length >= 3) {
        final mean =
            _recentAccels.map((e) => e.mag).reduce((a, b) => a + b) /
            _recentAccels.length;
        final variance =
            _recentAccels
                .map((e) => math.pow(e.mag - mean, 2))
                .reduce((a, b) => a + b) /
            _recentAccels.length;
        // Blueprint 7.1: acceleration variance threshold
        if (variance > 1.2) {
          isStable = false;
        }
      }

      // Roll and pitch in degrees
      final roll = math.atan2(event.y, event.z) * 180.0 / math.pi;
      final pitch =
          math.atan2(
            -event.x,
            math.sqrt(event.y * event.y + event.z * event.z),
          ) *
          180.0 /
          math.pi;

      ref.read(captureControllerProvider.notifier).updateSensors(
        rollDegrees: roll,
        pitchDegrees: pitch,
        isStable: isStable,
      );
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
      setState(() => _isInit = false);
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _accelSub?.cancel();
    _barcodeEngine?.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final xFile = await controller.takePicture();
      if (!mounted) return;

      ref.read(captureControllerProvider.notifier).setPhotoCaptured(xFile.path);

      // Navigate to crop screen
      unawaited(
        context.push(
          '${Routes.captureCrop}?imagePath=${Uri.encodeComponent(xFile.path)}',
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotoğraf çekilemedi: $e')),
        );
      }
    }
  }

  Future<void> _takeBarcodePhoto() async {
    final controller = _cameraController;
    if (controller == null ||
        !controller.value.isInitialized ||
        _isProcessingBarcode) {
      return;
    }

    setState(() => _isProcessingBarcode = true);

    try {
      final xFile = await controller.takePicture();
      if (!mounted) return;

      _barcodeEngine ??= BarcodeEngine();
      final isbns = await _barcodeEngine!.scanFile(xFile.path);

      if (isbns.isEmpty) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n?.invalidIsbn ??
                    'Barkod okunamadı. Lütfen çerçeveye ortalayın.',
              ),
            ),
          );
        }
        return;
      }

      final isbn = isbns.first;
      final book =
          await ref.read(barcodeLookupServiceProvider).lookupIsbn(isbn);

      if (!mounted) return;

      if (book == null) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n?.isbnNotFound ?? 'ISBN ($isbn) ile kitap bulunamadı.',
            ),
          ),
        );
        return;
      }

      await _showBarcodeBookSheet(book, isbn);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Barkod okuma hatası: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingBarcode = false);
      }
    }
  }

  Future<void> _showBarcodeBookSheet(
      ReviewCandidateBook book, String isbn) async {
    final semantic = context.spineColors;
    final l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: semantic.surfaceRaised,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(SpineRadius.sheet)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: SpineSpacing.lg,
            right: SpineSpacing.lg,
            top: SpineSpacing.lg,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom +
                SpineSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Brass handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: semantic.brass.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: SpineSpacing.md),
              Row(
                children: [
                  Icon(Icons.qr_code_2, color: semantic.brass, size: 22),
                  const SizedBox(width: SpineSpacing.xs),
                  Text(
                    (l10n?.bookFoundFromBarcode ?? 'BARKOD İLE KİTAP BULUNDU')
                        .toUpperCase(),
                    style: SpineTypography.metadataCaps
                        .copyWith(color: semantic.brass),
                  ),
                ],
              ),
              const SizedBox(height: SpineSpacing.md),
              Text(
                book.title,
                style: SpineTypography.headlineSmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: SpineSpacing.xs),
              Text(
                book.author,
                style: SpineTypography.bodyLarge.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              if (book.publisher != null || book.publishYear != null) ...[
                const SizedBox(height: SpineSpacing.xs),
                Text(
                  [
                    if (book.publisher != null) book.publisher!,
                    if (book.publishYear != null) book.publishYear!.toString(),
                    IsbnValidator.format(isbn),
                  ].join(' • '),
                  style: SpineTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
              const SizedBox(height: SpineSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                      child: Text(
                          MaterialLocalizations.of(context).cancelButtonLabel),
                    ),
                  ),
                  const SizedBox(width: SpineSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: semantic.brass,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () async {
                        Navigator.of(bottomSheetContext).pop();
                        await ref.read(libraryRepositoryProvider).addBook(
                              candidateBook: book,
                            );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('"${book.title}" kütüphaneye eklendi.'),
                            ),
                          );
                          // Pop back with result if requested by push caller
                          context.pop(book);
                        }
                      },
                      child: Text(
                        l10n?.addToLibrary ?? 'Kütüphaneye Ekle',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    final captureState = ref.read(captureControllerProvider);
    final isFlashOn =
        captureState is CaptureCapturing && captureState.flashOn;

    final nextMode = isFlashOn ? FlashMode.off : FlashMode.torch;
    await controller.setFlashMode(nextMode);
    ref.read(captureControllerProvider.notifier).toggleFlash();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (!_isPermissionChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_hasPermission) {
      return CameraPermissionScreen(
        onPermissionGranted: () {
          setState(() => _hasPermission = true);
          _initCamera();
          _startSensors();
        },
        onDismiss: () => context.pop(),
      );
    }

    if (_initError != null) {
      return AdaptiveScaffold(
        title: l10n?.cameraTitle ?? 'Kamera',
        largeTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SpineSpacing.lg),
            child: Text(
              _initError!,
              style: SpineTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final controller = _cameraController;
    if (!_isInit || controller == null || !controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final captureState = ref.watch(captureControllerProvider);
    final capturing =
        captureState is CaptureCapturing
            ? captureState
            : const CaptureCapturing();

    final semantic = context.spineColors;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera preview
          CameraPreview(controller),

          // 2. Shelf alignment guideline overlay
          _buildAlignmentGuide(context, semantic),

          // 3. Top bar (Close, Spirit level, Flash toggle)
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpineSpacing.base,
                  vertical: SpineSpacing.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                    if (_captureMode == CameraCaptureMode.spine)
                      LevelIndicator(
                        roll: capturing.roll,
                        pitch: capturing.pitch,
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SpineSpacing.sm,
                          vertical: SpineSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                              BorderRadius.circular(SpineRadius.chip),
                          border: Border.all(
                            color: semantic.brass.withValues(alpha: 0.5),
                            width: SpineBorders.hairline,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.qr_code,
                                size: 14, color: semantic.brass),
                            const SizedBox(width: 4),
                            Text(
                              'ISBN',
                              style: SpineTypography.metadataCaps.copyWith(
                                color: semantic.brass,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        capturing.flashOn
                            ? Icons.flash_on_outlined
                            : Icons.flash_off_outlined,
                        color: capturing.flashOn
                            ? semantic.brass
                            : Colors.white,
                      ),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. Bottom action area (Mode selector, Shutter button & Thumbnail)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: SpineSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeSelector(semantic, l10n),
                    const SizedBox(height: SpineSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 48), // Balance spacer
                        if (_isProcessingBarcode)
                          const SizedBox(
                            width: 64,
                            height: 64,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        else
                          ShutterButton(
                            canShoot: _captureMode == CameraCaptureMode.barcode
                                ? true
                                : capturing.canShoot,
                            onPressed:
                                _captureMode == CameraCaptureMode.barcode
                                    ? _takeBarcodePhoto
                                    : _takePhoto,
                          ),
                        const SizedBox(width: SpineSpacing.base),
                        // Recent thumbnail placeholder
                        if (capturing.lastPhotoPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              SpineRadius.thumbnail,
                            ),
                            child: Image.file(
                              File(capturing.lastPhotoPath!),
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                            ),
                          )
                        else
                          const SizedBox(width: 44),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(
    SpineSemanticColors semantic,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(SpineRadius.chip),
        border: Border.all(
          color: semantic.hairline,
          width: SpineBorders.hairline,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModePill(
            label: l10n?.spineMode ?? 'RAF SIRTI',
            isSelected: _captureMode == CameraCaptureMode.spine,
            onTap: () => setState(() => _captureMode = CameraCaptureMode.spine),
            semantic: semantic,
          ),
          const SizedBox(width: 4),
          _buildModePill(
            label: l10n?.barcodeMode ?? 'BARKOD (ISBN)',
            isSelected: _captureMode == CameraCaptureMode.barcode,
            onTap: () =>
                setState(() => _captureMode = CameraCaptureMode.barcode),
            semantic: semantic,
          ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required SpineSemanticColors semantic,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: SpineSpacing.md,
          vertical: SpineSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? semantic.brass.withValues(alpha: 0.25)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(SpineRadius.chip),
          border: Border.all(
            color: isSelected ? semantic.brass : Colors.transparent,
            width: SpineBorders.hairline,
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: SpineTypography.metadataCaps.copyWith(
            color: isSelected ? semantic.brass : Colors.white70,
            fontSize: 11,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildAlignmentGuide(
    BuildContext context,
    SpineSemanticColors semantic,
  ) {
    final l10n = AppLocalizations.of(context);
    final isBarcode = _captureMode == CameraCaptureMode.barcode;

    return IgnorePointer(
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: SpineSpacing.lg),
          height: isBarcode ? 150 : 220,
          width: isBarcode ? 270 : double.infinity,
          decoration: BoxDecoration(
            border: Border.all(
              color: semantic.brass.withValues(alpha: isBarcode ? 0.7 : 0.4),
              width: isBarcode ? 2.0 : SpineBorders.hairline,
            ),
            borderRadius: BorderRadius.circular(SpineRadius.card),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBarcode ? Icons.qr_code_scanner : Icons.menu_book_outlined,
                color: semantic.brass.withValues(alpha: 0.8),
                size: isBarcode ? 32 : 28,
              ),
              const SizedBox(height: SpineSpacing.xs),
              Text(
                (isBarcode
                        ? (l10n?.barcodeMode ?? 'BARKOD (ISBN)')
                        : (l10n?.cameraTitle ?? 'RAF KILAVUZU'))
                    .toUpperCase(),
                style: SpineTypography.metadataCaps.copyWith(
                  color: semantic.brass.withValues(alpha: 0.8),
                ),
              ),
              if (isBarcode) ...[
                const SizedBox(height: SpineSpacing.xs),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: SpineSpacing.sm),
                  child: Text(
                    l10n?.barcodeScanHint ??
                        'Arka kapaktaki ISBN barkodunu çerçeveye ortalayın',
                    style: SpineTypography.bodySmall.copyWith(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
