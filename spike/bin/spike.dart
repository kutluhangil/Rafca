import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:spike/eval/crops.dart';
import 'package:spike/eval/ground_truth.dart';
import 'package:spike/eval/metrics.dart';
import 'package:spike/eval/normalize.dart';
import 'package:spike/eval/report.dart';
import 'package:spike/ocr/ocr_source.dart';
import 'package:spike/ocr/vision_ocr_source.dart';
import 'package:spine_clustering/spine_clustering.dart';

/// Faz 0 accuracy spike, SPINE_BLUEPRINT.md section 2.
///
/// Runs the real clustering algorithm from `packages/spine_clustering` over an
/// annotated set of shelf photos and reports the three rates the GO/NO-GO gate
/// turns on. This harness is throwaway; the algorithm it exercises is not.
Future<int> main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('dataset',
        defaultsTo: 'dataset', help: 'Directory holding the shelf photos.')
    ..addOption('ground-truth',
        help: 'Annotations. Defaults to <dataset>/ground_truth.json.')
    ..addOption('publishers',
        defaultsTo: '../data/publishers.txt',
        help: 'Publisher list shared with the Go matching service.')
    ..addOption('vision-binary',
        defaultsTo: 'tool/vision_ocr',
        help: 'Compiled Apple Vision OCR helper.')
    ..addOption('out', defaultsTo: 'report.md', help: 'Report path.')
    ..addOption('strategy',
        defaultsTo: 'both',
        allowed: ['blueprint', 'otsu', 'both'],
        help: 'Which spine boundary rule to evaluate.')
    ..addFlag('crops',
        help: 'Also write spine crops and dominant colours to out/crops/.')
    ..addFlag('language-correction',
        help: 'Let Vision autocorrect words. Off by default: it rewrites '
            'unusual titles into common ones.')
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(arguments);
  if (args.flag('help')) {
    stdout.writeln('Faz 0 accuracy spike for Rafça.\n');
    stdout.writeln(parser.usage);
    return 0;
  }

  final datasetDir = args.option('dataset')!;
  final groundTruthPath =
      args.option('ground-truth') ?? p.join(datasetDir, 'ground_truth.json');
  final visionBinary = args.option('vision-binary')!;

  if (!File(visionBinary).existsSync()) {
    stderr.writeln(
      'OCR helper not built at $visionBinary.\n'
      'Build it with:\n'
      '  swiftc -O -o spike/tool/vision_ocr spike/tool/vision_ocr.swift',
    );
    return 1;
  }

  final truth = GroundTruth.fromFile(groundTruthPath);
  final publishers = PublisherIndex.fromFile(args.option('publishers')!);
  final built = catalogFromGroundTruth(truth);

  for (final warning in truth.coverageWarnings()) {
    stderr.writeln('warning: $warning');
  }

  final ocr = VisionOcrSource(
    binaryPath: visionBinary,
    languageCorrection: args.flag('language-correction'),
  );

  final strategies = switch (args.option('strategy')) {
    'blueprint' => [GapStrategy.blueprint],
    'otsu' => [GapStrategy.otsu],
    _ => [GapStrategy.blueprint, GapStrategy.otsu],
  };

  // OCR is by far the slow part, so every rotation of every photo is read
  // once and both strategies cluster the same elements.
  final elementsByPhoto = <String, List<OcrTextElement>>{};
  for (final photo in truth.photos) {
    final imagePath = p.join(datasetDir, photo.file);
    if (!File(imagePath).existsSync()) {
      throw StateError(
        'ground truth lists ${photo.file} but $imagePath does not exist',
      );
    }
    stdout.writeln('OCR ${photo.file} ...');
    elementsByPhoto[photo.file] =
        await recognizeAllRotations(ocr, imagePath);
  }

  final outDir = p.join('out');
  final runs = <RunResult>[];
  for (final strategy in strategies) {
    final config = ClusteringConfig(gapStrategy: strategy);
    final photoMetrics = <PhotoMetrics>[];
    final colorsByPhoto = <String, Map<String, String>>{};

    for (final photo in truth.photos) {
      final candidates = segmentSpines(
        elementsByPhoto[photo.file]!,
        config: config,
      );

      if (args.flag('crops') && strategy == strategies.first) {
        final decoded =
            img.decodeImage(File(p.join(datasetDir, photo.file)).readAsBytesSync());
        if (decoded == null) {
          throw StateError('cannot decode ${photo.file} for cropping');
        }
        final crops = writeCrops(
          source: decoded,
          candidates: candidates,
          outputDir: p.join(outDir, 'crops'),
          photoName: p.basenameWithoutExtension(photo.file),
        );
        colorsByPhoto[photo.file] = {
          for (final entry in crops.entries) entry.key: entry.value.dominantColor,
        };
      }

      photoMetrics.add(evaluatePhoto(
        photo: photo,
        candidates: candidates,
        catalog: built.catalog,
        idOf: built.idOf,
        publishers: publishers,
      ));
    }

    if (colorsByPhoto.isNotEmpty) {
      Directory(outDir).createSync(recursive: true);
      File(p.join(outDir, 'spine_colors.json')).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert(colorsByPhoto),
      );
    }

    runs.add(RunResult(label: 'GapStrategy.${strategy.name}', photos: photoMetrics));
  }

  final report = renderReport(
    runs: runs,
    engineName: ocr.engineName,
    catalogProvenance: built.catalog.provenance,
    truth: truth,
    generatedAt: DateTime.now(),
  );
  File(args.option('out')!).writeAsStringSync(report);

  stdout.writeln('\nwrote ${args.option('out')}');
  for (final run in runs) {
    final a = run.overall;
    stdout.writeln('  ${run.label}: '
        'segmentation ${(a.segmentationRecall * 100).toStringAsFixed(1)}%, '
        'text ${(a.textCaptureRate * 100).toStringAsFixed(1)}%, '
        'end-to-end ${(a.endToEndAccuracy * 100).toStringAsFixed(1)}%');
  }
  return 0;
}
