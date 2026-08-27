package normalize_test

import (
	"reflect"
	"testing"

	"github.com/kutluhangil/rafca/services/match/internal/normalize"
)

func TestFoldCaseFoldsTurkishDottedAndDotlessI(t *testing.T) {
	cases := map[string]string{
		"İSTANBUL":       "istanbul",
		"ışık":           "isik",
		"Tutunamayanlar": "tutunamayanlar",
		"Oğuz Atay":      "oguz atay",
		"ŞÜKRAN":         "sukran",
		"Æon":            "aeon",
	}
	for input, want := range cases {
		if got := normalize.FoldCase(input); got != want {
			t.Errorf("FoldCase(%q) = %q, want %q", input, got, want)
		}
	}
}

// The Dart implementation in spike/lib/eval/normalize.dart produced the Faz 0
// numbers. These are the same inputs, so a drift between the two shows up here
// rather than as an unexplained accuracy change.
func TestNormaliseMatchesTheSpikeImplementation(t *testing.T) {
	publishers := normalize.NewPublishers([]string{
		"# a comment",
		"",
		"iletisim yayinlari",
		"can yayinlari",
		"penguin",
		"penguin classics",
	})

	cases := []struct {
		name      string
		raw       string
		text      string
		tokens    []string
		publisher string
	}{
		{
			name:      "publisher is lifted out of the query",
			raw:       "Tutunamayanlar Oğuz Atay İletişim Yayınları",
			text:      "tutunamayanlar oguz atay",
			tokens:    []string{"tutunamayanlar", "oguz", "atay"},
			publisher: "iletisim yayinlari",
		},
		{
			name:      "the longest publisher wins",
			raw:       "Dune Frank Herbert Penguin Classics",
			text:      "dune frank herbert",
			tokens:    []string{"dune", "frank", "herbert"},
			publisher: "penguin classics",
		},
		{
			name:      "noise words are dropped",
			raw:       "Sefiller roman cilt 2",
			text:      "sefiller 2",
			tokens:    []string{"sefiller", "2"},
			publisher: "",
		},
		{
			name:      "punctuation collapses to single spaces",
			raw:       "1984 -- George   Orwell!!",
			text:      "1984 george orwell",
			tokens:    []string{"1984", "george", "orwell"},
			publisher: "",
		},
	}

	for _, testCase := range cases {
		t.Run(testCase.name, func(t *testing.T) {
			query := normalize.Normalise(testCase.raw, publishers)
			if query.Text != testCase.text {
				t.Errorf("Text = %q, want %q", query.Text, testCase.text)
			}
			if !reflect.DeepEqual(query.Tokens, testCase.tokens) {
				t.Errorf("Tokens = %v, want %v", query.Tokens, testCase.tokens)
			}
			if query.PublisherHint != testCase.publisher {
				t.Errorf("PublisherHint = %q, want %q", query.PublisherHint, testCase.publisher)
			}
		})
	}
}

func TestNormaliseOfNothingIsEmpty(t *testing.T) {
	query := normalize.Normalise("--- ??? ---", normalize.NewPublishers(nil))
	if !query.IsEmpty() {
		t.Errorf("query = %+v, want empty", query)
	}
}

func TestPublishersIgnoresCommentsAndBlanks(t *testing.T) {
	publishers := normalize.NewPublishers([]string{"# header", "  ", "can yayinlari"})
	if publishers.Len() != 1 {
		t.Fatalf("Len = %d, want 1", publishers.Len())
	}
	if got := publishers.FindIn("sefiller can yayinlari"); got != "can yayinlari" {
		t.Errorf("FindIn = %q, want the publisher", got)
	}
	if got := publishers.FindIn("sefiller"); got != "" {
		t.Errorf("FindIn = %q, want no match", got)
	}
}
