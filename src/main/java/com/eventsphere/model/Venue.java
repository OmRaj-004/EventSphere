package com.eventsphere.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// EventSphere project (TYBCA) - Venue entity class.
// Holds one row of the venues table: name, location, capacity,
// price per hour and who owns it (an admin via created_by or a
// host via host_id). Getters/setters below are used by the
// JSP pages to display venue details.
public class Venue {
    private int id;
    private String name;
    private String description;
    private String location;
    private String eventType;
    private int maxCapacity;
    private BigDecimal hourlyRate;
    private String amenities;
    private String imageUrl;
    private boolean available = true;
    private String status = "AVAILABLE";
    private Integer createdBy;
    private Integer hostId;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Venue() {
    }

    public Venue(String name, String description, String location, int maxCapacity, BigDecimal hourlyRate) {
        this.name = name;
        this.description = description;
        this.location = location;
        this.maxCapacity = maxCapacity;
        this.hourlyRate = hourlyRate;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public int getMaxCapacity() {
        return maxCapacity;
    }

    public void setMaxCapacity(int maxCapacity) {
        this.maxCapacity = maxCapacity;
    }

    public BigDecimal getHourlyRate() {
        return hourlyRate;
    }

    public void setHourlyRate(BigDecimal hourlyRate) {
        this.hourlyRate = hourlyRate;
    }

    public String getAmenities() {
        return amenities;
    }

    public void setAmenities(String amenities) {
        this.amenities = amenities;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public boolean isAvailable() {
        return available && (status == null || "AVAILABLE".equalsIgnoreCase(status));
    }

    public void setAvailable(boolean available) {
        this.available = available;
    }

    public String getStatus() {
        return status == null ? "AVAILABLE" : status;
    }

    public void setStatus(String status) {
        this.status = status == null ? "AVAILABLE" : status.trim().toUpperCase();
        if (this.status.isBlank()) {
            this.status = "AVAILABLE";
        }
    }

    public Integer getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(Integer createdBy) {
        this.createdBy = createdBy;
    }

    public Integer getHostId() {
        return hostId;
    }

    public void setHostId(Integer hostId) {
        this.hostId = hostId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }

    @Override
    public String toString() {
        return "Venue{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", location='" + location + '\'' +
                ", maxCapacity=" + maxCapacity +
                ", hourlyRate=" + hourlyRate +
                '}';
    }
}
