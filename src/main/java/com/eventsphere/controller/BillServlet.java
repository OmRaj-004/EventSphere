package com.eventsphere.controller;

import com.eventsphere.dao.BillDAO;
import com.eventsphere.dao.BookingDAO;
import com.eventsphere.dao.EventDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.Bill;
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

/**
 * Customer-only bill/invoice view. A customer can only see bills
 * for their own bookings (ownership enforced).
 */
// EventSphere project (TYBCA) - shows one booking's invoice page.
// Strictly customer-only: it checks that the booking's customer_id
// equals the logged-in user's id, otherwise it returns 403, so
// customers can never open each other's bills.
@WebServlet("/bill")
public class BillServlet extends HttpServlet {
    private final BookingDAO bookingDAO = new BookingDAO();
    private final EventDAO eventDAO = new EventDAO();
    private final VenueDAO venueDAO = new VenueDAO();
    private final BillDAO billDAO = new BillDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!user.isCustomer()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        int bookingId;
        try {
            bookingId = Integer.parseInt(request.getParameter("id"));
        } catch (NumberFormatException | NullPointerException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }

        Booking booking = bookingDAO.getBookingById(bookingId);
        if (booking == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND);
            return;
        }
        if (booking.getCustomerId() != user.getId()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        Event event = eventDAO.getEventById(booking.getEventId());
        Venue venue = venueDAO.getVenueById(booking.getVenueId());

        Bill bill = billDAO.getBillByBookingId(booking.getId());
        if (bill == null) {
            bill = backfillBill(booking);
            if (bill == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND);
                return;
            }
        }

        BigDecimal hours = BigDecimal.ZERO;
        if (event != null && event.getStartTime() != null && event.getEndTime() != null) {
            long minutes = Duration.between(event.getStartTime(), event.getEndTime()).toMinutes();
            hours = BigDecimal.valueOf(minutes).divide(BigDecimal.valueOf(60), 2, RoundingMode.HALF_UP);
        }
        BigDecimal rate = venue != null && venue.getHourlyRate() != null ? venue.getHourlyRate() : BigDecimal.ZERO;
        BigDecimal advance = booking.getAdvancePaid() == null ? BigDecimal.ZERO : booking.getAdvancePaid();
        BigDecimal total = booking.getTotalAmount() == null ? BigDecimal.ZERO : booking.getTotalAmount();
        BigDecimal balance = total.subtract(advance);

        request.setAttribute("booking", booking);
        request.setAttribute("event", event);
        request.setAttribute("venue", venue);
        request.setAttribute("customer", user);
        request.setAttribute("bill", bill);
        request.setAttribute("hours", hours);
        request.setAttribute("rate", rate);
        request.setAttribute("advance", advance);
        request.setAttribute("total", total);
        request.setAttribute("balance", balance);
        request.getRequestDispatcher("/customer/bill.jsp").forward(request, response);
    }

    private Bill backfillBill(Booking booking) {
        BigDecimal total = booking.getTotalAmount() == null ? BigDecimal.ZERO : booking.getTotalAmount();
        BigDecimal advance = booking.getAdvancePaid() == null ? BigDecimal.ZERO : booking.getAdvancePaid();
        Bill bill = new Bill();
        bill.setBillNumber(billDAO.generateBillNumber());
        bill.setBookingId(booking.getId());
        bill.setCustomerId(booking.getCustomerId());
        bill.setSubtotal(total);
        bill.setAdvancePaid(advance);
        bill.setBalanceDue(total.subtract(advance));
        bill.setStatus("CANCELLED".equals(booking.getStatus()) || "REJECTED".equals(booking.getStatus()) ? "CANCELLED" : "ISSUED");
        if (bill.getBillNumber() == null || !billDAO.createBill(bill)) {
            return null;
        }
        return billDAO.getBillByBookingId(booking.getId());
    }
}
