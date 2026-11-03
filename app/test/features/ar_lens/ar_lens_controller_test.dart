import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/database/app_database.dart';
import 'package:rafca/core/database/tables.dart';
import 'package:rafca/features/ar_lens/models/ar_lens_models.dart';
import 'package:rafca/features/ar_lens/services/ar_matching_engine.dart';
import 'package:rafca/features/ar_lens/state/ar_lens_controller.dart';
import 'package:rafca/features/capture/scan/ocr_engine.dart';
import 'package:rafca/features/library/data/library_repository.dart';
import 'package:spine_clustering/spine_clustering.dart';

class _FakeOcrEngine extends OcrEngine {
  List<OcrTextElement> mockElements = [];

  @override
  Future<List<OcrTextElement>> recognizePath(
    String imagePath, {
    int rotationDegrees = 0,
    int? imageWidth,
    int? imageHeight,
  }) async {
    return mockElements;
  }

  @override
  void dispose() {}
}

void main() {
  group('ArLensController', () {
    late AppDatabase db;
    late LibraryRepository repo;
    late ArMatchingEngine engine;
    late _FakeOcrEngine fakeOcr;
    late ArLensController controller;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = LibraryRepository(db);
      engine = ArMatchingEngine();
      fakeOcr = _FakeOcrEngine();
      controller = ArLensController(
        engine: engine,
        repo: repo,
        ocrEngine: fakeOcr,
      );

      // Seed a book into library
      await db.into(db.userBooks).insert(
            UserBooksCompanion(
              id: const Value('ub_1'),
              manualTitle: const Value('Dune'),
              manualAuthor: const Value('Frank Herbert'),
              status: const Value(ReadingStatus.read),
              confidence: const Value(MatchConfidence.matched),
              addedAt: Value(DateTime(2026, 1, 1)),
            ),
          );
    });

    tearDown(() async {
      controller.dispose();
      await db.close();
    });

    test('startLens activates lens and indexes library books', () async {
      expect(controller.state.isActive, isFalse);

      await controller.startLens();
      expect(controller.state.isActive, isTrue);
      expect(controller.state.items, isEmpty);
    });

    test('stopLens resets state and clears items', () async {
      await controller.startLens();
      controller.stopLens();

      expect(controller.state.isActive, isFalse);
      expect(controller.state.isProcessing, isFalse);
      expect(controller.state.items, isEmpty);
    });

    test('processFrame extracts elements and classifies item as ownedRead', () async {
      await controller.startLens();

      fakeOcr.mockElements = [
        OcrTextElement(
          text: 'DUNE FRANK HERBERT',
          corners: [
            const Point2(100, 100),
            const Point2(200, 100),
            const Point2(200, 600),
            const Point2(100, 600),
          ],
          sourceRotation: 0,
          confidence: 0.95,
        ),
      ];

      await controller.processFrame(
        imagePath: '/test/frame.jpg',
        imageWidth: 1000,
        imageHeight: 1000,
      );

      expect(controller.state.items.length, equals(1));
      final item = controller.state.items.first;
      expect(item.status, equals(ArBookStatus.ownedRead));
      expect(item.matchedTitle, equals('Dune'));
      expect(item.normalizedRect.left, equals(0.1));
    });

    test('processFrame drops rapid invocations within 450ms throttling window', () async {
      await controller.startLens();

      fakeOcr.mockElements = [];

      // First process
      await controller.processFrame(
        imagePath: '/test/frame.jpg',
        imageWidth: 1000,
        imageHeight: 1000,
      );

      final firstProcessed = controller.state.lastProcessedAt;
      expect(firstProcessed, isNotNull);

      // Rapid second process immediately after
      await controller.processFrame(
        imagePath: '/test/frame.jpg',
        imageWidth: 1000,
        imageHeight: 1000,
      );

      // Timestamp should remain unchanged because frame was dropped
      expect(controller.state.lastProcessedAt, equals(firstProcessed));
    });
  });
}
