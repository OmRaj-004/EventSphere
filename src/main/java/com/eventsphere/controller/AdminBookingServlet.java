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
<<<<<<< HEAD
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
=======
                boolean approved = "approve".equals(action);
                Object adminId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
                Booking booking = bookingDAO.getBookingById(id);
                String summary = booking == null ? ("booking #" + id) : describeBooking(booking);
                request.getSession().setAttribute("adminBookingSuccess",
                        (approved ? "Approved " : "Rejected ") + summary + ".");
                new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                        approved ? "BOOKING_APPROVE" : "BOOKING_REJECT",
                        "booking", id, booking == null ? null : booking.getBookingNumber());
                if (booking != null) {
                    new NotificationDAO().create(booking.getCustomerId(), "CUSTOMER",
                            approved ? "Booking approved - " + booking.getBookingNumber()
                                    : "Booking rejected - " + booking.getBookingNumber(),
                            approved
                                    ? "Good news! " + summary + " has been approved. View your bill from your dashboard."
                                    : "Sorry, " + summary + " was rejected (venue unavailable or details invalid). Please try another date or venue.",
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                            "/customer/dashboard.jsp");
                }
            } else {
                request.getSession().setAttribute("adminBookingError", "Booking could not be updated.");
            }
        } catch (NumberFormatException | SQLException ignored) {
            request.getSession().setAttribute("adminBookingError", "Invalid booking action.");
        }
        response.sendRedirect(request.getContextPath() + target);
<<<<<<< HEAD
=======
    }

    private String describeBooking(Booking booking) {
        String eventName = null;
        String venueName = null;
        try {
            com.eventsphere.model.Event event = new com.eventsphere.dao.EventDAO().getEventById(booking.getEventId());
            if (event != null) {
                eventName = event.getName();
            }
            com.eventsphere.model.Venue venue = new com.eventsphere.dao.VenueDAO().getVenueById(booking.getVenueId());
            if (venue != null) {
                venueName = venue.getName();
            }
        } catch (RuntimeException ignored) {
        }
        StringBuilder sb = new StringBuilder("booking ").append(booking.getBookingNumber());
        if (eventName != null) {
            sb.append(" (").append(eventName).append(')');
        }
        if (venueName != null) {
            sb.append(" at ").append(venueName);
        }
        if (booking.getBookingDate() != null) {
            sb.append(" on ").append(booking.getBookingDate());
        }
        return sb.toString();
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    }
}
