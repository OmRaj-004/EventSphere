package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

import org.junit.jupiter.api.Test;

class BookingWorkflowTest {

    @Test
    void shouldAllowCustomerCancellationOnlyForPendingBookings() {
        Booking pending = new Booking();
        pending.setStatus("PENDING");

        Booking approved = new Booking();
        approved.setStatus("APPROVED");

        assertTrue(pending.canCustomerCancel());
        assertFalse(approved.canCustomerCancel());
    }

    @Test
    void shouldRestrictInvalidStatusTransitions() {
        Booking booking = new Booking();
        booking.setStatus("PENDING");

        assertTrue(booking.isStatusTransitionAllowed("APPROVED"));
        assertTrue(booking.isStatusTransitionAllowed("REJECTED"));
        assertTrue(booking.isStatusTransitionAllowed("CANCELLED"));
        assertFalse(booking.isStatusTransitionAllowed("CONFIRMED"));
    }
}
