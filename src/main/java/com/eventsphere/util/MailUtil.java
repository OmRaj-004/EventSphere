package com.eventsphere.util;

/**
 * Outgoing mail helper.
 *
 * Configure SMTP via environment variables:
 *   EVENTSPHERE_SMTP_HOST, EVENTSPHERE_SMTP_PORT (default 587),
 *   EVENTSPHERE_SMTP_USER, EVENTSPHERE_SMTP_PASSWORD,
 *   EVENTSPHERE_SMTP_FROM, EVENTSPHERE_SMTP_TLS (true/false, default true)
 *
 * This deployment ships WITHOUT a mail library/server: when no SMTP host
 * is configured, messages are logged and surfaced in-app (notifications)
 * instead of emailed, and send() returns false. Add a Jakarta Mail
 * implementation and complete sendViaSmtp() to enable real delivery.
 */
// EventSphere project (TYBCA) - helper for sending emails.
// Email sending needs SMTP server settings (host, user, password),
// which are read from environment variables. If no SMTP host is
// configured, send() returns false and the caller falls back to
// saving the message in-app (notifications table + server log).
public final class MailUtil {

    private MailUtil() {
    }

    public static boolean isConfigured() {
        String host = System.getenv("EVENTSPHERE_SMTP_HOST");
        return host != null && !host.isBlank();
    }

    public static boolean send(String to, String subject, String body) {
        if (!isConfigured()) {
            return false;
        }
        return sendViaSmtp(to, subject, body);
    }

    private static boolean sendViaSmtp(String to, String subject, String body) {
        // TODO: implement with Jakarta Mail once SMTP credentials exist.
        // Env: EVENTSPHERE_SMTP_HOST/PORT/USER/PASSWORD/FROM/TLS
        return false;
    }
}
