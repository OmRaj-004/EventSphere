package com.eventsphere.dao;

import com.eventsphere.model.Booking;
import com.eventsphere.model.Event;
import com.eventsphere.model.Venue;
import com.eventsphere.util.DBUtil;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.*;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for bookings.
// The most important method here is createPendingBooking(), which
// runs inside ONE database transaction: it locks the venue row,
// checks for time clashes, then inserts the event, booking and
// bill rows together. If any step fails, everything is rolled back
// so the database is never left half-updated.
public class BookingDAO {

    // Creates one full booking inside a single transaction:
    // 1. lock the venue row, 2. re-check capacity + time clash,
    // 3. insert event, 4. insert booking, 5. insert its bill.
    // Any failure rolls everything back (all-or-nothing).
    public boolean createPendingBooking(Event event, Booking booking) throws SQLException {
        if (event == null || booking == null) {
            return false;
        }
        if (booking.getVenueId() <= 0 || booking.getCustomerId() <= 0) {
            return false;
        }
        if (event.getEventDate() == null || event.getStartTime() == null || event.getEndTime() == null) {
            return false;
        }
        if (!event.getStartTime().isBefore(event.getEndTime())) {
            return false;
        }
        if (event.getEventDate().isBefore(LocalDate.now())) {
            return false;
        }

        try (Connection connection = DBUtil.getConnection()) {
            connection.setAutoCommit(false);
            try {
                Venue venue = getVenueForUpdate(connection, booking.getVenueId());
                if (venue == null || !venue.isAvailable()) {
                    connection.rollback();
                    return false;
                }
                if (event.getExpectedGuests() <= 0 || event.getExpectedGuests() > venue.getMaxCapacity()) {
                    connection.rollback();
                    return false;
                }
                if (hasConflict(connection, booking.getVenueId(), event.getEventDate(), event.getStartTime(), event.getEndTime(), null)) {
                    connection.rollback();
                    return false;
                }

                String eventSql = "INSERT INTO events (name, description, event_type, event_date, start_time, end_time, expected_guests, organizer_id, venue_id, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'BOOKED')";
                try (PreparedStatement statement = connection.prepareStatement(eventSql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setString(1, event.getName());
                    statement.setString(2, event.getDescription());
                    statement.setString(3, event.getEventType());
                    statement.setDate(4, Date.valueOf(event.getEventDate()));
                    statement.setTime(5, Time.valueOf(event.getStartTime()));
                    statement.setTime(6, Time.valueOf(event.getEndTime()));
                    statement.setInt(7, event.getExpectedGuests());
                    statement.setInt(8, booking.getCustomerId());
                    statement.setInt(9, booking.getVenueId());
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (!keys.next()) {
                            throw new SQLException("Event ID was not generated");
                        }
                        event.setId(keys.getInt(1));
                    }
                }

                BigDecimal totalAmount = calculateTotalAmount(venue.getHourlyRate(), event.getStartTime(), event.getEndTime());
                BigDecimal discount = booking.getDiscountAmount() == null ? BigDecimal.ZERO : booking.getDiscountAmount();
                if (discount.signum() > 0 && discount.compareTo(totalAmount) < 0) {
                    totalAmount = totalAmount.subtract(discount);
                } else {
                    discount = BigDecimal.ZERO;
                }
                booking.setDiscountAmount(discount);
                booking.setBookingNumber(generateBookingNumber(connection));
                booking.setEventId(event.getId());
                booking.setBookingDate(event.getEventDate());
                booking.setStatus("PENDING");
                booking.setTotalAmount(totalAmount);

                String bookingSql = "INSERT INTO bookings (booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, notes) VALUES (?, ?, ?, ?, ?, ?, 0, ?, ?, 'PENDING', ?, ?)";
                try (PreparedStatement statement = connection.prepareStatement(bookingSql, Statement.RETURN_GENERATED_KEYS)) {
                    statement.setString(1, booking.getBookingNumber());
                    statement.setInt(2, booking.getEventId());
                    statement.setInt(3, booking.getVenueId());
                    statement.setInt(4, booking.getCustomerId());
                    statement.setDate(5, Date.valueOf(booking.getBookingDate()));
                    statement.setBigDecimal(6, booking.getTotalAmount());
                    statement.setBigDecimal(7, booking.getDiscountAmount());
                    if (booking.getPromoId() == null) {
                        statement.setNull(8, Types.INTEGER);
                    } else {
                        statement.setInt(8, booking.getPromoId());
                    }
                    statement.setString(9, booking.getPaymentMethod());
                    statement.setString(10, booking.getNotes());
                    statement.executeUpdate();
                    try (ResultSet keys = statement.getGeneratedKeys()) {
                        if (keys.next()) {
                            booking.setId(keys.getInt(1));
                        }
                    }
                }
                insertBillForBooking(connection, booking);
                connection.commit();
                return true;
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public boolean isVenueAvailable(int venueId, LocalDate bookingDate, LocalTime startTime, LocalTime endTime, Integer ignoredBookingId) {
        try (Connection connection = DBUtil.getConnection()) {
            return !hasConflict(connection, venueId, bookingDate, startTime, endTime, ignoredBookingId);
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean cancelPendingBooking(int bookingId, int customerId) {
        String sql = "UPDATE bookings SET status = 'CANCELLED', updated_at = CURRENT_TIMESTAMP WHERE id = ? AND customer_id = ? AND status = 'PENDING'";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, bookingId);
            statement.setInt(2, customerId);
            boolean cancelled = statement.executeUpdate() == 1;
            if (cancelled) {
                new BillDAO().markBillCancelled(bookingId);
                releaseBookingPromo(bookingId);
            }
            return cancelled;
        } catch (SQLException exception) {
            return false;
        }
    }

    private void releaseBookingPromo(int bookingId) {
        try {
            Booking booking = getBookingById(bookingId);
            if (booking != null && booking.getPromoId() != null) {
                new PromoDAO().release(booking.getPromoId());
            }
        } catch (RuntimeException ignored) {
        }
    }

    public boolean approveBooking(int bookingId) throws SQLException {
        try (Connection connection = DBUtil.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String sql = "SELECT b.venue_id, b.booking_date, e.start_time, e.end_time FROM bookings b JOIN events e ON e.id = b.event_id WHERE b.id = ? AND b.status = 'PENDING' FOR UPDATE";
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    statement.setInt(1, bookingId);
                    try (ResultSet result = statement.executeQuery()) {
                        if (!result.next()) {
                            connection.rollback();
                            return false;
                        }
                        int venueId = result.getInt("venue_id");
                        LocalDate date = result.getDate("booking_date").toLocalDate();
                        LocalTime start = result.getTime("start_time").toLocalTime();
                        LocalTime end = result.getTime("end_time").toLocalTime();
                        if (hasConflict(connection, venueId, date, start, end, bookingId)) {
                            connection.rollback();
                            return false;
                        }
                    }
                }

                String updateSql = "UPDATE bookings SET status = 'APPROVED', updated_at = CURRENT_TIMESTAMP WHERE id = ? AND status = 'PENDING'";
                try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                    statement.setInt(1, bookingId);
                    boolean updated = statement.executeUpdate() == 1;
                    if (!updated) {
                        connection.rollback();
                        return false;
                    }
                    connection.commit();
                    return true;
                }
            } catch (SQLException exception) {
                connection.rollback();
                throw exception;
            } finally {
                connection.setAutoCommit(true);
            }
        }
    }

    public boolean rejectBooking(int bookingId) {
        boolean rejected = updateBookingStatus(bookingId, "REJECTED");
        if (rejected) {
            new BillDAO().markBillCancelled(bookingId);
            releaseBookingPromo(bookingId);
        }
        return rejected;
    }

    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE bookings SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, bookingId);
            return statement.executeUpdate() == 1;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean addBooking(Booking booking) {
        String sql = "INSERT INTO bookings (booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, booking.getBookingNumber());
            pstmt.setInt(2, booking.getEventId());
            pstmt.setInt(3, booking.getVenueId());
            pstmt.setInt(4, booking.getCustomerId());
            pstmt.setDate(5, Date.valueOf(booking.getBookingDate()));
            pstmt.setBigDecimal(6, booking.getTotalAmount());
            pstmt.setBigDecimal(7, booking.getAdvancePaid());
            pstmt.setBigDecimal(8, booking.getDiscountAmount() == null ? BigDecimal.ZERO : booking.getDiscountAmount());
            if (booking.getPromoId() == null) {
                pstmt.setNull(9, Types.INTEGER);
            } else {
                pstmt.setInt(9, booking.getPromoId());
            }
            pstmt.setString(10, booking.getStatus());
            pstmt.setString(11, booking.getPaymentMethod());
            pstmt.setString(12, booking.getNotes());

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        booking.setId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException exception) {
            return false;
        }
        return false;
    }

    public Booking getBookingById(int id) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBooking(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public Booking getBookingByNumber(String bookingNumber) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE booking_number = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, bookingNumber);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBooking(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public List<Booking> getBookingsByCustomer(int customerId) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE customer_id = ? ORDER BY booking_date DESC";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapResultSetToBooking(rs));
                }
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public List<Booking> getApprovedBookingsByCustomerAndVenue(int customerId, int venueId) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE customer_id = ? AND venue_id = ? AND status = 'APPROVED' ORDER BY booking_date DESC";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            statement.setInt(2, venueId);
            try (ResultSet result = statement.executeQuery()) {
                while (result.next()) {
                    bookings.add(mapResultSetToBooking(result));
                }
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public List<Booking> getBookingsByVenue(int venueId) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE venue_id = ? ORDER BY booking_date DESC";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, venueId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapResultSetToBooking(rs));
                }
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public List<Booking> getBookingsByStatus(String status) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings WHERE status = ? ORDER BY booking_date DESC";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapResultSetToBooking(rs));
                }
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public List<Booking> getAllBookings() {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings ORDER BY booking_date DESC";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql); ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                bookings.add(mapResultSetToBooking(rs));
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public long countByCustomerAndStatus(int customerId, String status) {
        return count("SELECT COUNT(*) FROM bookings WHERE customer_id = ? AND status = ?", customerId, status);
    }

    public long countByStatus(String status) {
        return count("SELECT COUNT(*) FROM bookings WHERE status = ?", null, status);
    }

    private long count(String sql, Integer customerId, String status) {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            int index = 1;
            if (customerId != null) {
                statement.setInt(index++, customerId);
            }
            statement.setString(index, status);
            try (ResultSet result = statement.executeQuery()) {
                return result.next() ? result.getLong(1) : 0;
            }
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean updateBooking(Booking booking) {
        String sql = "UPDATE bookings SET event_id = ?, venue_id = ?, total_amount = ?, advance_paid = ?, status = ?, payment_method = ?, notes = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, booking.getEventId());
            pstmt.setInt(2, booking.getVenueId());
            pstmt.setBigDecimal(3, booking.getTotalAmount());
            pstmt.setBigDecimal(4, booking.getAdvancePaid());
            pstmt.setString(5, booking.getStatus());
            pstmt.setString(6, booking.getPaymentMethod());
            pstmt.setString(7, booking.getNotes());
            pstmt.setInt(8, booking.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public List<Booking> getBookingsPage(int offset, int limit) {
        String sql = "SELECT id, booking_number, event_id, venue_id, customer_id, booking_date, total_amount, advance_paid, discount_amount, promo_id, status, payment_method, transaction_id, notes, created_at, updated_at FROM bookings ORDER BY booking_date DESC LIMIT ? OFFSET ?";
        List<Booking> bookings = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, limit);
            pstmt.setInt(2, offset);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bookings.add(mapResultSetToBooking(rs));
                }
            }
        } catch (SQLException exception) {
            return bookings;
        }
        return bookings;
    }

    public long countAllBookings() {
        try (Connection connection = DBUtil.getConnection(); PreparedStatement statement = connection.prepareStatement("SELECT COUNT(*) FROM bookings"); ResultSet result = statement.executeQuery()) {
            return result.next() ? result.getLong(1) : 0;
        } catch (SQLException exception) {
            return 0;
        }
    }

    public boolean updateBookingTotals(int bookingId, BigDecimal total, BigDecimal discount) {
        String sql = "UPDATE bookings SET total_amount = ?, discount_amount = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ? AND status = 'PENDING'";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, total);
            pstmt.setBigDecimal(2, discount);
            pstmt.setInt(3, bookingId);
            return pstmt.executeUpdate() == 1;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean deleteBooking(int id) {
        String sql = "DELETE FROM bookings WHERE id = ?";
        try (Connection conn = DBUtil.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    private boolean hasConflict(Connection connection, int venueId, LocalDate bookingDate, LocalTime startTime, LocalTime endTime, Integer ignoredBookingId) throws SQLException {
        String sql = "SELECT 1 FROM bookings b JOIN events e ON e.id = b.event_id WHERE b.venue_id = ? AND b.booking_date = ? AND b.status IN ('PENDING', 'APPROVED') AND (? IS NULL OR b.id <> ?) AND e.start_time < ? AND e.end_time > ? LIMIT 1";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, venueId);
            statement.setDate(2, Date.valueOf(bookingDate));
            if (ignoredBookingId == null) {
                statement.setNull(3, Types.INTEGER);
                statement.setNull(4, Types.INTEGER);
            } else {
                statement.setInt(3, ignoredBookingId);
                statement.setInt(4, ignoredBookingId);
            }
            statement.setTime(5, Time.valueOf(endTime));
            statement.setTime(6, Time.valueOf(startTime));
            try (ResultSet result = statement.executeQuery()) {
                return result.next();
            }
        }
    }

    private Venue getVenueForUpdate(Connection connection, int venueId) throws SQLException {
        String sql = "SELECT id, name, description, location, event_type, max_capacity, hourly_rate, amenities, image_url, available, created_by, created_at, updated_at FROM venues WHERE id = ? FOR UPDATE";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, venueId);
            try (ResultSet result = statement.executeQuery()) {
                if (!result.next()) {
                    return null;
                }
                Venue venue = new Venue();
                venue.setId(result.getInt("id"));
                venue.setName(result.getString("name"));
                venue.setDescription(result.getString("description"));
                venue.setLocation(result.getString("location"));
                venue.setEventType(result.getString("event_type"));
                venue.setMaxCapacity(result.getInt("max_capacity"));
                venue.setHourlyRate(result.getBigDecimal("hourly_rate"));
                venue.setAmenities(result.getString("amenities"));
                venue.setImageUrl(result.getString("image_url"));
                venue.setAvailable(result.getBoolean("available"));
                venue.setCreatedBy(result.getInt("created_by"));
                return venue;
            }
        }
    }

    private void insertBillForBooking(Connection connection, Booking booking) throws SQLException {
        String billNumber = generateBillNumber(connection);
        String billSql = "INSERT INTO bills (bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status) VALUES (?, ?, ?, ?, 0, ?, 'ISSUED')";
        try (PreparedStatement statement = connection.prepareStatement(billSql)) {
            statement.setString(1, billNumber);
            statement.setInt(2, booking.getId());
            statement.setInt(3, booking.getCustomerId());
            statement.setBigDecimal(4, booking.getTotalAmount());
            statement.setBigDecimal(5, booking.getTotalAmount());
            statement.executeUpdate();
        }
    }

    private String generateBillNumber(Connection connection) throws SQLException {
        String currentYear = String.valueOf(LocalDate.now().getYear());
        String sql = "SELECT COALESCE(MAX(CAST(SUBSTRING(bill_number FROM 12) AS INTEGER)), 0) + 1 AS next_number FROM bills WHERE bill_number LIKE ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, "INV-" + currentYear + "-%");
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return String.format("INV-%s-%06d", currentYear, result.getInt("next_number"));
                }
            }
        }
        return String.format("INV-%s-%06d", currentYear, 1);
    }

    private String generateBookingNumber(Connection connection) throws SQLException {
        String currentYear = String.valueOf(LocalDate.now().getYear());
        String sql = "SELECT COALESCE(MAX(CAST(SUBSTRING(booking_number FROM 12) AS INTEGER)), 0) + 1 AS next_number FROM bookings WHERE booking_number LIKE ?";
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, "ES-" + currentYear + "-%");
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    int nextNumber = result.getInt("next_number");
                    return String.format("ES-%s-%06d", currentYear, nextNumber);
                }
            }
        }
        return String.format("ES-%s-%06d", currentYear, 1);
    }

    private BigDecimal calculateTotalAmount(BigDecimal hourlyRate, LocalTime startTime, LocalTime endTime) {
        long minutes = Duration.between(startTime, endTime).toMinutes();
        BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        return hourlyRate.multiply(hours).setScale(2, RoundingMode.HALF_UP);
    }

    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(rs.getInt("id"));
        booking.setBookingNumber(rs.getString("booking_number"));
        booking.setEventId(rs.getInt("event_id"));
        booking.setVenueId(rs.getInt("venue_id"));
        booking.setCustomerId(rs.getInt("customer_id"));

        Date bookingDate = rs.getDate("booking_date");
        if (bookingDate != null) {
            booking.setBookingDate(bookingDate.toLocalDate());
        }
        booking.setTotalAmount(rs.getBigDecimal("total_amount"));
        booking.setAdvancePaid(rs.getBigDecimal("advance_paid"));
        try {
            BigDecimal discount = rs.getBigDecimal("discount_amount");
            booking.setDiscountAmount(discount == null ? BigDecimal.ZERO : discount);
        } catch (SQLException ignored) {
            booking.setDiscountAmount(BigDecimal.ZERO);
        }
        try {
            int promoId = rs.getInt("promo_id");
            booking.setPromoId(rs.wasNull() ? null : promoId);
        } catch (SQLException ignored) {
            booking.setPromoId(null);
        }
        booking.setStatus(rs.getString("status"));
        booking.setPaymentMethod(rs.getString("payment_method"));
        booking.setTransactionId(rs.getString("transaction_id"));
        booking.setNotes(rs.getString("notes"));

        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            booking.setCreatedAt(createdAtTs.toLocalDateTime());
        }

        Timestamp updatedAtTs = rs.getTimestamp("updated_at");
        if (updatedAtTs != null) {
            booking.setUpdatedAt(updatedAtTs.toLocalDateTime());
        }
        return booking;
    }
}
