package com.eventsphere.filter;

import com.eventsphere.security.AuthSecurityConfig;
import com.eventsphere.security.ClientIpResolver;
import com.eventsphere.security.IdentifierNormalizer;
import com.eventsphere.security.LocalRateLimitFallback;
import com.eventsphere.security.RateLimitPolicy;
import com.eventsphere.security.RateLimitResult;
import com.eventsphere.security.RateLimitService;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * Layer 2 entry point for authentication endpoints.
 *
 * Checks request structure/size, resolves the client address through the
 * trusted-proxy policy, and counts each request before any database lookup or
 * BCrypt verification. Risk scoring, Turnstile and CSRF are added in later
 * checkpoints behind the request attributes set here.
 */
public class AuthSecurityFilter implements Filter {

    private static final int STATUS_TOO_MANY_REQUESTS = 429;

    public static final String ATTR_IP_HASH = "eventsphere.security.ipHash";
    public static final String ATTR_ACCOUNT_KEY = "eventsphere.security.accountKey";
    public static final String ATTR_ENDPOINT = "eventsphere.security.endpoint";
    public static final String ATTR_RATE_LIMIT = "eventsphere.security.rateLimit";

    private AuthSecurityConfig config;
    private RateLimitService rateLimitService;
    private IdentifierNormalizer normalizer;
    private ClientIpResolver ipResolver;
    private ServletContext context;
    private final AtomicBoolean configurationAlertLogged = new AtomicBoolean(false);

    @Override
    public void init(FilterConfig filterConfig) {
        this.context = filterConfig.getServletContext();
        this.config = AuthSecurityConfig.instance();
        this.rateLimitService = new LocalRateLimitFallback();
        this.normalizer = new IdentifierNormalizer(config.hmacSecret());
        this.ipResolver = new ClientIpResolver();
    }

    /** Visible for tests; production instances are created by init(). */
    public AuthSecurityFilter(AuthSecurityConfig config, RateLimitService rateLimitService,
                              IdentifierNormalizer normalizer, ClientIpResolver ipResolver) {
        this.config = config;
        this.rateLimitService = rateLimitService;
        this.normalizer = normalizer;
        this.ipResolver = ipResolver;
    }

    public AuthSecurityFilter() {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        if (!"POST".equalsIgnoreCase(httpRequest.getMethod())) {
            chain.doFilter(request, response);
            return;
        }

        if (!config.isProductionReady()) {
            logAlert("AUTH_CONFIG_INCOMPLETE missing=" + config.missingMandatorySettings());
            httpResponse.setHeader("Retry-After", "60");
            httpResponse.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Authentication is temporarily unavailable. Please try again later.");
            return;
        }

        if (!config.isRateLimitEnabled()) {
            chain.doFilter(request, response);
            return;
        }

        if (!hasValidStructure(httpRequest, httpResponse)) {
            return;
        }

        String endpoint = httpRequest.getServletPath() == null ? "" : httpRequest.getServletPath();
        RateLimitPolicy policy = config.ipPolicy(endpoint);
        if (policy == null) {
            chain.doFilter(request, response);
            return;
        }

        String ip = ipResolver.resolve(httpRequest.getRemoteAddr(),
                httpRequest.getHeader("X-Forwarded-For"),
                httpRequest.getHeader("Forwarded"),
                config.trustedProxies());
        String ipHash = normalizer.ipKey(ip);
        RateLimitResult result = rateLimitService.check("ip", endpoint, ipHash, policy);

        httpRequest.setAttribute(ATTR_IP_HASH, ipHash);
        httpRequest.setAttribute(ATTR_ENDPOINT, endpoint);
        httpRequest.setAttribute(ATTR_ACCOUNT_KEY, normalizer.accountKey(
                httpRequest.getParameter("email"), httpRequest.getParameter("role")));
        httpRequest.setAttribute(ATTR_RATE_LIMIT, result);

        if (!result.allowed()) {
            logEvent("LOGIN_RATE_LIMITED", endpoint, ipHash, 0, "THROTTLE");
            httpResponse.setHeader("Retry-After", String.valueOf(result.retryAfterSeconds()));
            httpResponse.sendError(STATUS_TOO_MANY_REQUESTS,
                    "Too many authentication attempts. Please try again shortly.");
            return;
        }

        chain.doFilter(request, response);
    }

    private boolean hasValidStructure(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        long contentLength = request.getContentLengthLong();
        if (contentLength > config.maxBodyBytes()) {
            response.sendError(HttpServletResponse.SC_REQUEST_ENTITY_TOO_LARGE, "Request is too large.");
            return false;
        }
        var names = request.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            String[] values = request.getParameterValues(name);
            if (values != null) {
                for (String value : values) {
                    if (value != null && value.length() > config.maxParameterLength()) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid request.");
                        return false;
                    }
                }
            }
        }
        return true;
    }

    private void logEvent(String eventType, String endpoint, String ipHash, int score, String action) {
        if (context != null) {
            context.log("SECURITY_EVENT event=" + eventType + " endpoint=" + endpoint
                    + " ipHash=" + ipHash + " riskScore=" + score + " action=" + action);
        }
    }

    private void logAlert(String message) {
        if (context != null && configurationAlertLogged.compareAndSet(false, true)) {
            context.log("SECURITY_ALERT " + message);
        }
    }

    @Override
    public void destroy() {
        // Resources are owned by SecurityInitializer in later checkpoints.
    }
}
