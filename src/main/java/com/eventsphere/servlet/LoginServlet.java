package com.eventsphere.servlet;

import com.eventsphere.dao.LoginTokenDAO;
import com.eventsphere.dao.UserDAO;
import com.eventsphere.model.User;
import com.eventsphere.util.TokenUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.time.LocalDateTime;
import at.favre.lib.crypto.bcrypt.BCrypt;

// EventSphere project (TYBCA) - handles user login.
// doGet shows the login page (three forms: admin/customer/host).
// doPost checks email + BCrypt password in the selected role's
// table, creates the HttpSession, and redirects each role to its
// own dashboard. Optional "remember me" stores a login cookie.
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String requestedRole = normalizeRole(request.getParameter("role"));
        
        if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Step 1: find the account in the selected role's table.
        User user = userDAO.getUserByEmailAndRole(email.trim().toLowerCase(), requestedRole);
        
        if (user == null) {
            request.setAttribute("error", "Invalid email or password for the selected role.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Step 2: compare the typed password with the stored BCrypt hash.
        // (Passwords are never stored or compared in plain text.)
        if (!BCrypt.verifyer().verify(password.toCharArray(), user.getPasswordHash()).verified) {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }
        
        // Step 3: login OK - create the session and remember who/which role.
        HttpSession session = request.getSession();
        request.changeSessionId();
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("userEmail", user.getEmail());
        session.setAttribute("userName", user.getFullName());
        session.setAttribute("userRole", user.getRole());

        if (request.getParameter("rememberMe") != null) {
            issueRememberMeCookie(request, response, user);
        }

        if (user.isAdmin()) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        } else if (user.isHost()) {
            response.sendRedirect(request.getContextPath() + "/host/dashboard.jsp");
        } else {
            response.sendRedirect(request.getContextPath() + "/customer/dashboard.jsp");
        }
    }

    public static void issueRememberMeCookie(HttpServletRequest request, HttpServletResponse response, User user) {
        String rawToken = TokenUtil.randomToken();
        LocalDateTime expires = LocalDateTime.now().plusDays(30);
        if (new LoginTokenDAO().create(user.getId(), user.getRole(), TokenUtil.sha256(rawToken), expires)) {
            Cookie cookie = new Cookie("remember_me", user.getRole() + ":" + rawToken);
            cookie.setHttpOnly(true);
            cookie.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
            cookie.setMaxAge(30 * 24 * 60 * 60);
            response.addCookie(cookie);
        }
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
