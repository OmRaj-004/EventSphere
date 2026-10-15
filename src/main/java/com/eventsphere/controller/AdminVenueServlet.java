package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.VenueDAO;
import com.eventsphere.model.Venue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.nio.file.Paths;
import java.util.UUID;

// EventSphere project (TYBCA) - admin adds/edits/deletes venues.
// Important rule: venues owned by a host (host_id set) are skipped
// here with 403 - only the host himself may change them. Venue
// photos can be uploaded (max 5MB, images only) or picked by URL.
@WebServlet("/admin/venues")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class AdminVenueServlet extends HttpServlet {
    private final VenueDAO venueDAO = new VenueDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws IOException, jakarta.servlet.ServletException {
        String value = request.getParameter("id");
        if (value != null && !value.isBlank()) {
            try {
                Venue venue = venueDAO.getVenueById(Integer.parseInt(value));
                if (venue == null) {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND);
                    return;
                }
                request.setAttribute("venue", venue);
            } catch (NumberFormatException exception) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                return;
            }
        }
        request.getRequestDispatcher("/admin/venue-form.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Object adminId = request.getSession(false) == null ? null : request.getSession(false).getAttribute("userId");
        String action = request.getParameter("action");
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            Venue existing = venueDAO.getVenueById(id);
            boolean override = existing != null && existing.getHostId() != null;
            if ("delete".equals(action) && venueDAO.deleteVenue(id)) {
                new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                        "VENUE_DELETE", "venue", id, override ? "Admin override on host-owned venue" : null);
            }
            if ("save".equals(action)) {
                Venue updated = readVenue(request, id);
                if (existing != null) {
                    updated.setHostId(existing.getHostId());
                }
                if (venueDAO.updateVenue(updated)) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            "VENUE_UPDATE", "venue", id, override ? "Admin override on host-owned venue: " + updated.getName() : updated.getName());
                }
            }
        } catch (NumberFormatException | NullPointerException | ServletException exception) {
            if ("save".equals(action)) {
                try {
                    Venue created = readVenue(request, 0);
                    if (venueDAO.addVenue(created)) {
                        new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                                "VENUE_CREATE", "venue", created.getId(), created.getName());
                    }
                } catch (NumberFormatException | NullPointerException | ServletException ignored) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST);
                    return;
                }
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/venues.jsp");
    }

    private Venue readVenue(HttpServletRequest request, int id) throws ServletException, IOException {
        Venue venue = new Venue();
        venue.setId(id);
        venue.setName(request.getParameter("name").trim());
        venue.setDescription(request.getParameter("description"));
        venue.setLocation(request.getParameter("location").trim());
        venue.setEventType(request.getParameter("eventType").trim().toUpperCase());
        venue.setMaxCapacity(Integer.parseInt(request.getParameter("capacity")));
        venue.setHourlyRate(new BigDecimal(request.getParameter("rate")));
        venue.setAmenities(request.getParameter("amenities"));
        String uploaded = saveUpload(request);
        venue.setImageUrl(uploaded != null ? uploaded : request.getParameter("imageUrl"));
        venue.setAvailable("AVAILABLE".equalsIgnoreCase(request.getParameter("status")) || request.getParameter("available") != null);
        venue.setStatus(request.getParameter("status") == null || request.getParameter("status").isBlank() ? "AVAILABLE" : request.getParameter("status"));
        venue.setCreatedBy((Integer) request.getSession(false).getAttribute("userId"));
        return venue;
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
        String fileName = "venue-" + UUID.randomUUID() + ext;
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
