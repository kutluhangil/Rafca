import 'dart:convert';
import 'dart:io';

import 'package:spine_clustering/spine_clustering.dart';

import 'ocr_source.dart';

/// Apple Vision text recognition, reached through the `vision_ocr` Swift CLI.
///
/// Build it once with:
///   swiftc -O -o spike/tool/vision_ocr spike/tool/vision_ocr.swift
class VisionOcrSource implements OcrSource {
  VisionOcrSource({
    required this.binaryPath,
    this.languages = const ['tr-TR', 'en-US'],
    this.languageCorrection = false,
  });

  final String binaryPath;
  final List<String> languages;
  final bool languageCorrection;

  @override
  String get engineName =>
      'apple-vision (languages=${languages.join("+")}, '
      'correction=$languageCorrection)';

  @override
  Future<OcrPass> recognize(String imagePath, int rotation) async {
    final result = await Process.run(binaryPath, [
      '--image', imagePath,
      '--rotation', '$rotation',
      '--languages', languages.join(','),
      if (languageCorrection) '--language-correction',
    ]);

    if (result.exitCode != 0) {
      throw StateError(
        'vision_ocr failed for $imagePath at rotation $rotation\n'
        'exit code: ${result.exitCode}\n'
        'stderr: ${result.stderr}',
      );
    }

    final stdoutText = result.stdout as String;
    final Object? decoded;
    try {
      decoded = jsonDecode(stdoutText);
    } on FormatException catch (e) {
      throw StateError(
        'vision_ocr returned malformed JSON for $imagePath at rotation '
        '$rotation: $e\nfirst 200 chars: '
        '${stdoutText.substring(0, stdoutText.length.clamp(0, 200))}',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw StateError(
        'vision_ocr returned ${decoded.runtimeType}, expected a JSON object, '
        'for $imagePath at rotation $rotation',
      );
    }

    final originalWidth = decoded['originalWidth'] as int;
    final originalHeight = decoded['originalHeight'] as int;
    final rawElements = decoded['elements'] as List<dynamic>;

    final elements = <OcrTextElement>[];
    for (final raw in rawElements) {
      final map = raw as Map<String, dynamic>;
      final corners = [
        for (final corner in map['corners'] as List<dynamic>)
          unrotatePoint(
            Point2(
              _toDouble((corner as Map<String, dynamic>)['x']),
              _toDouble(corner['y']),
            ),
            rotation,
            originalWidth,
            originalHeight,
          ),
      ];
      elements.add(
        OcrTextElement(
          text: map['text'] as String,
          corners: corners,
          sourceRotation: rotation,
          confidence: map['confidence'] == null
              ? null
              : _toDouble(map['confidence']),
        ),
      );
    }

    return OcrPass(
      rotation: rotation,
      originalWidth: originalWidth,
      originalHeight: originalHeight,
      elements: elements,
    );
  }
}

/// JSON numbers arrive as `int` whenever the value happens to be whole, so a
/// confidence of exactly 1.0 would fail a plain `as double` cast.
double _toDouble(Object? value) {
  if (value is num) return value.toDouble();
  throw StateError('vision_ocr returned ${value.runtimeType} where a number was expected: $value');
}
