package com.eventsphere.util;

/**
 * HTML-escapes untrusted data for JSP output. Use as
 * {@code <%= EscapeUtil.e(value) %>} instead of raw {@code <%= value %>}.
 * This converts characters like < > & " into safe codes so that
 * user input can never run as JavaScript in another user's browser.
 * (This protection is called prevention of Cross-Site Scripting/XSS.)
 */
public final class EscapeUtil {

    private EscapeUtil() {
    }

    public static String e(Object value) {
        if (value == null) {
            return "";
        }
        String s = String.valueOf(value);
        StringBuilder sb = new StringBuilder(s.length() + 16);
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '&':
                    sb.append("&amp;");
                    break;
                case '<':
                    sb.append("&lt;");
                    break;
                case '>':
                    sb.append("&gt;");
                    break;
                case '"':
                    sb.append("&quot;");
                    break;
                case '\'':
                    sb.append("&#x27;");
                    break;
                default:
                    sb.append(c);
            }
        }
        return sb.toString();
    }
}
