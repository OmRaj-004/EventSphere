package com.eventsphere.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Handles the public "Contact Us" form. No login required (public feature).
 * Currently acknowledges receipt; wire JavaMail here when SMTP is configured.
 */
// EventSphere project (TYBCA) - handles the public "Contact Us"
// form on the home page. Validates the message and, since no mail
// server is configured, records it in the server log for support
// to read (see MailUtil for enabling real email delivery).
@WebServlet("/contact")
public class ContactServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/#contact");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = trim(request.getParameter("contactName"));
        String email = trim(request.getParameter("contactEmail"));
        String message = trim(request.getParameter("contactMessage"));

        if (name == null || name.length() < 2 || name.length() > 100
                || email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
                || message == null || message.length() < 10 || message.length() > 2000) {
            response.sendRedirect(request.getContextPath() + "/?contact=error#contact");
            return;
        }

        getServletContext().log("Contact message from " + name + " <" + email + ">: " + message);
        response.sendRedirect(request.getContextPath() + "/?contact=sent#contact");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
