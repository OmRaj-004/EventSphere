package com.eventsphere.filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - protects customer pages and the
// booking endpoints. Guests without login go to the login page;
// logged-in admins or hosts get 403. Only CUSTOMER role passes.
@WebFilter({"/customer/*", "/booking", "/bookings"})
public class CustomerFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        RememberMeFilter.restore(httpRequest);
        jakarta.servlet.http.HttpSession session = httpRequest.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?redirect=" + httpRequest.getRequestURI());
            return;
        }
        if (!"CUSTOMER".equals(session.getAttribute("userRole"))) {
            httpResponse.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        chain.doFilter(request, response);
    }
}