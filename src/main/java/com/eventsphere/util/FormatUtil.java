package com.eventsphere.util;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

// EventSphere project (TYBCA) - date/time formatting helper.
// dt() turns a database timestamp into "yyyy-MM-dd HH:mm" text
// for dashboards, or "-" when there is no timestamp.
public final class FormatUtil {
    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private FormatUtil() {
    }

    public static String dt(LocalDateTime value) {
        return value == null ? "-" : value.format(DATE_TIME);
    }
}
