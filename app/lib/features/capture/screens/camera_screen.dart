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
import '../state/capture_notifier.dart';
import '../state/capture_state.dart';
import '../widgets/level_indicator.dart';
import '../widgets/shutter_button.dart';
import 'permission_screen.dart';

/// Live camera view with spirit leveling, alignment guidelines and capture gating.
///
/// Implements SPINE_BLUEPRINT.md 7.1 and FAZ 6.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool _isInit = false;
  bool _isPermissionChecked = false;
  bool _hasPermission = false;
  String? _initError;

  // Stability tracker over 300ms window
  final List<({DateTime time, double mag})> _recentAccels = [];

  @override
  void initState() {
    super.initState();
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
        title: 'Kamera',
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
          _buildAlignmentGuide(semantic),

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
                    LevelIndicator(
                      roll: capturing.roll,
                      pitch: capturing.pitch,
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

          // 4. Bottom action area (Shutter button & Thumbnail)
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: SpineSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 48), // Balance spacer
                    ShutterButton(
                      canShoot: capturing.canShoot,
                      onPressed: _takePhoto,
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentGuide(SpineSemanticColors semantic) {
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: SpineSpacing.lg),
          height: 220,
          decoration: BoxDecoration(
            border: Border.all(
              color: semantic.brass.withValues(alpha: 0.4),
              width: SpineBorders.hairline,
            ),
            borderRadius: BorderRadius.circular(SpineRadius.card),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RAF KILAVUZU / ALIGN SHELF',
                style: SpineTypography.metadataCaps.copyWith(
                  color: semantic.brass.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
