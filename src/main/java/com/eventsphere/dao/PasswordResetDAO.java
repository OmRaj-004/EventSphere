package com.eventsphere.dao;

import com.eventsphere.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

// EventSphere project (TYBCA) - database access for password resets.
// Stores single-use token hashes with a 30-minute expiry. consume()
// returns the ticket once and immediately marks it used, so a reset
// link can never work twice.
public class PasswordResetDAO {

    public static class ResetTicket {
        public final int id;
        public final String email;
        public final String role;

        ResetTicket(int id, String email, String role) {
            this.id = id;
            this.email = email;
            this.role = role;
        }
    }

    public boolean create(String email, String role, String tokenHash, LocalDateTime expiresAt) {
        String sql = "INSERT INTO password_resets (email, role, token_hash, expires_at) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            pstmt.setString(2, role);
            pstmt.setString(3, tokenHash);
            pstmt.setTimestamp(4, Timestamp.valueOf(expiresAt));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public ResetTicket consume(String tokenHash) {
        String sql = "SELECT id, email, role FROM password_resets WHERE token_hash = ? AND used = FALSE AND expires_at > CURRENT_TIMESTAMP";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, tokenHash);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    ResetTicket ticket = new ResetTicket(rs.getInt("id"), rs.getString("email"), rs.getString("role"));
                    try (PreparedStatement mark = conn.prepareStatement("UPDATE password_resets SET used = TRUE WHERE id = ?")) {
                        mark.setInt(1, ticket.id);
                        mark.executeUpdate();
                    }
                    return ticket;
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public void purgeExpired() {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("DELETE FROM password_resets WHERE expires_at <= CURRENT_TIMESTAMP OR used = TRUE")) {
            pstmt.executeUpdate();
        } catch (SQLException ignored) {
        }
    }
}
