package com.eventsphere.servlet;

import com.eventsphere.dao.VenueDAO;
import com.eventsphere.dao.BookingDAO;
import com.eventsphere.model.Booking;
import com.eventsphere.model.Venue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

// EventSphere project (TYBCA) - public venue browsing.
// doGet either shows one venue's details page or the venue list
// with optional filters (type, capacity, price) and pagination
// (9 venues per page). No login is needed to browse.
@WebServlet("/venues")
public class VenueServlet extends HttpServlet {
    private VenueDAO venueDAO = new VenueDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String action = request.getParameter("action");
        String eventType = request.getParameter("eventType");
        String maxCapacityStr = request.getParameter("maxCapacity");
        String priceRangeStr = request.getParameter("priceRange");
        String venueIdStr = request.getParameter("id");
        
        List<Venue> venues = new java.util.ArrayList<>();
        
        if ("details".equals(action) && venueIdStr != null) {
            try {
                int venueId = Integer.parseInt(venueIdStr);
                Venue venue = venueDAO.getVenueById(venueId);
                if (venue == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                request.setAttribute("venue", venue);
                Object userId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
                if (userId instanceof Integer && "CUSTOMER".equals(request.getSession(false).getAttribute("userRole"))) {
                    List<Booking> feedbackBookings = new BookingDAO().getApprovedBookingsByCustomerAndVenue((Integer) userId, venueId);
                    request.setAttribute("feedbackBookings", feedbackBookings);
                }
                request.getRequestDispatcher("/venue-details.jsp").forward(request, response);
            } catch (NumberFormatException e) {

                response.sendRedirect(request.getContextPath() + "/");
            }
        } else {
            Integer maxCapacity = null;
            BigDecimal priceRange = null;

            try {
                if (maxCapacityStr != null && !maxCapacityStr.isEmpty()) {
                    maxCapacity = Integer.parseInt(maxCapacityStr);
                }
                if (priceRangeStr != null && !priceRangeStr.isEmpty()) {
                    priceRange = new BigDecimal(priceRangeStr);
                }
            } catch (NumberFormatException e) {

            }

            boolean filtering = (maxCapacity != null && maxCapacity > 0) || priceRange != null || (eventType != null && !eventType.isBlank());
            int page = 1;
            try {
                page = Math.max(1, Integer.parseInt(request.getParameter("page")));
            } catch (NumberFormatException | NullPointerException e) {
                page = 1;
            }
            final int pageSize = 9;
            long totalVenues;
            if (filtering) {
                venues = venueDAO.searchVenues(eventType, maxCapacity, priceRange);
                totalVenues = venues.size();
            } else {
                totalVenues = venueDAO.countAvailableVenues();
            }
            int totalPages = (int) Math.max(1, (totalVenues + pageSize - 1) / pageSize);
            if (page > totalPages) {
                page = totalPages;
            }
            if (!filtering) {
                venues = venueDAO.getAvailableVenuesPage((page - 1) * pageSize, pageSize);
            }

            request.setAttribute("venues", venues);
            request.setAttribute("eventType", eventType);
            request.setAttribute("maxCapacity", maxCapacityStr);
            request.setAttribute("priceRange", priceRangeStr);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("filtering", filtering);
            request.getRequestDispatcher("/venues.jsp").forward(request, response);
        }
    }
}
