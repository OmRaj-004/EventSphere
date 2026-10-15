package com.eventsphere.model;

import java.time.LocalDateTime;

// EventSphere project (TYBCA) - Feedback (review) entity class.
// Holds one customer review for a venue: star rating (1-5),
// comment text, optional photo and the host/admin reply.
public class Feedback {
    private int id;
    private Integer bookingId;
    private int customerId;
    private int venueId;
    private int rating;
    private String comment;
    private String imageUrl;
    private String adminReply;
    private LocalDateTime createdAt;

    public Feedback() {
    }

    public Feedback(int customerId, int venueId, int rating) {
        this.customerId = customerId;
        this.venueId = venueId;
        this.rating = rating;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getVenueId() {
        return venueId;
    }

    public void setVenueId(int venueId) {
        this.venueId = venueId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        if (rating >= 1 && rating <= 5) {
            this.rating = rating;
        } else {
            throw new IllegalArgumentException("Rating must be between 1 and 5");
        }
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public String getAdminReply() {
        return adminReply;
    }

    public void setAdminReply(String adminReply) {
        this.adminReply = adminReply;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    @Override
    public String toString() {
        return "Feedback{" +
                "id=" + id +
                ", rating=" + rating +
                ", venueId=" + venueId +
                '}';
    }
}
