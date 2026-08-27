// Package config reads the service's settings from the environment.
//
// Everything configurable is an environment variable and nothing is read from
// a checked-in file: the API keys in here must never be able to reach the
// repository (SPINE_BLUEPRINT.md 8.6).
package config

import (
	"fmt"
	"os"
	"strconv"
	"time"
)

// Config is the whole of the service's settings.
type Config struct {
	Address        string
	DatabaseURL    string
	PublishersPath string

	CandidateLimit int
	RateLimit      int
	RateWindow     time.Duration

	GoogleBooksAPIKey   string
	GoogleBooksEndpoint string
	// FallbackLanguage limits the Google Books tier to one language. Empty
	// allows every language to fall back.
	FallbackLanguage string

	VLMAPIKey  string
	VLMModel   string
	VLMBaseURL string

	Version string
}

// Load reads the environment, failing loudly on anything it cannot work without.
func Load() (Config, error) {
	config := Config{
		Address:             stringOr("MATCH_ADDR", ":8080"),
		DatabaseURL:         os.Getenv("DATABASE_URL"),
		PublishersPath:      stringOr("PUBLISHERS_PATH", "/etc/rafca/publishers.txt"),
		GoogleBooksAPIKey:   os.Getenv("GOOGLE_BOOKS_API_KEY"),
		GoogleBooksEndpoint: os.Getenv("GOOGLE_BOOKS_ENDPOINT"),
		FallbackLanguage:    stringOr("FALLBACK_LANGUAGE", "tur"),
		VLMAPIKey:           os.Getenv("VLM_API_KEY"),
		VLMModel:            os.Getenv("VLM_MODEL"),
		VLMBaseURL:          os.Getenv("VLM_BASE_URL"),
		Version:             stringOr("MATCH_VERSION", "dev"),
	}

	if config.DatabaseURL == "" {
		return Config{}, fmt.Errorf("config: DATABASE_URL is unset; the matcher has no catalogue without it")
	}

	var err error
	if config.CandidateLimit, err = intOr("CANDIDATE_LIMIT", 20); err != nil {
		return Config{}, err
	}
	if config.RateLimit, err = intOr("RATE_LIMIT_PER_MINUTE", 60); err != nil {
		return Config{}, err
	}
	config.RateWindow = time.Minute
	return config, nil
}

func stringOr(name, fallback string) string {
	if value := os.Getenv(name); value != "" {
		return value
	}
	return fallback
}

func intOr(name string, fallback int) (int, error) {
	raw := os.Getenv(name)
	if raw == "" {
		return fallback, nil
	}
	value, err := strconv.Atoi(raw)
	if err != nil {
		return 0, fmt.Errorf("config: %s=%q is not a number: %w", name, raw, err)
	}
	if value <= 0 {
		return 0, fmt.Errorf("config: %s must be positive, got %d", name, value)
	}
	return value, nil
}
