package com.eventsphere.security;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.LongSupplier;

/**
 * Bounded, thread-safe, in-process counter store.
 *
 * Used as the primary limiter until Redis is wired in, and afterwards as the
 * conservative fallback when Redis is unavailable. Keys are bounded and carry
 * an expiry; a fail-closed denial is returned if the map is saturated so that
 * protection is never silently disabled.
 */
public final class LocalRateLimitFallback implements RateLimitService {

    static final int MAX_KEYS = 10_000;
    private static final long SWEEP_INTERVAL_MILLIS = 60_000L;

    private final double limitFactor;
    private final LongSupplier timeSource;
    private final ConcurrentHashMap<String, Window> counters = new ConcurrentHashMap<>();
    private final AtomicLong lastSweep = new AtomicLong();
    private final AtomicLong rejectedForCapacity = new AtomicLong();

    public LocalRateLimitFallback() {
        this(1.0, System::currentTimeMillis);
    }

    /** @param limitFactor 1.0 for normal use, below 1.0 for conservative Redis-failover limits. */
    public LocalRateLimitFallback(double limitFactor, LongSupplier timeSource) {
        this.limitFactor = limitFactor > 0 && limitFactor <= 1 ? limitFactor : 1.0;
        this.timeSource = timeSource;
    }

    public long rejectedForCapacity() {
        return rejectedForCapacity.get();
    }

    public int size() {
        return counters.size();
    }

    @Override
    public RateLimitResult check(String dimension, String endpoint, String keyHash, RateLimitPolicy policy) {
        String key = compositeKey(dimension, endpoint, keyHash);
        long now = timeSource.getAsLong();
        sweep(now);

        if (!counters.containsKey(key) && counters.size() >= MAX_KEYS) {
            sweepExpired(now);
            if (counters.size() >= MAX_KEYS) {
                rejectedForCapacity.incrementAndGet();
                return RateLimitResult.deny(0, policy.windowSeconds());
            }
        }

        long windowMillis = policy.windowMillis();
        int limit = Math.max(1, (int) Math.ceil(policy.maxRequests() * limitFactor));
        Window current = counters.compute(key, (ignored, existing) -> {
            if (existing == null || now >= existing.expiresAt) {
                return new Window(now, now + windowMillis, 1);
            }
            return new Window(existing.start, existing.expiresAt, existing.count + 1);
        });

        boolean allowed = current.count <= limit;
        int retry = allowed ? 0 : (int) Math.ceil((current.expiresAt - now) / 1000.0);
        return allowed ? RateLimitResult.allow(current.count) : RateLimitResult.deny(current.count, retry);
    }

    @Override
    public void recordFailure(String dimension, String endpoint, String keyHash, RateLimitPolicy policy) {
        check(dimension + ":failure", endpoint, keyHash, policy);
    }

    @Override
    public void reset(String dimension, String endpoint, String keyHash) {
        counters.remove(compositeKey(dimension, endpoint, keyHash));
    }

    private void sweep(long now) {
        long last = lastSweep.get();
        if (now - last >= SWEEP_INTERVAL_MILLIS && lastSweep.compareAndSet(last, now)) {
            sweepExpired(now);
        }
    }

    private void sweepExpired(long now) {
        for (var entry : counters.entrySet()) {
            Window value = entry.getValue();
            if (value != null && now >= value.expiresAt) {
                counters.remove(entry.getKey(), value);
            }
        }
    }

    private static String compositeKey(String dimension, String endpoint, String keyHash) {
        return String.valueOf(dimension) + "|" + String.valueOf(endpoint) + "|" + String.valueOf(keyHash);
    }

    private static final class Window {
        private final long start;
        private final long expiresAt;
        private final int count;

        private Window(long start, long expiresAt, int count) {
            this.start = start;
            this.expiresAt = expiresAt;
            this.count = count;
        }
    }
}
