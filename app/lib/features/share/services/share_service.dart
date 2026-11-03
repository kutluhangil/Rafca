import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  const ShareService();

  /// Captures the widget subtree wrapped in a [RepaintBoundary] as PNG bytes.
  Future<Uint8List?> capturePng(GlobalKey boundaryKey) async {
    try {
      final boundary = boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  /// Shares PNG image bytes via system share dialog.
  Future<void> shareImage(
    Uint8List pngBytes, {
    String? text,
    String? subject,
  }) async {
    final xFile = XFile.fromData(
      pngBytes,
      name: 'rafca_collection.png',
      mimeType: 'image/png',
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        text: text,
        subject: subject,
      ),
    );
  }

  /// Shares plain text representation of the collection.
  Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        subject: subject,
      ),
    );
  }
}
