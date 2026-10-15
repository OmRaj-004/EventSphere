package com.eventsphere.controller;

import com.eventsphere.dao.BookingDAO;
import com.eventsphere.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - customer cancels their own pending
// booking here. The cancel query matches both booking id AND
// customer id, so one customer can never cancel another's booking.
@WebServlet("/bookings")
public class CustomerBookingServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        var session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null || !user.isCustomer()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String action = request.getParameter("action");
        if ("cancel".equals(action)) {
            try {
                int bookingId = Integer.parseInt(request.getParameter("id"));
                boolean cancelled = bookingDAO.cancelPendingBooking(bookingId, user.getId());
                if (cancelled) {
                    session.setAttribute("bookingSuccess", "Booking cancelled.");
                    new com.eventsphere.dao.NotificationDAO().create(user.getId(), "CUSTOMER", "Booking cancelled",
                            "Your pending booking was cancelled.", "/customer/dashboard.jsp");
                } else {
                    session.setAttribute("bookingError", "Only pending bookings can be cancelled.");
                }
            } catch (NumberFormatException ignored) {
                session.setAttribute("bookingError", "Invalid booking selection.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
    }
}
