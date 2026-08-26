import 'dart:io';

/// Query normalisation, SPINE_BLUEPRINT.md 8.2.
///
/// The production implementation lives in the Go matching service (Faz 5).
/// This Dart copy exists so the Faz 0 spike can measure end-to-end accuracy
/// before that service is written; the two must agree, and the word lists are
/// read from `data/` precisely so they cannot drift.

/// Noise words dropped from a spine query. Straight from the blueprint list,
/// written in normalised form.
const noiseWords = <String>{
  'yayinlari',
  'kitap',
  'roman',
  'cilt',
  'vol',
  'edition',
  'press',
  'books',
  'classics',
};

const _diacritics = <String, String>{
  'ç': 'c', 'ğ': 'g', 'ı': 'i', 'İ': 'i', 'ö': 'o', 'ş': 's', 'ü': 'u',
  'â': 'a', 'ä': 'a', 'à': 'a', 'á': 'a', 'å': 'a', 'ã': 'a',
  'ê': 'e', 'ë': 'e', 'è': 'e', 'é': 'e',
  'î': 'i', 'ï': 'i', 'ì': 'i', 'í': 'i',
  'ô': 'o', 'ò': 'o', 'ó': 'o', 'õ': 'o', 'ø': 'o',
  'û': 'u', 'ù': 'u', 'ú': 'u',
  'ñ': 'n', 'ý': 'y', 'ÿ': 'y', 'ß': 'ss', 'æ': 'ae', 'œ': 'oe',
};

/// Case folds and strips diacritics.
///
/// Turkish dotted and dotless i are folded together on purpose: OCR cannot
/// reliably tell 'ı' from 'i' on a spine, so treating them as one letter
/// removes a whole class of false mismatches.
String foldCase(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    var char = String.fromCharCode(rune);
    // Fold the Turkish capitals before the generic lower casing, which would
    // otherwise turn 'I' into 'i' and 'İ' into 'i̇' (i plus a combining dot).
    if (char == 'İ' || char == 'I' || char == 'ı') {
      buffer.write('i');
      continue;
    }
    char = char.toLowerCase();
    buffer.write(_diacritics[char] ?? char);
  }
  return buffer.toString();
}

final _nonWord = RegExp(r'[^a-z0-9]+');
final _repeatedSpace = RegExp(r'\s+');

/// Result of normalising one raw spine query.
class NormalizedQuery {
  const NormalizedQuery({
    required this.raw,
    required this.text,
    required this.tokens,
    required this.publisherHint,
  });

  /// The query as it came off the spine.
  final String raw;

  /// Normalised text with noise words and the publisher name removed.
  final String text;

  /// [text] split into tokens.
  final List<String> tokens;

  /// The publisher recognised in the query, or null. Kept as a separate
  /// scoring signal rather than left in the query, where it would drown out
  /// the title.
  final String? publisherHint;

  bool get isEmpty => tokens.isEmpty;

  @override
  String toString() =>
      'NormalizedQuery("$text"${publisherHint == null ? '' : ', publisher=$publisherHint'})';
}

/// Normalises one raw spine query.
NormalizedQuery normalizeQuery(String raw, {required PublisherIndex publishers}) {
  final folded = foldCase(raw);
  final cleaned = folded.replaceAll(_nonWord, ' ').replaceAll(_repeatedSpace, ' ').trim();

  final publisher = publishers.findIn(cleaned);
  var withoutPublisher = cleaned;
  if (publisher != null) {
    withoutPublisher = cleaned.replaceAll(publisher, ' ');
  }

  final tokens = [
    for (final token in withoutPublisher.split(_repeatedSpace))
      if (token.isNotEmpty && !noiseWords.contains(token)) token,
  ];

  return NormalizedQuery(
    raw: raw,
    text: tokens.join(' '),
    tokens: tokens,
    publisherHint: publisher,
  );
}

/// Publisher names loaded from `data/publishers.txt`.
class PublisherIndex {
  PublisherIndex(this.names);

  /// Loads the shared list. Throws if the file is missing rather than quietly
  /// matching nothing, which would silently skew every score in the report.
  factory PublisherIndex.fromFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'publisher list not found at $path. It is shared with the Go matching '
        'service; pass --publishers to point at it.',
      );
    }
    final names = <String>[];
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      names.add(foldCase(trimmed).replaceAll(_nonWord, ' ').trim());
    }
    if (names.isEmpty) {
      throw StateError('publisher list at $path contains no entries');
    }
    // Longest first, so "penguin classics" wins over "penguin".
    names.sort((a, b) => b.length.compareTo(a.length));
    return PublisherIndex(names);
  }

  final List<String> names;

  /// The longest publisher name contained in [normalizedText], or null.
  String? findIn(String normalizedText) {
    final padded = ' $normalizedText ';
    for (final name in names) {
      if (padded.contains(' $name ')) return name;
    }
    return null;
  }
}
