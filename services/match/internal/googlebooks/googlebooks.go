// Package googlebooks is the second tier of SPINE_BLUEPRINT.md 8.5.
//
// It is consulted only when the local index came back UNKNOWN and the spine is
// in the language the local subset is thinnest on. What it returns is written
// into books_index, so the tier pays for itself: the same book is a first-tier
// hit the next time anyone photographs it.
package googlebooks

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"

	"github.com/kutluhangil/rafca/services/match/internal/catalog"
)

// DefaultEndpoint is the public volumes endpoint.
const DefaultEndpoint = "https://www.googleapis.com/books/v1/volumes"

// Client queries the Google Books volumes API.
type Client struct {
	endpoint string
	apiKey   string
	http     *http.Client
	maxItems int
}

// Options configure a client.
type Options struct {
	// Endpoint overrides the API base, which is what the tests point at a
	// local server.
	Endpoint string
	// APIKey is optional: the volumes endpoint answers unauthenticated
	// requests at a lower quota.
	APIKey string
	// Timeout bounds one lookup. A scan is a foreground operation, so a slow
	// third party must not hold the whole batch open.
	Timeout  time.Duration
	MaxItems int
}

// New builds a client.
func New(options Options) *Client {
	endpoint := options.Endpoint
	if endpoint == "" {
		endpoint = DefaultEndpoint
	}
	timeout := options.Timeout
	if timeout == 0 {
		timeout = 5 * time.Second
	}
	maxItems := options.MaxItems
	if maxItems == 0 {
		maxItems = 5
	}
	return &Client{
		endpoint: endpoint,
		apiKey:   options.APIKey,
		http:     &http.Client{Timeout: timeout},
		maxItems: maxItems,
	}
}

type volumesResponse struct {
	Items []struct {
		VolumeInfo struct {
			Title               string   `json:"title"`
			Subtitle            string   `json:"subtitle"`
			Authors             []string `json:"authors"`
			Publisher           string   `json:"publisher"`
			PublishedDate       string   `json:"publishedDate"`
			Language            string   `json:"language"`
			IndustryIdentifiers []struct {
				Type       string `json:"type"`
				Identifier string `json:"identifier"`
			} `json:"industryIdentifiers"`
			ImageLinks struct {
				Thumbnail string `json:"thumbnail"`
			} `json:"imageLinks"`
		} `json:"volumeInfo"`
	} `json:"items"`
}

// Lookup searches Google Books and projects the answer onto books_index rows.
func (c *Client) Lookup(ctx context.Context, query string, languageHint string) ([]catalog.Book, error) {
	endpoint, err := url.Parse(c.endpoint)
	if err != nil {
		return nil, fmt.Errorf("googlebooks: bad endpoint %q: %w", c.endpoint, err)
	}
	parameters := endpoint.Query()
	parameters.Set("q", query)
	parameters.Set("maxResults", strconv.Itoa(c.maxItems))
	if languageHint != "" {
		parameters.Set("langRestrict", twoLetter(languageHint))
	}
	if c.apiKey != "" {
		parameters.Set("key", c.apiKey)
	}
	endpoint.RawQuery = parameters.Encode()

	request, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint.String(), nil)
	if err != nil {
		return nil, fmt.Errorf("googlebooks: building request: %w", err)
	}

	response, err := c.http.Do(request)
	if err != nil {
		return nil, fmt.Errorf("googlebooks: querying %q: %w", query, err)
	}
	defer response.Body.Close()

	body, err := io.ReadAll(io.LimitReader(response.Body, 1<<20))
	if err != nil {
		return nil, fmt.Errorf("googlebooks: reading response for %q: %w", query, err)
	}
	if response.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("googlebooks: %q returned %d: %s", query, response.StatusCode, strings.TrimSpace(string(body)))
	}

	var decoded volumesResponse
	if err := json.Unmarshal(body, &decoded); err != nil {
		return nil, fmt.Errorf("googlebooks: decoding response for %q: %w", query, err)
	}

	books := make([]catalog.Book, 0, len(decoded.Items))
	for _, item := range decoded.Items {
		info := item.VolumeInfo
		if strings.TrimSpace(info.Title) == "" {
			continue
		}
		book := catalog.Book{
			Title:       strings.TrimSpace(info.Title),
			Subtitle:    strings.TrimSpace(info.Subtitle),
			Authors:     info.Authors,
			Publisher:   strings.TrimSpace(info.Publisher),
			PublishYear: year(info.PublishedDate),
			Language:    threeLetter(info.Language),
			CoverURL:    info.ImageLinks.Thumbnail,
		}
		for _, identifier := range info.IndustryIdentifiers {
			if identifier.Type == "ISBN_13" {
				book.ISBN13 = identifier.Identifier
				break
			}
		}
		// books_index keys on ol_key, and Google Books has no Open Library
		// key to offer. An ISBN-derived key keeps the upsert idempotent; a
		// book without one is inserted fresh, which is the honest outcome
		// when there is nothing stable to key on.
		if book.ISBN13 != "" {
			book.OLKey = "gb:isbn:" + book.ISBN13
		}
		books = append(books, book)
	}
	return books, nil
}

func year(publishedDate string) int {
	if len(publishedDate) < 4 {
		return 0
	}
	parsed, err := strconv.Atoi(publishedDate[:4])
	if err != nil {
		return 0
	}
	return parsed
}

// Google Books speaks two-letter language codes, books_index stores three.
var languageCodes = map[string]string{"tur": "tr", "eng": "en", "deu": "de", "fra": "fr", "spa": "es", "ita": "it", "rus": "ru"}

func twoLetter(threeLetterCode string) string {
	if code, ok := languageCodes[threeLetterCode]; ok {
		return code
	}
	return threeLetterCode
}

func threeLetter(twoLetterCode string) string {
	for three, two := range languageCodes {
		if two == twoLetterCode {
			return three
		}
	}
	return twoLetterCode
}
