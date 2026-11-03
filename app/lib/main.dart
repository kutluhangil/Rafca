import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'core/app/rafca_app.dart';
import 'core/telemetry/telemetry_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  void runAppScope() {
    final container = ProviderContainer();
    // Warm up and install telemetry hooks
    container.read(telemetryServiceProvider);

    runApp(
      UncontrolledProviderScope(
        container: container,
        child: const RafcaApp(),
      ),
    );
  }

  if (dsn.isNotEmpty) {
    await SentryFlutter.init(
      (options) {
        options.dsn = dsn;
        options.tracesSampleRate = 1.0;
        options.attachScreenshot = false;
        options.sendDefaultPii = false;
      },
      appRunner: runAppScope,
    );
  } else {
    runAppScope();
  }
}
