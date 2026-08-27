import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../design/gallery.dart';
import '../../features/home/home_screen.dart';

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
    ],
  );
}
