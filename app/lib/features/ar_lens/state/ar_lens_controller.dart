import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spine_clustering/spine_clustering.dart';

import '../../capture/scan/ocr_engine.dart';
import '../../library/data/library_repository.dart';
import '../models/ar_lens_models.dart';
import '../services/ar_matching_engine.dart';

final arMatchingEngineProvider = Provider<ArMatchingEngine>((ref) {
  final engine = ArMatchingEngine();
  // Keep engine index fresh with latest books
  ref.listen(libraryRepositoryProvider, (previous, next) async {
    final books = await next.getAllBooks();
    engine.updateIndex(books);
  });
  return engine;
});

final arLensControllerProvider =
    StateNotifierProvider<ArLensController, ArLensState>((ref) {
  final engine = ref.watch(arMatchingEngineProvider);
  final repo = ref.watch(libraryRepositoryProvider);
  return ArLensController(engine: engine, repo: repo);
});

/// Controls real-time OCR frame ingestion, 500ms throttling, and HUD item classification.
class ArLensController extends StateNotifier<ArLensState> {
  ArLensController({
    required this.engine,
    required this.repo,
    OcrEngine? ocrEngine,
  })  : _ocr = ocrEngine ?? OcrEngine(),
        super(const ArLensState());

  final ArMatchingEngine engine;
  final LibraryRepository repo;
  final OcrEngine _ocr;

  /// Activates the AR lens and initializes the index from the library.
  Future<void> startLens() async {
    final books = await repo.getAllBooks();
    engine.updateIndex(books);
    state = state.copyWith(isActive: true, items: []);
  }

  /// Deactivates the AR lens and clears HUD items.
  void stopLens() {
    state = state.copyWith(isActive: false, isProcessing: false, items: []);
  }

  /// Processes an incoming camera frame.
  ///
  /// Drops frame if a previous frame is still processing or if under 450ms threshold (2 FPS target).
  Future<void> processFrame({
    required String imagePath,
    required int imageWidth,
    required int imageHeight,
  }) async {
    if (!state.isActive || state.isProcessing) return;

    final now = DateTime.now();
    if (state.lastProcessedAt != null &&
        now.difference(state.lastProcessedAt!) <
            const Duration(milliseconds: 450)) {
      return; // Throttled drop
    }

    state = state.copyWith(isProcessing: true);

    try {
      final elements = await _ocr.recognizePath(
        imagePath,
        rotationDegrees: 0,
        imageWidth: imageWidth,
        imageHeight: imageHeight,
      );

      final detectedItems = <ArDetectedItem>[];

      // Cluster OCR elements into coarse vertical spine rects
      final groups = _clusterTextElements(elements);

      for (var i = 0; i < groups.length; i++) {
        final group = groups[i];
        final rawText = group.text;
        if (rawText.trim().length < 3) continue;

        // Normalize bounding box coordinates 0.0 .. 1.0
        final normalizedRect = Rect.fromLTRB(
          (group.bbox.left / imageWidth).clamp(0.0, 1.0),
          (group.bbox.top / imageHeight).clamp(0.0, 1.0),
          (group.bbox.right / imageWidth).clamp(0.0, 1.0),
          (group.bbox.bottom / imageHeight).clamp(0.0, 1.0),
        );

        final classified = engine.classifyText(
          id: 'ar_$i',
          rawText: rawText,
          normalizedRect: normalizedRect,
        );

        detectedItems.add(classified);
      }

      state = state.copyWith(
        items: detectedItems,
        isProcessing: false,
        lastProcessedAt: DateTime.now(),
      );
    } catch (_) {
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Simple bounding-box clustering for real-time live preview.
  List<({String text, Rect bbox})> _clusterTextElements(
      List<OcrTextElement> elements) {
    if (elements.isEmpty) return const [];

    final list = <({String text, Rect bbox})>[];
    for (final el in elements) {
      double minX = double.infinity;
      double minY = double.infinity;
      double maxX = double.negativeInfinity;
      double maxY = double.negativeInfinity;

      for (final pt in el.corners) {
        minX = math.min(minX, pt.x);
        minY = math.min(minY, pt.y);
        maxX = math.max(maxX, pt.x);
        maxY = math.max(maxY, pt.y);
      }

      if (maxX > minX && maxY > minY) {
        list.add((
          text: el.text,
          bbox: Rect.fromLTRB(minX, minY, maxX, maxY),
        ));
      }
    }
    return list;
  }

  @override
  void dispose() {
    _ocr.dispose();
    super.dispose();
  }
}
