package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.User;
import com.eventsphere.model.Venue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.UUID;

// EventSphere project (TYBCA) - hosts add/edit/delete ONLY their own
// venues here. Every request first proves the venue's host_id
// matches the logged-in host; anything else gets 403. Works just
// like the admin venue servlet but scoped to one owner.
@WebServlet("/host/venues")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class HostVenueServlet extends HttpServlet {
    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        User host = currentHost(request, response);
        if (host == null) {
            return;
        }
        String value = request.getParameter("id");
        if (value != null && !value.isBlank()) {
            try {
                Venue venue = venueDAO.getVenueById(Integer.parseInt(value));
                if (venue == null || !Integer.valueOf(host.getId()).equals(venue.getHostId())) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                request.setAttribute("venue", venue);
            } catch (NumberFormatException e) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        request.getRequestDispatcher("/host/venue-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException, ServletException {
        User host = currentHost(request, response);
        if (host == null) {
            return;
        }
        String action = request.getParameter("action");
        if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Venue venue = venueDAO.getVenueById(id);
                if (venue != null && Integer.valueOf(host.getId()).equals(venue.getHostId()) && venueDAO.deleteVenue(id)) {
                    new AuditDAO().log(host.getId(), "HOST", "VENUE_DELETE", "venue", id, venue.getName());
                    request.getSession().setAttribute("hostVenueSuccess", "Venue deleted.");
                }
            } catch (NumberFormatException ignored) {
            }
            response.sendRedirect(request.getContextPath() + "/host/dashboard.jsp");
            return;
        }
        if ("save".equals(action)) {
            Venue venue = readVenue(request, host);
            if (venue == null) {
                request.getSession().setAttribute("hostVenueError", "Please fill all required fields correctly.");
                response.sendRedirect(request.getContextPath() + "/host/dashboard.jsp");
                return;
            }
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                Venue existing = venueDAO.getVenueById(id);
                if (existing == null || !Integer.valueOf(host.getId()).equals(existing.getHostId())) {
                    response.sendError(HttpServletResponse.SC_FORBIDDEN);
                    return;
                }
                venue.setId(id);
                venue.setHostId(host.getId());
                if (venueDAO.updateVenue(venue)) {
                    new AuditDAO().log(host.getId(), "HOST", "VENUE_UPDATE", "venue", id, venue.getName());
                    request.getSession().setAttribute("hostVenueSuccess", "Venue updated.");
                }
            } catch (NumberFormatException | NullPointerException e) {
                venue.setHostId(host.getId());
                if (venueDAO.addVenue(venue)) {
                    new AuditDAO().log(host.getId(), "HOST", "VENUE_CREATE", "venue", venue.getId(), venue.getName());
                    request.getSession().setAttribute("hostVenueSuccess", "Venue listed.");
                }
            }
            response.sendRedirect(request.getContextPath() + "/host/dashboard.jsp");
        }
    }

    private User currentHost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        if (!user.isHost()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        return user;
    }

    private Venue readVenue(HttpServletRequest request, User host) throws IOException, ServletException {
        try {
            Venue venue = new Venue();
            venue.setName(request.getParameter("name").trim());
            venue.setDescription(request.getParameter("description"));
            venue.setLocation(request.getParameter("location").trim());
            venue.setEventType(request.getParameter("eventType").trim().toUpperCase());
            venue.setMaxCapacity(Integer.parseInt(request.getParameter("capacity")));
            venue.setHourlyRate(new BigDecimal(request.getParameter("rate")));
            venue.setAmenities(request.getParameter("amenities"));
            String imageUrl = request.getParameter("imageUrl");
            String uploaded = saveUpload(request);
            venue.setImageUrl(uploaded != null ? uploaded : imageUrl);
            venue.setAvailable(request.getParameter("available") != null);
            venue.setStatus("AVAILABLE");
            venue.setCreatedBy(null);
            venue.setHostId(host.getId());
            if (venue.getName().isEmpty() || venue.getLocation().isEmpty() || venue.getMaxCapacity() < 1
                    || venue.getHourlyRate().signum() < 0) {
                return null;
            }
            return venue;
        } catch (NumberFormatException | NullPointerException e) {
            return null;
        }
    }

    private String saveUpload(HttpServletRequest request) throws IOException, ServletException {
        Part part;
        try {
            part = request.getPart("photo");
        } catch (IllegalStateException | ServletException e) {
            return null;
        }
        if (part == null || part.getSize() == 0) {
            return null;
        }
        String contentType = part.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return null;
        }
        String submitted = Paths.get(part.getSubmittedFileName()).getFileName().toString();
        String ext = submitted.contains(".") ? submitted.substring(submitted.lastIndexOf('.')).toLowerCase() : ".jpg";
        if (!ext.matches("\\.(jpg|jpeg|png|webp|gif)")) {
            return null;
        }
        String fileName = "host-" + UUID.randomUUID() + ext;
        String uploadDir = getServletContext().getRealPath("/images");
        if (uploadDir == null) {
            return null;
        }
        File dir = new File(uploadDir);
        if (!dir.exists()) {
            dir.mkdirs();
        }
        part.write(new File(dir, fileName).getAbsolutePath());
        return "/images/" + fileName;
    }
}
