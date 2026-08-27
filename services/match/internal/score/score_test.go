package score_test

import (
	"testing"

	"github.com/kutluhangil/rafca/services/match/internal/score"
)

func TestTotalAppliesTheBlueprintWeights(t *testing.T) {
	config := score.DefaultConfig()
	got := config.Total(score.Signals{
		Trigram:         1,
		TextRank:        1,
		LanguageMatches: true,
		PublisherHint:   true,
	})
	if want := 1.0; got != want {
		t.Errorf("a perfect candidate scores %v, want %v", got, want)
	}
}

func TestBand(t *testing.T) {
	config := score.DefaultConfig()
	cases := []struct {
		name   string
		best   float64
		margin float64
		want   score.Band
	}{
		{"below the floor is unknown", 0.44, 0.44, score.Unknown},
		{"in the middle is review", 0.60, 0.60, score.Review},
		{"high with a clear gap is matched", 0.90, 0.20, score.Matched},
		{"high with a close runner up is review", 0.90, 0.05, score.Review},
		{"exactly on both thresholds is matched", 0.82, 0.12, score.Matched},
	}
	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			if got := config.Band(testCase.best, testCase.margin); got != testCase.want {
				t.Errorf("Band(%v, %v) = %v, want %v", testCase.best, testCase.margin, got, testCase.want)
			}
		})
	}
}

func TestRankKeepsTheBestThree(t *testing.T) {
	hits := []score.Hit[string]{
		{Candidate: "c", Score: 0.3},
		{Candidate: "a", Score: 0.9},
		{Candidate: "d", Score: 0.1},
		{Candidate: "b", Score: 0.5},
	}
	ranked := score.Rank(hits, score.DefaultConfig())
	if len(ranked) != 3 {
		t.Fatalf("len = %d, want 3", len(ranked))
	}
	for i, want := range []string{"a", "b", "c"} {
		if ranked[i].Candidate != want {
			t.Errorf("ranked[%d] = %q, want %q", i, ranked[i].Candidate, want)
		}
	}
}

func TestMarginOfASingleHitIsItsScore(t *testing.T) {
	if got := score.Margin([]score.Hit[string]{{Score: 0.7}}); got != 0.7 {
		t.Errorf("Margin = %v, want the score itself", got)
	}
	if got := score.Margin[string](nil); got != 0 {
		t.Errorf("Margin(nil) = %v, want 0", got)
	}
}
