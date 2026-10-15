package com.eventsphere.filter;

import com.eventsphere.dao.LoginTokenDAO;
import com.eventsphere.model.User;
import com.eventsphere.util.TokenUtil;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

// EventSphere project (TYBCA) - implements "remember me".
// If there is no logged-in session but the browser sent a valid
// remember_me cookie, the matching login_tokens row is looked up
// and the session is rebuilt, so the user stays logged in for
// 30 days. The static restore() helper is also called by the
// role filters, because filter execution order is not guaranteed.
@WebFilter(urlPatterns = "/*")
public class RememberMeFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        restore((HttpServletRequest) request);
        chain.doFilter(request, response);
    }

    public static void restore(HttpServletRequest httpRequest) {
        HttpSession session = httpRequest.getSession(false);
        if ((session == null || session.getAttribute("user") == null) && httpRequest.getCookies() != null) {
            for (Cookie cookie : httpRequest.getCookies()) {
                if ("remember_me".equals(cookie.getName()) && cookie.getValue() != null && cookie.getValue().contains(":")) {
                    String rawToken = cookie.getValue().substring(cookie.getValue().indexOf(':') + 1);
                    LoginTokenDAO.RememberedLogin login = new LoginTokenDAO().consume(TokenUtil.sha256(rawToken));
                    if (login != null) {
                        HttpSession fresh = httpRequest.getSession(true);
                        User user = login.user;
                        fresh.setAttribute("user", user);
                        fresh.setAttribute("userId", user.getId());
                        fresh.setAttribute("userEmail", user.getEmail());
                        fresh.setAttribute("userName", user.getFullName());
                        fresh.setAttribute("userRole", user.getRole());
                    }
                    break;
                }
            }
        }
    }
}
