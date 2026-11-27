package com.eventsphere.security;

/** Result of one counter check. retryAfterSeconds is always at least 1 when denied. */
public record RateLimitResult(boolean allowed, long count, int retryAfterSeconds) {

    public static RateLimitResult allow(long count) {
        return new RateLimitResult(true, count, 0);
    }

    public static RateLimitResult deny(long count, int retryAfterSeconds) {
        return new RateLimitResult(false, count, Math.max(1, retryAfterSeconds));
    }
}
