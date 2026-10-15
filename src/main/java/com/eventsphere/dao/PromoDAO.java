package com.eventsphere.dao;

import com.eventsphere.model.PromoCode;
import com.eventsphere.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for promo codes.
// Validates discount coupons at booking time and counts each
// redemption, so exhausted or disabled codes stop working.
public class PromoDAO {

    public PromoCode findUsableByCode(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        String sql = "SELECT id, code, percent_off, max_uses, used_count, active, created_at FROM promocodes WHERE UPPER(code) = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, code.trim().toUpperCase());
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    PromoCode promo = map(rs);
                    return promo.isUsable() ? promo : null;
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public boolean redeem(int promoId) {
        String sql = "UPDATE promocodes SET used_count = used_count + 1 WHERE id = ? AND active = TRUE AND used_count < max_uses";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, promoId);
            return pstmt.executeUpdate() == 1;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<PromoCode> getAllPromos() {
        String sql = "SELECT id, code, percent_off, max_uses, used_count, active, created_at FROM promocodes ORDER BY id";
        List<PromoCode> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                list.add(map(rs));
            }
        } catch (SQLException exception) {
            return list;
        }
        return list;
    }

    public boolean savePromo(String code, int percentOff, int maxUses) {
        String sql = "INSERT INTO promocodes (code, percent_off, max_uses) VALUES (?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, code.trim().toUpperCase());
            pstmt.setInt(2, percentOff);
            pstmt.setInt(3, maxUses);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean release(int promoId) {
        String sql = "UPDATE promocodes SET used_count = GREATEST(0, used_count - 1) WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, promoId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean setActive(int promoId, boolean active) {
        String sql = "UPDATE promocodes SET active = ? WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBoolean(1, active);
            pstmt.setInt(2, promoId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    private PromoCode map(ResultSet rs) throws SQLException {
        PromoCode promo = new PromoCode();
        promo.setId(rs.getInt("id"));
        promo.setCode(rs.getString("code"));
        promo.setPercentOff(rs.getInt("percent_off"));
        promo.setMaxUses(rs.getInt("max_uses"));
        promo.setUsedCount(rs.getInt("used_count"));
        promo.setActive(rs.getBoolean("active"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            promo.setCreatedAt(ts.toLocalDateTime());
        }
        return promo;
    }
}
