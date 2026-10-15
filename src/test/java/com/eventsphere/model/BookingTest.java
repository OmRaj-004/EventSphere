package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class BookingTest {

    @Test
    void shouldCreateBookingWithIdentityFields() {
        Booking booking = new Booking("BK-1001", 12, 3, 5);

        assertEquals("BK-1001", booking.getBookingNumber());
        assertEquals(12, booking.getEventId());
        assertEquals(3, booking.getVenueId());
        assertEquals(5, booking.getCustomerId());
    }

    @Test
    void shouldSetAndGetBookingProperties() {
        Booking booking = new Booking();
        LocalDate bookingDate = LocalDate.of(2026, 9, 12);
        LocalDateTime createdAt = LocalDateTime.of(2026, 9, 10, 9, 15);
        LocalDateTime updatedAt = LocalDateTime.of(2026, 9, 10, 11, 0);

        booking.setId(42);
        booking.setBookingNumber("BK-2048");
        booking.setEventId(12);
        booking.setVenueId(4);
        booking.setCustomerId(7);
        booking.setBookingDate(bookingDate);
        booking.setTotalAmount(new BigDecimal("950.00"));
        booking.setAdvancePaid(new BigDecimal("250.00"));
        booking.setStatus("CONFIRMED");
        booking.setPaymentMethod("CARD");
        booking.setTransactionId("txn-abc-123");
        booking.setNotes("VIP setup required");
        booking.setCreatedAt(createdAt);
        booking.setUpdatedAt(updatedAt);

        assertEquals(42, booking.getId());
        assertEquals("BK-2048", booking.getBookingNumber());
        assertEquals(12, booking.getEventId());
        assertEquals(4, booking.getVenueId());
        assertEquals(7, booking.getCustomerId());
        assertEquals(bookingDate, booking.getBookingDate());
        assertEquals(new BigDecimal("950.00"), booking.getTotalAmount());
        assertEquals(new BigDecimal("250.00"), booking.getAdvancePaid());
        assertEquals("CONFIRMED", booking.getStatus());
        assertEquals("CARD", booking.getPaymentMethod());
        assertEquals("txn-abc-123", booking.getTransactionId());
        assertEquals("VIP setup required", booking.getNotes());
        assertEquals(createdAt, booking.getCreatedAt());
        assertEquals(updatedAt, booking.getUpdatedAt());
    }

    @Test
    void shouldRenderToStringWithBookingSummary() {
        Booking booking = new Booking();
        booking.setBookingNumber("BK-900");
        booking.setStatus("PENDING");
        booking.setTotalAmount(new BigDecimal("500.00"));

        String value = booking.toString();

        assertTrue(value.contains("Booking{"));
        assertTrue(value.contains("BK-900"));
        assertTrue(value.contains("PENDING"));
        assertTrue(value.contains("500.00"));
    }
}
