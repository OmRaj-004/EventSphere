package com.eventsphere.security;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.UUID;
import java.util.function.Function;

/**
 * Central configuration for the authentication security layer.
 *
 * Values follow the project's existing convention: environment variables are
 * read from System.getenv() with the EVENTSPHERE_ prefix. Safe development
 * defaults are provided; in PROD, missing mandatory secrets are reported via
 * missingMandatorySettings() so the filter can fail closed instead of running
 * with an incomplete security configuration.
 */
public final class AuthSecurityConfig {

    public enum Profile { DEV, PROD }

    private static final AuthSecurityConfig INSTANCE = new AuthSecurityConfig(System::getenv);

    private final Profile profile;
    private final String hmacSecret;
    private final boolean rateLimitEnabled;
    private final List<String> trustedProxies;
    private final Map<String, RateLimitPolicy> ipPolicies;
    private final int accountFailureLimit;
    private final int accountFailureWindowSeconds;
    private final int globalFailureThreshold;
    private final int globalWindowSeconds;
    private final int maxParameterLength;
    private final long maxBodyBytes;
    private final List<String> missingMandatorySettings;

    public static AuthSecurityConfig instance() {
        return INSTANCE;
    }

    /** Visible for tests so environment values can be injected deterministically. */
    public AuthSecurityConfig(Function<String, String> env) {
        this.profile = "PROD".equalsIgnoreCase(value(env, "EVENTSPHERE_APP_PROFILE", "DEV"))
                ? Profile.PROD : Profile.DEV;

        List<String> missing = new ArrayList<>();
        String secret = value(env, "EVENTSPHERE_HMAC_SECRET", "");
        if (secret.isBlank()) {
            if (this.profile == Profile.PROD) {
                missing.add("EVENTSPHERE_HMAC_SECRET");
                // Ephemeral value only: PROD requests are rejected while config is incomplete.
                this.hmacSecret = UUID.randomUUID().toString();
            } else {
                this.hmacSecret = "eventsphere-dev-only-hmac-secret-change-me";
            }
        } else {
            this.hmacSecret = secret;
        }
        this.missingMandatorySettings = List.copyOf(missing);

        this.rateLimitEnabled = !"false".equalsIgnoreCase(
                value(env, "EVENTSPHERE_AUTH_RATE_LIMIT_ENABLED", "true"));

        String proxyList = value(env, "EVENTSPHERE_TRUSTED_PROXIES", "");
        List<String> proxies = new ArrayList<>();
        for (String entry : proxyList.split(",")) {
            if (!entry.isBlank()) {
                proxies.add(entry.trim());
            }
        }
        this.trustedProxies = List.copyOf(proxies);

        Map<String, RateLimitPolicy> policies = new LinkedHashMap<>();
        policies.put("/login", new RateLimitPolicy("login-ip",
                intValue(env, "EVENTSPHERE_AUTH_IP_LIMIT", 10, 1),
                intValue(env, "EVENTSPHERE_AUTH_IP_LIMIT_WINDOW_SECONDS", 300, 1)));
        policies.put("/register", new RateLimitPolicy("register-ip",
                intValue(env, "EVENTSPHERE_AUTH_REGISTER_IP_LIMIT", 5, 1),
                intValue(env, "EVENTSPHERE_AUTH_REGISTER_WINDOW_SECONDS", 3600, 1)));
        policies.put("/forgot-password", new RateLimitPolicy("forgot-password-ip",
                intValue(env, "EVENTSPHERE_AUTH_FORGOT_IP_LIMIT", 5, 1),
                intValue(env, "EVENTSPHERE_AUTH_FORGOT_WINDOW_SECONDS", 3600, 1)));
        policies.put("/reset-password", new RateLimitPolicy("reset-password-ip",
                intValue(env, "EVENTSPHERE_AUTH_RESET_IP_LIMIT", 5, 1),
                intValue(env, "EVENTSPHERE_AUTH_RESET_WINDOW_SECONDS", 3600, 1)));
        RateLimitPolicy adminCreation = new RateLimitPolicy("admin-account-creation-ip",
                intValue(env, "EVENTSPHERE_AUTH_ADMIN_CREATE_IP_LIMIT", 5, 1),
                intValue(env, "EVENTSPHERE_AUTH_ADMIN_CREATE_WINDOW_SECONDS", 3600, 1));
        policies.put("/admin/admins", adminCreation);
        policies.put("/admin/hosts", adminCreation);
        this.ipPolicies = Map.copyOf(policies);

        this.accountFailureLimit = intValue(env, "EVENTSPHERE_AUTH_ACCOUNT_FAILURE_LIMIT", 5, 1);
        this.accountFailureWindowSeconds = intValue(env, "EVENTSPHERE_AUTH_ACCOUNT_FAILURE_WINDOW_SECONDS", 600, 1);
        this.globalFailureThreshold = intValue(env, "EVENTSPHERE_AUTH_GLOBAL_FAILURE_THRESHOLD", 100, 1);
        this.globalWindowSeconds = intValue(env, "EVENTSPHERE_AUTH_GLOBAL_WINDOW_SECONDS", 600, 1);
        this.maxParameterLength = intValue(env, "EVENTSPHERE_AUTH_MAX_PARAMETER_LENGTH", 4096, 1);
        this.maxBodyBytes = longValue(env, "EVENTSPHERE_AUTH_MAX_BODY_BYTES", 16384L, 1L);
    }

    public Profile profile() {
        return profile;
    }

    public String hmacSecret() {
        return hmacSecret;
    }

    public boolean isRateLimitEnabled() {
        return rateLimitEnabled;
    }

    public List<String> trustedProxies() {
        return trustedProxies;
    }

    public RateLimitPolicy ipPolicy(String servletPath) {
        return ipPolicies.get(normalizePath(servletPath));
    }

    public Map<String, RateLimitPolicy> ipPolicies() {
        return ipPolicies;
    }

    public int accountFailureLimit() {
        return accountFailureLimit;
    }

    public int accountFailureWindowSeconds() {
        return accountFailureWindowSeconds;
    }

    public int globalFailureThreshold() {
        return globalFailureThreshold;
    }

    public int globalWindowSeconds() {
        return globalWindowSeconds;
    }

    public int maxParameterLength() {
        return maxParameterLength;
    }

    public long maxBodyBytes() {
        return maxBodyBytes;
    }

    public List<String> missingMandatorySettings() {
        return missingMandatorySettings;
    }

    public boolean isProductionReady() {
        return missingMandatorySettings.isEmpty();
    }

    private static String normalizePath(String path) {
        if (path == null || path.isBlank()) {
            return "";
        }
        String normalized = path.trim().toLowerCase(Locale.ROOT);
        int index = normalized.indexOf(';');
        return index < 0 ? normalized : normalized.substring(0, index);
    }

    private static String value(Function<String, String> env, String key, String fallback) {
        String raw = env.apply(key);
        return raw == null || raw.isBlank() ? fallback : raw;
    }

    private static int intValue(Function<String, String> env, String key, int fallback, int minimum) {
        try {
            int parsed = Integer.parseInt(value(env, key, String.valueOf(fallback)));
            return Math.max(minimum, parsed);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }

    private static long longValue(Function<String, String> env, String key, long fallback, long minimum) {
        try {
            long parsed = Long.parseLong(value(env, key, String.valueOf(fallback)));
            return Math.max(minimum, parsed);
        } catch (NumberFormatException e) {
            return fallback;
        }
    }
}
