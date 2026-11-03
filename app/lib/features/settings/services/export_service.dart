import 'dart:convert';
import 'package:share_plus/share_plus.dart';

import '../../library/models/library_models.dart';

class ExportService {
  const ExportService();

  /// Converts a list of library books to RFC 4180 compliant CSV string.
  String generateCsv(List<LibraryBook> books) {
    final buffer = StringBuffer();
    // CSV Header
    buffer.writeln('id,title,author,publisher,publish_year,status,shelf_name,confidence,added_at');

    for (final book in books) {
      final fields = <String>[
        book.id,
        book.title,
        book.author,
        book.publisher ?? '',
        book.publishYear?.toString() ?? '',
        book.status.name,
        book.shelfName ?? '',
        book.confidence.name,
        book.addedAt.toIso8601String(),
      ];

      final escaped = fields.map((String f) {
        if (f.contains(',') || f.contains('"') || f.contains('\n')) {
          return '"${f.replaceAll('"', '""')}"';
        }
        return f;
      }).join(',');

      buffer.writeln(escaped);
    }

    return buffer.toString();
  }

  /// Converts a list of library books to pretty-printed JSON string.
  String generateJson(List<LibraryBook> books) {
    final list = books.map((book) {
      return {
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'publisher': book.publisher,
        'publish_year': book.publishYear,
        'status': book.status.name,
        'shelf_name': book.shelfName,
        'confidence': book.confidence.name,
        'spine_color': book.spineColor,
        'added_at': book.addedAt.toIso8601String(),
      };
    }).toList();

    return const JsonEncoder.withIndent('  ').convert(list);
  }

  /// Shares exported data as a text file via system share dialog.
  Future<void> shareExport(
    String content, {
    required String filename,
    required String mimeType,
    String? subject,
  }) async {
    final xFile = XFile.fromData(
      utf8.encode(content),
      name: filename,
      mimeType: mimeType,
    );
    await SharePlus.instance.share(
      ShareParams(
        files: [xFile],
        subject: subject,
      ),
    );
  }
}
