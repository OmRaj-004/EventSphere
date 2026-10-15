package com.eventsphere.model;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Locale;

// EventSphere project (TYBCA) - Booking entity class.
// Holds one row of the bookings table. A booking always links
// one customer to one venue for one event, and its status moves
// PENDING -> APPROVED/REJECTED (or CANCELLED by the customer).
public class Booking {
    private int id;
    private String bookingNumber;
    private int eventId;
    private int venueId;
    private int customerId;
    private LocalDate bookingDate;
    private BigDecimal totalAmount;
    private BigDecimal advancePaid;
    private BigDecimal discountAmount = BigDecimal.ZERO;
    private Integer promoId;
    private String status;
    private String paymentMethod;
    private String transactionId;
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;

    public Booking() {
    }

    public Booking(String bookingNumber, int eventId, int venueId, int customerId) {
        this.bookingNumber = bookingNumber;
        this.eventId = eventId;
        this.venueId = venueId;
        this.customerId = customerId;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBookingNumber() {
        return bookingNumber;
    }

    public void setBookingNumber(String bookingNumber) {
        this.bookingNumber = bookingNumber;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public int getVenueId() {
        return venueId;
    }

    public void setVenueId(int venueId) {
        this.venueId = venueId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public LocalDate getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(LocalDate bookingDate) {
        this.bookingDate = bookingDate;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public BigDecimal getAdvancePaid() {
        return advancePaid;
    }

    public void setAdvancePaid(BigDecimal advancePaid) {
        this.advancePaid = advancePaid;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public Integer getPromoId() {
        return promoId;
    }

    public void setPromoId(Integer promoId) {
        this.promoId = promoId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status == null ? null : status.trim().toUpperCase(Locale.ROOT);
    }

    public boolean canCustomerCancel() {
        return "PENDING".equalsIgnoreCase(this.status);
    }

    public boolean isStatusTransitionAllowed(String nextStatus) {
        if (nextStatus == null || nextStatus.isBlank()) {
            return false;
        }

        String normalizedNext = nextStatus.trim().toUpperCase(Locale.ROOT);
        if (!isValidStatus(normalizedNext)) {
            return false;
        }

        String currentStatus = this.status == null ? "" : this.status.trim().toUpperCase(Locale.ROOT);
        if (currentStatus.isBlank()) {
            return "PENDING".equals(normalizedNext);
        }

        if (!"PENDING".equals(currentStatus)) {
            return false;
        }

        return "APPROVED".equals(normalizedNext)
                || "REJECTED".equals(normalizedNext)
                || "CANCELLED".equals(normalizedNext);
    }

    public static boolean isValidStatus(String status) {
        if (status == null || status.isBlank()) {
            return false;
        }
        String normalized = status.trim().toUpperCase(Locale.ROOT);
        return "PENDING".equals(normalized)
                || "APPROVED".equals(normalized)
                || "REJECTED".equals(normalized)
                || "CANCELLED".equals(normalized);
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public String getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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
        return "Booking{" +
                "id=" + id +
                ", bookingNumber='" + bookingNumber + '\'' +
                ", status='" + status + '\'' +
                ", totalAmount=" + totalAmount +
                '}';
    }
}
