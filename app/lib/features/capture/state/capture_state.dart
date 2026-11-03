import 'package:flutter/foundation.dart';
import 'package:spine_clustering/spine_clustering.dart';

enum CapturePhase {
  idle,
  permissionRequired,
  capturing,
  cropping,
  processing,
  done,
  error,
}

@immutable
sealed class CaptureState {
  const CaptureState();
}

class CaptureIdle extends CaptureState {
  const CaptureIdle();
}

class CapturePermissionRequired extends CaptureState {
  const CapturePermissionRequired();
}

class CaptureCapturing extends CaptureState {
  const CaptureCapturing({
    this.isLeveled = false,
    this.isStable = false,
    this.roll = 0.0,
    this.pitch = 0.0,
    this.lastPhotoPath,
    this.flashOn = false,
  });

  final bool isLeveled;
  final bool isStable;
  final double roll;
  final double pitch;
  final String? lastPhotoPath;
  final bool flashOn;

  bool get canShoot => isLeveled && isStable;

  CaptureCapturing copyWith({
    bool? isLeveled,
    bool? isStable,
    double? roll,
    double? pitch,
    String? lastPhotoPath,
    bool? flashOn,
  }) {
    return CaptureCapturing(
      isLeveled: isLeveled ?? this.isLeveled,
      isStable: isStable ?? this.isStable,
      roll: roll ?? this.roll,
      pitch: pitch ?? this.pitch,
      lastPhotoPath: lastPhotoPath ?? this.lastPhotoPath,
      flashOn: flashOn ?? this.flashOn,
    );
  }
}

class CaptureCropping extends CaptureState {
  const CaptureCropping({required this.imagePath});
  final String imagePath;
}

class CaptureProcessing extends CaptureState {
  const CaptureProcessing({
    required this.imagePath,
    this.progress = 0.0,
    this.logLines = const [],
    this.detectedCandidates = const [],
  });

  final String imagePath;
  final double progress;
  final List<String> logLines;
  final List<SpineCandidate> detectedCandidates;

  CaptureProcessing copyWith({
    double? progress,
    List<String>? logLines,
    List<SpineCandidate>? detectedCandidates,
  }) {
    return CaptureProcessing(
      imagePath: imagePath,
      progress: progress ?? this.progress,
      logLines: logLines ?? this.logLines,
      detectedCandidates: detectedCandidates ?? this.detectedCandidates,
    );
  }
}

class CaptureDone extends CaptureState {
  const CaptureDone({
    required this.imagePath,
    required this.candidates,
  });

  final String imagePath;
  final List<SpineCandidate> candidates;
}

class CaptureError extends CaptureState {
  const CaptureError({
    required this.message,
    required this.phase,
  });

  final String message;
  final CapturePhase phase;
}
