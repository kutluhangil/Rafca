import 'package:flutter/foundation.dart';

/// Which platform's conventions the adaptive widgets should follow.
///
/// SPINE_BLUEPRINT.md 4.6: feature code never asks what platform it is on.
/// This enum, and the widgets in this directory, are the only place that
/// question is allowed to be asked — which also makes both variants testable
/// without a device, by overriding [debugDefaultTargetPlatformOverride].
enum AdaptivePlatform {
  material,
  cupertino;

  static AdaptivePlatform get current => switch (defaultTargetPlatform) {
        TargetPlatform.iOS || TargetPlatform.macOS => AdaptivePlatform.cupertino,
        _ => AdaptivePlatform.material,
      };

  bool get isCupertino => this == AdaptivePlatform.cupertino;
}
