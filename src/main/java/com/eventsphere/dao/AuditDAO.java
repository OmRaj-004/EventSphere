package com.eventsphere.dao;

import com.eventsphere.model.AuditLog;
import com.eventsphere.util.DBUtil;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for the audit log.
// Every important admin/host action (approvals, venue changes,
// promos, replies) writes one row here via log(), shown on the
// Analytics page activity feed.
public class AuditDAO {

    public boolean log(Integer actorId, String actorRole, String action, String targetType, Integer targetId, String detail) {
        String sql = "INSERT INTO audit_logs (actor_id, actor_role, action, target_type, target_id, detail) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            if (actorId == null) {
                pstmt.setNull(1, Types.INTEGER);
            } else {
                pstmt.setInt(1, actorId);
            }
            pstmt.setString(2, actorRole);
            pstmt.setString(3, action);
            pstmt.setString(4, targetType);
            if (targetId == null) {
                pstmt.setNull(5, Types.INTEGER);
            } else {
                pstmt.setInt(5, targetId);
            }
            pstmt.setString(6, detail);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<AuditLog> latest(int limit) {
        String sql = "SELECT id, actor_id, actor_role, action, target_type, target_id, detail, created_at FROM audit_logs ORDER BY created_at DESC LIMIT ?";
        List<AuditLog> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getInt("id"));
                    int actorId = rs.getInt("actor_id");
                    log.setActorId(rs.wasNull() ? null : actorId);
                    log.setActorRole(rs.getString("actor_role"));
                    log.setAction(rs.getString("action"));
                    log.setTargetType(rs.getString("target_type"));
                    int targetId = rs.getInt("target_id");
                    log.setTargetId(rs.wasNull() ? null : targetId);
                    log.setDetail(rs.getString("detail"));
                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        log.setCreatedAt(ts.toLocalDateTime());
                    }
                    list.add(log);
                }
            }
        } catch (SQLException exception) {
            return list;
        }
        return list;
    }
}
