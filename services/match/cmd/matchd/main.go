// Command matchd is the Rafça matching service (SPINE_BLUEPRINT.md 8).
package main

import (
	"context"
	"errors"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"github.com/kutluhangil/rafca/services/match/internal/catalog"
	"github.com/kutluhangil/rafca/services/match/internal/config"
	"github.com/kutluhangil/rafca/services/match/internal/googlebooks"
	"github.com/kutluhangil/rafca/services/match/internal/httpapi"
	"github.com/kutluhangil/rafca/services/match/internal/matcher"
	"github.com/kutluhangil/rafca/services/match/internal/normalize"
	"github.com/kutluhangil/rafca/services/match/internal/score"
	"github.com/kutluhangil/rafca/services/match/internal/vlm"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stderr, nil))
	if err := run(logger); err != nil {
		logger.Error("matchd stopped", "error", err)
		os.Exit(1)
	}
}

func run(logger *slog.Logger) error {
	settings, err := config.Load()
	if err != nil {
		return err
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	pool, err := pgxpool.New(ctx, settings.DatabaseURL)
	if err != nil {
		return fmt.Errorf("connecting to the catalogue: %w", err)
	}
	defer pool.Close()

	// search_blob and search_tsv are indexed with operators from the
	// `extensions` schema, so the pool has to be able to resolve them on every
	// connection, not just the first.
	if _, err := pool.Exec(ctx, "set search_path to public, extensions"); err != nil {
		return fmt.Errorf("setting search_path: %w", err)
	}

	publishers, err := loadPublishers(settings.PublishersPath)
	if err != nil {
		return err
	}
	logger.Info("publishers loaded", "path", settings.PublishersPath, "count", publishers.Len())

	store := catalog.New(pool, settings.CandidateLimit)

	var fallback matcher.Fallback
	// The Google Books tier is optional. Without a key the endpoint still
	// answers at a lower quota, so an empty key disables nothing; an empty
	// endpoint override just means the public one.
	fallback = googlebooks.New(googlebooks.Options{
		Endpoint: settings.GoogleBooksEndpoint,
		APIKey:   settings.GoogleBooksAPIKey,
	})

	enhancer := vlm.New(vlm.Options{
		APIKey:  settings.VLMAPIKey,
		Model:   settings.VLMModel,
		BaseURL: settings.VLMBaseURL,
	})
	if enhancer == nil {
		logger.Warn("enhance disabled: VLM_API_KEY is unset")
	}

	api := httpapi.New(
		matcher.New(store, publishers, score.DefaultConfig(), fallback, settings.FallbackLanguage),
		store,
		enhancer,
		settings.Version,
		logger,
	)

	server := &http.Server{
		Addr:              settings.Address,
		Handler:           api.Handler(httpapi.NewRateLimiter(settings.RateLimit, settings.RateWindow)),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       30 * time.Second,
		WriteTimeout:      60 * time.Second,
	}

	serverErrors := make(chan error, 1)
	go func() {
		logger.Info("listening", "address", settings.Address, "version", settings.Version)
		serverErrors <- server.ListenAndServe()
	}()

	select {
	case err := <-serverErrors:
		if errors.Is(err, http.ErrServerClosed) {
			return nil
		}
		return fmt.Errorf("serving: %w", err)
	case <-ctx.Done():
		logger.Info("shutting down")
		shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := server.Shutdown(shutdown); err != nil {
			return fmt.Errorf("shutting down: %w", err)
		}
		return nil
	}
}

func loadPublishers(path string) (*normalize.Publishers, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, fmt.Errorf("reading the publisher list at %s: %w", path, err)
	}
	publishers := normalize.NewPublishers(strings.Split(string(raw), "\n"))
	if publishers.Len() == 0 {
		// The list is shared with the Faz 0 spike so that the client and the
		// server score a spine the same way. An empty one would silently drop
		// the publisher signal instead of failing.
		return nil, fmt.Errorf("the publisher list at %s has no entries", path)
	}
	return publishers, nil
}
