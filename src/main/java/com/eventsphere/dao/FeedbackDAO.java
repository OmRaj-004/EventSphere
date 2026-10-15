package com.eventsphere.dao;

import com.eventsphere.model.Feedback;
import com.eventsphere.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for feedback.
// Customers can review only their own APPROVED bookings (checked
// inside addEligibleFeedback), one review per booking. Also
// provides average ratings per venue and admin/host replies.
public class FeedbackDAO {

    public boolean addEligibleFeedback(int customerId, int bookingId, int rating, String comment) {
        return addEligibleFeedback(customerId, bookingId, rating, comment, null);
    }

    public boolean addEligibleFeedback(int customerId, int bookingId, int rating, String comment, String imageUrl) {
        if (rating < 1 || rating > 5 || comment == null || comment.isBlank()) {
            return false;
        }
        if (hasFeedbackForBooking(customerId, bookingId)) {
            return false;
        }

        String lookupSql = "SELECT venue_id FROM bookings WHERE id = ? AND customer_id = ? AND status = 'APPROVED'";
        String insertSql = "INSERT INTO feedback (booking_id, customer_id, venue_id, rating, comment, image_url) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try (PreparedStatement lookup = conn.prepareStatement(lookupSql)) {
                lookup.setInt(1, bookingId);
                lookup.setInt(2, customerId);
                try (ResultSet result = lookup.executeQuery()) {
                    if (!result.next()) {
                        conn.rollback();
                        return false;
                    }
                    try (PreparedStatement insert = conn.prepareStatement(insertSql)) {
                        insert.setInt(1, bookingId);
                        insert.setInt(2, customerId);
                        insert.setInt(3, result.getInt("venue_id"));
                        insert.setInt(4, rating);
                        insert.setString(5, comment.trim());
                        insert.setString(6, imageUrl);
                        insert.executeUpdate();
                    }
                }
            }
            conn.commit();
            return true;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean hasFeedbackForBooking(int customerId, int bookingId) {
        String sql = "SELECT 1 FROM feedback WHERE customer_id = ? AND booking_id = ? LIMIT 1";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            statement.setInt(2, bookingId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        } catch (SQLException exception) {
            return true;
        }
    }

    public boolean addFeedback(Feedback feedback) {
        String sql = "INSERT INTO feedback (booking_id, customer_id, venue_id, rating, comment) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            if (feedback.getBookingId() != null) {
                pstmt.setInt(1, feedback.getBookingId());
            } else {
                pstmt.setNull(1, Types.INTEGER);
            }
            pstmt.setInt(2, feedback.getCustomerId());
            pstmt.setInt(3, feedback.getVenueId());
            pstmt.setInt(4, feedback.getRating());
            pstmt.setString(5, feedback.getComment());

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        feedback.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException exception) {
            return false;
        }
        return false;
    }

    public Feedback getFeedbackById(int id) {
        String sql = "SELECT id, booking_id, customer_id, venue_id, rating, comment, image_url, admin_reply, created_at FROM feedback WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToFeedback(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public long countByVenue(int venueId) {
        String sql = "SELECT COUNT(*) FROM feedback WHERE venue_id = ?";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, venueId);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? result.getLong(1) : 0;
            }
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean deleteOwnFeedback(int feedbackId, int customerId) {
        String sql = "DELETE FROM feedback WHERE id = ? AND customer_id = ?";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, feedbackId);
            statement.setInt(2, customerId);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean saveAdminReply(int feedbackId, String reply) {
        String sql = "UPDATE feedback SET admin_reply = ? WHERE id = ?";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, reply);
            statement.setInt(2, feedbackId);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<Feedback> getFeedbackByVenue(int venueId) {
        String sql = "SELECT id, booking_id, customer_id, venue_id, rating, comment, image_url, admin_reply, created_at FROM feedback WHERE venue_id = ? ORDER BY created_at DESC";
        List<Feedback> feedbackList = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, venueId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    feedbackList.add(mapResultSetToFeedback(rs));
                }
            }
        } catch (SQLException exception) {
            return feedbackList;
        }
        return feedbackList;
    }

    public List<Feedback> getFeedbackByCustomer(int customerId) {
        String sql = "SELECT id, booking_id, customer_id, venue_id, rating, comment, image_url, admin_reply, created_at FROM feedback WHERE customer_id = ? ORDER BY created_at DESC";
        List<Feedback> feedbackList = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    feedbackList.add(mapResultSetToFeedback(rs));
                }
            }
        } catch (SQLException exception) {
            return feedbackList;
        }
        return feedbackList;
    }

    public List<Feedback> getAllFeedback() {
        String sql = "SELECT id, booking_id, customer_id, venue_id, rating, comment, image_url, admin_reply, created_at FROM feedback ORDER BY created_at DESC";
        List<Feedback> feedbackList = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                feedbackList.add(mapResultSetToFeedback(rs));
            }
        } catch (SQLException exception) {
            return feedbackList;
        }
        return feedbackList;
    }

    public double getAverageRatingByVenue(int venueId) {
        String sql = "SELECT AVG(rating) as avg_rating FROM feedback WHERE venue_id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, venueId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_rating");
                }
            }
        } catch (SQLException exception) {
            return 0.0;
        }
        return 0.0;
    }

    public double getOverallAverageRating() {
        String sql = "SELECT AVG(rating) as avg_rating FROM feedback";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_rating");
                }
            }
        } catch (SQLException exception) {
            return 0.0;
        }
        return 0.0;
    }

    public long countAllFeedback() {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM feedback"); ResultSet rs = statement.executeQuery()) {
            return rs.next() ? rs.getLong(1) : 0;
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean deleteFeedback(int id) {
        String sql = "DELETE FROM feedback WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    private Feedback mapResultSetToFeedback(ResultSet rs) throws SQLException {
        Feedback feedback = new Feedback();
        feedback.setId(rs.getInt("id"));

        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) {
            feedback.setBookingId(bookingId);
        }

        feedback.setCustomerId(rs.getInt("customer_id"));
        feedback.setVenueId(rs.getInt("venue_id"));
        feedback.setRating(rs.getInt("rating"));
        feedback.setComment(rs.getString("comment"));
        try {
            feedback.setImageUrl(rs.getString("image_url"));
        } catch (SQLException ignored) {
        }
        try {
            feedback.setAdminReply(rs.getString("admin_reply"));
        } catch (SQLException ignored) {
        }

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            feedback.setCreatedAt(createdAtTs.toLocalDateTime());
        }
        return feedback;
    }
}
