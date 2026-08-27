package matcher_test

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/kutluhangil/rafca/services/match/internal/catalog"
	"github.com/kutluhangil/rafca/services/match/internal/matcher"
	"github.com/kutluhangil/rafca/services/match/internal/normalize"
	"github.com/kutluhangil/rafca/services/match/internal/score"
)

// The golden set is SPINE_BLUEPRINT.md section 9's regression gate. It runs the
// real pipeline — normalise, retrieve out of Postgres, score, band — because
// the parts it is meant to protect are the ones only the database can produce:
// which rows the trigram and full-text indexes return, and in what order.
//
// databaseURLVar names a database the test owns outright. It inserts its
// fixture catalogue into books_index and expects to be the only writer, so it
// must never be pointed at the development database. `make match-golden`
// rebuilds a throwaway one from the migrations and passes it in.
const databaseURLVar = "RAFCA_GOLDEN_DATABASE_URL"

// publishersPath is data/publishers.txt from this package's directory. The
// publisher list is a scoring signal, so the golden bands only reproduce when
// the test reads the same file the service does.
const publishersPath = "../../../../data/publishers.txt"

type goldenFile struct {
	Provenance  string         `json:"provenance"`
	MinAccuracy float64        `json:"min_accuracy"`
	Catalog     []catalog.Book `json:"catalog"`
	Cases       []goldenCase   `json:"cases"`
}

type goldenCase struct {
	Name         string `json:"name"`
	Forward      string `json:"forward"`
	Reverse      string `json:"reverse"`
	LanguageHint string `json:"language_hint"`
	ExpectOLKey  string `json:"expect_ol_key"`
	ExpectBand   string `json:"expect_band"`
}

func TestGolden(t *testing.T) {
	databaseURL := os.Getenv(databaseURLVar)
	if databaseURL == "" {
		t.Skipf("%s is unset; run `make match-golden` to build the throwaway database and run this gate", databaseURLVar)
	}

	golden := readGolden(t)
	ctx := context.Background()

	pool, err := pgxpool.New(ctx, databaseURL)
	if err != nil {
		t.Fatalf("connecting to %s: %v", databaseURLVar, err)
	}
	t.Cleanup(pool.Close)

	store := catalog.New(pool, 20)
	requireEmptyCatalogue(ctx, t, pool)
	for _, book := range golden.Catalog {
		if _, err := store.Insert(ctx, book); err != nil {
			t.Fatalf("seeding %q: %v", book.Title, err)
		}
	}

	// No fallback: the gate measures the local index, and a tier that calls out
	// to Google Books would make the result depend on the network.
	match := matcher.New(store, readPublishers(t), score.DefaultConfig(), nil, "")

	passed := 0
	for _, testCase := range golden.Cases {
		result, err := match.Match(ctx, matcher.Spine{
			ID:           testCase.Name,
			Forward:      testCase.Forward,
			Reverse:      testCase.Reverse,
			LanguageHint: testCase.LanguageHint,
		})
		if err != nil {
			t.Fatalf("%s: %v", testCase.Name, err)
		}
		if failure := check(testCase, result); failure != "" {
			t.Errorf("%s: %s", testCase.Name, failure)
			continue
		}
		passed++
	}

	accuracy := float64(passed) / float64(len(golden.Cases))
	if accuracy < golden.MinAccuracy {
		t.Errorf("accuracy %.3f is below the recorded %.3f (%d of %d cases)",
			accuracy, golden.MinAccuracy, passed, len(golden.Cases))
	}
}

// check reports why one case failed, or "" when it passed.
func check(testCase goldenCase, result matcher.Result) string {
	if string(result.Confidence) != testCase.ExpectBand {
		return "band " + string(result.Confidence) + ", want " + testCase.ExpectBand
	}
	if testCase.ExpectOLKey == "" {
		return ""
	}
	if len(result.Hits) == 0 {
		return "no hits, want " + testCase.ExpectOLKey
	}
	if result.Hits[0].Book.OLKey != testCase.ExpectOLKey {
		return "top hit " + result.Hits[0].Book.OLKey + ", want " + testCase.ExpectOLKey
	}
	return ""
}

// requireEmptyCatalogue refuses to run against a database that already holds
// books. The fixture bands depend on the catalogue holding exactly these six
// rows, and a stray million-row index would both wreck the expectations and
// leave the test's own rows behind in something real.
func requireEmptyCatalogue(ctx context.Context, t *testing.T, pool *pgxpool.Pool) {
	t.Helper()
	var count int64
	if err := pool.QueryRow(ctx, "select count(*) from books_index").Scan(&count); err != nil {
		t.Fatalf("counting books_index: %v", err)
	}
	if count != 0 {
		t.Fatalf("books_index already holds %d rows; %s must point at a database freshly built by supabase/harness/apply.sh, not one with a catalogue in it", count, databaseURLVar)
	}
}

func readGolden(t *testing.T) goldenFile {
	t.Helper()
	path := filepath.Join("testdata", "golden.json")
	raw, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("reading %s: %v", path, err)
	}
	var golden goldenFile
	if err := json.Unmarshal(raw, &golden); err != nil {
		t.Fatalf("parsing %s: %v", path, err)
	}
	if len(golden.Cases) == 0 {
		t.Fatalf("%s holds no cases", path)
	}
	return golden
}

func readPublishers(t *testing.T) *normalize.Publishers {
	t.Helper()
	raw, err := os.ReadFile(publishersPath)
	if err != nil {
		t.Fatalf("reading %s: %v", publishersPath, err)
	}
	publishers := normalize.NewPublishers(strings.Split(string(raw), "\n"))
	if publishers.Len() == 0 {
		t.Fatalf("%s holds no publisher names", publishersPath)
	}
	return publishers
}
