package com.eventsphere.servlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// EventSphere project (TYBCA) - handles logout.
// Destroys the HttpSession and deletes the "remember me" cookie
// (both in the browser and in the login_tokens table).
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        if (session != null) {
            session.invalidate();
        }

        if (request.getCookies() != null) {
            for (jakarta.servlet.http.Cookie cookie : request.getCookies()) {
                if ("remember_me".equals(cookie.getName()) && cookie.getValue() != null && cookie.getValue().contains(":")) {
                    new com.eventsphere.dao.LoginTokenDAO().deleteByHash(
                            com.eventsphere.util.TokenUtil.sha256(cookie.getValue().substring(cookie.getValue().indexOf(':') + 1)));
                    jakarta.servlet.http.Cookie dead = new jakarta.servlet.http.Cookie("remember_me", "");
                    dead.setPath(request.getContextPath().isEmpty() ? "/" : request.getContextPath());
                    dead.setMaxAge(0);
                    response.addCookie(dead);
                }
            }
        }

        response.sendRedirect(request.getContextPath() + "/");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
