package com.eventsphere.controller;

import com.eventsphere.dao.BillDAO;
import com.eventsphere.dao.BookingDAO;
import com.eventsphere.dao.EventDAO;
import com.eventsphere.dao.NotificationDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.Booking;
import com.eventsphere.model.Event;
import com.eventsphere.model.User;
import com.eventsphere.model.Venue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;

/**
 * Customer-only modification of PENDING bookings (event details + totals).
 */
// EventSphere project (TYBCA) - lets a customer correct their own
// PENDING booking (event details, date, time, guests). Approved
// bookings or other customers' bookings are blocked with 403.
// Totals and the bill are recalculated after every saved edit.
@WebServlet("/bookings/edit")
public class BookingEditServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final EventDAO eventDAO = new EventDAO();
    private final VenueDAO venueDAO = new VenueDAO();
    private final BillDAO billDAO = new BillDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Booking booking = ownedPendingBooking(request, response);
        if (booking == null) {
            return;
        }
        request.setAttribute("booking", booking);
        request.setAttribute("event", eventDAO.getEventById(booking.getEventId()));
        request.setAttribute("venue", venueDAO.getVenueById(booking.getVenueId()));
        request.getRequestDispatcher("/customer/booking-edit.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Booking booking = ownedPendingBooking(request, response);
        if (booking == null) {
            return;
        }
        Event event = eventDAO.getEventById(booking.getEventId());
        Venue venue = venueDAO.getVenueById(booking.getVenueId());
        if (event == null || venue == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }

        String error = validate(request, venue, event);
        if (error != null) {
            request.setAttribute("error", error);
            request.setAttribute("booking", booking);
            request.setAttribute("event", event);
            request.setAttribute("venue", venue);
            request.getRequestDispatcher("/customer/booking-edit.jsp").forward(request, response);
            return;
        }

        if (!bookingDAO.isVenueAvailable(venue.getId(), event.getEventDate(), event.getStartTime(), event.getEndTime(), booking.getId())) {
            request.setAttribute("error", "This venue is not available for the selected date and time.");
            request.setAttribute("booking", booking);
            request.setAttribute("event", event);
            request.setAttribute("venue", venue);
            request.getRequestDispatcher("/customer/booking-edit.jsp").forward(request, response);
            return;
        }

        event.setOrganizerId(booking.getCustomerId());
        if (!eventDAO.updateEvent(event)) {
            request.setAttribute("error", "Could not save changes. Please try again.");
            request.setAttribute("booking", booking);
            request.setAttribute("event", event);
            request.setAttribute("venue", venue);
            request.getRequestDispatcher("/customer/booking-edit.jsp").forward(request, response);
            return;
        }

        long minutes = Duration.between(event.getStartTime(), event.getEndTime()).toMinutes();
        BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        BigDecimal gross = venue.getHourlyRate().multiply(hours).setScale(2, RoundingMode.HALF_UP);
        BigDecimal discount = booking.getDiscountAmount() == null ? BigDecimal.ZERO : booking.getDiscountAmount();
        if (discount.compareTo(gross) >= 0) {
            discount = BigDecimal.ZERO;
        }
        BigDecimal total = gross.subtract(discount);
        bookingDAO.updateBookingTotals(booking.getId(), total, discount);
        booking.setBookingDate(event.getEventDate());
        billDAO.updateAmounts(booking.getId(), total, BigDecimal.ZERO);

        notificationDAO.create(booking.getCustomerId(), "CUSTOMER", "Booking updated",
                "Booking " + booking.getBookingNumber() + " was updated.", "/customer/dashboard.jsp");
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp?success=Booking+updated");
    }

    private Booking ownedPendingBooking(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        if (!user.isCustomer()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        int id;
        try {
            id = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return null;
        }
        Booking booking = bookingDAO.getBookingById(id);
        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return null;
        }
        if (booking.getCustomerId() != user.getId() || !"PENDING".equals(booking.getStatus())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return booking;
    }

    private String validate(HttpServletRequest request, Venue venue, Event event) {
        event.setName(trim(request.getParameter("eventName")));
        event.setEventType(trim(request.getParameter("eventType")));
        event.setDescription(trim(request.getParameter("notes")));
        if (event.getName() == null || event.getName().length() < 2 || event.getName().length() > 150) return "Enter a valid event name.";
        if (event.getEventType() == null || event.getEventType().isBlank()) return "Select an event type.";
        try {
            event.setEventDate(LocalDate.parse(request.getParameter("bookingDate")));
            event.setStartTime(LocalTime.parse(request.getParameter("startTime")));
            event.setEndTime(LocalTime.parse(request.getParameter("endTime")));
        } catch (DateTimeParseException | NullPointerException exception) {
            return "Enter a valid booking date and time.";
        }
        if (event.getEventDate().isBefore(LocalDate.now())) return "Please select a future booking date.";
        if (!event.getStartTime().isBefore(event.getEndTime())) return "Start time must be before end time.";
        try {
            event.setExpectedGuests(Integer.parseInt(request.getParameter("expectedGuests")));
        } catch (NumberFormatException exception) {
            return "Expected guests must be a positive number.";
        }
        if (event.getExpectedGuests() <= 0) return "Expected guests must be greater than zero.";
        if (event.getExpectedGuests() > venue.getMaxCapacity()) return "Expected guests exceed the venue capacity.";
        return null;
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
