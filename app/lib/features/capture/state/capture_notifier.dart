import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:spine_clustering/spine_clustering.dart';

import 'capture_state.dart';

part 'capture_notifier.g.dart';

@riverpod
class CaptureController extends _$CaptureController {
  @override
  CaptureState build() => const CaptureIdle();

  /// Checks camera permission status.
  Future<bool> checkPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (state is! CaptureCapturing) {
        state = const CaptureCapturing();
      }
      return true;
    } else {
      state = const CapturePermissionRequired();
      return false;
    }
  }

  /// Requests camera permission from user.
  Future<bool> requestPermission() async {
    final result = await Permission.camera.request();
    if (result.isGranted) {
      state = const CaptureCapturing();
      return true;
    } else {
      state = const CapturePermissionRequired();
      return false;
    }
  }

  /// Updates roll & pitch angles in degrees, plus stability boolean.
  ///
  /// SPINE_BLUEPRINT.md 7.1: roll & pitch must be within +/- 7 degrees.
  void updateSensors({
    required double rollDegrees,
    required double pitchDegrees,
    required bool isStable,
  }) {
    if (state is! CaptureCapturing) return;

    final current = state as CaptureCapturing;
    const maxTilt = 7.0;
    final isLeveled = rollDegrees.abs() <= maxTilt && pitchDegrees.abs() <= maxTilt;

    state = current.copyWith(
      isLeveled: isLeveled,
      isStable: isStable,
      roll: rollDegrees,
      pitch: pitchDegrees,
    );
  }

  void toggleFlash() {
    if (state is! CaptureCapturing) return;
    final current = state as CaptureCapturing;
    state = current.copyWith(flashOn: !current.flashOn);
  }

  void setPhotoCaptured(String path) {
    if (state is CaptureCapturing) {
      final current = state as CaptureCapturing;
      state = current.copyWith(lastPhotoPath: path);
    }
  }

  void startCropping(String imagePath) {
    state = CaptureCropping(imagePath: imagePath);
  }

  void startProcessing(String imagePath) {
    state = CaptureProcessing(
      imagePath: imagePath,
      progress: 0.0,
      logLines: const ['TARAMA BAŞLATILDI...'],
    );
  }

  void updateProcessingProgress(
    double progress,
    String log, {
    List<SpineCandidate>? detected,
  }) {
    if (state is! CaptureProcessing) return;
    final current = state as CaptureProcessing;
    final lines = List<String>.from(current.logLines)..add(log);
    if (lines.length > 5) {
      lines.removeRange(0, lines.length - 5);
    }

    state = current.copyWith(
      progress: progress.clamp(0.0, 1.0),
      logLines: lines,
      detectedCandidates: detected ?? current.detectedCandidates,
    );
  }

  void completeProcessing(String imagePath, List<SpineCandidate> candidates) {
    state = CaptureDone(imagePath: imagePath, candidates: candidates);
  }

  void setError(String message, CapturePhase phase) {
    state = CaptureError(message: message, phase: phase);
  }

  void reset() {
    state = const CaptureIdle();
  }
}
