package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.FeedbackDAO;
import com.eventsphere.dao.NotificationDAO;
import com.eventsphere.model.Feedback;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - admin/host replies to customer
// reviews. The returnTo redirect is validated against a safe list
// so it cannot be abused to send users to outside websites.
@WebServlet("/admin/feedback")
public class AdminFeedbackServlet extends HttpServlet {
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    private String safeReturnTo(String back) {
        if (back != null && back.startsWith("/admin/") && !back.contains("..")) {
            return back;
        }
        if (back != null && back.startsWith("/venues?action=details&id=")) {
            try {
                Integer.parseInt(back.substring("/venues?action=details&id=".length()));
                return back;
            } catch (NumberFormatException ignored) {
            }
        }
        return "/admin/dashboard.jsp";
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String reply = request.getParameter("reply");
            if (reply != null && reply.length() <= 2000 && feedbackDAO.saveAdminReply(id, reply.trim())) {
                Object adminId = request.getSession(false).getAttribute("userId");
                new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                        "FEEDBACK_REPLY", "feedback", id, "Replied to feedback " + id);
                Feedback feedback = feedbackDAO.getFeedbackById(id);
                if (feedback != null) {
                    new NotificationDAO().create(feedback.getCustomerId(), "CUSTOMER", "Host replied to your review",
                            "A venue host replied to your review.", "/customer/feedback.jsp");
                }
                request.getSession().setAttribute("adminFeedbackSuccess", "Reply saved.");
            } else {
                request.getSession().setAttribute("adminFeedbackError", "Reply could not be saved.");
            }
        } catch (NumberFormatException ignored) {
            request.getSession().setAttribute("adminFeedbackError", "Invalid feedback selection.");
        }
        String back = safeReturnTo(request.getParameter("returnTo"));
        response.sendRedirect(request.getContextPath() + back);
    }
}
