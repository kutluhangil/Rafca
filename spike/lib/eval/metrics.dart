import 'package:spine_clustering/spine_clustering.dart';

import 'catalog.dart';
import 'ground_truth.dart';
import 'matcher.dart';
import 'normalize.dart';

/// One spine candidate after matching, kept so the report can show the actual
/// text that was read rather than only an aggregate.
class CandidateOutcome {
  const CandidateOutcome({
    required this.photoFile,
    required this.candidateId,
    required this.rawTextForward,
    required this.rawTextReverse,
    required this.result,
    required this.linkedBook,
    required this.isCorrect,
  });

  final String photoFile;
  final String candidateId;
  final String rawTextForward;
  final String rawTextReverse;
  final MatchResult result;

  /// The ground-truth book this candidate was judged to be looking at, or
  /// null when it could not be linked to any of them.
  final GroundTruthBook? linkedBook;

  /// The top catalogue hit is the linked book and the band is not UNKNOWN.
  final bool isCorrect;
}

/// Metric definitions for SPINE_BLUEPRINT.md 2.1.
///
/// The blueprint names the three rates but not how to compute them, and the
/// GO/NO-GO gate turns on the numbers, so the definitions are fixed here and
/// restated in the report:
///
/// * segmentation recall — a ground-truth book counts as segmented when some
///   candidate links to it above [linkThreshold]. Links are one to one, so
///   one candidate covering two books scores one, not two.
/// * text capture rate — of the segmented books, those where at least two
///   meaningful words of the real title were read.
/// * end-to-end accuracy — books whose correct catalogue entry is the top hit
///   with a band other than UNKNOWN.
class PhotoMetrics {
  const PhotoMetrics({
    required this.photo,
    required this.candidateCount,
    required this.segmentedBooks,
    required this.textCapturedBooks,
    required this.correctBooks,
    required this.outcomes,
  });

  final GroundTruthPhoto photo;

  /// How many spines the clustering produced.
  final int candidateCount;

  final int segmentedBooks;
  final int textCapturedBooks;
  final int correctBooks;
  final List<CandidateOutcome> outcomes;

  int get bookCount => photo.books.length;
}

/// Aggregate over a set of photos.
class Aggregate {
  const Aggregate({
    required this.photoCount,
    required this.bookCount,
    required this.candidateCount,
    required this.segmentedBooks,
    required this.textCapturedBooks,
    required this.correctBooks,
  });

  factory Aggregate.of(Iterable<PhotoMetrics> metrics) {
    var photos = 0, books = 0, candidates = 0;
    var segmented = 0, captured = 0, correct = 0;
    for (final m in metrics) {
      photos++;
      books += m.bookCount;
      candidates += m.candidateCount;
      segmented += m.segmentedBooks;
      captured += m.textCapturedBooks;
      correct += m.correctBooks;
    }
    return Aggregate(
      photoCount: photos,
      bookCount: books,
      candidateCount: candidates,
      segmentedBooks: segmented,
      textCapturedBooks: captured,
      correctBooks: correct,
    );
  }

  final int photoCount;
  final int bookCount;
  final int candidateCount;
  final int segmentedBooks;
  final int textCapturedBooks;
  final int correctBooks;

  double get segmentationRecall => _rate(segmentedBooks, bookCount);
  double get textCaptureRate => _rate(textCapturedBooks, bookCount);
  double get endToEndAccuracy => _rate(correctBooks, bookCount);

  /// Candidates produced per real book. Above 1 means spines were split, below
  /// 1 means neighbouring spines merged.
  double get segmentationRatio => _rate(candidateCount, bookCount);

  static double _rate(int part, int whole) => whole == 0 ? 0 : part / whole;
}

/// Minimum link score for a candidate to be considered "looking at" a book.
/// Deliberately permissive: segmentation recall asks whether a cluster formed,
/// not whether the text was good.
const linkThreshold = 0.18;

/// Builds a catalogue from every book in the ground truth, deduplicated.
///
/// Returns the catalogue plus the entry id for each ground-truth book, so
/// end-to-end correctness can be checked by identity rather than by comparing
/// title strings again.
({Catalog catalog, Map<GroundTruthBook, String> idOf}) catalogFromGroundTruth(
  GroundTruth truth,
) {
  final byBlob = <String, CatalogEntry>{};
  final idOf = <GroundTruthBook, String>{};

  for (final photo in truth.photos) {
    for (final book in photo.books) {
      final probe = CatalogEntry(
        id: 'gt-${byBlob.length + 1}',
        title: book.title,
        authors: book.author.isEmpty ? const [] : [book.author],
        language: book.language,
        publisher: book.publisher,
      );
      final existing = byBlob[probe.searchBlob];
      if (existing != null) {
        idOf[book] = existing.id;
        continue;
      }
      byBlob[probe.searchBlob] = probe;
      idOf[book] = probe.id;
    }
  }

  return (
    catalog: Catalog(
      byBlob.values.toList(),
      provenance: 'ground truth union, ${byBlob.length} distinct books',
    ),
    idOf: idOf,
  );
}

/// Scores one photo's candidates against its ground truth.
PhotoMetrics evaluatePhoto({
  required GroundTruthPhoto photo,
  required List<SpineCandidate> candidates,
  required Catalog catalog,
  required Map<GroundTruthBook, String> idOf,
  required PublisherIndex publishers,
  MatchConfig config = const MatchConfig(),
}) {
  final results = [
    for (final candidate in candidates)
      matchSpine(
        forwardText: candidate.rawTextForward,
        reverseText: candidate.rawTextReverse,
        catalog: catalog,
        publishers: publishers,
        languageHint: photo.languageHint,
        config: config,
      ),
  ];

  final linkedBook = _linkCandidatesToBooks(
    candidates: candidates,
    results: results,
    books: photo.books,
    publishers: publishers,
  );

  final correctIds = <String>{};
  final outcomes = <CandidateOutcome>[];
  var textCaptured = 0;

  for (var i = 0; i < candidates.length; i++) {
    final book = linkedBook[i];
    final result = results[i];
    final topId = result.best?.entry.id;
    final expectedId = book == null ? null : idOf[book];
    final isCorrect = topId != null &&
        expectedId != null &&
        topId == expectedId &&
        result.confidence != Confidence.unknown;

    if (isCorrect) correctIds.add(expectedId);
    if (book != null &&
        _readEnoughOfTitle(
          candidate: candidates[i],
          book: book,
          publishers: publishers,
        )) {
      textCaptured++;
    }

    outcomes.add(CandidateOutcome(
      photoFile: photo.file,
      candidateId: candidates[i].id,
      rawTextForward: candidates[i].rawTextForward,
      rawTextReverse: candidates[i].rawTextReverse,
      result: result,
      linkedBook: book,
      isCorrect: isCorrect,
    ));
  }

  // A book is correct once, even if two candidates both resolve to it.
  final correctBooks = photo.books
      .map((book) => idOf[book])
      .whereType<String>()
      .toSet()
      .where(correctIds.contains)
      .length;

  return PhotoMetrics(
    photo: photo,
    candidateCount: candidates.length,
    segmentedBooks: linkedBook.values.toSet().length,
    textCapturedBooks: textCaptured,
    correctBooks: correctBooks,
    outcomes: outcomes,
  );
}

/// Greedy one-to-one assignment of candidates to books, strongest pair first.
Map<int, GroundTruthBook> _linkCandidatesToBooks({
  required List<SpineCandidate> candidates,
  required List<MatchResult> results,
  required List<GroundTruthBook> books,
  required PublisherIndex publishers,
}) {
  final bookGrams = [
    for (final book in books)
      trigrams(
        normalizeQuery('${book.title} ${book.author}', publishers: publishers)
            .text,
      ),
  ];

  final pairs = <({int candidate, int book, double score})>[];
  for (var c = 0; c < candidates.length; c++) {
    final queryGrams = trigrams(results[c].query.text);
    for (var b = 0; b < books.length; b++) {
      final score = trigramSimilarity(queryGrams, bookGrams[b]);
      if (score >= linkThreshold) {
        pairs.add((candidate: c, book: b, score: score));
      }
    }
  }
  pairs.sort((a, b) => b.score.compareTo(a.score));

  final linked = <int, GroundTruthBook>{};
  final takenBooks = <int>{};
  for (final pair in pairs) {
    if (linked.containsKey(pair.candidate)) continue;
    if (takenBooks.contains(pair.book)) continue;
    linked[pair.candidate] = books[pair.book];
    takenBooks.add(pair.book);
  }
  return linked;
}

/// Whether at least two meaningful words of the real title were read.
///
/// Titles with fewer than two meaningful words, such as "1984", require all
/// of them.
bool _readEnoughOfTitle({
  required SpineCandidate candidate,
  required GroundTruthBook book,
  required PublisherIndex publishers,
}) {
  final titleTokens = normalizeQuery(book.title, publishers: publishers)
      .tokens
      .where((t) => t.length >= 3 || RegExp(r'^\d+$').hasMatch(t))
      .toList();
  if (titleTokens.isEmpty) return false;

  final read = {
    ...normalizeQuery(candidate.rawTextForward, publishers: publishers).tokens,
  };
  final hits = titleTokens.where(read.contains).length;
  final needed = titleTokens.length < 2 ? titleTokens.length : 2;
  return hits >= needed;
}
