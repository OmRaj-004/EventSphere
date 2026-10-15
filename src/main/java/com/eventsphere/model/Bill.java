package com.eventsphere.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

// EventSphere project (TYBCA) - Bill (invoice) entity class.
// Every booking automatically gets exactly one bill row, created
// in the same database transaction as the booking itself, so a
// booking can never exist without its invoice.
public class Bill {
    private int id;
    private String billNumber;
    private int bookingId;
    private int customerId;
    private BigDecimal subtotal;
    private BigDecimal advancePaid = BigDecimal.ZERO;
    private BigDecimal balanceDue;
    private String status = "ISSUED";
    private LocalDateTime createdAt;

    public Bill() {
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBillNumber() {
        return billNumber;
    }

    public void setBillNumber(String billNumber) {
        this.billNumber = billNumber;
    }

    public int getBookingId() {
        return bookingId;
    }

    public void setBookingId(int bookingId) {
        this.bookingId = bookingId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal subtotal) {
        this.subtotal = subtotal;
    }

    public BigDecimal getAdvancePaid() {
        return advancePaid;
    }

    public void setAdvancePaid(BigDecimal advancePaid) {
        this.advancePaid = advancePaid;
    }

    public BigDecimal getBalanceDue() {
        return balanceDue;
    }

    public void setBalanceDue(BigDecimal balanceDue) {
        this.balanceDue = balanceDue;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
