// Package httpapi serves the endpoints of SPINE_BLUEPRINT.md 8.1.
package httpapi

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"time"

	"github.com/kutluhangil/rafca/services/match/internal/catalog"
	"github.com/kutluhangil/rafca/services/match/internal/matcher"
	"github.com/kutluhangil/rafca/services/match/internal/vlm"
)

// maxRequestBytes bounds a /v1/match body. A shelf photo yields tens of spines
// of a few hundred characters; anything past this is not a shelf.
const maxRequestBytes = 1 << 20

// maxCropBytes bounds an /v1/enhance upload. One spine crop, not a photo.
const maxCropBytes = 4 << 20

// API holds the handlers' dependencies.
type API struct {
	matcher *matcher.Matcher
	store   *catalog.Store
	vlm     *vlm.Client
	version string
	logger  *slog.Logger
}

// New builds the API. enhancer may be nil, which makes /v1/enhance answer 503.
func New(match *matcher.Matcher, store *catalog.Store, enhancer *vlm.Client, version string, logger *slog.Logger) *API {
	return &API{matcher: match, store: store, vlm: enhancer, version: version, logger: logger}
}

// Handler wires the routes and the rate limit.
func (a *API) Handler(limiter *RateLimiter) http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("POST /v1/match", a.handleMatch)
	mux.HandleFunc("POST /v1/enhance", a.handleEnhance)
	mux.HandleFunc("GET /v1/health", a.handleHealth)
	return limiter.Middleware(mux)
}

type matchRequest struct {
	Spines []matcher.Spine `json:"spines"`
}

type matchResponse struct {
	Results []matcher.Result `json:"results"`
}

func (a *API) handleMatch(writer http.ResponseWriter, request *http.Request) {
	var body matchRequest
	if err := decodeJSON(request, maxRequestBytes, &body); err != nil {
		writeError(writer, http.StatusBadRequest, "%s", err)
		return
	}
	if len(body.Spines) == 0 {
		writeError(writer, http.StatusBadRequest, "spines is empty: nothing to match")
		return
	}

	results, err := a.matcher.MatchBatch(request.Context(), body.Spines)
	if err != nil {
		a.logger.Error("match failed", "error", err, "spines", len(body.Spines))
		writeError(writer, http.StatusInternalServerError, "matching failed: %s", err)
		return
	}
	writeJSON(writer, http.StatusOK, matchResponse{Results: results})
}

type enhanceRequest struct {
	// Image is the base64 spine crop. It is the only image the client ever
	// sends, and only because the user asked for it (SPINE_BLUEPRINT.md 5).
	Image     []byte `json:"image"`
	MediaType string `json:"media_type"`
}

type enhanceResponse struct {
	Title  string `json:"title"`
	Author string `json:"author"`
}

func (a *API) handleEnhance(writer http.ResponseWriter, request *http.Request) {
	if a.vlm == nil {
		writeError(writer, http.StatusServiceUnavailable,
			"enhance is not configured on this deployment: VLM_API_KEY is unset")
		return
	}

	var body enhanceRequest
	if err := decodeJSON(request, maxCropBytes, &body); err != nil {
		writeError(writer, http.StatusBadRequest, "%s", err)
		return
	}

	reading, err := a.vlm.Read(request.Context(), body.Image, body.MediaType)
	if err != nil {
		a.logger.Error("enhance failed", "error", err)
		writeError(writer, http.StatusBadGateway, "enhance failed: %s", err)
		return
	}
	writeJSON(writer, http.StatusOK, enhanceResponse{Title: reading.Title, Author: reading.Author})
}

type healthResponse struct {
	Version  string `json:"version"`
	Database string `json:"database"`
}

func (a *API) handleHealth(writer http.ResponseWriter, request *http.Request) {
	ctx, cancel := context.WithTimeout(request.Context(), 2*time.Second)
	defer cancel()

	if err := a.store.Ping(ctx); err != nil {
		writeJSON(writer, http.StatusServiceUnavailable, healthResponse{
			Version:  a.version,
			Database: err.Error(),
		})
		return
	}
	writeJSON(writer, http.StatusOK, healthResponse{Version: a.version, Database: "ok"})
}

func decodeJSON(request *http.Request, limit int64, target any) error {
	decoder := json.NewDecoder(io.LimitReader(request.Body, limit))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(target); err != nil {
		return fmt.Errorf("cannot read request body: %w", err)
	}
	return nil
}

func writeJSON(writer http.ResponseWriter, status int, body any) {
	writer.Header().Set("Content-Type", "application/json; charset=utf-8")
	writer.WriteHeader(status)
	_ = json.NewEncoder(writer).Encode(body)
}

type errorBody struct {
	Error string `json:"error"`
}

func writeError(writer http.ResponseWriter, status int, format string, args ...any) {
	writeJSON(writer, status, errorBody{Error: fmt.Sprintf(format, args...)})
}
