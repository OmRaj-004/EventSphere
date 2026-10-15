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

// EventSphere project (TYBCA) - a filter runs BEFORE the servlet.
// This one blocks visitors with no login session from customer
// pages and sends them to the login page instead.
@WebFilter(urlPatterns = {"/booking", "/bookings", "/customer/*"})
public class AuthenticationFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;
        RememberMeFilter.restore(httpRequest);

        if (httpRequest.getSession(false) == null) {
            httpResponse.sendRedirect(httpRequest.getContextPath() + "/login?redirect=" + httpRequest.getRequestURI());
            return;
        }
        chain.doFilter(request, response);
    }
}