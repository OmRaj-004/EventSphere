package com.eventsphere.security;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class IdentifierNormalizerTest {

    private final IdentifierNormalizer normalizer = new IdentifierNormalizer("test-hmac-secret");

    @Test
    void emailIsTrimmedAndLowercased() {
        assertEquals("john.doe@example.com", normalizer.normalizeEmail("  John.Doe@Example.COM "));
        assertEquals("", normalizer.normalizeEmail(null));
    }

    @Test
    void emailIsCappedBeforeHashing() {
        String longEmail = "a".repeat(400) + "@example.com";
        assertEquals(254, normalizer.normalizeEmail(longEmail).length());
        assertEquals(64, normalizer.accountKey(longEmail, "CUSTOMER").length());
    }

    @Test
    void accountKeysAreDeterministicAndDoNotContainRawEmail() {
        String first = normalizer.accountKey("User@Example.com", "customer");
        assertEquals(first, normalizer.accountKey("  user@example.com ", "CUSTOMER"));
        assertNotEquals(first, normalizer.accountKey("user@example.com", "ADMIN"));
        assertFalse(first.contains("user@example.com"));
        assertNotEquals(first, new IdentifierNormalizer("other-secret").accountKey("user@example.com", "CUSTOMER"));
    }

    @Test
    void ipNormalizationRejectsInvalidAndCanonicalizesIpv6() {
        assertEquals("192.0.2.10", normalizer.normalizeIp(" 192.0.2.10 "));
        assertEquals("invalid", normalizer.normalizeIp("192.0.2.999"));
        assertEquals("invalid", normalizer.normalizeIp(null));
        assertTrue(normalizer.normalizeIp("2001:0DB8::1").contains("2001:db8"));
    }

    @Test
    void subnetKeysUseIpv4TwentyFourAndIpv6FortyEight() {
        assertEquals("v4:192.0.2.0", normalizer.subnetOf("192.0.2.55"));
        assertEquals("v4:192.0.2.0", normalizer.subnetOf("192.0.2.99"));
        assertTrue(normalizer.subnetOf("2001:db8:abcd::1").startsWith("v6:"));
        assertEquals(15, normalizer.subnetOf("2001:db8:abcd::1").length());
    }

    @Test
    void tokenKeysNeverContainTheRawToken() {
        String token = "cf-very-secret-token-value";
        String key = normalizer.tokenKey(token);
        assertFalse(key.contains(token));
        assertEquals(64, key.length());
    }
}
