package com.eventsphere.servlet;

import com.eventsphere.dao.FeedbackDAO;
import com.eventsphere.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// EventSphere project (TYBCA) - lets a customer delete their own
// review. The delete query also matches customer_id, so nobody can
// delete somebody else's review by guessing its id.
@WebServlet("/feedback/delete")
public class FeedbackDeleteServlet extends HttpServlet {
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
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
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            if (feedbackDAO.deleteOwnFeedback(id, user.getId())) {
                session.setAttribute("feedbackDeleteSuccess", "Review deleted.");
            } else {
                session.setAttribute("feedbackDeleteError", "Review could not be deleted.");
            }
        } catch (NumberFormatException ignored) {
            session.setAttribute("feedbackDeleteError", "Invalid review selection.");
        }
        response.sendRedirect(request.getContextPath() + "/customer/feedback.jsp");
    }
}
