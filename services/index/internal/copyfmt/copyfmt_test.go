package copyfmt_test

import (
	"testing"

	"github.com/kutluhangil/rafca/services/index/internal/copyfmt"
)

func TestEscape(t *testing.T) {
	got := copyfmt.Escape("a\tb\nc\\d")
	if want := `a\tb\nc\\d`; got != want {
		t.Errorf("Escape = %q, want %q", got, want)
	}
}

func TestNullOrDistinguishesAbsentFromEmpty(t *testing.T) {
	if got := copyfmt.NullOr(""); got != copyfmt.Null {
		t.Errorf("NullOr(\"\") = %q, want the NULL marker", got)
	}
	if got := copyfmt.NullOr("x"); got != "x" {
		t.Errorf("NullOr(\"x\") = %q, want x", got)
	}
}

func TestArrayQuotesElementsBeforeEscapingTheLiteral(t *testing.T) {
	got := copyfmt.Array([]string{`Oğuz Atay`, `He said "hi"`, `back\slash`})
	// The array literal is {"Oğuz Atay","He said \"hi\"","back\\slash"}, and
	// every backslash it introduced is then data COPY has to be told about.
	want := `{"Oğuz Atay","He said \\"hi\\"","back\\\\slash"}`
	if got != want {
		t.Errorf("Array = %q, want %q", got, want)
	}
}

func TestArrayEmpty(t *testing.T) {
	if got := copyfmt.Array(nil); got != "{}" {
		t.Errorf("Array(nil) = %q, want an empty array literal", got)
	}
}

func TestLine(t *testing.T) {
	if got := copyfmt.Line("a", "b"); got != "a\tb\n" {
		t.Errorf("Line = %q", got)
	}
}
