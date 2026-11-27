package com.eventsphere.security;

import org.junit.jupiter.api.Test;

import java.util.concurrent.atomic.AtomicLong;

import static org.junit.jupiter.api.Assertions.*;

class LocalRateLimitFallbackTest {

    private static final RateLimitPolicy POLICY = new RateLimitPolicy("test", 3, 60);

    @Test
    void allowsUpToConfiguredThresholdAndCountsRejectedRequests() {
        LocalRateLimitFallback limiter = new LocalRateLimitFallback();
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        RateLimitResult denied = limiter.check("ip", "/login", "hash-a", POLICY);
        assertFalse(denied.allowed());
        assertEquals(4, denied.count());
        assertTrue(denied.retryAfterSeconds() > 0);
    }

    @Test
    void dimensionsAndKeysAreIndependent() {
        LocalRateLimitFallback limiter = new LocalRateLimitFallback();
        for (int i = 0; i < 2; i++) {
            limiter.check("ip", "/login", "hash-a", POLICY);
            limiter.check("ip", "/login", "hash-b", POLICY);
            limiter.check("account", "/login", "hash-a", POLICY);
        }
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        assertTrue(limiter.check("ip", "/login", "hash-b", POLICY).allowed());
        assertTrue(limiter.check("account", "/login", "hash-a", POLICY).allowed());
        assertFalse(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
    }

    @Test
    void countersExpireAfterWindowWithoutSleeping() {
        AtomicLong now = new AtomicLong(1_000L);
        LocalRateLimitFallback limiter = new LocalRateLimitFallback(1.0, now::get);
        for (int i = 0; i < 3; i++) {
            limiter.check("ip", "/login", "hash-a", POLICY);
        }
        assertFalse(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        now.addAndGet(61_000L);
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
    }

    @Test
    void fallbackAppliesConservativeFactor() {
        LocalRateLimitFallback limiter = new LocalRateLimitFallback(0.5, () -> 0L);
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
        assertFalse(limiter.check("ip", "/login", "hash-a", POLICY).allowed());
    }

    @Test
    void resetClearsOnlyTheRequestedCounter() {
        LocalRateLimitFallback limiter = new LocalRateLimitFallback();
        limiter.check("ip", "/login", "hash-a", POLICY);
        limiter.check("ip", "/login", "hash-b", POLICY);
        limiter.reset("ip", "/login", "hash-a");
        assertTrue(limiter.check("ip", "/login", "hash-a", POLICY).count() == 1);
        assertTrue(limiter.check("ip", "/login", "hash-b", POLICY).count() == 2);
    }

    @Test
    void failureCountersUseSeparateNamespace() {
        LocalRateLimitFallback limiter = new LocalRateLimitFallback();
        for (int i = 0; i < 3; i++) {
            limiter.check("ip", "/login", "hash-a", POLICY);
        }
        assertTrue(limiter.check("ip:failure", "/login", "hash-a", POLICY).allowed());
    }
}
