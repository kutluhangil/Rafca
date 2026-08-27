// Command index-bench measures the latency of a single trigram lookup against
// books_index.
//
// This is the Faz 4 acceptance gate (SPINE_BLUEPRINT.md 9): the index is only
// useful if one spine's worth of text comes back fast enough that a shelf of
// twenty can be matched while the user is still looking at the photo. The
// measurement is taken from the client, through pgx, because that is how the
// Faz 5 match service will pay for it.
package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"math/rand/v2"
	"os"
	"sort"
	"time"

	"github.com/jackc/pgx/v5"
)

// scoringQuery is the shape section 8.3 scores with, reduced to the two signals
// that actually touch an index. The language and publisher terms are constants
// per request, so they cannot change which rows the planner has to visit.
const scoringQuery = `
select id,
       0.55 * similarity(search_blob, $1)
     + 0.30 * ts_rank(search_tsv, plainto_tsquery('simple', $1)) as score
  from books_index
 where search_blob % $1
 order by score desc
 limit 3`

func main() {
	log.SetFlags(0)
	log.SetPrefix("index-bench: ")

	databaseURL := flag.String("database-url", os.Getenv("DATABASE_URL"), "libpq connection string")
	samples := flag.Int("queries", 500, "number of measured queries")
	warmup := flag.Int("warmup", 50, "queries run before measuring")
	budget := flag.Duration("budget", 80*time.Millisecond, "p95 the index has to stay under")
	threshold := flag.Float64("similarity-threshold", 0.3, "pg_trgm similarity threshold")
	flag.Parse()

	if *databaseURL == "" {
		log.Fatal("no database: pass -database-url or set DATABASE_URL")
	}
	if err := run(*databaseURL, *samples, *warmup, *budget, *threshold); err != nil {
		log.Fatal(err)
	}
}

func run(databaseURL string, samples, warmup int, budget time.Duration, threshold float64) error {
	ctx := context.Background()

	conn, err := pgx.Connect(ctx, databaseURL)
	if err != nil {
		return fmt.Errorf("connecting: %w", err)
	}
	defer conn.Close(ctx)

	if _, err := conn.Exec(ctx, "set search_path to public, extensions"); err != nil {
		return fmt.Errorf("setting search_path: %w", err)
	}
	if _, err := conn.Exec(ctx, fmt.Sprintf("set pg_trgm.similarity_threshold = %v", threshold)); err != nil {
		return fmt.Errorf("setting the similarity threshold: %w", err)
	}

	var rows int64
	if err := conn.QueryRow(ctx, "select count(*) from books_index").Scan(&rows); err != nil {
		return fmt.Errorf("counting rows: %w", err)
	}

	queries, err := sampleQueries(ctx, conn, samples+warmup)
	if err != nil {
		return err
	}
	if len(queries) < samples+warmup {
		return fmt.Errorf("wanted %d sample queries, the catalogue yielded %d", samples+warmup, len(queries))
	}

	for _, query := range queries[:warmup] {
		if _, err := runOnce(ctx, conn, query); err != nil {
			return err
		}
	}

	durations := make([]time.Duration, 0, samples)
	for _, query := range queries[warmup:] {
		elapsed, err := runOnce(ctx, conn, query)
		if err != nil {
			return err
		}
		durations = append(durations, elapsed)
	}
	sort.Slice(durations, func(i, j int) bool { return durations[i] < durations[j] })

	p95 := percentile(durations, 0.95)
	fmt.Printf("rows      %d\n", rows)
	fmt.Printf("queries   %d\n", len(durations))
	fmt.Printf("p50       %v\n", percentile(durations, 0.50))
	fmt.Printf("p95       %v\n", p95)
	fmt.Printf("p99       %v\n", percentile(durations, 0.99))
	fmt.Printf("max       %v\n", durations[len(durations)-1])
	fmt.Printf("budget    %v\n", budget)

	if p95 > budget {
		return fmt.Errorf("p95 %v is over the %v budget", p95, budget)
	}
	fmt.Println("result    PASS")
	return nil
}

func runOnce(ctx context.Context, conn *pgx.Conn, query string) (time.Duration, error) {
	started := time.Now()
	rows, err := conn.Query(ctx, scoringQuery, query)
	if err != nil {
		return 0, fmt.Errorf("querying %q: %w", query, err)
	}
	for rows.Next() {
		var id int64
		var score float64
		if err := rows.Scan(&id, &score); err != nil {
			rows.Close()
			return 0, fmt.Errorf("scanning result for %q: %w", query, err)
		}
	}
	if err := rows.Err(); err != nil {
		return 0, fmt.Errorf("reading results for %q: %w", query, err)
	}
	return time.Since(started), nil
}

// sampleQueries draws real catalogue text, because a synthetic query would only
// measure the index against strings the index has never had to separate.
func sampleQueries(ctx context.Context, conn *pgx.Conn, count int) ([]string, error) {
	rows, err := conn.Query(ctx, `
		select title, coalesce(array_to_string(authors, ' '), '')
		  from books_index
		 order by random()
		 limit $1`, count)
	if err != nil {
		return nil, fmt.Errorf("sampling queries: %w", err)
	}
	defer rows.Close()

	queries := make([]string, 0, count)
	for rows.Next() {
		var title, authors string
		if err := rows.Scan(&title, &authors); err != nil {
			return nil, fmt.Errorf("scanning sample: %w", err)
		}
		queries = append(queries, spineText(title, authors))
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("reading samples: %w", err)
	}
	return queries, nil
}

// spineText approximates what OCR hands the matcher: the title, usually the
// author, and rarely both in the order the catalogue stores them.
func spineText(title, authors string) string {
	switch rand.IntN(3) {
	case 0:
		return title
	case 1:
		if authors == "" {
			return title
		}
		return authors + " " + title
	default:
		if authors == "" {
			return title
		}
		return title + " " + authors
	}
}

func percentile(sorted []time.Duration, fraction float64) time.Duration {
	if len(sorted) == 0 {
		return 0
	}
	index := int(float64(len(sorted)-1) * fraction)
	return sorted[index]
}
