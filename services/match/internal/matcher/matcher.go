// Package matcher turns spine text into ranked catalogue hits.
//
// It is the whole of SPINE_BLUEPRINT.md 8.2 to 8.5 in one place: normalise,
// retrieve, score, band, and fall back when the local index has nothing.
package matcher

import (
	"context"
	"fmt"
	"strings"

	"github.com/kutluhangil/rafca/services/match/internal/catalog"
	"github.com/kutluhangil/rafca/services/match/internal/normalize"
	"github.com/kutluhangil/rafca/services/match/internal/score"
)

// Source records which tier answered, so the client can tell a local hit from
// one that cost a call out to the internet.
type Source string

const (
	SourceIndex        Source = "index"
	SourceGoogleBooks  Source = "google_books"
	SourceNothingFound Source = "none"
)

// Fallback is the second tier of section 8.5.
type Fallback interface {
	// Lookup searches an external catalogue. Returning no books and no error
	// means the tier ran and found nothing, which is not a failure.
	Lookup(ctx context.Context, query string, languageHint string) ([]catalog.Book, error)
}

// Spine is one candidate read off a photo.
type Spine struct {
	// ID is the caller's handle for this spine; it is echoed back untouched so
	// a batch response can be zipped onto the crops that produced it.
	ID string `json:"id"`
	// Forward and Reverse are the two readings of a vertical spine. Which one
	// is upright cannot be known before matching, so both are scored and the
	// better one wins (SPINE_BLUEPRINT.md 8.3).
	Forward string `json:"forward"`
	Reverse string `json:"reverse"`
	// LanguageHint is the device language, worth 0.10 when it agrees with the
	// book's own language.
	LanguageHint string `json:"language_hint,omitempty"`
}

// Hit is one scored book.
type Hit struct {
	Book     catalog.Book `json:"book"`
	Score    float64      `json:"score"`
	Trigram  float64      `json:"trigram"`
	TextRank float64      `json:"text_rank"`
}

// Result is the answer for one spine.
type Result struct {
	ID         string     `json:"id"`
	Query      string     `json:"query"`
	Confidence score.Band `json:"confidence"`
	Source     Source     `json:"source"`
	Hits       []Hit      `json:"hits"`
}

// Matcher holds everything one request needs.
type Matcher struct {
	store      *catalog.Store
	publishers *normalize.Publishers
	config     score.Config
	fallback   Fallback
	// fallbackLanguage limits the second tier to the language it was added for
	// (SPINE_BLUEPRINT.md 8.5: Turkish books are what the Open Library subset
	// is thinnest on). Empty means every language may fall back.
	fallbackLanguage string
}

// New builds a matcher. fallback may be nil, which disables the second tier.
func New(store *catalog.Store, publishers *normalize.Publishers, config score.Config, fallback Fallback, fallbackLanguage string) *Matcher {
	return &Matcher{
		store:            store,
		publishers:       publishers,
		config:           config,
		fallback:         fallback,
		fallbackLanguage: fallbackLanguage,
	}
}

// MatchBatch scores every spine of one photo.
func (m *Matcher) MatchBatch(ctx context.Context, spines []Spine) ([]Result, error) {
	results := make([]Result, 0, len(spines))
	for _, spine := range spines {
		result, err := m.Match(ctx, spine)
		if err != nil {
			return nil, err
		}
		results = append(results, result)
	}
	return results, nil
}

// Match scores one spine, falling back when the local index cannot place it.
func (m *Matcher) Match(ctx context.Context, spine Spine) (Result, error) {
	result, err := m.matchLocally(ctx, spine)
	if err != nil {
		return Result{}, err
	}
	if result.Confidence != score.Unknown || m.fallback == nil {
		return result, nil
	}
	if m.fallbackLanguage != "" && spine.LanguageHint != m.fallbackLanguage {
		return result, nil
	}

	// Section 8.5, tier two. The result is written into books_index and then
	// re-scored through tier one, so the answer the client sees always comes
	// out of the same scorer and the index has learned the book for next time.
	query := result.Query
	if query == "" {
		return result, nil
	}
	books, err := m.fallback.Lookup(ctx, query, spine.LanguageHint)
	if err != nil {
		return Result{}, fmt.Errorf("matcher: fallback for %q: %w", query, err)
	}
	if len(books) == 0 {
		return result, nil
	}
	for _, book := range books {
		if _, err := m.store.Insert(ctx, book); err != nil {
			return Result{}, fmt.Errorf("matcher: writing back %q: %w", book.Title, err)
		}
	}

	retried, err := m.matchLocally(ctx, spine)
	if err != nil {
		return Result{}, err
	}
	retried.Source = SourceGoogleBooks
	return retried, nil
}

func (m *Matcher) matchLocally(ctx context.Context, spine Spine) (Result, error) {
	forward, forwardHits, err := m.scoreReading(ctx, spine.Forward, spine.LanguageHint)
	if err != nil {
		return Result{}, err
	}
	reverse, reverseHits, err := m.scoreReading(ctx, spine.Reverse, spine.LanguageHint)
	if err != nil {
		return Result{}, err
	}

	query, hits := forward, forwardHits
	if best(reverseHits) > best(forwardHits) {
		query, hits = reverse, reverseHits
	}

	source := SourceIndex
	if len(hits) == 0 {
		source = SourceNothingFound
	}

	return Result{
		ID:         spine.ID,
		Query:      query.Text,
		Confidence: m.config.Band(best(hits), score.Margin(hits)),
		Source:     source,
		Hits:       toHits(hits),
	}, nil
}

func (m *Matcher) scoreReading(ctx context.Context, raw, languageHint string) (normalize.Query, []score.Hit[catalog.Candidate], error) {
	query := normalize.Normalise(raw, m.publishers)
	if query.IsEmpty() {
		return query, nil, nil
	}

	candidates, err := m.store.Search(ctx, query.Text)
	if err != nil {
		return query, nil, err
	}

	queryGrams := score.Trigrams(query.Text)

	hits := make([]score.Hit[catalog.Candidate], 0, len(candidates))
	for _, candidate := range candidates {
		blob := normalize.Clean(candidate.Book.Title + " " + strings.Join(candidate.Book.Authors, " "))
		signals := score.Signals{
			Trigram:         score.TrigramSimilarity(queryGrams, score.Trigrams(blob)),
			TextRank:        score.CoverageRank(query.Tokens, score.TokenSet(normalize.Tokens(blob))),
			LanguageMatches: languageHint != "" && candidate.Book.Language == languageHint,
			PublisherHint:   publisherMatches(query.PublisherHint, candidate.Book.Publisher),
		}
		hits = append(hits, score.Hit[catalog.Candidate]{
			Candidate: candidate,
			Score:     m.config.Total(signals),
			Signals:   signals,
		})
	}
	return query, score.Rank(hits, m.config), nil
}

func publisherMatches(hint, publisher string) bool {
	if hint == "" || publisher == "" {
		return false
	}
	return strings.Contains(normalize.FoldCase(publisher), hint)
}

func best(hits []score.Hit[catalog.Candidate]) float64 {
	if len(hits) == 0 {
		return 0
	}
	return hits[0].Score
}

func toHits(scored []score.Hit[catalog.Candidate]) []Hit {
	hits := make([]Hit, 0, len(scored))
	for _, hit := range scored {
		hits = append(hits, Hit{
			Book:     hit.Candidate.Book,
			Score:    hit.Score,
			Trigram:  hit.Signals.Trigram,
			TextRank: hit.Signals.TextRank,
		})
	}
	return hits
}
