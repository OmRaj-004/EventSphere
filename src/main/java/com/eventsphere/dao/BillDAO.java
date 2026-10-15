package com.eventsphere.dao;

import com.eventsphere.model.Bill;
import com.eventsphere.util.DBUtil;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - database access for bills.
// Reads stored invoices by booking/customer and generates the
// next bill number (INV-year-serial). New bills are normally
// created inside BookingDAO's booking transaction; the
// backfill path in BillServlet covers older bookings.
public class BillDAO {

    public Bill getBillByBookingId(int bookingId) {
        String sql = "SELECT id, bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status, created_at FROM bills WHERE booking_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBill(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public Bill getBillById(int id) {
        String sql = "SELECT id, bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status, created_at FROM bills WHERE id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToBill(rs);
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return null;
    }

    public List<Bill> getAllBills() {
        String sql = "SELECT id, bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status, created_at FROM bills ORDER BY created_at DESC";
        List<Bill> bills = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                bills.add(mapResultSetToBill(rs));
            }
        } catch (SQLException exception) {
            return bills;
        }
        return bills;
    }

    public List<Bill> getBillsByCustomer(int customerId) {
        String sql = "SELECT id, bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status, created_at FROM bills WHERE customer_id = ? ORDER BY created_at DESC";
        List<Bill> bills = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, customerId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    bills.add(mapResultSetToBill(rs));
                }
            }
        } catch (SQLException exception) {
            return bills;
        }
        return bills;
    }

    public boolean createBill(Bill bill) {
        String sql = "INSERT INTO bills (bill_number, booking_id, customer_id, subtotal, advance_paid, balance_due, status) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, bill.getBillNumber());
            pstmt.setInt(2, bill.getBookingId());
            pstmt.setInt(3, bill.getCustomerId());
            pstmt.setBigDecimal(4, bill.getSubtotal());
            pstmt.setBigDecimal(5, bill.getAdvancePaid());
            pstmt.setBigDecimal(6, bill.getBalanceDue());
            pstmt.setString(7, bill.getStatus());
            if (pstmt.executeUpdate() > 0) {
                try (ResultSet keys = pstmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        bill.setId(keys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException exception) {
            return false;
        }
        return false;
    }

    public String generateBillNumber() {
        String currentYear = String.valueOf(LocalDate.now().getYear());
        String sql = "SELECT COALESCE(MAX(CAST(SUBSTRING(bill_number FROM 12) AS INTEGER)), 0) + 1 AS next_number FROM bills WHERE bill_number LIKE ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement statement = conn.prepareStatement(sql)) {
            statement.setString(1, "INV-" + currentYear + "-%");
            try (ResultSet result = statement.executeQuery()) {
                if (result.next()) {
                    return String.format("INV-%s-%06d", currentYear, result.getInt("next_number"));
                }
            }
        } catch (SQLException exception) {
            return null;
        }
        return String.format("INV-%s-%06d", currentYear, 1);
    }

    public boolean updateAmounts(int bookingId, BigDecimal subtotal, BigDecimal advance) {
        String sql = "UPDATE bills SET subtotal = ?, advance_paid = ?, balance_due = ? - ? WHERE booking_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setBigDecimal(1, subtotal);
            pstmt.setBigDecimal(2, advance);
            pstmt.setBigDecimal(3, subtotal);
            pstmt.setBigDecimal(4, advance);
            pstmt.setInt(5, bookingId);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException exception) {
            return false;
        }
    }

    public boolean markBillCancelled(int bookingId) {
        String sql = "UPDATE bills SET status = 'CANCELLED' WHERE booking_id = ? AND status = 'ISSUED'";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, bookingId);
            pstmt.executeUpdate();
            return true;
        } catch (SQLException exception) {
            return false;
        }
    }

    private Bill mapResultSetToBill(ResultSet rs) throws SQLException {
        Bill bill = new Bill();
        bill.setId(rs.getInt("id"));
        bill.setBillNumber(rs.getString("bill_number"));
        bill.setBookingId(rs.getInt("booking_id"));
        bill.setCustomerId(rs.getInt("customer_id"));
        bill.setSubtotal(rs.getBigDecimal("subtotal"));
        BigDecimal advance = rs.getBigDecimal("advance_paid");
        bill.setAdvancePaid(advance == null ? BigDecimal.ZERO : advance);
        bill.setBalanceDue(rs.getBigDecimal("balance_due"));
        bill.setStatus(rs.getString("status"));
        Timestamp createdAtTs = rs.getTimestamp("created_at");
        if (createdAtTs != null) {
            bill.setCreatedAt(createdAtTs.toLocalDateTime());
        }
        return bill;
    }
}
