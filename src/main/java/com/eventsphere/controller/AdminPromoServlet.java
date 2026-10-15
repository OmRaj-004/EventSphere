package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.PromoDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - admin creates promo codes and
// enables/disables them. Every change is written to the audit log.
@WebServlet("/admin/promos")
public class AdminPromoServlet extends HttpServlet {
    private final PromoDAO promoDAO = new PromoDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Object adminId = request.getSession(false).getAttribute("userId");
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            try {
                String code = request.getParameter("code");
                int percent = Integer.parseInt(request.getParameter("percent"));
                int maxUses = Integer.parseInt(request.getParameter("maxUses"));
                if (code != null && !code.isBlank() && percent >= 1 && percent <= 90 && maxUses >= 1
                        && promoDAO.savePromo(code, percent, maxUses)) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            "PROMO_CREATE", "promocode", null, "Created promo " + code.trim().toUpperCase());
                    request.getSession().setAttribute("adminPromoSuccess", "Promo code created.");
                } else {
                    request.getSession().setAttribute("adminPromoError", "Invalid promo details (code, 1-90% off, max uses).");
                }
            } catch (NumberFormatException ignored) {
                request.getSession().setAttribute("adminPromoError", "Percent and max uses must be numbers.");
            }
        } else if ("toggle".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                boolean active = request.getParameter("active") != null;
                if (promoDAO.setActive(id, active)) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            active ? "PROMO_ENABLE" : "PROMO_DISABLE", "promocode", id, null);
                }
            } catch (NumberFormatException ignored) {
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/promos.jsp");
    }
}
