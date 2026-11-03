/// Performance budget definitions and validation per SPINE_BLUEPRINT.md §443.
///
/// Bütçeler:
/// - cold start < 2s (2000ms)
/// - tarama pipeline < 8s (8000ms)
/// - APK < 45MB (47,185,920 bytes)
/// - bellek tepe < 250MB
class PerformanceBudgets {
  PerformanceBudgets._();

  static const int coldStartMaxMs = 2000;
  static const int scanPipelineMaxMs = 8000;
  static const int apkSizeMaxBytes = 45 * 1024 * 1024; // 45 MB
  static const int peakMemoryMaxMb = 250; // 250 MB

  /// Validates a measured metric set against the defined budgets.
  static BudgetValidationResult validate({
    required int coldStartMs,
    required int scanPipelineMs,
    int? apkSizeBytes,
    int? peakMemoryMb,
  }) {
    final violations = <String>[];

    if (coldStartMs > coldStartMaxMs) {
      violations.add(
        'Cold start ($coldStartMs ms) exceeded budget of $coldStartMaxMs ms',
      );
    }

    if (scanPipelineMs > scanPipelineMaxMs) {
      violations.add(
        'Scan pipeline ($scanPipelineMs ms) exceeded budget of $scanPipelineMaxMs ms',
      );
    }

    if (apkSizeBytes != null && apkSizeBytes > apkSizeMaxBytes) {
      final mb = (apkSizeBytes / (1024 * 1024)).toStringAsFixed(1);
      violations.add(
        'APK size (${mb}MB) exceeded budget of 45MB',
      );
    }

    if (peakMemoryMb != null && peakMemoryMb > peakMemoryMaxMb) {
      violations.add(
        'Peak memory (${peakMemoryMb}MB) exceeded budget of $peakMemoryMaxMb MB',
      );
    }

    return BudgetValidationResult(
      passed: violations.isEmpty,
      violations: violations,
      coldStartMs: coldStartMs,
      scanPipelineMs: scanPipelineMs,
      apkSizeBytes: apkSizeBytes,
      peakMemoryMb: peakMemoryMb,
    );
  }
}

/// Result of budget evaluation.
class BudgetValidationResult {
  const BudgetValidationResult({
    required this.passed,
    required this.violations,
    required this.coldStartMs,
    required this.scanPipelineMs,
    this.apkSizeBytes,
    this.peakMemoryMb,
  });

  final bool passed;
  final List<String> violations;
  final int coldStartMs;
  final int scanPipelineMs;
  final int? apkSizeBytes;
  final int? peakMemoryMb;

  String summary() {
    final buffer = StringBuffer();
    buffer.writeln('=== Rafça Performance Budget Report ===');
    buffer.writeln('Status: ${passed ? "PASSED" : "FAILED"}');
    buffer.writeln('Cold Start: $coldStartMs ms (Budget: ${PerformanceBudgets.coldStartMaxMs} ms)');
    buffer.writeln('Scan Pipeline: $scanPipelineMs ms (Budget: ${PerformanceBudgets.scanPipelineMaxMs} ms)');
    if (apkSizeBytes != null) {
      final mb = (apkSizeBytes! / (1024 * 1024)).toStringAsFixed(2);
      buffer.writeln('APK Size: $mb MB (Budget: 45.00 MB)');
    }
    if (peakMemoryMb != null) {
      buffer.writeln('Peak Memory: $peakMemoryMb MB (Budget: ${PerformanceBudgets.peakMemoryMaxMb} MB)');
    }
    if (violations.isNotEmpty) {
      buffer.writeln('\nViolations:');
      for (final v in violations) {
        buffer.writeln(' - $v');
      }
    }
    return buffer.toString();
  }
}

/// Simple stop-watch tracker for pipeline execution.
class PipelineBenchmarkTracker {
  PipelineBenchmarkTracker();

  final Stopwatch _stopwatch = Stopwatch();

  void start() => _stopwatch.start();
  void stop() => _stopwatch.stop();
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
  void reset() => _stopwatch.reset();
}
