import 'catalog.dart';
import 'normalize.dart';

/// Confidence bands, SPINE_BLUEPRINT.md 8.4.
enum Confidence { matched, review, unknown }

/// One scored catalogue hit.
class ScoredHit {
  const ScoredHit({
    required this.entry,
    required this.score,
    required this.trigram,
    required this.textRank,
  });

  final CatalogEntry entry;
  final double score;
  final double trigram;
  final double textRank;
}

/// The matcher's answer for one spine.
class MatchResult {
  const MatchResult({
    required this.query,
    required this.hits,
    required this.confidence,
  });

  /// The normalised query that scored highest, forward or reverse.
  final NormalizedQuery query;

  /// Top hits, best first. At most three, as `/v1/match` returns.
  final List<ScoredHit> hits;

  final Confidence confidence;

  ScoredHit? get best => hits.isEmpty ? null : hits.first;
  double get bestScore => hits.isEmpty ? 0 : hits.first.score;

  /// Gap to the runner up. A small gap is what turns a high score into
  /// REVIEW: "Dune 1965" against "Dune 50th Anniversary".
  double get margin => hits.length < 2 ? bestScore : hits[0].score - hits[1].score;
}

/// Weights and thresholds from SPINE_BLUEPRINT.md 8.3 and 8.4. Faz 0 exists
/// partly to check that these numbers are calibrated, so they are parameters.
class MatchConfig {
  const MatchConfig({
    this.trigramWeight = 0.55,
    this.textRankWeight = 0.30,
    this.languageWeight = 0.10,
    this.publisherWeight = 0.05,
    this.matchedThreshold = 0.82,
    this.matchedMargin = 0.12,
    this.reviewThreshold = 0.45,
    this.maxHits = 3,
  });

  final double trigramWeight;
  final double textRankWeight;
  final double languageWeight;
  final double publisherWeight;
  final double matchedThreshold;
  final double matchedMargin;
  final double reviewThreshold;
  final int maxHits;
}

/// Trigram set of a string, the way `pg_trgm` builds one: each word padded
/// with two leading spaces and one trailing space, then cut into 3-grams.
Set<String> trigrams(String normalized) {
  final result = <String>{};
  for (final word in normalized.split(RegExp(r'\s+'))) {
    if (word.isEmpty) continue;
    final padded = '  $word ';
    for (var i = 0; i + 3 <= padded.length; i++) {
      result.add(padded.substring(i, i + 3));
    }
  }
  return result;
}

/// Jaccard overlap of two trigram sets, matching `similarity()` in `pg_trgm`.
double trigramSimilarity(Set<String> a, Set<String> b) {
  if (a.isEmpty || b.isEmpty) return 0;
  var shared = 0;
  for (final gram in a) {
    if (b.contains(gram)) shared++;
  }
  final union = a.length + b.length - shared;
  if (union == 0) return 0;
  return shared / union;
}

/// Stand-in for `ts_rank(search_tsv, plainto_tsquery(query))`: the fraction of
/// query tokens present in the entry, damped by how many extra tokens the
/// entry carries.
///
/// Postgres ranks by term frequency and position; this approximates only the
/// coverage part. Faz 5 replaces it with the real `ts_rank` and the golden
/// test is what proves the two agree within tolerance.
double approximateTextRank(List<String> queryTokens, Set<String> entryTokens) {
  if (queryTokens.isEmpty || entryTokens.isEmpty) return 0;
  var hits = 0;
  for (final token in queryTokens) {
    if (entryTokens.contains(token)) hits++;
  }
  if (hits == 0) return 0;
  final coverage = hits / queryTokens.length;
  final precision = hits / entryTokens.length;
  // Harmonic mean, so a query matching 2 of 2 tokens in a 12 token entry does
  // not outrank one matching 2 of 2 in a 3 token entry.
  return 2 * coverage * precision / (coverage + precision);
}

/// Scores one normalised query against the whole catalogue.
///
/// SPINE_BLUEPRINT.md 8.3.
List<ScoredHit> scoreQuery(
  NormalizedQuery query,
  Catalog catalog, {
  String? languageHint,
  MatchConfig config = const MatchConfig(),
}) {
  if (query.isEmpty) return const [];
  final queryGrams = trigrams(query.text);

  final hits = <ScoredHit>[];
  for (final entry in catalog.entries) {
    final trigram = trigramSimilarity(queryGrams, trigrams(entry.searchBlob));
    final textRank = approximateTextRank(query.tokens, entry.searchTokens);
    final languageMatch =
        languageHint != null && entry.language == languageHint ? 1.0 : 0.0;
    final publisherMatch = query.publisherHint != null &&
            entry.publisher != null &&
            foldCase(entry.publisher!).contains(query.publisherHint!)
        ? 1.0
        : 0.0;

    final score = config.trigramWeight * trigram +
        config.textRankWeight * textRank +
        config.languageWeight * languageMatch +
        config.publisherWeight * publisherMatch;

    hits.add(ScoredHit(
      entry: entry,
      score: score,
      trigram: trigram,
      textRank: textRank,
    ));
  }

  hits.sort((a, b) => b.score.compareTo(a.score));
  return hits.take(config.maxHits).toList();
}

/// Assigns a confidence band, SPINE_BLUEPRINT.md 8.4.
///
/// A high score with a close runner up is REVIEW, not MATCHED. That rule is
/// the whole reason the correction flow exists.
Confidence bandFor(
  double bestScore,
  double margin, {
  MatchConfig config = const MatchConfig(),
}) {
  if (bestScore < config.reviewThreshold) return Confidence.unknown;
  if (bestScore >= config.matchedThreshold && margin >= config.matchedMargin) {
    return Confidence.matched;
  }
  return Confidence.review;
}

/// Runs both reading directions of a spine and keeps the better one, as
/// SPINE_BLUEPRINT.md 8.3 requires.
MatchResult matchSpine({
  required String forwardText,
  required String reverseText,
  required Catalog catalog,
  required PublisherIndex publishers,
  String? languageHint,
  MatchConfig config = const MatchConfig(),
}) {
  final forward = normalizeQuery(forwardText, publishers: publishers);
  final reverse = normalizeQuery(reverseText, publishers: publishers);

  final forwardHits =
      scoreQuery(forward, catalog, languageHint: languageHint, config: config);
  final reverseHits =
      scoreQuery(reverse, catalog, languageHint: languageHint, config: config);

  final forwardBest = forwardHits.isEmpty ? 0.0 : forwardHits.first.score;
  final reverseBest = reverseHits.isEmpty ? 0.0 : reverseHits.first.score;

  final useForward = forwardBest >= reverseBest;
  final query = useForward ? forward : reverse;
  final hits = useForward ? forwardHits : reverseHits;

  final result = MatchResult(
    query: query,
    hits: hits,
    confidence: Confidence.unknown,
  );
  return MatchResult(
    query: query,
    hits: hits,
    confidence: bandFor(result.bestScore, result.margin, config: config),
  );
}
