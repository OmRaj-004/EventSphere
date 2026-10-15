package com.eventsphere.servlet;

import com.eventsphere.dao.UserDAO;
import com.eventsphere.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import at.favre.lib.crypto.bcrypt.BCrypt;

// EventSphere project (TYBCA) - handles new customer registration.
// Validates name/email/password on the server, rejects duplicate
// emails, hashes the password with BCrypt and saves a CUSTOMER row.
// Public registration can never create admin or host accounts.
@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        
        String errorMessage = validateInput(fullName, email, password, confirmPassword);
        
        if (errorMessage != null) {
            request.setAttribute("error", errorMessage);
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        if (userDAO.emailExists(email)) {
            request.setAttribute("error", "Email already registered.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }
        
        String passwordHash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
        User newUser = new User(fullName.trim(), email.trim().toLowerCase(), passwordHash, "CUSTOMER");
        
        if (userDAO.registerUser(newUser)) {
            request.setAttribute("success", "Registration successful! You can now login.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }
    
    private String validateInput(String fullName, String email, String password, String confirmPassword) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "Full name is required.";
        }
        
        if (email == null || email.trim().isEmpty()) {
            return "Email is required.";
        }
        
        if (!email.matches("^[A-Za-z0-9+_.-]+@(.+)$")) {
            return "Invalid email format.";
        }
        
        if (password == null || password.length() < 6) {
            return "Password must be at least 6 characters long.";
        }
        
        if (!password.equals(confirmPassword)) {
            return "Passwords do not match.";
        }
        
        return null;
    }
}
