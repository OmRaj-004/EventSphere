package com.eventsphere.controller;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.UserDAO;
import com.eventsphere.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - admin creates and removes host
// (venue owner) accounts. Host passwords are BCrypt-hashed exactly
// like customer passwords. Deleting a host keeps their venues
// listed (host_id becomes empty).
@WebServlet("/admin/hosts")
public class AdminHostServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Object adminId = request.getSession(false).getAttribute("userId");
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            String name = trim(request.getParameter("fullName"));
            String email = trim(request.getParameter("email"));
            String password = request.getParameter("password");
            if (name == null || name.length() < 2 || email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
                    || password == null || password.length() < 6 || userDAO.emailExists(email.toLowerCase())) {
                request.getSession().setAttribute("adminHostError", "Invalid details or email already registered.");
            } else {
                String hash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
                if (userDAO.registerUser(new User(name, email.toLowerCase(), hash, "HOST"))) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            "HOST_CREATE", "host", null, "Created host " + email.toLowerCase());
                    request.getSession().setAttribute("adminHostSuccess", "Host account created.");
                } else {
                    request.getSession().setAttribute("adminHostError", "Host could not be created.");
                }
            }
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                if (userDAO.deleteHost(id)) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            "HOST_DELETE", "host", id, null);
                    request.getSession().setAttribute("adminHostSuccess", "Host removed.");
                }
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/hosts.jsp");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
