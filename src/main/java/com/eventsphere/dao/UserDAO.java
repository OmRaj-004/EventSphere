package com.eventsphere.dao;

import com.eventsphere.model.User;
import com.eventsphere.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import at.favre.lib.crypto.bcrypt.BCrypt;

// EventSphere project (TYBCA) - database access for users.
// This DAO class contains all SQL queries for the three login
// tables (admin_users, customer_users, host_users). Servlets never
// write SQL themselves; they call these methods instead (this
// design is called the DAO pattern). Every query uses
// PreparedStatement with ? placeholders, which also blocks
// SQL injection attacks.
public class UserDAO {
    
    public boolean registerUser(User user) {
        String table = tableForRole(user.getRole());
        String sql = "INSERT INTO " + table + " (full_name, email, password_hash, created_at, updated_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getEmail());
            pstmt.setString(3, user.getPasswordHash());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }
    
    public User getUserByEmail(String email) {
        return getUserByEmailAndRole(email, null);
    }

    public User getUserByEmailAndRole(String email, String role) {
        String sql;
        if ("ADMIN".equalsIgnoreCase(role)) {
            sql = "SELECT id, full_name, email, password_hash, 'ADMIN' AS role, created_at, updated_at FROM admin_users WHERE email = ?";
        } else if ("CUSTOMER".equalsIgnoreCase(role)) {
            sql = "SELECT id, full_name, email, password_hash, 'CUSTOMER' AS role, created_at, updated_at FROM customer_users WHERE email = ?";
        } else if ("HOST".equalsIgnoreCase(role)) {
            sql = "SELECT id, full_name, email, password_hash, 'HOST' AS role, created_at, updated_at FROM host_users WHERE email = ?";
        } else {
            sql = "SELECT id, full_name, email, password_hash, 'ADMIN' AS role, created_at, updated_at FROM admin_users WHERE email = ? UNION ALL SELECT id, full_name, email, password_hash, 'CUSTOMER' AS role, created_at, updated_at FROM customer_users WHERE email = ? UNION ALL SELECT id, full_name, email, password_hash, 'HOST' AS role, created_at, updated_at FROM host_users WHERE email = ?";
        }
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, email);
            if (role == null || role.isBlank()) {
                pstmt.setString(2, email);
                pstmt.setString(3, email);
            }
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
            
        } catch (SQLException e) {

        }
        
        return null;
    }
    
    public User getUserById(int id) {
        String sql = "SELECT id, full_name, email, password_hash, 'ADMIN' AS role, created_at, updated_at FROM admin_users WHERE id = ? UNION ALL SELECT id, full_name, email, password_hash, 'CUSTOMER' AS role, created_at, updated_at FROM customer_users WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            pstmt.setInt(2, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToUser(rs);
            }
            
        } catch (SQLException e) {

        }
        
        return null;
    }
    
    public User getCustomerById(int id) {
        String sql = "SELECT id, full_name, email, password_hash, 'CUSTOMER' AS role, created_at, updated_at FROM customer_users WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }

        } catch (SQLException e) {

        }

        return null;
    }

    public User getAdminById(int id) {
        return getScopedUserById("admin_users", "ADMIN", id);
    }

    public User getHostById(int id) {
        return getScopedUserById("host_users", "HOST", id);
    }

    private User getScopedUserById(String table, String role, int id) {
        String sql = "SELECT id, full_name, email, password_hash, '" + role + "' AS role, created_at, updated_at FROM " + table + " WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToUser(rs);
            }

        } catch (SQLException e) {

        }

        return null;
    }

    public List<User> getAllAdmins() {
        return getAllInRole("admin_users", "ADMIN");
    }

    public List<User> getAllCustomers() {
        return getAllInRole("customer_users", "CUSTOMER");
    }

    public List<User> getAllHosts() {
        return getAllInRole("host_users", "HOST");
    }

    private List<User> getAllInRole(String table, String role) {
        String sql = "SELECT id, full_name, email, password_hash, '" + role + "' AS role, created_at, updated_at FROM " + table + " ORDER BY created_at DESC";
        List<User> users = new ArrayList<>();

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                users.add(mapResultSetToUser(rs));
            }

        } catch (SQLException e) {

        }

        return users;
    }

    public boolean updatePasswordForRole(String email, String role, String passwordHash) {
        String table = tableForRole(role);
        String sql = "UPDATE " + table + " SET password_hash = ?, updated_at = CURRENT_TIMESTAMP WHERE email = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, passwordHash);
            pstmt.setString(2, email);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            return false;
        }
    }

    public boolean deleteCustomer(int id) {
        String sql = "DELETE FROM customer_users WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            return false;
        }
    }

    public boolean deleteCustomerCascade(int id) {
        // Removes a customer plus every row that would otherwise be
        // orphaned: their inbox, login tokens, reset requests, events
        // they organized, then the account itself. Bookings, bills and
        // reviews disappear automatically through ON DELETE CASCADE.
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM notifications WHERE user_id = ? AND user_role = 'CUSTOMER'")) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM login_tokens WHERE user_id = ? AND user_role = 'CUSTOMER'")) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM password_resets WHERE email = (SELECT email FROM customer_users WHERE id = ?)")) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM events WHERE organizer_id = ?")) {
                    pstmt.setInt(1, id);
                    pstmt.executeUpdate();
                }
                try (PreparedStatement pstmt = conn.prepareStatement("DELETE FROM customer_users WHERE id = ?")) {
                    pstmt.setInt(1, id);
                    if (pstmt.executeUpdate() != 1) {
                        conn.rollback();
                        return false;
                    }
                }
                conn.commit();
                return true;
            } catch (SQLException e) {
                conn.rollback();
                return false;
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean deleteAdmin(int id) {
        String sql = "DELETE FROM admin_users WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            return false;
        }
    }

    public boolean deleteHost(int id) {
        String sql = "DELETE FROM host_users WHERE id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            return false;
        }
    }

    private String tableForRole(String role) {
        if ("ADMIN".equalsIgnoreCase(role)) {
            return "admin_users";
        }
        if ("HOST".equalsIgnoreCase(role)) {
            return "host_users";
        }
        return "customer_users";
    }

    public boolean emailExists(String email) {
        String[] tables = {"admin_users", "customer_users", "host_users"};

        try (Connection conn = DBUtil.getConnection()) {
            for (String table : tables) {
                try (PreparedStatement pstmt = conn.prepareStatement("SELECT id FROM " + table + " WHERE email = ?")) {
                    pstmt.setString(1, email);
                    ResultSet rs = pstmt.executeQuery();
                    if (rs.next()) {
                        return true;
                    }
                }
            }
        } catch (SQLException e) {

        }

        return false;
    }

    public boolean emailExistsInRole(String email, String role) {
        String sql = "SELECT id FROM " + tableForRole(role) + " WHERE email = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();

        } catch (SQLException e) {
            return false;
        }
    }

    public boolean updateUser(User user) {
        String table = tableForRole(user.getRole());
        String sql = "UPDATE " + table + " SET full_name = ?, email = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, user.getFullName());
            pstmt.setString(2, user.getEmail());
            pstmt.setInt(3, user.getId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }
    
    public boolean updatePassword(int userId, String newPassword) {
        String sql = "UPDATE customer_users SET password_hash = ? WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            String passwordHash = BCrypt.withDefaults().hashToString(12, newPassword.toCharArray());
            pstmt.setString(1, passwordHash);
            pstmt.setInt(2, userId);
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }
    
    public boolean deleteUser(int id) {
        String sql = "DELETE FROM customer_users WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }

    public long countCustomers() {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM customer_users"); ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0;
        } catch (SQLException exception) {
            return 0;
        }
    }
    
    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        
        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            user.setCreatedAt(createdAtTs.toLocalDateTime());
        }
        
        Timestamp updatedAtTs = rs.getTimestamp("updated_at");
        if (updatedAtTs != null) {
            user.setUpdatedAt(updatedAtTs.toLocalDateTime());
        }
        
        return user;
    }
}
