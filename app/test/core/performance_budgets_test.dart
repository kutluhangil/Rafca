import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/performance/performance_budgets.dart';

void main() {
  group('PerformanceBudgets', () {
    test('passes when all metrics are within budgets', () {
      final result = PerformanceBudgets.validate(
        coldStartMs: 1450,
        scanPipelineMs: 4200,
        apkSizeBytes: 38 * 1024 * 1024,
        peakMemoryMb: 180,
      );

      expect(result.passed, isTrue);
      expect(result.violations, isEmpty);
      expect(result.summary(), contains('Status: PASSED'));
      expect(result.summary(), contains('Cold Start: 1450 ms'));
    });

    test('flags violations when cold start or scan pipeline exceeds limits', () {
      final result = PerformanceBudgets.validate(
        coldStartMs: 2500, // > 2000
        scanPipelineMs: 9200, // > 8000
        apkSizeBytes: 50 * 1024 * 1024, // > 45MB
        peakMemoryMb: 300, // > 250MB
      );

      expect(result.passed, isFalse);
      expect(result.violations.length, 4);
      expect(result.violations[0], contains('Cold start'));
      expect(result.violations[1], contains('Scan pipeline'));
      expect(result.violations[2], contains('APK size'));
      expect(result.violations[3], contains('Peak memory'));
      expect(result.summary(), contains('Status: FAILED'));
    });

    test('PipelineBenchmarkTracker measures elapsed duration', () async {
      final tracker = PipelineBenchmarkTracker();
      tracker.start();
      await Future<void>.delayed(const Duration(milliseconds: 50));
      tracker.stop();

      expect(tracker.elapsedMilliseconds, greaterThanOrEqualTo(40));
      tracker.reset();
      expect(tracker.elapsedMilliseconds, 0);
    });
  });
}
