// Package normalize turns raw spine text into the query the catalogue is
// searched with (SPINE_BLUEPRINT.md 8.2).
//
// This is a port of spike/lib/eval/normalize.dart, and it has to stay one. The
// Faz 0 accuracy report was produced with the Dart implementation; if the two
// drift, the golden test stops meaning what it claims to mean.
package normalize

import (
	"regexp"
	"strings"
	"unicode"
)

// NoiseWords are dropped from a query. Straight from the blueprint list, in
// already-folded form.
var NoiseWords = map[string]bool{
	"yayinlari": true,
	"kitap":     true,
	"roman":     true,
	"cilt":      true,
	"vol":       true,
	"edition":   true,
	"press":     true,
	"books":     true,
	"classics":  true,
}

var diacritics = map[rune]string{
	'ç': "c", 'ğ': "g", 'ö': "o", 'ş': "s", 'ü': "u",
	'â': "a", 'ä': "a", 'à': "a", 'á': "a", 'å': "a", 'ã': "a",
	'ê': "e", 'ë': "e", 'è': "e", 'é': "e",
	'î': "i", 'ï': "i", 'ì': "i", 'í': "i",
	'ô': "o", 'ò': "o", 'ó': "o", 'õ': "o", 'ø': "o",
	'û': "u", 'ù': "u", 'ú': "u",
	'ñ': "n", 'ý': "y", 'ÿ': "y", 'ß': "ss", 'æ': "ae", 'œ': "oe",
}

// FoldCase lower cases and strips diacritics.
//
// Turkish dotted and dotless i are folded together deliberately: OCR cannot
// tell 'ı' from 'i' on a printed spine, so treating them as one letter removes
// a whole class of false mismatches. They are handled before the generic lower
// casing, which would turn 'İ' into "i" plus a combining dot.
func FoldCase(input string) string {
	var builder strings.Builder
	builder.Grow(len(input))
	for _, char := range input {
		switch char {
		case 'İ', 'I', 'ı':
			builder.WriteByte('i')
			continue
		}
		lowered := unicode.ToLower(char)
		if replacement, ok := diacritics[lowered]; ok {
			builder.WriteString(replacement)
			continue
		}
		builder.WriteRune(lowered)
	}
	return builder.String()
}

var (
	nonWord       = regexp.MustCompile(`[^a-z0-9]+`)
	repeatedSpace = regexp.MustCompile(`\s+`)
)

// Query is one normalised spine reading.
type Query struct {
	// Raw is the text as it came off the spine.
	Raw string
	// Text is the normalised query, with noise words and the publisher removed.
	Text string
	// Tokens is Text split on whitespace.
	Tokens []string
	// PublisherHint is the publisher recognised in the query, or "". It is kept
	// as a separate scoring signal rather than left in the query, where a long
	// imprint name would drown out the title.
	PublisherHint string
}

// IsEmpty reports a query with nothing left to search for.
func (q Query) IsEmpty() bool { return len(q.Tokens) == 0 }

// Publishers recognises publisher names inside a normalised query.
type Publishers struct {
	// names is sorted longest first, so "penguin classics" wins over "penguin".
	names []string
}

// NewPublishers builds the index from raw lines, ignoring blanks and comments.
func NewPublishers(lines []string) *Publishers {
	names := make([]string, 0, len(lines))
	for _, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		folded := strings.TrimSpace(nonWord.ReplaceAllString(FoldCase(trimmed), " "))
		if folded != "" {
			names = append(names, folded)
		}
	}
	sortLongestFirst(names)
	return &Publishers{names: names}
}

// Len reports how many names the index holds.
func (p *Publishers) Len() int { return len(p.names) }

// FindIn returns the longest publisher name contained in normalisedText.
func (p *Publishers) FindIn(normalisedText string) string {
	padded := " " + normalisedText + " "
	for _, name := range p.names {
		if strings.Contains(padded, " "+name+" ") {
			return name
		}
	}
	return ""
}

func sortLongestFirst(names []string) {
	for i := 1; i < len(names); i++ {
		for j := i; j > 0 && len(names[j]) > len(names[j-1]); j-- {
			names[j], names[j-1] = names[j-1], names[j]
		}
	}
}

// Normalise applies the whole of section 8.2 to one raw reading.
func Normalise(raw string, publishers *Publishers) Query {
	folded := FoldCase(raw)
	cleaned := strings.TrimSpace(repeatedSpace.ReplaceAllString(nonWord.ReplaceAllString(folded, " "), " "))

	publisher := publishers.FindIn(cleaned)
	withoutPublisher := cleaned
	if publisher != "" {
		withoutPublisher = strings.ReplaceAll(cleaned, publisher, " ")
	}

	tokens := make([]string, 0, 8)
	for _, token := range repeatedSpace.Split(withoutPublisher, -1) {
		if token == "" || NoiseWords[token] {
			continue
		}
		tokens = append(tokens, token)
	}

	return Query{
		Raw:           raw,
		Text:          strings.Join(tokens, " "),
		Tokens:        tokens,
		PublisherHint: publisher,
	}
}

// Clean folds and strips a catalogue string the same way a query is cleaned.
//
// It is the Go form of the `search_blob` the Faz 0 spike built
// (spike/lib/eval/catalog.dart). It is deliberately not the same as the
// `search_blob` column, which keeps punctuation: the column exists to be
// indexed, this exists to be scored, and scoring a cleaned query against an
// uncleaned blob would charge every apostrophe against the match.
func Clean(text string) string {
	return strings.TrimSpace(repeatedSpace.ReplaceAllString(nonWord.ReplaceAllString(FoldCase(text), " "), " "))
}

// Tokens splits an already-cleaned string.
func Tokens(cleaned string) []string {
	if cleaned == "" {
		return nil
	}
	return repeatedSpace.Split(cleaned, -1)
}
