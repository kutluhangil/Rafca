// Package score combines the retrieval signals into one number and turns that
// number into a confidence band (SPINE_BLUEPRINT.md 8.3, 8.4).
package score

import "sort"

// Band is how sure the matcher is (SPINE_BLUEPRINT.md 8.4).
type Band string

const (
	Matched Band = "matched"
	Review  Band = "review"
	Unknown Band = "unknown"
)

// Config holds the weights and thresholds. Faz 0 exists partly to calibrate
// these, so none of them are constants.
type Config struct {
	TrigramWeight   float64
	TextRankWeight  float64
	LanguageWeight  float64
	PublisherWeight float64

	MatchedThreshold float64
	MatchedMargin    float64
	ReviewThreshold  float64

	MaxHits int
}

// DefaultConfig is section 8.3 and 8.4 as written.
func DefaultConfig() Config {
	return Config{
		TrigramWeight:    0.55,
		TextRankWeight:   0.30,
		LanguageWeight:   0.10,
		PublisherWeight:  0.05,
		MatchedThreshold: 0.82,
		MatchedMargin:    0.12,
		ReviewThreshold:  0.45,
		MaxHits:          3,
	}
}

// Signals are what retrieval measured for one candidate.
type Signals struct {
	Trigram         float64
	TextRank        float64
	LanguageMatches bool
	PublisherHint   bool
}

// Total applies the section 8.3 weights.
func (c Config) Total(signals Signals) float64 {
	total := c.TrigramWeight*signals.Trigram + c.TextRankWeight*signals.TextRank
	if signals.LanguageMatches {
		total += c.LanguageWeight
	}
	if signals.PublisherHint {
		total += c.PublisherWeight
	}
	return total
}

// Band assigns a confidence band.
//
// A high score with a close runner up is REVIEW, not MATCHED: "Dune 1965"
// against "Dune 50th Anniversary" is exactly the case the correction flow
// exists for, and calling it MATCHED would put the wrong book in the library
// without ever asking.
func (c Config) Band(best, margin float64) Band {
	if best < c.ReviewThreshold {
		return Unknown
	}
	if best >= c.MatchedThreshold && margin >= c.MatchedMargin {
		return Matched
	}
	return Review
}

// Hit is one scored candidate.
type Hit[T any] struct {
	Candidate T
	Score     float64
	Signals   Signals
}

// Rank sorts hits best first and keeps at most MaxHits.
func Rank[T any](hits []Hit[T], config Config) []Hit[T] {
	sort.SliceStable(hits, func(i, j int) bool { return hits[i].Score > hits[j].Score })
	if config.MaxHits > 0 && len(hits) > config.MaxHits {
		hits = hits[:config.MaxHits]
	}
	return hits
}

// Margin is the gap between the best hit and the runner up. With a single hit
// there is nothing to be confused with, so the margin is the score itself.
func Margin[T any](hits []Hit[T]) float64 {
	if len(hits) == 0 {
		return 0
	}
	if len(hits) == 1 {
		return hits[0].Score
	}
	return hits[0].Score - hits[1].Score
}
