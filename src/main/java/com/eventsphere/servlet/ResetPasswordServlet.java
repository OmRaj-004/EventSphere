package com.eventsphere.servlet;

import com.eventsphere.dao.PasswordResetDAO;
import com.eventsphere.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import at.favre.lib.crypto.bcrypt.BCrypt;

// EventSphere project (TYBCA) - step 2 of password reset.
// Validates the token from the link (one use only, must not be
// expired), then saves the new BCrypt-hashed password in the
// correct role table (admin/customer/host).
@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final PasswordResetDAO resetDAO = new PasswordResetDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("token", request.getParameter("token"));
        request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String rawToken = request.getParameter("token");
        String password = request.getParameter("password");
        String confirm = request.getParameter("confirmPassword");

        if (rawToken == null || rawToken.isBlank()) {
            request.setAttribute("error", "Reset link is missing. Request a new one.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }
        if (password == null || password.length() < 6 || !password.equals(confirm)) {
            request.setAttribute("token", rawToken);
            request.setAttribute("error", "Password must be at least 6 characters and match the confirmation.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        PasswordResetDAO.ResetTicket ticket = resetDAO.consume(com.eventsphere.util.TokenUtil.sha256(rawToken.trim()));
        if (ticket == null) {
            request.setAttribute("error", "This reset link is invalid, expired, or already used.");
            request.getRequestDispatcher("/reset-password.jsp").forward(request, response);
            return;
        }

        String hash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        if (userDAO.updatePasswordForRole(ticket.email, ticket.role, hash)) {
            request.setAttribute("success", "Password updated. You can now log in.");
        } else {
            request.setAttribute("error", "Could not update the password. Please try again.");
        }
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}
