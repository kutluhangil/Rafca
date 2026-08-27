// Package openlibrary reads the Open Library bulk dumps and projects them onto
// the columns books_index actually stores.
//
// The dumps are line-oriented TSV whose fifth column is the record's JSON. They
// are far wider than Rafça needs — subjects, physical dimensions, source
// records — so nothing beyond the projection is kept in memory.
package openlibrary

import (
	"encoding/json"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"
)

// dumpColumns is the fixed shape of a dump line: type, key, revision,
// last-modified, JSON.
const dumpColumns = 5

// ErrNotJSON reports a line that does not carry a record.
var ErrNotJSON = errors.New("openlibrary: line has no JSON column")

// Ref is Open Library's pointer to another record.
type Ref struct {
	Key string `json:"key"`
}

// Edition is the subset of an edition record Rafça reads.
type Edition struct {
	Key         string   `json:"key"`
	Title       string   `json:"title"`
	Subtitle    string   `json:"subtitle"`
	ISBN13      []string `json:"isbn_13"`
	Publishers  []string `json:"publishers"`
	PublishDate string   `json:"publish_date"`
	Languages   []Ref    `json:"languages"`
	Authors     []Ref    `json:"authors"`
	// Covers holds nulls and sentinel -1 values in the wild, so the elements
	// are pointers and the sentinel is filtered rather than trusted.
	Covers []*int64 `json:"covers"`
}

// Author is the subset of an author record Rafça reads.
type Author struct {
	Key  string `json:"key"`
	Name string `json:"name"`
}

// Record is one projected edition, before author names are resolved.
type Record struct {
	OLKey       string   `json:"ol_key"`
	ISBN13      string   `json:"isbn13"`
	Title       string   `json:"title"`
	Subtitle    string   `json:"subtitle"`
	AuthorKeys  []string `json:"author_keys"`
	Publisher   string   `json:"publisher"`
	PublishYear int      `json:"publish_year"`
	Language    string   `json:"language"`
	CoverURL    string   `json:"cover_url"`
}

// JSONColumn returns the record JSON of a dump line.
func JSONColumn(line string) (string, error) {
	columns := strings.SplitN(line, "\t", dumpColumns)
	if len(columns) < dumpColumns {
		return "", fmt.Errorf("%w: got %d columns, want %d", ErrNotJSON, len(columns), dumpColumns)
	}
	return columns[dumpColumns-1], nil
}

// ParseEdition decodes one line of the editions dump.
func ParseEdition(line string) (Edition, error) {
	payload, err := JSONColumn(line)
	if err != nil {
		return Edition{}, err
	}
	var edition Edition
	if err := json.Unmarshal([]byte(payload), &edition); err != nil {
		return Edition{}, fmt.Errorf("openlibrary: decoding edition: %w", err)
	}
	return edition, nil
}

// ParseAuthor decodes one line of the authors dump.
func ParseAuthor(line string) (Author, error) {
	payload, err := JSONColumn(line)
	if err != nil {
		return Author{}, err
	}
	var author Author
	if err := json.Unmarshal([]byte(payload), &author); err != nil {
		return Author{}, fmt.Errorf("openlibrary: decoding author: %w", err)
	}
	return author, nil
}

// ErrNoTitle reports an edition that cannot be indexed.
//
// A spine is matched on its printed text. An edition with no title has nothing
// for the matcher to score against, so it is dropped at ingest rather than
// carried as a row that can never win.
var ErrNoTitle = errors.New("openlibrary: edition has no title")

// Project reduces an edition to the columns books_index stores.
func Project(edition Edition) (Record, error) {
	title := strings.TrimSpace(edition.Title)
	if title == "" {
		return Record{}, ErrNoTitle
	}

	record := Record{
		OLKey:       edition.Key,
		Title:       title,
		Subtitle:    strings.TrimSpace(edition.Subtitle),
		AuthorKeys:  refKeys(edition.Authors),
		Publisher:   firstNonEmpty(edition.Publishers),
		PublishYear: publishYear(edition.PublishDate),
		Language:    LanguageCode(edition.Languages),
		CoverURL:    coverURL(edition.Covers),
	}
	if isbn := firstNonEmpty(edition.ISBN13); isbn != "" {
		record.ISBN13 = normaliseISBN(isbn)
	}
	return record, nil
}

// LanguageCode returns the first three-letter code of an edition, or "" when
// the record does not say.
func LanguageCode(languages []Ref) string {
	for _, language := range languages {
		if code := strings.TrimPrefix(language.Key, "/languages/"); code != "" && code != language.Key {
			return code
		}
	}
	return ""
}

func refKeys(refs []Ref) []string {
	keys := make([]string, 0, len(refs))
	for _, ref := range refs {
		if ref.Key != "" {
			keys = append(keys, ref.Key)
		}
	}
	return keys
}

func firstNonEmpty(values []string) string {
	for _, value := range values {
		if trimmed := strings.TrimSpace(value); trimmed != "" {
			return trimmed
		}
	}
	return ""
}

var isbnNoise = strings.NewReplacer("-", "", " ", "")

func normaliseISBN(isbn string) string {
	return isbnNoise.Replace(isbn)
}

// publishDatePattern matches a plausible four-digit year anywhere in the free
// text Open Library stores. The field holds everything from "1996" to
// "December 31, 1996" to "c2004" to "MCMXCVI [1996]", so parsing the whole
// string is not on the table.
//
// The neighbouring characters are matched rather than a word boundary: "c2004"
// has no boundary before the digits, and "12345" has one before them. Both are
// in the dump, and only the first is a year.
var publishDatePattern = regexp.MustCompile(`(^|[^0-9])(1[0-9]{3}|20[0-9]{2})([^0-9]|$)`)

func publishYear(publishDate string) int {
	match := publishDatePattern.FindStringSubmatch(publishDate)
	if match == nil {
		return 0
	}
	year, err := strconv.Atoi(match[2])
	if err != nil {
		return 0
	}
	return year
}

func coverURL(covers []*int64) string {
	for _, cover := range covers {
		if cover == nil || *cover <= 0 {
			continue
		}
		return fmt.Sprintf("https://covers.openlibrary.org/b/id/%d-M.jpg", *cover)
	}
	return ""
}
