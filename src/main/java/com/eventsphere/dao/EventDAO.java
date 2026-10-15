package com.eventsphere.dao;

import com.eventsphere.model.Event;
import com.eventsphere.util.DBUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for events.
// Simple CRUD (create, read, update, delete) for the events table,
// plus lookups by organizer and by venue (used for the
// availability calendar on the venue details page).
public class EventDAO {
    
    public boolean addEvent(Event event) {
        String sql = "INSERT INTO events (name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            pstmt.setString(1, event.getName());
            pstmt.setString(2, event.getDescription());
            pstmt.setString(3, event.getEventType());
            pstmt.setDate(4, java.sql.Date.valueOf(event.getEventDate()));
            pstmt.setTime(5, java.sql.Time.valueOf(event.getStartTime()));
            pstmt.setTime(6, java.sql.Time.valueOf(event.getEndTime()));
            pstmt.setInt(7, event.getExpectedGuests());
            pstmt.setInt(8, event.getOrganizerId());
            pstmt.setInt(9, event.getVenueId());
            pstmt.setString(10, event.getStatus() != null ? event.getStatus() : "DRAFT");
            
            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        event.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            
        } catch (SQLException e) {

        }
        
        return false;
    }
    
    public Event getEventById(int id) {
        String sql = "SELECT id, name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status, created_at, updated_at FROM events WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToEvent(rs);
            }
            
        } catch (SQLException e) {

        }
        
        return null;
    }
    
    public List<Event> getEventsByOrganizer(int organizerId) {
        String sql = "SELECT id, name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status, created_at, updated_at FROM events WHERE organizer_id = ? ORDER BY event_date DESC";
        List<Event> events = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, organizerId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    events.add(mapResultSetToEvent(rs));
                }
            }
            
        } catch (SQLException e) {

        }
        
        return events;
    }
    
    public List<Event> getEventsByVenue(int venueId) {
        String sql = "SELECT id, name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status, created_at, updated_at FROM events WHERE venue_id = ? ORDER BY event_date DESC";
        List<Event> events = new ArrayList<>();
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, venueId);
            
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    events.add(mapResultSetToEvent(rs));
                }
            }
            
        } catch (SQLException e) {

        }
        
        return events;
    }
    
    public boolean updateEvent(Event event) {
        String sql = "UPDATE events SET name = ?, description = ?, event_type = ?, event_date = ?, start_time = ?, end_time = ?, expected_guests = ?, venue_id = ?, status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, event.getName());
            pstmt.setString(2, event.getDescription());
            pstmt.setString(3, event.getEventType());
            pstmt.setDate(4, java.sql.Date.valueOf(event.getEventDate()));
            pstmt.setTime(5, java.sql.Time.valueOf(event.getStartTime()));
            pstmt.setTime(6, java.sql.Time.valueOf(event.getEndTime()));
            pstmt.setInt(7, event.getExpectedGuests());
            pstmt.setInt(8, event.getVenueId());
            pstmt.setString(9, event.getStatus());
            pstmt.setInt(10, event.getId());
            
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }
    
    public boolean deleteEvent(int id) {
        String sql = "DELETE FROM events WHERE id = ?";
        
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {

            return false;
        }
    }
    
    private Event mapResultSetToEvent(ResultSet rs) throws SQLException {
        Event event = new Event();
        event.setId(rs.getInt("id"));
        event.setName(rs.getString("name"));
        event.setDescription(rs.getString("description"));
        event.setEventType(rs.getString("event_type"));
        
        java.sql.Date eventDate = rs.getDate("event_date");
        if (eventDate != null) {
            event.setEventDate(eventDate.toLocalDate());
        }
        
        java.sql.Time startTime = rs.getTime("start_time");
        if (startTime != null) {
            event.setStartTime(startTime.toLocalTime());
        }
        
        java.sql.Time endTime = rs.getTime("end_time");
        if (endTime != null) {
            event.setEndTime(endTime.toLocalTime());
        }
        
        event.setExpectedGuests(rs.getInt("expected_guests"));
        event.setOrganizerId(rs.getInt("organizer_id"));
        event.setVenueId(rs.getInt("venue_id"));
        event.setStatus(rs.getString("status"));
        
        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            event.setCreatedAt(createdAtTs.toLocalDateTime());
        }
        
        Timestamp updatedAtTs = rs.getTimestamp("updated_at");
        if (updatedAtTs != null) {
            event.setUpdatedAt(updatedAtTs.toLocalDateTime());
        }
        
        return event;
    }
}
