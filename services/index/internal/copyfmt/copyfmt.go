// Package copyfmt encodes fields for PostgreSQL's COPY text format.
//
// The index is loaded with COPY rather than INSERT because Faz 4 moves over a
// million rows and the difference is minutes against hours. COPY text has only
// four escapes and one NULL marker, so encoding it directly is both smaller and
// faster than pulling in a CSV writer that would have to be configured out of
// its own quoting rules.
package copyfmt

import "strings"

// Null is what COPY text reads as SQL NULL. An unescaped empty field is the
// empty string, which is a different value.
const Null = `\N`

var fieldEscaper = strings.NewReplacer(
	`\`, `\\`,
	"\t", `\t`,
	"\n", `\n`,
	"\r", `\r`,
)

// Escape encodes one value for COPY text.
func Escape(value string) string {
	return fieldEscaper.Replace(value)
}

// NullOr encodes value, or emits SQL NULL when it is empty.
//
// Open Library leaves a missing subtitle, publisher or cover absent rather than
// blank, and the matcher treats "absent" and "present but empty" the same way,
// so collapsing them at the boundary keeps the column honest.
func NullOr(value string) string {
	if value == "" {
		return Null
	}
	return Escape(value)
}

var arrayElementEscaper = strings.NewReplacer(
	`\`, `\\`,
	`"`, `\"`,
)

// Array encodes values as a Postgres text[] literal.
//
// The element quoting runs first and the COPY escaping second, because the
// backslashes the array literal introduces are themselves data as far as COPY
// is concerned.
func Array(values []string) string {
	if len(values) == 0 {
		return Escape("{}")
	}
	var builder strings.Builder
	builder.WriteByte('{')
	for i, value := range values {
		if i > 0 {
			builder.WriteByte(',')
		}
		builder.WriteByte('"')
		builder.WriteString(arrayElementEscaper.Replace(value))
		builder.WriteByte('"')
	}
	builder.WriteByte('}')
	return Escape(builder.String())
}

// Line joins already-encoded fields into one COPY row.
func Line(fields ...string) string {
	return strings.Join(fields, "\t") + "\n"
}
