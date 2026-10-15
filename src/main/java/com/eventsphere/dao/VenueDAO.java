package com.eventsphere.dao;

import com.eventsphere.model.Venue;
import com.eventsphere.util.DBUtil;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for venues.
// Handles all SELECT/INSERT/UPDATE/DELETE queries on the venues
// table: listing, searching with filters, paged browsing, adding,
// editing and deleting venues, plus host-ownership lookups.
public class VenueDAO {

    public boolean addVenue(Venue venue) {
        String sql = "INSERT INTO venues (name, description, location, event_type, max_capacity, hourly_rate, amenities, image_url, available, status, created_by, host_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, venue.getName());
            pstmt.setString(2, venue.getDescription());
            pstmt.setString(3, venue.getLocation());
            pstmt.setString(4, venue.getEventType());
            pstmt.setInt(5, venue.getMaxCapacity());
            pstmt.setBigDecimal(6, venue.getHourlyRate());
            pstmt.setString(7, venue.getAmenities());
            pstmt.setString(8, venue.getImageUrl());
            pstmt.setBoolean(9, venue.isAvailable());
            pstmt.setString(10, venue.getStatus());
            pstmt.setObject(11, venue.getCreatedBy(), Types.INTEGER);
            pstmt.setObject(12, venue.getHostId(), Types.INTEGER);

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        venue.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException exception) {
            return false;
        }
        return false;
    }

    public Venue findById(int id) {
        return getVenueById(id);
    }

    public List<Venue> findAll() {
        return getAllVenues();
    }

    public List<Venue> findByFilters(String eventType, Integer minCapacity, BigDecimal maxPrice) {
        return searchVenues(eventType, minCapacity, maxPrice);
    }

    public Venue getVenueById(int id) {
        String sql = venueSelect(" WHERE id = ?");
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToVenue(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public List<Venue> getAllVenues() {
        String sql = venueSelect(" WHERE available = TRUE ORDER BY id DESC");
        List<Venue> venues = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                venues.add(mapResultSetToVenue(rs));
            }
        } catch (SQLException exception) {
            return venues;
        }
        return venues;
    }

    public List<Venue> searchVenues(String eventType, Integer minCapacity, BigDecimal maxPrice) {
        return searchVenues(eventType, null, minCapacity, maxPrice);
    }

    public List<Venue> searchVenues(String eventType, String location, Integer minCapacity, BigDecimal maxPrice) {
        StringBuilder sql = new StringBuilder(venueSelect(" WHERE available = TRUE AND status IN ('AVAILABLE', 'MAINTENANCE')"));
        List<Object> params = new ArrayList<>();

        if (eventType != null && !eventType.isBlank()) {
            sql.append(" AND event_type = ?");
            params.add(eventType.trim().toUpperCase());
        }
        if (location != null && !location.isBlank()) {
            sql.append(" AND LOWER(location) LIKE ?");
            params.add("%" + location.trim().toLowerCase() + "%");
        }
        if (minCapacity != null && minCapacity > 0) {
            sql.append(" AND max_capacity >= ?");
            params.add(minCapacity);
        }
        if (maxPrice != null) {
            sql.append(" AND hourly_rate <= ?");
            params.add(maxPrice);
        }
        sql.append(" ORDER BY hourly_rate ASC");

        List<Venue> venues = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                Object value = params.get(i);
                if (value instanceof String) {
                    pstmt.setString(i + 1, (String) value);
                } else if (value instanceof Integer) {
                    pstmt.setInt(i + 1, (Integer) value);
                } else if (value instanceof BigDecimal) {
                    pstmt.setBigDecimal(i + 1, (BigDecimal) value);
                }
            }
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    venues.add(mapResultSetToVenue(rs));
                }
            }
        } catch (SQLException exception) {
            return venues;
        }
        return venues;
    }

    public List<Venue> getVenuesByAdmin(int adminId) {
        String sql = venueSelect(" WHERE created_by = ? ORDER BY id DESC");
        List<Venue> venues = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, adminId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    venues.add(mapResultSetToVenue(rs));
                }
            }
        } catch (SQLException exception) {
            return venues;
        }
        return venues;
    }

    public boolean updateVenue(Venue venue) {
        String sql = "UPDATE venues SET name = ?, description = ?, location = ?, event_type = ?, max_capacity = ?, hourly_rate = ?, amenities = ?, image_url = ?, available = ?, status = ?, host_id = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, venue.getName());
            pstmt.setString(2, venue.getDescription());
            pstmt.setString(3, venue.getLocation());
            pstmt.setString(4, venue.getEventType());
            pstmt.setInt(5, venue.getMaxCapacity());
            pstmt.setBigDecimal(6, venue.getHourlyRate());
            pstmt.setString(7, venue.getAmenities());
            pstmt.setString(8, venue.getImageUrl());
            pstmt.setBoolean(9, venue.isAvailable());
            pstmt.setString(10, venue.getStatus());
            pstmt.setObject(11, venue.getHostId(), Types.INTEGER);
            pstmt.setInt(12, venue.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<Venue> getVenuesByHost(int hostId) {
        String sql = venueSelect(" WHERE host_id = ? ORDER BY id DESC");
        List<Venue> venues = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, hostId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    venues.add(mapResultSetToVenue(rs));
                }
            }
        } catch (SQLException exception) {
            return venues;
        }
        return venues;
    }

    public List<Venue> getAvailableVenuesPage(int offset, int limit) {
        String sql = venueSelect(" WHERE available = TRUE ORDER BY id DESC LIMIT ? OFFSET ?");
        List<Venue> venues = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    venues.add(mapResultSetToVenue(rs));
                }
            }
        } catch (SQLException exception) {
            return venues;
        }
        return venues;
    }

    public long countAvailableVenues() {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM venues WHERE available = TRUE"); ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0;
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean deleteVenue(int id) {
        String sql = "DELETE FROM venues WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public long countVenues() {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM venues"); ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0;
        } catch (SQLException exception) {
            return 0;
        }
    }

    private Venue mapResultSetToVenue(ResultSet rs) throws SQLException {
        Venue venue = new Venue();
        venue.setId(rs.getInt("id"));
        venue.setName(rs.getString("name"));
        venue.setDescription(rs.getString("description"));
        venue.setLocation(rs.getString("location"));
        venue.setEventType(rs.getString("event_type"));
        venue.setMaxCapacity(rs.getInt("max_capacity"));
        venue.setHourlyRate(rs.getBigDecimal("hourly_rate"));
        venue.setAmenities(rs.getString("amenities"));
        venue.setImageUrl(rs.getString("image_url"));
        venue.setAvailable(rs.getBoolean("available"));
        venue.setStatus(rs.getString("status"));
        venue.setCreatedBy((Integer) rs.getObject("created_by"));
        venue.setHostId((Integer) rs.getObject("host_id"));

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            venue.setCreatedAt(createdAtTs.toLocalDateTime());
        }

        Timestamp updatedAtTs = rs.getTimestamp("updated_at");
        if (updatedAtTs != null) {
            venue.setUpdatedAt(updatedAtTs.toLocalDateTime());
        }
        return venue;
    }

    private String venueSelect(String suffix) {
        return "SELECT id, name, description, location, event_type, max_capacity, hourly_rate, amenities, image_url, available, status, created_by, host_id, created_at, updated_at FROM venues" + suffix;
    }
}
