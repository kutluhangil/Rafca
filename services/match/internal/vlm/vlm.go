// Package vlm is the third tier of SPINE_BLUEPRINT.md 8.5.
//
// It runs only when the user presses "Enhance" on an UNKNOWN card, and it is
// the single exception to the rule that no image leaves the device
// (SPINE_BLUEPRINT.md 5): exactly one spine crop is sent, for one request, and
// nothing is stored. The API key lives here and never on the phone.
package vlm

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/anthropics/anthropic-sdk-go"
	"github.com/anthropics/anthropic-sdk-go/option"
)

// Reading is what the model claims to see on the spine.
type Reading struct {
	Title  string `json:"title"`
	Author string `json:"author"`
}

// ErrNotConfigured reports a client with no credentials.
//
// The endpoint refuses rather than degrading to a guess: a user who pressed
// Enhance and spent a credit has to be told the truth about what happened.
var ErrNotConfigured = errors.New("vlm: no API key configured")

// Client reads a spine crop with Claude.
type Client struct {
	messages *anthropic.Client
	model    anthropic.Model
	// promptSystem keeps the model to transcription. Guessing a plausible book
	// from a blurry crop is worse than admitting the crop is unreadable: the
	// answer is fed straight back into the matcher as tier one input.
	promptSystem string
}

// Options configure a client.
type Options struct {
	APIKey string
	// Model defaults to Claude Opus 5.
	Model string
	// BaseURL overrides the API host, which is what the tests point at a local
	// server.
	BaseURL string
}

// DefaultModel is what an unconfigured client uses.
const DefaultModel = "claude-opus-5"

const systemPrompt = `You transcribe the printed text on the spine of a single book.
Return the title and the author exactly as printed, without translating, expanding
abbreviations or correcting spelling. Do not infer a book you cannot read: if the
crop is unreadable or does not show a book spine, return empty strings.`

// New builds a client. It returns nil when no key is configured, which is a
// valid deployment: /v1/enhance then answers 503 instead of pretending.
func New(options Options) *Client {
	if options.APIKey == "" {
		return nil
	}
	clientOptions := []option.RequestOption{option.WithAPIKey(options.APIKey)}
	if options.BaseURL != "" {
		clientOptions = append(clientOptions, option.WithBaseURL(options.BaseURL))
	}
	client := anthropic.NewClient(clientOptions...)

	model := options.Model
	if model == "" {
		model = DefaultModel
	}
	return &Client{
		messages:     &client,
		model:        anthropic.Model(model),
		promptSystem: systemPrompt,
	}
}

// readingSchema constrains the answer to the two fields the matcher can use.
var readingSchema = map[string]any{
	"type": "object",
	"properties": map[string]any{
		"title":  map[string]any{"type": "string"},
		"author": map[string]any{"type": "string"},
	},
	"required":             []string{"title", "author"},
	"additionalProperties": false,
}

// Read transcribes one spine crop.
func (c *Client) Read(ctx context.Context, image []byte, mediaType string) (Reading, error) {
	if c == nil {
		return Reading{}, ErrNotConfigured
	}
	if len(image) == 0 {
		return Reading{}, errors.New("vlm: empty image")
	}
	if !supportedMediaTypes[mediaType] {
		return Reading{}, fmt.Errorf("vlm: unsupported media type %q", mediaType)
	}

	response, err := c.messages.Messages.New(ctx, anthropic.MessageNewParams{
		Model:     c.model,
		MaxTokens: 1024,
		System:    []anthropic.TextBlockParam{{Text: c.promptSystem}},
		OutputConfig: anthropic.OutputConfigParam{
			Effort: anthropic.OutputConfigEffortLow,
			Format: anthropic.JSONOutputFormatParam{Schema: readingSchema},
		},
		Messages: []anthropic.MessageParam{
			anthropic.NewUserMessage(
				anthropic.NewImageBlockBase64(mediaType, base64.StdEncoding.EncodeToString(image)),
				anthropic.NewTextBlock("Transcribe this book spine."),
			),
		},
	})
	if err != nil {
		return Reading{}, fmt.Errorf("vlm: reading spine: %w", err)
	}
	if response.StopReason == anthropic.StopReasonRefusal {
		return Reading{}, fmt.Errorf("vlm: request declined (%s): %s",
			response.StopDetails.Category, response.StopDetails.Explanation)
	}

	var text strings.Builder
	for _, block := range response.Content {
		if textBlock, ok := block.AsAny().(anthropic.TextBlock); ok {
			text.WriteString(textBlock.Text)
		}
	}
	if text.Len() == 0 {
		return Reading{}, errors.New("vlm: model returned no text")
	}

	var reading Reading
	if err := json.Unmarshal([]byte(text.String()), &reading); err != nil {
		return Reading{}, fmt.Errorf("vlm: decoding %q: %w", text.String(), err)
	}
	reading.Title = strings.TrimSpace(reading.Title)
	reading.Author = strings.TrimSpace(reading.Author)
	return reading, nil
}

var supportedMediaTypes = map[string]bool{
	"image/jpeg": true,
	"image/png":  true,
	"image/webp": true,
}
