package com.eventsphere.servlet;

import com.eventsphere.dao.NotificationDAO;
import com.eventsphere.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Marks notifications read. Works for every role (uses the session role),
 * keeping each role's notification center intact.
 */
// EventSphere project (TYBCA) - marks inbox notifications as read.
// Works for every role because it always uses the logged-in
// session's own user id and role, then returns to that role's
// notification center page.
@WebServlet("/notifications")
public class NotificationServlet extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User user = session == null ? null : (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        String id = request.getParameter("read");
        if (id != null) {
            try {
                notificationDAO.markRead(Integer.parseInt(id), user.getId(), user.getRole());
            } catch (NumberFormatException ignored) {
            }
        } else if ("all".equals(request.getParameter("do"))) {
            notificationDAO.markAllRead(user.getId(), user.getRole());
        }
        String back = request.getParameter("back");
        if ("/customer/notifications.jsp".equals(back) || "/admin/notifications.jsp".equals(back)
                || "/host/notifications.jsp".equals(back)) {
            response.sendRedirect(request.getContextPath() + back);
            return;
        }
        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/notifications.jsp");
        } else if (user.isHost()) {
            response.sendRedirect(request.getContextPath() + "/host/notifications.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/notifications.jsp");
        }
    }
}
