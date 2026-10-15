package com.eventsphere.servlet;

import com.eventsphere.dao.PasswordResetDAO;
import com.eventsphere.dao.UserDAO;
import com.eventsphere.model.User;
import com.eventsphere.util.TokenUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;

// EventSphere project (TYBCA) - step 1 of password reset.
// The user enters email + account type; if the account exists we
// create a random single-use token (valid 30 minutes) and share
// the reset link (by email once SMTP is configured, server log
// until then). Same reply either way, so attackers cannot probe
// which emails are registered.
@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        resetDAO.purgeExpired();
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String role = normalizeRole(request.getParameter("role"));

        if (email == null || email.isBlank() || role == null) {
            request.setAttribute("error", "Email and account type are required.");
            request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
            return;
        }

        User user = userDAO.getUserByEmailAndRole(email.trim().toLowerCase(), role);
        if (user != null) {
            String rawToken = TokenUtil.randomToken();
            resetDAO.create(user.getEmail(), user.getRole(), TokenUtil.sha256(rawToken),
                    LocalDateTime.now().plusMinutes(30));
            String resetLink = request.getRequestURL().toString().replace(request.getServletPath(), "")
                    + "/reset-password?token=" + rawToken;
            boolean emailed = com.eventsphere.util.MailUtil.send(user.getEmail(), "EventSphere password reset",
                    "Use this link within 30 minutes to choose a new password:\n" + resetLink);
            if (!emailed) {
                // No SMTP configured: token is server-logged so support can
                // relay it, and a matching in-app notice is unnecessary here
                // because the account owner is logged out by definition.
                getServletContext().log("Password reset token for " + user.getEmail() + " (" + user.getRole() + "): " + resetLink);
            }
        }

        request.setAttribute("success", "If an account exists for that email, a reset link was sent (valid 30 minutes).");
        request.getRequestDispatcher("/forgot-password.jsp").forward(request, response);
    }

    private String normalizeRole(String role) {
        if (role == null || role.isBlank()) {
            return null;
        }
        String normalized = role.trim().toUpperCase();
        if ("ADMIN".equals(normalized) || "CUSTOMER".equals(normalized) || "HOST".equals(normalized)) {
            return normalized;
        }
        return null;
    }
}
