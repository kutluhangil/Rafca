package httpapi

import (
	"net"
	"net/http"
	"sync"
	"time"
)

// RateLimiter caps requests per client address (SPINE_BLUEPRINT.md 8.6: 60 per
// minute per IP).
//
// It is a fixed window rather than a token bucket because the limit exists to
// stop one device hammering the enhance tier, not to shape traffic: a window
// that resets on the minute is what the blueprint states and what an operator
// can reason about from a log line.
type RateLimiter struct {
	limit  int
	window time.Duration

	mutex   sync.Mutex
	counts  map[string]int
	resetAt time.Time
	now     func() time.Time
}

// NewRateLimiter builds a limiter.
func NewRateLimiter(limit int, window time.Duration) *RateLimiter {
	return &RateLimiter{
		limit:  limit,
		window: window,
		counts: map[string]int{},
		now:    time.Now,
	}
}

// Allow reports whether address may make another request.
func (r *RateLimiter) Allow(address string) bool {
	r.mutex.Lock()
	defer r.mutex.Unlock()

	now := r.now()
	if now.After(r.resetAt) {
		// The whole window is dropped rather than aged per key, so memory
		// cannot grow with the number of addresses seen.
		r.counts = make(map[string]int, len(r.counts))
		r.resetAt = now.Add(r.window)
	}
	if r.counts[address] >= r.limit {
		return false
	}
	r.counts[address]++
	return true
}

// Middleware rejects requests over the limit with 429.
func (r *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(writer http.ResponseWriter, request *http.Request) {
		if !r.Allow(clientAddress(request)) {
			writeError(writer, http.StatusTooManyRequests,
				"rate limit exceeded: at most %d requests per %v from one address",
				r.limit, r.window)
			return
		}
		next.ServeHTTP(writer, request)
	})
}

// clientAddress is the remote address, with the tunnel's forwarded header
// preferred because the service sits behind Cloudflare (SPINE_BLUEPRINT.md 8.6)
// and every request would otherwise share one address.
func clientAddress(request *http.Request) string {
	if forwarded := request.Header.Get("CF-Connecting-IP"); forwarded != "" {
		return forwarded
	}
	host, _, err := net.SplitHostPort(request.RemoteAddr)
	if err != nil {
		return request.RemoteAddr
	}
	return host
}
