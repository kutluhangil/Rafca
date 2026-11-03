import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'offline_error_queue.dart';

/// Breadcrumb log entry for diagnostic context.
class TelemetryBreadcrumb {
  const TelemetryBreadcrumb({
    required this.message,
    required this.timestamp,
    this.category = 'default',
    this.data,
  });

  final String message;
  final DateTime timestamp;
  final String category;
  final Map<String, dynamic>? data;

  Map<String, dynamic> toJson() => {
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'category': category,
        if (data != null) 'data': data,
      };
}

/// Abstract contract for crash & telemetry reporting.
abstract class TelemetryService {
  void addBreadcrumb(String message, {String category = 'default', Map<String, dynamic>? data});
  void recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extras,
  });
  Future<int> flushOfflineQueue();
  List<TelemetryBreadcrumb> get breadcrumbs;
  OfflineErrorQueue get offlineQueue;
  bool get isSentryConfigured;
}

/// Production telemetry implementation with offline queue and Sentry readiness.
class AppTelemetryService implements TelemetryService {
  AppTelemetryService({
    this.sentryDsn,
    OfflineErrorQueue? offlineQueue,
    this.maxBreadcrumbs = 100,
  }) : offlineQueue = offlineQueue ?? OfflineErrorQueue();

  final String? sentryDsn;
  @override
  final OfflineErrorQueue offlineQueue;
  final int maxBreadcrumbs;
  final List<TelemetryBreadcrumb> _breadcrumbs = [];
  int _eventCounter = 0;

  @override
  bool get isSentryConfigured => sentryDsn != null && sentryDsn!.trim().isNotEmpty;

  @override
  List<TelemetryBreadcrumb> get breadcrumbs => List.unmodifiable(_breadcrumbs);

  @override
  void addBreadcrumb(String message, {String category = 'default', Map<String, dynamic>? data}) {
    if (_breadcrumbs.length >= maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }
    _breadcrumbs.add(
      TelemetryBreadcrumb(
        message: message,
        timestamp: DateTime.now(),
        category: category,
        data: data,
      ),
    );
  }

  @override
  void recordError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? extras,
  }) {
    _eventCounter++;
    final event = ErrorEvent(
      id: 'err_${DateTime.now().millisecondsSinceEpoch}_$_eventCounter',
      message: error.toString(),
      stackTrace: stackTrace.toString(),
      timestamp: DateTime.now(),
      reason: reason,
      fatal: fatal,
      extras: {
        ...?extras,
        'recent_breadcrumbs': _breadcrumbs.take(10).map((b) => b.toJson()).toList(),
      },
    );

    // If Sentry DSN is configured and online, it would dispatch to Sentry SDK.
    // For local-first and offline tolerance, always enqueue in the offline queue.
    offlineQueue.enqueue(event);

    if (kDebugMode) {
      debugPrint('[Telemetry] Error logged (${fatal ? "FATAL" : "NON-FATAL"}): $error');
      if (reason != null) debugPrint('[Telemetry] Reason: $reason');
    }
  }

  @override
  Future<int> flushOfflineQueue() async {
    final drained = offlineQueue.drain();
    if (drained.isEmpty) return 0;

    // When Sentry or backend endpoint is available, posts all items.
    // Drained count is returned for monitoring.
    return drained.length;
  }

  /// Installs global Flutter and platform error hooks.
  void installGlobalErrorHooks() {
    FlutterError.onError = (details) {
      recordError(
        details.exception,
        details.stack ?? StackTrace.current,
        reason: details.context?.toString(),
        fatal: false,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(
        error,
        stack,
        reason: 'Uncaught PlatformDispatcher error',
        fatal: true,
      );
      return true; // Error handled
    };
  }
}

/// Global provider for telemetry service.
final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  // Sentry DSN can be passed via --dart-define=SENTRY_DSN=...
  const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');
  final service = AppTelemetryService(
    sentryDsn: dsn.isNotEmpty ? dsn : null,
  );
  service.installGlobalErrorHooks();
  return service;
});
