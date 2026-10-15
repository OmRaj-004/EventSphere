package com.eventsphere.dao;

import static org.junit.jupiter.api.Assertions.assertNotNull;

import java.time.LocalDate;
import java.time.LocalTime;
import org.junit.jupiter.api.Test;

class BookingAvailabilityTest {

    @Test
    void shouldExposeVenueAvailabilityChecksForBookingValidation() {
        BookingDAO bookingDAO = new BookingDAO();

        assertNotNull(bookingDAO.isVenueAvailable(1, LocalDate.now().plusDays(5), LocalTime.of(18, 0), LocalTime.of(22, 0), null));
    }
}
