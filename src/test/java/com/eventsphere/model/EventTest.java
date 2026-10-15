package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import org.junit.jupiter.api.Test;

class EventTest {

    @Test
    void shouldCreateEventWithNameTypeAndDate() {
        LocalDate date = LocalDate.of(2026, 10, 15);
        Event event = new Event("Tech Meetup", "WORKSHOP", date);

        assertEquals("Tech Meetup", event.getName());
        assertEquals("WORKSHOP", event.getEventType());
        assertEquals(date, event.getEventDate());
    }

    @Test
    void shouldSetAndGetEventProperties() {
        Event event = new Event();
        LocalDate date = LocalDate.of(2026, 12, 2);
        LocalTime start = LocalTime.of(9, 30);
        LocalTime end = LocalTime.of(11, 0);
        LocalDateTime created = LocalDateTime.of(2026, 9, 1, 8, 0);
        LocalDateTime updated = LocalDateTime.of(2026, 9, 1, 9, 0);

        event.setId(19);
        event.setName("Startup Expo");
        event.setDescription("Find new investors");
        event.setEventType("CONFERENCE");
        event.setEventDate(date);
        event.setStartTime(start);
        event.setEndTime(end);
        event.setExpectedGuests(150);
        event.setOrganizerId(7);
        event.setVenueId(3);
        event.setStatus("APPROVED");
        event.setCreatedAt(created);
        event.setUpdatedAt(updated);

        assertEquals(19, event.getId());
        assertEquals("Startup Expo", event.getName());
        assertEquals("Find new investors", event.getDescription());
        assertEquals("CONFERENCE", event.getEventType());
        assertEquals(date, event.getEventDate());
        assertEquals(start, event.getStartTime());
        assertEquals(end, event.getEndTime());
        assertEquals(150, event.getExpectedGuests());
        assertEquals(7, event.getOrganizerId());
        assertEquals(3, event.getVenueId());
        assertEquals("APPROVED", event.getStatus());
        assertEquals(created, event.getCreatedAt());
        assertEquals(updated, event.getUpdatedAt());
    }

    @Test
    void shouldRenderToStringWithCoreFields() {
        Event event = new Event();
        event.setId(11);
        event.setName("Music Night");
        event.setEventType("FESTIVAL");
        event.setEventDate(LocalDate.of(2026, 11, 13));
        event.setStatus("DRAFT");

        String value = event.toString();

        assertTrue(value.contains("Event{"));
        assertTrue(value.contains("Music Night"));
        assertTrue(value.contains("FESTIVAL"));
        assertTrue(value.contains("2026-11-13"));
        assertTrue(value.contains("DRAFT"));
    }
}
