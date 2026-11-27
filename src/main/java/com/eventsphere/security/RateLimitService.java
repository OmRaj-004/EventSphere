package com.eventsphere.security;

/**
 * Counter storage abstraction. Implementations must be thread-safe, apply a TTL
 * to every temporary key, and update counters atomically.
 *
 * Dimensions are independent: request counts are incremented before password
 * verification, failure counts only after a failed verification.
 */
public interface RateLimitService {

    RateLimitResult check(String dimension, String endpoint, String keyHash, RateLimitPolicy policy);

    void recordFailure(String dimension, String endpoint, String keyHash, RateLimitPolicy policy);

    void reset(String dimension, String endpoint, String keyHash);
}
