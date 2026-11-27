package com.eventsphere.security;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Locale;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

/**
 * Normalizes identifiers once and HMACs them before they are used in counters,
 * event records or logs. Raw email addresses and IP addresses never leave this
 * class (except for the resolved IP passed to the trusted-proxy decision).
 */
public final class IdentifierNormalizer {

    private static final char[] HEX = "0123456789abcdef".toCharArray();
    private static final int MAX_EMAIL_LENGTH = 254;
    private static final String IPV4 = "^(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})\\.(\\d{1,3})$";

    private final byte[] hmacKey;

    public IdentifierNormalizer(String secret) {
        this.hmacKey = (secret == null ? "" : secret).getBytes(StandardCharsets.UTF_8);
    }

    public String normalizeEmail(String raw) {
        if (raw == null) {
            return "";
        }
        String normalized = raw.trim().toLowerCase(Locale.ROOT);
        return normalized.length() > MAX_EMAIL_LENGTH ? normalized.substring(0, MAX_EMAIL_LENGTH) : normalized;
    }

    public String normalizeRole(String raw) {
        if (raw == null) {
            return "UNKNOWN";
        }
        String role = raw.trim().toUpperCase(Locale.ROOT);
        return role.equals("ADMIN") || role.equals("CUSTOMER") || role.equals("HOST") ? role : "UNKNOWN";
    }

    /** Canonical numeric IP only; anything else becomes "invalid" (no DNS lookups on hostnames). */
    public String normalizeIp(String raw) {
        if (raw == null) {
            return "invalid";
        }
        String candidate = raw.trim();
        if (candidate.matches(IPV4)) {
            String[] parts = candidate.split("\\.");
            for (String part : parts) {
                if (Integer.parseInt(part) > 255) {
                    return "invalid";
                }
            }
            return candidate;
        }
        if (candidate.indexOf(':') >= 0) {
            InetAddress address = numericAddress(candidate);
            return address == null ? "invalid" : address.getHostAddress();
        }
        return "invalid";
    }

    /** IPv4 /24 and IPv6 /48 identifiers, expressed canonically before HMAC. */
    public String subnetOf(String ip) {
        InetAddress address = numericAddress(normalizeIp(ip));
        if (address == null) {
            return "invalid";
        }
        byte[] bytes = address.getAddress();
        if (bytes.length == 4) {
            return "v4:" + (bytes[0] & 0xFF) + "." + (bytes[1] & 0xFF) + "." + (bytes[2] & 0xFF) + ".0";
        }
        if (bytes.length == 16) {
            return "v6:" + hex(Arrays.copyOf(bytes, 6));
        }
        return "invalid";
    }

    public String accountKey(String email, String role) {
        return hmac("account|" + normalizeEmail(email) + "|" + normalizeRole(role));
    }

    public String ipKey(String ip) {
        return hmac("ip|" + normalizeIp(ip));
    }

    public String subnetKey(String ip) {
        return hmac("subnet|" + subnetOf(ip));
    }

    public String tokenKey(String token) {
        String value = token == null ? "" : token.trim();
        return hmac("token|" + (value.length() > 512 ? value.substring(0, 512) : value));
    }

    /** Stable HMAC-SHA256 hex digest. Never used for passwords. */
    public String hmac(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(hmacKey, "HmacSHA256"));
            return hex(mac.doFinal(value.getBytes(StandardCharsets.UTF_8)));
        } catch (Exception e) {
            throw new IllegalStateException("HMAC-SHA256 unavailable", e);
        }
    }

    private static InetAddress numericAddress(String value) {
        if (value == null || value.isBlank() || "invalid".equals(value)) {
            return null;
        }
        if (!value.contains(":") && !value.matches(IPV4)) {
            return null;
        }
        try {
            return InetAddress.getByName(value);
        } catch (UnknownHostException e) {
            return null;
        }
    }

    private static String hex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(HEX[(b >> 4) & 0xF]).append(HEX[b & 0xF]);
        }
        return sb.toString();
    }

    /** Exposed for tests that need to verify digests without reimplementing HMAC. */
    public static String sha256Hex(String value) {
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256").digest(value.getBytes(StandardCharsets.UTF_8));
            return hex(digest);
        } catch (Exception e) {
            throw new IllegalStateException("SHA-256 unavailable", e);
        }
    }
}
