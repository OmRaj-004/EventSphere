package com.eventsphere.model;

import java.time.LocalDateTime;

// EventSphere project (TYBCA) - PromoCode entity class.
// Holds one discount coupon (for example WELCOME10 = 10 percent
// off). used_count tracks redemptions against max_uses so an
// expired code is rejected automatically at booking time.
public class PromoCode {
    private int id;
    private String code;
    private int percentOff;
    private int maxUses;
    private int usedCount;
    private boolean active;
    private LocalDateTime createdAt;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public int getPercentOff() {
        return percentOff;
    }

    public void setPercentOff(int percentOff) {
        this.percentOff = percentOff;
    }

    public int getMaxUses() {
        return maxUses;
    }

    public void setMaxUses(int maxUses) {
        this.maxUses = maxUses;
    }

    public int getUsedCount() {
        return usedCount;
    }

    public void setUsedCount(int usedCount) {
        this.usedCount = usedCount;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }

    public boolean isUsable() {
        return active && usedCount < maxUses;
    }
}
