package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class FeedbackTest {

    @Test
    void shouldCreateFeedbackWithCustomerVenueAndRating() {
        Feedback feedback = new Feedback(5, 9, 4);

        assertEquals(5, feedback.getCustomerId());
        assertEquals(9, feedback.getVenueId());
        assertEquals(4, feedback.getRating());
    }

    @Test
    void shouldAllowValidRatingsAndRejectInvalidOnes() {
        Feedback feedback = new Feedback();

        feedback.setRating(1);
        assertEquals(1, feedback.getRating());

        feedback.setRating(5);
        assertEquals(5, feedback.getRating());

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> feedback.setRating(0));
        assertEquals("Rating must be between 1 and 5", ex.getMessage());

        IllegalArgumentException ex2 = assertThrows(IllegalArgumentException.class, () -> feedback.setRating(6));
        assertEquals("Rating must be between 1 and 5", ex2.getMessage());
    }

    @Test
    void shouldSetAndGetAdditionalFields() {
        Feedback feedback = new Feedback();
        LocalDateTime now = LocalDateTime.of(2026, 9, 13, 18, 20);

        feedback.setId(21);
        feedback.setBookingId(88);
        feedback.setCustomerId(7);
        feedback.setVenueId(4);
        feedback.setRating(3);
        feedback.setComment("Great experience and staff support");
        feedback.setCreatedAt(now);

        assertEquals(21, feedback.getId());
        assertEquals(88, feedback.getBookingId());
        assertEquals(7, feedback.getCustomerId());
        assertEquals(4, feedback.getVenueId());
        assertEquals(3, feedback.getRating());
        assertEquals("Great experience and staff support", feedback.getComment());
        assertEquals(now, feedback.getCreatedAt());
    }

    @Test
    void shouldRenderToStringWithSummaryValues() {
        Feedback feedback = new Feedback();
        feedback.setId(10);
        feedback.setRating(5);
        feedback.setVenueId(12);

        String value = feedback.toString();

        assertTrue(value.contains("Feedback{"));
        assertTrue(value.contains("rating=5"));
        assertTrue(value.contains("venueId=12"));
    }
}
