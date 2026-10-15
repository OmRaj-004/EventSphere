package com.eventsphere.servlet;

import com.eventsphere.dao.FeedbackDAO;
import com.eventsphere.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.util.UUID;

// EventSphere project (TYBCA) - customers submit venue reviews here.
// Only logged-in customers can post, and only for their own
// APPROVED bookings (one review per booking). An optional photo
// (max 5MB) can be uploaded with the review.
@WebServlet("/feedback")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class FeedbackServlet extends HttpServlet {
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        jakarta.servlet.http.HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!user.isCustomer()) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        String venueId = request.getParameter("venueId");
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            int rating = Integer.parseInt(request.getParameter("rating"));
            String comment = request.getParameter("comment");
            boolean validComment = comment != null && comment.length() <= 2000;
            String photoPath = savePhoto(request);
            boolean saved = validComment && feedbackDAO.addEligibleFeedback(user.getId(), bookingId, rating, comment.trim(), photoPath);
            String message = saved ? "feedbackSuccess=Feedback+submitted" : "feedbackError=Unable+to+submit+feedback";
            response.sendRedirect(request.getContextPath() + "/venues?action=details&id=" + venueId + "&" + message);
        } catch (NumberFormatException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (ServletException exception) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }

    private String savePhoto(HttpServletRequest request) throws IOException, ServletException {
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
        String fileName = "review-" + UUID.randomUUID() + ext;
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