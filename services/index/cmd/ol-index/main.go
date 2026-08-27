// Command ol-index turns the Open Library bulk dumps into a COPY-ready file for
// books_index.
//
// It runs in three passes, on purpose. Author names live in a separate dump
// from the editions that reference them, and holding every author in memory to
// resolve them in one pass costs gigabytes for a catalogue that is then thrown
// away. Instead:
//
//	filter   editions dump -> projected records + the author keys they cite
//	authors  authors dump  -> names for exactly those keys
//	join     records + names -> COPY text
//
// Peak memory is therefore bounded by the number of authors the filtered subset
// actually cites, not by the size of either dump.
package main

import (
	"bufio"
	"compress/gzip"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"strings"

	"github.com/kutluhangil/rafca/services/index/internal/copyfmt"
	"github.com/kutluhangil/rafca/services/index/internal/openlibrary"
)

// scanBuffer is generous because a single Open Library record can carry a long
// list of source records. A line over this is a corrupt dump, not a big book.
const scanBuffer = 16 << 20

// progressEvery keeps a half-hour pass from looking like a hang.
const progressEvery = 1_000_000

func main() {
	log.SetFlags(0)
	log.SetPrefix("ol-index: ")

	if len(os.Args) < 2 {
		usage()
	}

	var err error
	switch os.Args[1] {
	case "filter":
		err = runFilter(os.Args[2:])
	case "authors":
		err = runAuthors(os.Args[2:])
	case "join":
		err = runJoin(os.Args[2:])
	default:
		usage()
	}
	if err != nil {
		log.Fatal(err)
	}
}

func usage() {
	fmt.Fprintln(os.Stderr, "usage: ol-index filter|authors|join [flags]")
	os.Exit(2)
}

func runFilter(args []string) error {
	flags := flag.NewFlagSet("filter", flag.ExitOnError)
	in := flags.String("in", "-", "editions dump, gzipped; - for stdin")
	out := flags.String("out", "", "projected records, one JSON object per line")
	keysOut := flags.String("author-keys", "", "author keys cited by the kept records")
	languages := flags.String("languages", "tur,eng", "language codes to keep, highest priority first")
	maxPerLanguage := flags.Int("max-per-language", 1_500_000, "cap per language; 0 means no cap")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if *out == "" || *keysOut == "" {
		return errors.New("filter needs -out and -author-keys")
	}

	wanted := map[string]bool{}
	for _, code := range strings.Split(*languages, ",") {
		if code = strings.TrimSpace(code); code != "" {
			wanted[code] = true
		}
	}
	if len(wanted) == 0 {
		return errors.New("filter needs at least one language code")
	}

	source, closeSource, err := openDump(*in)
	if err != nil {
		return err
	}
	defer closeSource()

	records, closeRecords, err := createFile(*out)
	if err != nil {
		return err
	}
	defer closeRecords()

	keysFile, closeKeys, err := createFile(*keysOut)
	if err != nil {
		return err
	}
	defer closeKeys()

	encoder := json.NewEncoder(records)
	kept := map[string]int{}
	authorKeys := map[string]bool{}
	scanner := newScanner(source)
	read := 0

	// Most of the dump is neither wanted nor cheap to reject: over half the
	// editions are English, and once that cap is met every one of them still
	// costs a full JSON decode to find out. Matching the language key as a
	// substring first turns that decode into a memchr, and the marker list
	// shrinks as caps fill.
	markers := languageMarkers(wanted, kept, *maxPerLanguage)

	for scanner.Scan() {
		read++
		if read%progressEvery == 0 {
			log.Printf("read %d editions, kept %d", read, total(kept))
		}

		line := scanner.Text()
		if !containsAny(line, markers) {
			continue
		}

		edition, err := openlibrary.ParseEdition(line)
		if err != nil {
			// A dump of this size carries a handful of malformed lines. They
			// are counted by their absence from the kept total rather than
			// aborting a half-hour pass.
			continue
		}
		language := openlibrary.LanguageCode(edition.Languages)
		if !wanted[language] {
			continue
		}
		if *maxPerLanguage > 0 && kept[language] >= *maxPerLanguage {
			continue
		}
		record, err := openlibrary.Project(edition)
		if err != nil {
			continue
		}
		if err := encoder.Encode(record); err != nil {
			return fmt.Errorf("writing record: %w", err)
		}
		kept[language]++
		if *maxPerLanguage > 0 && kept[language] == *maxPerLanguage {
			log.Printf("%s cap of %d reached", language, *maxPerLanguage)
			markers = languageMarkers(wanted, kept, *maxPerLanguage)
			if len(markers) == 0 {
				break
			}
		}
		for _, key := range record.AuthorKeys {
			authorKeys[key] = true
		}
	}
	if err := scanner.Err(); err != nil {
		return fmt.Errorf("reading editions dump: %w", err)
	}

	for key := range authorKeys {
		if _, err := fmt.Fprintln(keysFile, key); err != nil {
			return fmt.Errorf("writing author keys: %w", err)
		}
	}

	log.Printf("read %d editions, kept %d (%v), cited %d authors", read, total(kept), kept, len(authorKeys))
	return nil
}

func runAuthors(args []string) error {
	flags := flag.NewFlagSet("authors", flag.ExitOnError)
	in := flags.String("in", "-", "authors dump, gzipped; - for stdin")
	keysIn := flags.String("keys", "", "author keys to resolve, one per line")
	out := flags.String("out", "", "key and name, tab separated")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if *keysIn == "" || *out == "" {
		return errors.New("authors needs -keys and -out")
	}

	wanted, err := readKeys(*keysIn)
	if err != nil {
		return err
	}

	source, closeSource, err := openDump(*in)
	if err != nil {
		return err
	}
	defer closeSource()

	names, closeNames, err := createFile(*out)
	if err != nil {
		return err
	}
	defer closeNames()

	scanner := newScanner(source)
	read, resolved := 0, 0
	for scanner.Scan() {
		read++
		if read%progressEvery == 0 {
			log.Printf("read %d authors, resolved %d of %d", read, resolved, len(wanted))
		}
		line := scanner.Text()
		author, err := openlibrary.ParseAuthor(line)
		if err != nil || author.Name == "" || !wanted[author.Key] {
			continue
		}
		// A tab or newline inside a name would break this file's own two-column
		// shape, and no author name legitimately contains one.
		if _, err := fmt.Fprintf(names, "%s\t%s\n", author.Key, flatten(author.Name)); err != nil {
			return fmt.Errorf("writing author names: %w", err)
		}
		resolved++
	}
	if err := scanner.Err(); err != nil {
		return fmt.Errorf("reading authors dump: %w", err)
	}

	log.Printf("read %d authors, resolved %d of %d cited", read, resolved, len(wanted))
	return nil
}

func runJoin(args []string) error {
	flags := flag.NewFlagSet("join", flag.ExitOnError)
	in := flags.String("in", "", "projected records from filter")
	namesIn := flags.String("names", "", "key and name pairs from authors")
	out := flags.String("out", "-", "COPY text; - for stdout")
	if err := flags.Parse(args); err != nil {
		return err
	}
	if *in == "" || *namesIn == "" {
		return errors.New("join needs -in and -names")
	}

	names, err := readNames(*namesIn)
	if err != nil {
		return err
	}

	records, closeRecords, err := openFile(*in)
	if err != nil {
		return err
	}
	defer closeRecords()

	var sink io.Writer = os.Stdout
	if *out != "-" {
		file, closeFile, err := createFile(*out)
		if err != nil {
			return err
		}
		defer closeFile()
		sink = file
	}
	buffered := bufio.NewWriterSize(sink, 1<<20)

	scanner := newScanner(records)
	written := 0
	for scanner.Scan() {
		var record openlibrary.Record
		if err := json.Unmarshal(scanner.Bytes(), &record); err != nil {
			return fmt.Errorf("decoding projected record: %w", err)
		}
		authors := make([]string, 0, len(record.AuthorKeys))
		for _, key := range record.AuthorKeys {
			if name, ok := names[key]; ok {
				authors = append(authors, name)
			}
		}
		line := copyfmt.Line(
			copyfmt.NullOr(record.OLKey),
			copyfmt.NullOr(record.ISBN13),
			copyfmt.Escape(record.Title),
			copyfmt.NullOr(record.Subtitle),
			copyfmt.Array(authors),
			copyfmt.NullOr(record.Publisher),
			publishYearField(record.PublishYear),
			copyfmt.NullOr(record.Language),
			copyfmt.NullOr(record.CoverURL),
		)
		if _, err := buffered.WriteString(line); err != nil {
			return fmt.Errorf("writing COPY text: %w", err)
		}
		written++
	}
	if err := scanner.Err(); err != nil {
		return fmt.Errorf("reading projected records: %w", err)
	}
	if err := buffered.Flush(); err != nil {
		return fmt.Errorf("flushing COPY text: %w", err)
	}

	log.Printf("wrote %d rows", written)
	return nil
}

var nameFlattener = strings.NewReplacer("\t", " ", "\n", " ", "\r", " ")

func flatten(value string) string {
	return nameFlattener.Replace(value)
}

func publishYearField(year int) string {
	if year == 0 {
		return copyfmt.Null
	}
	return fmt.Sprint(year)
}

// languageMarkers lists the record substrings still worth decoding for.
func languageMarkers(wanted map[string]bool, kept map[string]int, maxPerLanguage int) []string {
	markers := make([]string, 0, len(wanted))
	for code := range wanted {
		if maxPerLanguage > 0 && kept[code] >= maxPerLanguage {
			continue
		}
		markers = append(markers, `"/languages/`+code+`"`)
	}
	return markers
}

func containsAny(line string, markers []string) bool {
	for _, marker := range markers {
		if strings.Contains(line, marker) {
			return true
		}
	}
	return false
}

func total(counts map[string]int) int {
	sum := 0
	for _, count := range counts {
		sum += count
	}
	return sum
}

func newScanner(source io.Reader) *bufio.Scanner {
	scanner := bufio.NewScanner(source)
	scanner.Buffer(make([]byte, 0, 64<<10), scanBuffer)
	return scanner
}

func openDump(path string) (io.Reader, func(), error) {
	if path == "-" {
		reader, err := gzip.NewReader(bufio.NewReaderSize(os.Stdin, 1<<20))
		if err != nil {
			return nil, nil, fmt.Errorf("reading gzip from stdin: %w", err)
		}
		return reader, func() { reader.Close() }, nil
	}
	file, err := os.Open(path)
	if err != nil {
		return nil, nil, fmt.Errorf("opening dump: %w", err)
	}
	reader, err := gzip.NewReader(bufio.NewReaderSize(file, 1<<20))
	if err != nil {
		file.Close()
		return nil, nil, fmt.Errorf("reading gzip from %s: %w", path, err)
	}
	return reader, func() { reader.Close(); file.Close() }, nil
}

func openFile(path string) (io.Reader, func(), error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, nil, fmt.Errorf("opening %s: %w", path, err)
	}
	return bufio.NewReaderSize(file, 1<<20), func() { file.Close() }, nil
}

func createFile(path string) (*bufio.Writer, func(), error) {
	file, err := os.Create(path)
	if err != nil {
		return nil, nil, fmt.Errorf("creating %s: %w", path, err)
	}
	writer := bufio.NewWriterSize(file, 1<<20)
	return writer, func() { writer.Flush(); file.Close() }, nil
}

func readKeys(path string) (map[string]bool, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("opening %s: %w", path, err)
	}
	defer file.Close()

	keys := map[string]bool{}
	scanner := newScanner(bufio.NewReaderSize(file, 1<<20))
	for scanner.Scan() {
		if key := scanner.Text(); key != "" {
			keys[key] = true
		}
	}
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("reading %s: %w", path, err)
	}
	return keys, nil
}

func readNames(path string) (map[string]string, error) {
	file, err := os.Open(path)
	if err != nil {
		return nil, fmt.Errorf("opening %s: %w", path, err)
	}
	defer file.Close()

	names := map[string]string{}
	scanner := newScanner(bufio.NewReaderSize(file, 1<<20))
	for scanner.Scan() {
		key, name, found := strings.Cut(scanner.Text(), "\t")
		if !found {
			return nil, fmt.Errorf("malformed name line in %s: %q", path, scanner.Text())
		}
		names[key] = name
	}
	if err := scanner.Err(); err != nil {
		return nil, fmt.Errorf("reading %s: %w", path, err)
	}
	return names, nil
}
