package com.eventsphere.dao;

import com.eventsphere.model.User;
import com.eventsphere.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;

// EventSphere project (TYBCA) - database access for "remember me".
// Stores login token hashes (30-day expiry). On each request the
// RememberMeFilter looks up the cookie token here and rebuilds the
// logged-in session automatically.
public class LoginTokenDAO {

    public static class RememberedLogin {
        public final User user;

        RememberedLogin(User user) {
            this.user = user;
        }
    }

    public boolean create(int userId, String role, String tokenHash, LocalDateTime expiresAt) {
        String sql = "INSERT INTO login_tokens (user_id, user_role, token_hash, expires_at) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, role);
            pstmt.setString(3, tokenHash);
            pstmt.setTimestamp(4, Timestamp.valueOf(expiresAt));
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public RememberedLogin consume(String tokenHash) {
        String sql = "SELECT user_id, user_role FROM login_tokens WHERE token_hash = ? AND expires_at > CURRENT_TIMESTAMP";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, tokenHash);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                int userId = rs.getInt("user_id");
                String role = rs.getString("user_role");
                UserDAO userDAO = new UserDAO();
                User user;
                if ("ADMIN".equals(role)) {
                    user = userDAO.getAdminById(userId);
                } else if ("HOST".equals(role)) {
                    user = userDAO.getHostById(userId);
                } else {
                    user = userDAO.getCustomerById(userId);
                }
                return user == null ? null : new RememberedLogin(user);
            }
        } catch (SQLException exception) {
            return null;
        }
    }

    public boolean deleteByHash(String tokenHash) {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("DELETE FROM login_tokens WHERE token_hash = ?")) {
            pstmt.setString(1, tokenHash);
            pstmt.executeUpdate();
            return true;
        } catch (SQLException exception) {
            return false;
        }
    }

    public void deleteExpired() {
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("DELETE FROM login_tokens WHERE expires_at <= CURRENT_TIMESTAMP")) {
            pstmt.executeUpdate();
        } catch (SQLException ignored) {
        }
    }
}
