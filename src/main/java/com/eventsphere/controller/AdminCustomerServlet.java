package com.eventsphere.controller;

import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.UserDAO;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

// EventSphere project (TYBCA) - admin removes customer accounts.
// Deleting a customer also removes their bookings, bills and reviews
// through database cascade rules, so the confirm dialog warns first.
// Admins can never delete their own account through this endpoint.
@WebServlet("/admin/customers")
public class AdminCustomerServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Object adminId = request.getSession(false).getAttribute("userId");
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            if (adminId instanceof Integer && ((Integer) adminId) == id) {
                request.getSession().setAttribute("adminCustomerError", "You cannot remove your own admin account.");
            } else if (userDAO.deleteCustomerCascade(id)) {
                new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                        "CUSTOMER_DELETE", "customer", id, null);
                request.getSession().setAttribute("adminCustomerSuccess", "Customer removed with all their data.");
            } else {
                request.getSession().setAttribute("adminCustomerError", "Customer could not be removed.");
            }
        } catch (NumberFormatException ignored) {
            request.getSession().setAttribute("adminCustomerError", "Invalid customer selection.");
        }
        response.sendRedirect(request.getContextPath() + "/admin/customers.jsp");
    }
}
