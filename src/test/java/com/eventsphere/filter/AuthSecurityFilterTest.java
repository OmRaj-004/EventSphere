package com.eventsphere.filter;

import com.eventsphere.security.AuthSecurityConfig;
import com.eventsphere.security.ClientIpResolver;
import com.eventsphere.security.IdentifierNormalizer;
import com.eventsphere.security.RateLimitPolicy;
import com.eventsphere.security.RateLimitResult;
import com.eventsphere.security.RateLimitService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

class AuthSecurityFilterTest {

    private final IdentifierNormalizer normalizer = new IdentifierNormalizer("test-secret");

    @Test
    void allowedRequestContinuesAndExposesRiskAttributes() throws Exception {
        FakeLimits limits = new FakeLimits(RateLimitResult.allow(1));
        AuthSecurityFilter filter = new AuthSecurityFilter(config(""), limits,
                normalizer, new ClientIpResolver());

        TestRequest request = new TestRequest();
        TestResponse response = new TestResponse();
        boolean[] chained = {false};
        filter.doFilter(request.proxy(), response.proxy(), (req, res) -> chained[0] = true);

        assertTrue(chained[0]);
        assertEquals(normalizer.ipKey("203.0.113.5"),
                request.attribute(AuthSecurityFilter.ATTR_IP_HASH));
        assertEquals("/login", request.attribute(AuthSecurityFilter.ATTR_ENDPOINT));
        assertEquals(normalizer.accountKey("user@example.com", "CUSTOMER"),
                request.attribute(AuthSecurityFilter.ATTR_ACCOUNT_KEY));
        assertTrue(response.errors.isEmpty());
    }

    @Test
    void rateLimitedRequestGets429AndNeverReachesServlet() throws Exception {
        FakeLimits limits = new FakeLimits(RateLimitResult.deny(11, 42));
        AuthSecurityFilter filter = new AuthSecurityFilter(config(""), limits,
                normalizer, new ClientIpResolver());

        TestRequest request = new TestRequest();
        TestResponse response = new TestResponse();
        boolean[] chained = {false};
        filter.doFilter(request.proxy(), response.proxy(), (req, res) -> chained[0] = true);

        assertFalse(chained[0]);
        assertEquals(List.of(429), response.errors);
        assertEquals("42", response.headers.get("Retry-After"));
    }

    @Test
    void oversizedBodyAndParameterAreRejectedBeforeCounting() throws Exception {
        AuthSecurityFilter filter = new AuthSecurityFilter(config(""), new FakeLimits(RateLimitResult.allow(1)),
                normalizer, new ClientIpResolver());

        TestRequest bigBody = new TestRequest();
        bigBody.contentLength = 99_999L;
        TestResponse bodyResponse = new TestResponse();
        filter.doFilter(bigBody.proxy(), bodyResponse.proxy(), (req, res) -> fail("chain must not run"));
        assertEquals(List.of(413), bodyResponse.errors);

        TestRequest bigParam = new TestRequest();
        bigParam.parameters.put("password", "x".repeat(5_000));
        TestResponse paramResponse = new TestResponse();
        filter.doFilter(bigParam.proxy(), paramResponse.proxy(), (req, res) -> fail("chain must not run"));
        assertEquals(List.of(400), paramResponse.errors);
    }

    @Test
    void xffIsUsedOnlyBehindConfiguredTrustedProxy() throws Exception {
        TestRequest request = new TestRequest();
        request.remoteAddress = "10.0.0.5";
        request.headers.put("X-Forwarded-For", "198.51.100.7");

        FakeLimits trustedLimits = new FakeLimits(RateLimitResult.allow(1));
        new AuthSecurityFilter(config("10.0.0.5"), trustedLimits, normalizer, new ClientIpResolver())
                .doFilter(request.proxy(), new TestResponse().proxy(), (req, res) -> { });
        assertEquals(normalizer.ipKey("198.51.100.7"), trustedLimits.keyHash);

        FakeLimits directLimits = new FakeLimits(RateLimitResult.allow(1));
        new AuthSecurityFilter(config(""), directLimits, normalizer, new ClientIpResolver())
                .doFilter(new TestRequest().proxy(), new TestResponse().proxy(), (req, res) -> { });
        assertEquals(normalizer.ipKey("203.0.113.5"), directLimits.keyHash);
    }

    private static AuthSecurityConfig config(String trustedProxy) {
        return new AuthSecurityConfig(key -> switch (key) {
            case "EVENTSPHERE_HMAC_SECRET" -> "test-secret";
            case "EVENTSPHERE_TRUSTED_PROXIES" -> trustedProxy;
            default -> null;
        });
    }

    private static Object defaultValue(Class<?> type) {
        if (type == boolean.class) return false;
        if (type == int.class) return 0;
        if (type == long.class) return 0L;
        return null;
    }

    private static final class FakeLimits implements RateLimitService {
        private final RateLimitResult result;
        private String keyHash;

        private FakeLimits(RateLimitResult result) {
            this.result = result;
        }

        @Override
        public RateLimitResult check(String dimension, String endpoint, String keyHash, RateLimitPolicy policy) {
            this.keyHash = keyHash;
            return result;
        }

        @Override
        public void recordFailure(String dimension, String endpoint, String keyHash, RateLimitPolicy policy) {
        }

        @Override
        public void reset(String dimension, String endpoint, String keyHash) {
        }
    }

    private static final class TestRequest {
        private final Map<String, Object> attributes = new HashMap<>();
        private final Map<String, String> headers = new HashMap<>();
        private final Map<String, String> parameters = new LinkedHashMap<>();
        private String remoteAddress = "203.0.113.5";
        private long contentLength = 0L;

        private TestRequest() {
            parameters.put("email", "user@example.com");
            parameters.put("role", "CUSTOMER");
        }

        private Object attribute(String name) {
            return attributes.get(name);
        }

        private HttpServletRequest proxy() {
            return (HttpServletRequest) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletRequest.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "getMethod" -> "POST";
                        case "getServletPath" -> "/login";
                        case "getRemoteAddr" -> remoteAddress;
                        case "getHeader" -> headers.get((String) args[0]);
                        case "getParameterNames" -> Collections.enumeration(parameters.keySet());
                        case "getParameter" -> parameters.get((String) args[0]);
                        case "getParameterValues" -> new String[]{parameters.get((String) args[0])};
                        case "getContentLengthLong" -> contentLength;
                        case "setAttribute" -> {
                            attributes.put((String) args[0], args[1]);
                            yield null;
                        }
                        case "getAttribute" -> attributes.get((String) args[0]);
                        default -> defaultValue(method.getReturnType());
                    });
        }
    }

    private static final class TestResponse {
        private final Map<String, String> headers = new HashMap<>();
        private final List<Integer> errors = new ArrayList<>();

        private HttpServletResponse proxy() {
            return (HttpServletResponse) Proxy.newProxyInstance(getClass().getClassLoader(),
                    new Class<?>[]{HttpServletResponse.class}, (proxy, method, args) -> switch (method.getName()) {
                        case "setHeader" -> {
                            headers.put((String) args[0], (String) args[1]);
                            yield null;
                        }
                        case "sendError" -> {
                            errors.add((Integer) args[0]);
                            yield null;
                        }
                        case "getStatus" -> 200;
                        default -> defaultValue(method.getReturnType());
                    });
        }
    }
}
