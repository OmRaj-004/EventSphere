package com.eventsphere.security;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

class ClientIpResolverTest {

    private final ClientIpResolver resolver = new ClientIpResolver();

    @Test
    void arbitraryForwardedHeadersAreIgnoredOnDirectConnections() {
        assertEquals("203.0.113.5", resolver.resolve("203.0.113.5",
                "198.51.100.7", "for=198.51.100.7", List.of()));
    }

    @Test
    void trustedProxyUsesRightmostUntrustedXffHop() {
        assertEquals("203.0.113.9", resolver.resolve("10.0.0.5",
                "198.51.100.7, 203.0.113.9", null, List.of("10.0.0.5")));
    }

    @Test
    void trustedCidrUsesXffAndSkipsTrustedHops() {
        assertEquals("198.51.100.7", resolver.resolve("10.1.2.3",
                "198.51.100.7, 10.9.9.9", null, List.of("10.0.0.0/8")));
    }

    @Test
    void allTrustedHopsFallBackToSocketAddress() {
        assertEquals("10.0.0.5", resolver.resolve("10.0.0.5",
                "10.0.0.6, 10.0.0.7", null, List.of("10.0.0.0/8")));
    }

    @Test
    void forwardedHeaderIsParsedOnlyBehindTrustedProxy() {
        assertEquals("192.0.2.43", resolver.resolve("10.0.0.5", null,
                "for=192.0.2.43;proto=https", List.of("10.0.0.5")));
        assertEquals("2001:db8::1", resolver.resolve("10.0.0.5", null,
                "for=\"[2001:db8::1]:8443\"", List.of("10.0.0.5")));
    }

    @Test
    void invalidCidrEntriesAreIgnored() {
        assertFalse(ClientIpResolver.isTrusted("10.0.0.1", List.of("not-an-ip/33")));
        assertTrue(ClientIpResolver.isTrusted("10.0.0.1", List.of("10.0.0.0/8")));
    }
}
