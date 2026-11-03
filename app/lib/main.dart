import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/app/rafca_app.dart';
import 'core/telemetry/telemetry_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
