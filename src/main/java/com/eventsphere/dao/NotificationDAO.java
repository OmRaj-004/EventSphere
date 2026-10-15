package com.eventsphere.dao;

import com.eventsphere.model.Notification;
import com.eventsphere.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for notifications.
// Stores the inbox messages shown under the bell icon on each
// dashboard (booking submitted/approved/rejected, replies).
public class NotificationDAO {

    public boolean create(int userId, String userRole, String title, String body, String link) {
        String sql = "INSERT INTO notifications (user_id, user_role, title, body, link) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, userRole);
            pstmt.setString(3, title);
            pstmt.setString(4, body);
            pstmt.setString(5, link);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<Notification> listForUser(int userId, String userRole, int limit) {
        String sql = "SELECT id, user_id, user_role, title, body, link, is_read, created_at FROM notifications WHERE user_id = ? AND user_role = ? ORDER BY created_at DESC LIMIT ?";
        List<Notification> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, userRole);
            pstmt.setInt(3, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        } catch (SQLException exception) {
            return list;
        }
        return list;
    }

    public long unreadCount(int userId, String userRole) {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND user_role = ? AND is_read = FALSE";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, userRole);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() ? rs.getLong(1) : 0;
            }
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean markAllRead(int userId, String userRole) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ? AND user_role = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            pstmt.setString(2, userRole);
            pstmt.executeUpdate();
            return true;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean markRead(int id, int userId, String userRole) {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ? AND user_role = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.setInt(2, userId);
            pstmt.setString(3, userRole);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    private Notification map(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setId(rs.getInt("id"));
        n.setUserId(rs.getInt("user_id"));
        n.setUserRole(rs.getString("user_role"));
        n.setTitle(rs.getString("title"));
        n.setBody(rs.getString("body"));
        n.setLink(rs.getString("link"));
        n.setRead(rs.getBoolean("is_read"));
        Timestamp ts = rs.getTimestamp("created_at");
        if (ts != null) {
            n.setCreatedAt(ts.toLocalDateTime());
        }
        return n;
    }
}
