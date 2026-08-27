package googlebooks_test

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/kutluhangil/rafca/services/match/internal/googlebooks"
)

const volumesBody = `{
  "items": [
    {"volumeInfo": {
       "title": "Tutunamayanlar",
       "subtitle": "Roman",
       "authors": ["Oğuz Atay"],
       "publisher": "İletişim Yayınları",
       "publishedDate": "1972-01-01",
       "language": "tr",
       "industryIdentifiers": [
         {"type": "ISBN_10", "identifier": "9750708008"},
         {"type": "ISBN_13", "identifier": "9789750708008"}
       ],
       "imageLinks": {"thumbnail": "https://example.test/cover.jpg"}
     }},
    {"volumeInfo": {"title": "   "}}
  ]
}`

func TestLookupProjectsVolumesOntoCatalogueRows(t *testing.T) {
	var seen *http.Request
	server := httptest.NewServer(http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		seen = request
		writer.Header().Set("Content-Type", "application/json")
		_, _ = writer.Write([]byte(volumesBody))
	}))
	defer server.Close()

	client := googlebooks.New(googlebooks.Options{Endpoint: server.URL})
	books, err := client.Lookup(context.Background(), "tutunamayanlar oguz atay", "tur")
	if err != nil {
		t.Fatalf("Lookup: %v", err)
	}

	if got := seen.URL.Query().Get("langRestrict"); got != "tr" {
		t.Errorf("langRestrict = %q, want the two-letter code", got)
	}
	if len(books) != 1 {
		t.Fatalf("got %d books, want the untitled one dropped", len(books))
	}

	book := books[0]
	if book.Title != "Tutunamayanlar" || book.Subtitle != "Roman" {
		t.Errorf("title/subtitle = %q/%q", book.Title, book.Subtitle)
	}
	if book.ISBN13 != "9789750708008" {
		t.Errorf("ISBN13 = %q, want the 13 digit identifier", book.ISBN13)
	}
	if book.PublishYear != 1972 {
		t.Errorf("PublishYear = %d, want 1972", book.PublishYear)
	}
	if book.Language != "tur" {
		t.Errorf("Language = %q, want the three-letter code", book.Language)
	}
	if book.OLKey != "gb:isbn:9789750708008" {
		t.Errorf("OLKey = %q, want a key derived from the ISBN", book.OLKey)
	}
}

func TestLookupReportsAnErrorStatus(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(writer http.ResponseWriter, _ *http.Request) {
		writer.WriteHeader(http.StatusForbidden)
		_, _ = writer.Write([]byte(`{"error": "quota"}`))
	}))
	defer server.Close()

	client := googlebooks.New(googlebooks.Options{Endpoint: server.URL})
	if _, err := client.Lookup(context.Background(), "anything", ""); err == nil {
		t.Fatal("a 403 was swallowed")
	}
}
