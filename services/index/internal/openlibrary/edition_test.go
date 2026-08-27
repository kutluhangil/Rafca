package openlibrary_test

import (
	"errors"
	"testing"

	"github.com/kutluhangil/rafca/services/index/internal/openlibrary"
)

func dumpLine(payload string) string {
	return "/type/edition\t/books/OL1M\t3\t2026-01-03T07:51:31.882542\t" + payload
}

func TestProjectKeepsTheColumnsBooksIndexStores(t *testing.T) {
	line := dumpLine(`{
		"key": "/books/OL1M",
		"title": "  Tutunamayanlar  ",
		"subtitle": "Roman",
		"isbn_13": ["978-975-07-0800-1"],
		"publishers": ["", "İletişim Yayınları"],
		"publish_date": "December 31, 1996",
		"languages": [{"key": "/languages/tur"}],
		"authors": [{"key": "/authors/OL1A"}, {"key": ""}],
		"covers": [null, -1, 12907309]
	}`)

	edition, err := openlibrary.ParseEdition(line)
	if err != nil {
		t.Fatalf("ParseEdition: %v", err)
	}
	record, err := openlibrary.Project(edition)
	if err != nil {
		t.Fatalf("Project: %v", err)
	}

	if record.Title != "Tutunamayanlar" {
		t.Errorf("Title = %q, want the trimmed title", record.Title)
	}
	if record.ISBN13 != "9789750708001" {
		t.Errorf("ISBN13 = %q, want the hyphens removed", record.ISBN13)
	}
	if record.Publisher != "İletişim Yayınları" {
		t.Errorf("Publisher = %q, want the first non-empty publisher", record.Publisher)
	}
	if record.PublishYear != 1996 {
		t.Errorf("PublishYear = %d, want 1996 read out of the free text", record.PublishYear)
	}
	if record.Language != "tur" {
		t.Errorf("Language = %q, want tur", record.Language)
	}
	if len(record.AuthorKeys) != 1 || record.AuthorKeys[0] != "/authors/OL1A" {
		t.Errorf("AuthorKeys = %v, want the empty ref dropped", record.AuthorKeys)
	}
	if record.CoverURL != "https://covers.openlibrary.org/b/id/12907309-M.jpg" {
		t.Errorf("CoverURL = %q, want the first usable cover", record.CoverURL)
	}
}

func TestProjectRejectsAnEditionWithNoTitle(t *testing.T) {
	edition, err := openlibrary.ParseEdition(dumpLine(`{"key": "/books/OL1M", "title": "   "}`))
	if err != nil {
		t.Fatalf("ParseEdition: %v", err)
	}

	if _, err := openlibrary.Project(edition); !errors.Is(err, openlibrary.ErrNoTitle) {
		t.Errorf("Project error = %v, want ErrNoTitle", err)
	}
}

func TestProjectLeavesUnknownFieldsEmpty(t *testing.T) {
	edition, err := openlibrary.ParseEdition(dumpLine(`{"key": "/books/OL1M", "title": "Anonim"}`))
	if err != nil {
		t.Fatalf("ParseEdition: %v", err)
	}
	record, err := openlibrary.Project(edition)
	if err != nil {
		t.Fatalf("Project: %v", err)
	}

	if record.ISBN13 != "" || record.Publisher != "" || record.CoverURL != "" || record.Language != "" {
		t.Errorf("record = %+v, want the absent fields empty", record)
	}
	if record.PublishYear != 0 {
		t.Errorf("PublishYear = %d, want 0 for an absent date", record.PublishYear)
	}
}

func TestPublishYear(t *testing.T) {
	cases := map[string]int{
		"1996":              1996,
		"December 31, 1996": 1996,
		"1996-01-02":        1996,
		"MCMXCVI [1996]":    1996,
		"c2004":             2004,
		"":                  0,
		"no year here":      0,
		"12345":             0,
	}
	for date, want := range cases {
		edition, err := openlibrary.ParseEdition(dumpLine(`{"title": "T", "publish_date": ` + quote(date) + `}`))
		if err != nil {
			t.Fatalf("ParseEdition(%q): %v", date, err)
		}
		record, err := openlibrary.Project(edition)
		if err != nil {
			t.Fatalf("Project(%q): %v", date, err)
		}
		if record.PublishYear != want {
			t.Errorf("publishYear(%q) = %d, want %d", date, record.PublishYear, want)
		}
	}
}

func TestParseEditionRejectsALineWithoutJSON(t *testing.T) {
	if _, err := openlibrary.ParseEdition("/type/edition\t/books/OL1M"); !errors.Is(err, openlibrary.ErrNotJSON) {
		t.Errorf("error = %v, want ErrNotJSON", err)
	}
}

func TestParseAuthor(t *testing.T) {
	author, err := openlibrary.ParseAuthor("/type/author\t/authors/OL1A\t1\t2026-01-01\t" + `{"key": "/authors/OL1A", "name": "Oğuz Atay"}`)
	if err != nil {
		t.Fatalf("ParseAuthor: %v", err)
	}
	if author.Key != "/authors/OL1A" || author.Name != "Oğuz Atay" {
		t.Errorf("author = %+v, want the key and name", author)
	}
}

func quote(value string) string {
	return `"` + value + `"`
}
