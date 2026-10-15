package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.BookingDAO;
import com.eventsphere.dao.NotificationDAO;
import com.eventsphere.model.Booking;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;

// EventSphere project (TYBCA) - admin approves or rejects bookings.
// Rejects non-admin users with 403. Every decision is recorded in
// the audit log and the customer gets an inbox notification.
@WebServlet("/admin/bookings")
public class AdminBookingServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String returnTo = request.getParameter("returnTo");
        String target = "/admin/bookings.jsp";
        if ("/admin/dashboard.jsp".equals(returnTo)) {
            target = "/admin/dashboard.jsp";
        }
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String action = request.getParameter("action");
            boolean success = false;
            if ("approve".equals(action)) {
                success = bookingDAO.approveBooking(id);
            } else if ("reject".equals(action)) {
                success = bookingDAO.rejectBooking(id);
            }
            if (success) {
                request.getSession().setAttribute("adminBookingSuccess",
                        "approve".equals(action) ? "Booking approved." : "Booking rejected.");
                Object adminId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
                Booking booking = bookingDAO.getBookingById(id);
                new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                        "approve".equals(action) ? "BOOKING_APPROVE" : "BOOKING_REJECT",
                        "booking", id, booking == null ? null : booking.getBookingNumber());
                if (booking != null) {
                    new NotificationDAO().create(booking.getCustomerId(), "CUSTOMER",
                            "approve".equals(action) ? "Booking approved" : "Booking rejected",
                            "Booking " + booking.getBookingNumber() + " was " + ("approve".equals(action) ? "approved." : "rejected."),
                            "/customer/dashboard.jsp");
                }
            } else {
                request.getSession().setAttribute("adminBookingError", "Booking could not be updated.");
            }
        } catch (NumberFormatException | SQLException ignored) {
            request.getSession().setAttribute("adminBookingError", "Invalid booking action.");
        }
        response.sendRedirect(request.getContextPath() + target);
    }
}
