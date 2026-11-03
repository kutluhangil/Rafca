import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../design/gallery.dart';
import '../../features/capture/screens/camera_screen.dart';
import '../../features/capture/screens/crop_screen.dart';
import '../../features/capture/screens/processing_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/library/screens/book_detail_screen.dart';
import '../../features/library/screens/shelves_screen.dart';
import '../../features/review/models/review_models.dart';
import '../../features/review/screens/scan_results_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

part 'app_router.g.dart';

/// Route paths, in one place so that deep links and tests never spell a route
/// by hand.
abstract final class Routes {
  const Routes._();

  static const home = '/';

  /// The Faz 2 design gallery. A developer surface, not a product screen — it
  /// stays reachable so that a component regression is one tap away rather
  /// than a rebuild away.
  static const gallery = '/gallery';

  /// Faz 6 — Capture routes
  static const capture = '/capture';
  static const captureCrop = '/capture/crop';
  static const captureProcessing = '/capture/processing';

  /// Faz 7 — Review & Correction routes
  static const reviewResults = '/review/results';

  /// Faz 8 — Library & Shelves routes
  static const bookDetail = '/book';
  static const shelves = '/shelves';

  /// Faz 9 — Settings route
  static const settings = '/settings';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: Routes.home,
    routes: [
      GoRoute(
        path: Routes.home,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: Routes.gallery,
        name: 'gallery',
        builder: (context, state) => const DesignGalleryScreen(),
      ),
      GoRoute(
        path: Routes.capture,
        name: 'capture',
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          final initialMode = switch (mode) {
            'barcode' => CameraCaptureMode.barcode,
            'ar' || 'arLens' => CameraCaptureMode.arLens,
            _ => CameraCaptureMode.spine,
          };
          return CameraScreen(initialMode: initialMode);
        },
      ),
      GoRoute(
        path: Routes.captureCrop,
        name: 'captureCrop',
        builder: (context, state) {
          final imagePath = state.uri.queryParameters['imagePath'] ?? '';
          return CropScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: Routes.captureProcessing,
        name: 'captureProcessing',
        builder: (context, state) {
          final imagePath = state.uri.queryParameters['imagePath'] ?? '';
          return ProcessingScreen(imagePath: imagePath);
        },
      ),
      GoRoute(
        path: Routes.reviewResults,
        name: 'reviewResults',
        builder: (context, state) {
          final batch = state.extra as ReviewBatch?;
          if (batch == null) return const HomeScreen();
          return ScanResultsScreen(initialBatch: batch);
        },
      ),
      GoRoute(
        path: Routes.bookDetail,
        name: 'bookDetail',
        builder: (context, state) {
          final id = state.uri.queryParameters['id'] ?? '';
          return BookDetailScreen(userBookId: id);
        },
      ),
      GoRoute(
        path: Routes.shelves,
        name: 'shelves',
        builder: (context, state) => const ShelvesScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
