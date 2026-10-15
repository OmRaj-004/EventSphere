package com.eventsphere.controller;

import com.eventsphere.dao.BookingDAO;
import com.eventsphere.dao.NotificationDAO;
import com.eventsphere.dao.PromoDAO;
import com.eventsphere.dao.UserDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.Booking;
import com.eventsphere.model.Event;
import com.eventsphere.model.PromoCode;
import com.eventsphere.model.User;
import com.eventsphere.model.Venue;
import com.eventsphere.util.EscapeUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.sql.SQLException;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.List;

// EventSphere project (TYBCA) - creates customer bookings.
// doGet shows the booking form for one venue (or the multi-venue
// form when venueIds are passed). doPost validates everything,
// applies an optional promo code, and saves the booking as PENDING
// for admin approval. Customers are notified of the result.
@WebServlet("/booking")
public class BookingServlet extends HttpServlet {
    private final VenueDAO venueDAO = new VenueDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final PromoDAO promoDAO = new PromoDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String multi = request.getParameter("venueIds");
        if (multi != null && !multi.isBlank()) {
            List<Venue> venues = new ArrayList<>();
            for (String part : multi.split(",")) {
                Venue venue = findVenue(part.trim());
                if (venue != null && venue.isAvailable()) {
                    venues.add(venue);
                }
            }
            if (venues.isEmpty()) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
            request.setAttribute("venues", venues);
            request.getRequestDispatcher("/booking-multi.jsp").forward(request, response);
            return;
        }
        Venue venue = findVenue(request.getParameter("venueId"));
        if (venue == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        request.setAttribute("venue", venue);
        request.getRequestDispatcher("/booking.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null || !user.isCustomer()) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String multi = request.getParameter("venueIds");
        if (multi != null && !multi.isBlank()) {
            handleMultiBooking(request, response, user, multi);
            return;
        }

        Venue venue = findVenue(request.getParameter("venueId"));
        Event event = new Event();
        String error = validate(request, venue, event);
        if (error != null) {
            fail(request, response, venue, event, error);
            return;
        }

        String promoInput = trim(request.getParameter("promoCode"));
        PromoCode promo = resolvePromo(promoInput);
        if (promoInput != null && !promoInput.isEmpty() && promo == null) {
            fail(request, response, venue, event, "Promo code '" + EscapeUtil.e(promoInput.toUpperCase()) + "' is invalid, disabled or exhausted. Remove it or fix it to continue.");
            return;
        }
        Booking booking = buildBooking(request, user, venue, event, promo);
        try {
            if (!bookingDAO.createPendingBooking(event, booking)) {
                fail(request, response, venue, event, "This venue is not available for the selected date and time.");
                return;
            }
            afterSuccess(promo, booking, event);
        } catch (SQLException exception) {
            getServletContext().log("Booking creation failed", exception);
            fail(request, response, venue, event, "Something went wrong. Please try again later.");
            return;
        }
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp?success=Booking+submitted");
    }

    private void handleMultiBooking(HttpServletRequest request, HttpServletResponse response, User user, String multi)
            throws ServletException, IOException {
        List<Venue> venues = new ArrayList<>();
        for (String part : multi.split(",")) {
            Venue venue = findVenue(part.trim());
            if (venue != null) {
                venues.add(venue);
            }
        }
        if (venues.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        String promoInput = trim(request.getParameter("promoCode"));
        PromoCode promo = resolvePromo(promoInput);
        if (promoInput != null && !promoInput.isEmpty() && promo == null) {
            request.setAttribute("venues", venues);
            request.setAttribute("error", "Promo code '" + EscapeUtil.e(promoInput.toUpperCase()) + "' is invalid, disabled or exhausted. Remove it or fix it to continue.");
            request.getRequestDispatcher("/booking-multi.jsp").forward(request, response);
            return;
        }
        int created = 0;
        List<String> failed = new ArrayList<>();
        for (Venue venue : venues) {
            Event event = new Event();
            String error = validate(request, venue, event);
            if (error != null) {
                failed.add(venue.getName());
                continue;
            }
            Booking booking = buildBooking(request, user, venue, event, promo);
            try {
                if (bookingDAO.createPendingBooking(event, booking)) {
                    created++;
                    afterSuccess(promo, booking, event);
                } else {
                    failed.add(venue.getName());
                }
            } catch (SQLException exception) {
                getServletContext().log("Multi booking failed for venue " + venue.getId(), exception);
                failed.add(venue.getName());
            }
        }
        if (created == 0) {
            request.setAttribute("venues", venues);
            request.setAttribute("error", "None of the selected venues could be booked for that slot.");
            request.getRequestDispatcher("/booking-multi.jsp").forward(request, response);
            return;
        }
        String message = created + " of " + venues.size() + " venues booked"
                + (failed.isEmpty() ? "" : " (" + String.join(", ", failed) + " unavailable)");
        notificationDAO.create(user.getId(), "CUSTOMER", "Multi-venue booking submitted",
                message, "/customer/dashboard.jsp");
        for (com.eventsphere.model.User admin : new UserDAO().getAllAdmins()) {
            notificationDAO.create(admin.getId(), "ADMIN", "Approval needed: multi-venue request",
                    user.getFullName() + " submitted " + created + " booking(s) awaiting your decision.",
                    "/admin/bookings.jsp");
        }
        response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp?success=" + created + "+bookings+submitted");
    }

    private Booking buildBooking(HttpServletRequest request, User user, Venue venue, Event event, PromoCode promo) {
        Booking booking = new Booking();
        booking.setVenueId(venue.getId());
        booking.setCustomerId(user.getId());
        booking.setNotes(trim(request.getParameter("notes")));
        if (promo != null) {
            booking.setDiscountAmount(estimateDiscount(venue, event, promo));
            booking.setPromoId(promo.getId());
        }
        return booking;
    }

    private void afterSuccess(PromoCode promo, Booking booking, Event event) {
        if (promo != null) {
            promoDAO.redeem(promo.getId());
        }
        notificationDAO.create(booking.getCustomerId(), "CUSTOMER", "Booking submitted",
                event.getName() + " (" + booking.getBookingNumber() + ") is awaiting approval.",
                "/customer/dashboard.jsp");
        notifyAdminsForApproval(booking, event);
    }

    private void notifyAdminsForApproval(Booking booking, Event event) {
        Venue venue = venueDAO.getVenueById(booking.getVenueId());
        String venueName = venue == null ? "a venue" : venue.getName();
        for (com.eventsphere.model.User admin : new UserDAO().getAllAdmins()) {
            notificationDAO.create(admin.getId(), "ADMIN", "Approval needed: " + booking.getBookingNumber(),
                    event.getName() + " at " + venueName + " on " + booking.getBookingDate() + " awaits your decision.",
                    "/admin/bookings.jsp");
        }
    }

    private PromoCode resolvePromo(String code) {
        if (code == null || code.isBlank()) {
            return null;
        }
        return promoDAO.findUsableByCode(code);
    }

    private BigDecimal estimateDiscount(Venue venue, Event event, PromoCode promo) {
        long minutes = Duration.between(event.getStartTime(), event.getEndTime()).toMinutes();
        BigDecimal hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        BigDecimal gross = venue.getHourlyRate().multiply(hours).setScale(2, RoundingMode.HALF_UP);
        return gross.multiply(BigDecimal.valueOf(promo.getPercentOff()))
                .divide(BigDecimal.valueOf(100), 2, RoundingMode.HALF_UP);
    }

    private void fail(HttpServletRequest request, HttpServletResponse response, Venue venue, Event event, String error)
            throws ServletException, IOException {
        request.setAttribute("error", error);
        request.setAttribute("venue", venue);
        request.setAttribute("event", event);
        request.getRequestDispatcher("/booking.jsp").forward(request, response);
    }

    private String validate(HttpServletRequest request, Venue venue, Event event) {
        if (venue == null) return "Please select a valid venue.";
        if (!venue.isAvailable()) return "This venue is currently unavailable.";
        event.setName(trim(request.getParameter("eventName")));
        event.setEventType(trim(request.getParameter("eventType")));
        event.setDescription(trim(request.getParameter("notes")));
        event.setVenueId(venue.getId());
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

    private Venue findVenue(String value) {
        try {
            return value == null ? null : venueDAO.getVenueById(Integer.parseInt(value));
        } catch (NumberFormatException exception) {
            return null;
        }
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
