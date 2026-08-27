package httpapi

import (
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

func TestRateLimiterCountsPerAddress(t *testing.T) {
	limiter := NewRateLimiter(2, time.Minute)

	for i := 0; i < 2; i++ {
		if !limiter.Allow("1.1.1.1") {
			t.Fatalf("request %d from the first address was refused", i+1)
		}
	}
	if limiter.Allow("1.1.1.1") {
		t.Error("the third request from the first address was allowed")
	}
	if !limiter.Allow("2.2.2.2") {
		t.Error("a second address was refused because of the first one's usage")
	}
}

func TestRateLimiterResetsWithTheWindow(t *testing.T) {
	limiter := NewRateLimiter(1, time.Minute)
	clock := time.Date(2026, 8, 27, 12, 0, 0, 0, time.UTC)
	limiter.now = func() time.Time { return clock }

	if !limiter.Allow("1.1.1.1") || limiter.Allow("1.1.1.1") {
		t.Fatal("the limit of one was not enforced inside the window")
	}

	clock = clock.Add(time.Minute + time.Second)
	if !limiter.Allow("1.1.1.1") {
		t.Error("the address was still blocked after the window rolled over")
	}
}

func TestMiddlewareAnswers429(t *testing.T) {
	limiter := NewRateLimiter(1, time.Minute)
	handler := limiter.Middleware(http.HandlerFunc(func(writer http.ResponseWriter, _ *http.Request) {
		writer.WriteHeader(http.StatusOK)
	}))

	for i, want := range []int{http.StatusOK, http.StatusTooManyRequests} {
		request := httptest.NewRequest(http.MethodGet, "/v1/health", nil)
		request.RemoteAddr = "9.9.9.9:1234"
		recorder := httptest.NewRecorder()
		handler.ServeHTTP(recorder, request)
		if recorder.Code != want {
			t.Errorf("request %d: status = %d, want %d", i+1, recorder.Code, want)
		}
	}
}

func TestClientAddressPrefersTheTunnelHeader(t *testing.T) {
	request := httptest.NewRequest(http.MethodGet, "/v1/health", nil)
	request.RemoteAddr = "10.0.0.1:5000"
	if got := clientAddress(request); got != "10.0.0.1" {
		t.Errorf("clientAddress = %q, want the remote host", got)
	}

	request.Header.Set("CF-Connecting-IP", "203.0.113.7")
	if got := clientAddress(request); got != "203.0.113.7" {
		t.Errorf("clientAddress = %q, want the forwarded address", got)
	}
}
