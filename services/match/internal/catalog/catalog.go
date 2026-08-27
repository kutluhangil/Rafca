// Package catalog retrieves candidate books from the Postgres index.
package catalog

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

// Book is one row of books_index.
type Book struct {
	ID          int64    `json:"id"`
	OLKey       string   `json:"ol_key,omitempty"`
	ISBN13      string   `json:"isbn13,omitempty"`
	Title       string   `json:"title"`
	Subtitle    string   `json:"subtitle,omitempty"`
	Authors     []string `json:"authors"`
	Publisher   string   `json:"publisher,omitempty"`
	PublishYear int      `json:"publish_year,omitempty"`
	Language    string   `json:"language,omitempty"`
	CoverURL    string   `json:"cover_url,omitempty"`
}

// Candidate is a book the index thinks is worth scoring.
//
// It carries no score: retrieval and scoring are separate steps here, for the
// reasons set out in internal/score/textual.go.
type Candidate struct {
	Book Book
}

// Store is the catalogue as the matcher sees it.
type Store struct {
	pool *pgxpool.Pool
	// candidateLimit caps how many rows one query pulls back for re-scoring.
	// The index orders by trigram similarity alone; the language and publisher
	// signals can only reorder within what it returns, so this is the width of
	// the window those signals get to work in.
	candidateLimit int
}

// New wraps a pool.
func New(pool *pgxpool.Pool, candidateLimit int) *Store {
	return &Store{pool: pool, candidateLimit: candidateLimit}
}

// searchQuery is retrieval, not scoring: it decides which rows are worth
// looking at and in what order to take them, and the matcher scores the window
// it returns.
//
// Both indexes are consulted. The trigram index catches a misread character;
// the full-text index catches a spine where OCR dropped a word entirely, which
// can push trigram similarity under pg_trgm's threshold even though the words
// that were read are exact.
const searchQuery = `
select id,
       coalesce(ol_key, ''), coalesce(isbn13, ''),
       title, coalesce(subtitle, ''), authors,
       coalesce(publisher, ''), coalesce(publish_year, 0),
       coalesce(language, ''), coalesce(cover_url, '')
  from books_index
 where search_blob % $1
    or search_tsv @@ plainto_tsquery('simple', $1)
 order by similarity(search_blob, $1) desc
 limit $2`

// Search returns the candidates the index considers close to query.
func (s *Store) Search(ctx context.Context, query string) ([]Candidate, error) {
	rows, err := s.pool.Query(ctx, searchQuery, query, s.candidateLimit)
	if err != nil {
		return nil, fmt.Errorf("catalog: searching for %q: %w", query, err)
	}
	defer rows.Close()

	candidates := make([]Candidate, 0, s.candidateLimit)
	for rows.Next() {
		var candidate Candidate
		if err := rows.Scan(
			&candidate.Book.ID,
			&candidate.Book.OLKey,
			&candidate.Book.ISBN13,
			&candidate.Book.Title,
			&candidate.Book.Subtitle,
			&candidate.Book.Authors,
			&candidate.Book.Publisher,
			&candidate.Book.PublishYear,
			&candidate.Book.Language,
			&candidate.Book.CoverURL,
		); err != nil {
			return nil, fmt.Errorf("catalog: scanning candidate for %q: %w", query, err)
		}
		candidates = append(candidates, candidate)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("catalog: reading candidates for %q: %w", query, err)
	}
	return candidates, nil
}

// Insert adds a book the local index did not have.
//
// Section 8.5: when the Google Books tier answers, the answer is written back
// so the index feeds itself and the same spine is a first-tier hit next time.
// Conflicts update rather than fail, because two devices can discover the same
// missing book within seconds of each other.
func (s *Store) Insert(ctx context.Context, book Book) (int64, error) {
	const insert = `
insert into books_index (ol_key, isbn13, title, subtitle, authors, publisher, publish_year, language, cover_url)
values (nullif($1, ''), nullif($2, ''), $3, nullif($4, ''), $5, nullif($6, ''), nullif($7, 0), nullif($8, ''), nullif($9, ''))
on conflict (ol_key) do update set
  isbn13 = excluded.isbn13,
  title = excluded.title,
  subtitle = excluded.subtitle,
  authors = excluded.authors,
  publisher = excluded.publisher,
  publish_year = excluded.publish_year,
  language = excluded.language,
  cover_url = excluded.cover_url
returning id`

	authors := book.Authors
	if authors == nil {
		authors = []string{}
	}

	var id int64
	err := s.pool.QueryRow(ctx, insert,
		book.OLKey, book.ISBN13, book.Title, book.Subtitle, authors,
		book.Publisher, book.PublishYear, book.Language, book.CoverURL,
	).Scan(&id)
	if err != nil {
		if err == pgx.ErrNoRows {
			return 0, fmt.Errorf("catalog: inserting %q returned no id", book.Title)
		}
		return 0, fmt.Errorf("catalog: inserting %q: %w", book.Title, err)
	}
	return id, nil
}

// Ping is the database half of the health endpoint.
func (s *Store) Ping(ctx context.Context) error {
	if err := s.pool.Ping(ctx); err != nil {
		return fmt.Errorf("catalog: ping: %w", err)
	}
	return nil
}
