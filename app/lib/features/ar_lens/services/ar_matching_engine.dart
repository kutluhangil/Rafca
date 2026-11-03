import 'package:flutter/material.dart';

import '../../../core/database/tables.dart';
import '../../library/models/library_models.dart';
import '../models/ar_lens_models.dart';

/// Pre-indexed book in the user's library for microsecond trigram matching.
class ArIndexEntry {
  const ArIndexEntry({
    required this.title,
    required this.author,
    required this.status,
    required this.trigrams,
    this.catalogBookId,
  });

  final String title;
  final String author;
  final ReadingStatus status;
  final Set<String> trigrams;
  final int? catalogBookId;
}

/// Real-time trigram matching engine for Live AR HUD.
///
/// Compares camera OCR candidate text against the user's library in-memory (<2ms latency).
class ArMatchingEngine {
  ArMatchingEngine({List<ArIndexEntry>? initialIndex})
      : _index = initialIndex ?? [];

  List<ArIndexEntry> _index;

  /// Updates the in-memory index from user's current library books.
  void updateIndex(List<LibraryBook> books) {
    _index = books.map((b) {
      final combined = '${b.title} ${b.author}';
      return ArIndexEntry(
        title: b.title,
        author: b.author,
        status: b.status,
        catalogBookId: b.catalogBookId,
        trigrams: makeTrigrams(combined),
      );
    }).toList();
  }

  /// Classifies a raw recognized OCR text fragment against the library.
  ArDetectedItem classifyText({
    required String id,
    required String rawText,
    required Rect normalizedRect,
  }) {
    final queryGrams = makeTrigrams(rawText);
    if (queryGrams.isEmpty || _index.isEmpty) {
      return ArDetectedItem(
        id: id,
        rawText: rawText,
        normalizedRect: normalizedRect,
        status: ArBookStatus.notOwned,
        matchedTitle: _extractProbableTitle(rawText),
      );
    }

    ArIndexEntry? bestEntry;
    var bestSimilarity = 0.0;

    for (final entry in _index) {
      final sim = trigramSimilarity(queryGrams, entry.trigrams);
      if (sim > bestSimilarity) {
        bestSimilarity = sim;
        bestEntry = entry;
      }
    }

    // Match threshold: 0.48 allows for camera angles and minor OCR typos
    if (bestSimilarity >= 0.48 && bestEntry != null) {
      final status = bestEntry.status == ReadingStatus.read
          ? ArBookStatus.ownedRead
          : ArBookStatus.ownedUnread;

      return ArDetectedItem(
        id: id,
        rawText: rawText,
        normalizedRect: normalizedRect,
        status: status,
        matchedTitle: bestEntry.title,
        matchedAuthor: bestEntry.author,
        catalogBookId: bestEntry.catalogBookId,
        similarity: bestSimilarity,
      );
    }

    return ArDetectedItem(
      id: id,
      rawText: rawText,
      normalizedRect: normalizedRect,
      status: ArBookStatus.notOwned,
      matchedTitle: _extractProbableTitle(rawText),
      similarity: bestSimilarity,
    );
  }

  /// Splits text by line and selects first meaningful line as title candidate.
  static String _extractProbableTitle(String text) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.length >= 3)
        .toList();
    if (lines.isEmpty) return text.trim();
    return lines.first;
  }

  /// Extracts 3-character character n-grams matching PostgreSQL `pg_trgm`.
  static Set<String> makeTrigrams(String text) {
    final clean = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\sğüşıöçĞÜŞİÖÇ]'), ' ')
        .trim();
    final words = clean.split(RegExp(r'\s+'));
    final grams = <String>{};

    for (final word in words) {
      if (word.isEmpty) continue;
      final padded = '  $word ';
      for (var i = 0; i + 3 <= padded.length; i++) {
        grams.add(padded.substring(i, i + 3));
      }
    }
    return grams;
  }

  /// Computes Jaccard index similarity of two trigram sets (0.0 to 1.0).
  static double trigramSimilarity(Set<String> a, Set<String> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;
    var shared = 0;
    for (final gram in a) {
      if (b.contains(gram)) shared++;
    }
    final union = a.length + b.length - shared;
    if (union == 0) return 0.0;
    return shared / union;
  }
}
