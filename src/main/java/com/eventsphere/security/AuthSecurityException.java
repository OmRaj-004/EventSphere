package com.eventsphere.security;

/** Base type for decisions that stop an authentication request before password verification. */
public class AuthSecurityException extends RuntimeException {

    public AuthSecurityException(String message) {
        super(message);
    }

    public AuthSecurityException(String message, Throwable cause) {
        super(message, cause);
    }

    /** The request exceeded a configured rate limit. */
    public static final class RateLimitException extends AuthSecurityException {
        public RateLimitException(String message) {
            super(message);
        }
    }

    /** A server-verified challenge is required before authentication may continue. */
    public static final class ChallengeRequiredException extends AuthSecurityException {
        public ChallengeRequiredException(String message) {
            super(message);
        }
    }

    /** A required verification service (Redis, Turnstile) is unavailable; fail closed. */
    public static final class VerificationUnavailableException extends AuthSecurityException {
        public VerificationUnavailableException(String message, Throwable cause) {
            super(message, cause);
        }
    }
}
