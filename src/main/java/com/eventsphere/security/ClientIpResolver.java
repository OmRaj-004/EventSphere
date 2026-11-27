package com.eventsphere.security;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.Arrays;
import java.util.List;
import java.util.Locale;

/**
 * Resolves the client address from the socket peer and, only when that peer is
 * an explicitly trusted proxy, from X-Forwarded-For or Forwarded metadata.
 * Arbitrary client-supplied headers are ignored on direct connections.
 *
 * This class is intentionally free of Servlet types so it can be unit tested
 * independently; the filter passes in the raw header values.
 */
public final class ClientIpResolver {

    public String resolve(String socketAddress, String forwardedFor, String forwarded,
                          List<String> trustedProxies) {
        String peer = clean(socketAddress);
        if (trustedProxies == null || trustedProxies.isEmpty() || !isTrusted(peer, trustedProxies)) {
            return peer;
        }

        String fromXff = fromForwardedFor(forwardedFor, trustedProxies);
        if (fromXff != null) {
            return fromXff;
        }
        String fromForwarded = fromForwardedHeader(forwarded, trustedProxies);
        return fromForwarded == null ? peer : fromForwarded;
    }

    /** Right-most untrusted hop wins; trusted hops are skipped. */
    private String fromForwardedFor(String header, List<String> trustedProxies) {
        if (header == null || header.isBlank()) {
            return null;
        }
        String[] hops = header.split(",");
        for (int i = hops.length - 1; i >= 0; i--) {
            String hop = clean(hops[i]);
            if (!hop.isEmpty() && isNumeric(hop) && !isTrusted(hop, trustedProxies)) {
                return hop;
            }
        }
        return null;
    }

    /** Minimal RFC 7239 parser for the for= parameter; quoted IPv6 literals are supported. */
    private String fromForwardedHeader(String header, List<String> trustedProxies) {
        if (header == null || header.isBlank()) {
            return null;
        }
        String[] elements = header.split(",");
        for (int i = elements.length - 1; i >= 0; i--) {
            for (String part : elements[i].split(";")) {
                String trimmed = part.trim().toLowerCase(Locale.ROOT);
                if (!trimmed.startsWith("for=")) {
                    continue;
                }
                String value = part.trim().substring(4).trim();
                if (value.length() >= 2 && value.startsWith("\"") && value.endsWith("\"")) {
                    value = value.substring(1, value.length() - 1);
                }
                if (value.startsWith("[")) {
                    int closing = value.indexOf(']');
                    if (closing > 0) {
                        value = value.substring(1, closing);
                    }
                } else {
                    int colon = value.lastIndexOf(':');
                    if (colon > 0 && value.indexOf(':') == colon && value.substring(colon + 1).matches("\\d+")) {
                        value = value.substring(0, colon);
                    }
                }
                if (isNumeric(value) && !isTrusted(value, trustedProxies)) {
                    return value;
                }
            }
        }
        return null;
    }

    public static boolean isTrusted(String ip, List<String> trustedProxies) {
        InetAddress address = numericAddress(ip);
        if (address == null || trustedProxies == null) {
            return false;
        }
        for (String entry : trustedProxies) {
            if (matches(address, entry.trim())) {
                return true;
            }
        }
        return false;
    }

    private static boolean matches(InetAddress address, String entry) {
        if (entry.isEmpty()) {
            return false;
        }
        try {
            if (entry.contains("/")) {
                String[] parts = entry.split("/", 2);
                InetAddress network = numericAddress(parts[0]);
                if (network == null || network.getAddress().length != address.getAddress().length) {
                    return false;
                }
                int prefix = Integer.parseInt(parts[1]);
                int bits = address.getAddress().length * 8;
                if (prefix < 0 || prefix > bits) {
                    return false;
                }
                byte[] expected = network.getAddress();
                byte[] actual = address.getAddress();
                int fullBytes = prefix / 8;
                int remaining = prefix % 8;
                for (int i = 0; i < fullBytes; i++) {
                    if (expected[i] != actual[i]) {
                        return false;
                    }
                }
                if (remaining == 0) {
                    return true;
                }
                int mask = 0xFF << (8 - remaining);
                return (expected[fullBytes] & mask) == (actual[fullBytes] & mask);
            }
            InetAddress exact = numericAddress(entry);
            return exact != null && Arrays.equals(exact.getAddress(), address.getAddress());
        } catch (NumberFormatException e) {
            return false;
        }
    }

    private static boolean isNumeric(String value) {
        return numericAddress(value) != null;
    }

    private static InetAddress numericAddress(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String candidate = value.trim();
        if (!candidate.contains(":") && !candidate.matches("^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$")) {
            return null;
        }
        try {
            return InetAddress.getByName(candidate);
        } catch (UnknownHostException e) {
            return null;
        }
    }

    private static String clean(String value) {
        return value == null ? "" : value.trim();
    }
}
