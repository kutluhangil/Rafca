/// Pure Dart spine segmentation for Rafça.
///
/// Deliberately free of any Flutter dependency so that both the Faz 0 spike
/// (a plain Dart CLI) and the app (Faz 6 capture pipeline) run the exact same
/// algorithm against the exact same regression dataset.
library;

export 'src/clustering.dart';
export 'src/geometry.dart';
export 'src/models.dart';
