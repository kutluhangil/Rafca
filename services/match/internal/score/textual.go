package score

import "strings"

// This file holds the two textual signals of SPINE_BLUEPRINT.md 8.3.
//
// They are computed here rather than taken from Postgres, and that is a
// deliberate departure from the literal wording of section 8.3. Two reasons:
//
//  1. `ts_rank` is not on a 0..1 scale. A perfect full-text hit returns a raw
//     rank around 0.1, so the 0.30 term contributes at most about 0.03 and the
//     0.82 MATCHED threshold of section 8.4 becomes unreachable — every spine
//     would come back REVIEW no matter how exact the reading.
//  2. The Faz 0 accuracy report, which the Faz 5 golden test has to reproduce
//     within three points, was produced with these definitions
//     (spike/lib/eval/matcher.dart). Scoring with different ones would compare
//     two different numbers.
//
// Postgres still does the retrieval: the trigram and full-text indexes decide
// which rows are worth looking at. Only the ordering within that window is
// computed here.

// Trigrams builds the trigram set of a cleaned string the way pg_trgm does:
// each word padded with two leading spaces and one trailing space, then cut
// into three-character windows.
func Trigrams(cleaned string) map[string]struct{} {
	grams := map[string]struct{}{}
	for _, word := range strings.Fields(cleaned) {
		padded := "  " + word + " "
		for i := 0; i+3 <= len(padded); i++ {
			grams[padded[i:i+3]] = struct{}{}
		}
	}
	return grams
}

// TrigramSimilarity is the Jaccard overlap of two trigram sets, which is what
// pg_trgm's similarity() reports.
func TrigramSimilarity(a, b map[string]struct{}) float64 {
	if len(a) == 0 || len(b) == 0 {
		return 0
	}
	shared := 0
	for gram := range a {
		if _, ok := b[gram]; ok {
			shared++
		}
	}
	union := len(a) + len(b) - shared
	if union == 0 {
		return 0
	}
	return float64(shared) / float64(union)
}

// CoverageRank stands in for ts_rank: the harmonic mean of how much of the
// query the entry covers and how much of the entry the query accounts for.
//
// The second half is what stops a two-word query matching two of twelve words
// from outranking the same query matching two of three.
func CoverageRank(queryTokens []string, entryTokens map[string]struct{}) float64 {
	if len(queryTokens) == 0 || len(entryTokens) == 0 {
		return 0
	}
	hits := 0
	for _, token := range queryTokens {
		if _, ok := entryTokens[token]; ok {
			hits++
		}
	}
	if hits == 0 {
		return 0
	}
	coverage := float64(hits) / float64(len(queryTokens))
	precision := float64(hits) / float64(len(entryTokens))
	return 2 * coverage * precision / (coverage + precision)
}

// TokenSet turns a token slice into a set.
func TokenSet(tokens []string) map[string]struct{} {
	set := make(map[string]struct{}, len(tokens))
	for _, token := range tokens {
		if token != "" {
			set[token] = struct{}{}
		}
	}
	return set
}
