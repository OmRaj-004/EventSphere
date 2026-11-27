package com.eventsphere.security;

/** A configurable counter policy: at most maxRequests events within windowSeconds. */
public record RateLimitPolicy(String name, int maxRequests, int windowSeconds) {

    public RateLimitPolicy {
        if (maxRequests < 1) {
            throw new IllegalArgumentException("maxRequests must be positive");
        }
        if (windowSeconds < 1) {
            throw new IllegalArgumentException("windowSeconds must be positive");
        }
    }

    public long windowMillis() {
        return windowSeconds * 1000L;
    }
}
