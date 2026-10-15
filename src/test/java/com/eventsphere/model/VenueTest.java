package com.eventsphere.model;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import org.junit.jupiter.api.Test;

class VenueTest {

    @Test
    void shouldCreateVenueWithRequiredFields() {
        BigDecimal rate = new BigDecimal("250.50");
        Venue venue = new Venue("Grand Hall", "Large event space", "Downtown", 400, rate);

        assertEquals("Grand Hall", venue.getName());
        assertEquals("Large event space", venue.getDescription());
        assertEquals("Downtown", venue.getLocation());
        assertEquals(400, venue.getMaxCapacity());
        assertEquals(rate, venue.getHourlyRate());
    }

    @Test
    void shouldSetAndGetAllVenueFields() {
        Venue venue = new Venue();
        LocalDateTime createdAt = LocalDateTime.of(2026, 8, 12, 10, 30);
        LocalDateTime updatedAt = LocalDateTime.of(2026, 8, 12, 12, 0);

        venue.setId(8);
        venue.setName("Sunset Terrace");
        venue.setDescription("Open-air venue");
        venue.setLocation("Hill Street");
        venue.setMaxCapacity(220);
        venue.setHourlyRate(new BigDecimal("180.00"));
        venue.setAmenities("Lighting, stage, catering");
        venue.setImageUrl("https://example.com/venue.jpg");
        venue.setCreatedBy(2);
        venue.setCreatedAt(createdAt);
        venue.setUpdatedAt(updatedAt);

        assertEquals(8, venue.getId());
        assertEquals("Sunset Terrace", venue.getName());
        assertEquals("Open-air venue", venue.getDescription());
        assertEquals("Hill Street", venue.getLocation());
        assertEquals(220, venue.getMaxCapacity());
        assertEquals(new BigDecimal("180.00"), venue.getHourlyRate());
        assertEquals("Lighting, stage, catering", venue.getAmenities());
        assertEquals("https://example.com/venue.jpg", venue.getImageUrl());
        assertEquals(2, venue.getCreatedBy());
        assertEquals(createdAt, venue.getCreatedAt());
        assertEquals(updatedAt, venue.getUpdatedAt());
    }

    @Test
    void shouldRenderToStringWithRelevantVenueDetails() {
        Venue venue = new Venue();
        venue.setId(5);
        venue.setName("Harbor View");
        venue.setLocation("Coastal Road");
        venue.setMaxCapacity(300);
        venue.setHourlyRate(new BigDecimal("320.75"));

        String value = venue.toString();

        assertTrue(value.contains("Venue{"));
        assertTrue(value.contains("Harbor View"));
        assertTrue(value.contains("Coastal Road"));
        assertTrue(value.contains("300"));
        assertTrue(value.contains("320.75"));
    }
}
