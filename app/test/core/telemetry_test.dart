import 'package:flutter_test/flutter_test.dart';
import 'package:rafca/core/telemetry/offline_error_queue.dart';
import 'package:rafca/core/telemetry/telemetry_service.dart';

void main() {
  group('OfflineErrorQueue', () {
    test('enqueues and drains events in FIFO order', () {
      final queue = OfflineErrorQueue(maxCapacity: 3);

      final e1 = ErrorEvent(
        id: '1',
        message: 'Error 1',
        stackTrace: 'trace 1',
        timestamp: DateTime.now(),
      );
      final e2 = ErrorEvent(
        id: '2',
        message: 'Error 2',
        stackTrace: 'trace 2',
        timestamp: DateTime.now(),
      );

      queue.enqueue(e1);
      queue.enqueue(e2);

      expect(queue.length, 2);
      expect(queue.isNotEmpty, isTrue);

      final drained = queue.drain();
      expect(drained.length, 2);
      expect(drained[0].id, '1');
      expect(drained[1].id, '2');
      expect(queue.isEmpty, isTrue);
    });

    test('drops oldest items when max capacity is reached', () {
      final queue = OfflineErrorQueue(maxCapacity: 2);

      queue.enqueue(ErrorEvent(id: '1', message: 'E1', stackTrace: '', timestamp: DateTime.now()));
      queue.enqueue(ErrorEvent(id: '2', message: 'E2', stackTrace: '', timestamp: DateTime.now()));
      queue.enqueue(ErrorEvent(id: '3', message: 'E3', stackTrace: '', timestamp: DateTime.now()));

      expect(queue.length, 2);
      final remaining = queue.drain();
      expect(remaining.map((e) => e.id), ['2', '3']);
    });

    test('ErrorEvent serialize and deserialize round-trip', () {
      final now = DateTime.now();
      final original = ErrorEvent(
        id: 'e_test',
        message: 'NetworkException',
        stackTrace: 'custom_trace',
        timestamp: now,
        reason: 'timeout',
        fatal: true,
        extras: {'code': 504},
      );

      final json = original.toJson();
      final reconstructed = ErrorEvent.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.message, original.message);
      expect(reconstructed.stackTrace, original.stackTrace);
      expect(reconstructed.timestamp.toIso8601String(), original.timestamp.toIso8601String());
      expect(reconstructed.reason, 'timeout');
      expect(reconstructed.fatal, isTrue);
      expect(reconstructed.extras['code'], 504);
    });
  });

  group('AppTelemetryService', () {
    test('records breadcrumbs up to maxBreadcrumbs', () {
      final telemetry = AppTelemetryService(maxBreadcrumbs: 3);

      telemetry.addBreadcrumb('step 1');
      telemetry.addBreadcrumb('step 2', category: 'nav');
      telemetry.addBreadcrumb('step 3');
      telemetry.addBreadcrumb('step 4');

      expect(telemetry.breadcrumbs.length, 3);
      expect(telemetry.breadcrumbs.map((b) => b.message), ['step 2', 'step 3', 'step 4']);
      expect(telemetry.breadcrumbs[0].category, 'nav');
    });

    test('records errors with context into offline queue and flushes', () async {
      final telemetry = AppTelemetryService();

      telemetry.addBreadcrumb('pre-action');
      telemetry.recordError(
        Exception('Database error'),
        StackTrace.current,
        reason: 'Query timeout',
        fatal: false,
        extras: {'table': 'user_books'},
      );

      expect(telemetry.offlineQueue.length, 1);
      final event = telemetry.offlineQueue.peekAll().first;
      expect(event.message, contains('Database error'));
      expect(event.reason, 'Query timeout');
      expect(event.fatal, isFalse);
      expect(event.extras['table'], 'user_books');
      expect(event.extras['recent_breadcrumbs'], isNotEmpty);

      final flushed = await telemetry.flushOfflineQueue();
      expect(flushed, 1);
      expect(telemetry.offlineQueue.isEmpty, isTrue);
    });

    test('isSentryConfigured flag reflects DSN presence', () {
      final withoutDsn = AppTelemetryService();
      expect(withoutDsn.isSentryConfigured, isFalse);

      final withDsn = AppTelemetryService(sentryDsn: 'https://key@sentry.io/12345');
      expect(withDsn.isSentryConfigured, isTrue);
    });
  });
}
