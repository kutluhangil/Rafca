import 'normalize.dart';

/// One book the matcher can return.
class CatalogEntry {
  CatalogEntry({
    required this.id,
    required this.title,
    required this.authors,
    this.language,
    this.publisher,
  })  : searchBlob = foldCase('$title ${authors.join(' ')}')
            .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
            .trim(),
        searchTokens = foldCase('$title ${authors.join(' ')}')
            .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
            .split(RegExp(r'\s+'))
            .where((t) => t.isNotEmpty)
            .toSet();

  final String id;
  final String title;
  final List<String> authors;

  /// ISO 639-2 code as used by `books_index.language`, e.g. `tur`, `eng`.
  final String? language;
  final String? publisher;

  /// Mirror of the `search_blob` generated column in `books_index`.
  final String searchBlob;
  final Set<String> searchTokens;

  @override
  String toString() => '$title — ${authors.join(', ')}';
}

/// The set of books the spike matches against.
///
/// Faz 0 runs before the real Open Library index exists (Faz 4), so by default
/// the catalogue is the union of every book in the ground truth. That is an
/// optimistic setting: a real index holds a million confusable neighbours.
/// The report states which catalogue produced the numbers, and Faz 5 re-runs
/// the same queries against the real index as a golden test.
class Catalog {
  Catalog(this.entries, {required this.provenance});

  final List<CatalogEntry> entries;

  /// Human readable description of where these entries came from, printed in
  /// the report so a number is never quoted without its catalogue.
  final String provenance;

  int get size => entries.length;
}
