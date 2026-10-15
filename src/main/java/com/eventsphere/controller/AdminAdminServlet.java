package com.eventsphere.controller;

import at.favre.lib.crypto.bcrypt.BCrypt;
import com.eventsphere.dao.AuditDAO;
import com.eventsphere.dao.UserDAO;
import com.eventsphere.model.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

// EventSphere project (TYBCA) - lets an admin create more admin
// accounts and remove them. All admins are equal: any admin can
// manage the admin list, except nobody can remove their own
// account while logged in with it.
@WebServlet("/admin/admins")
public class AdminAdminServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        if (request.getSession(false) == null || !"ADMIN".equals(request.getSession(false).getAttribute("userRole"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return;
        }
        Object adminId = request.getSession(false).getAttribute("userId");
        String action = request.getParameter("action");
        if ("create".equals(action)) {
            String name = trim(request.getParameter("fullName"));
            String email = trim(request.getParameter("email"));
            String password = request.getParameter("password");
            if (name == null || name.length() < 2 || email == null || !email.matches("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$")
                    || password == null || password.length() < 6 || userDAO.emailExists(email.toLowerCase())) {
                request.getSession().setAttribute("adminAdminError", "Invalid details or email already registered.");
            } else {
                String hash = BCrypt.withDefaults().hashToString(12, password.toCharArray());
                if (userDAO.registerUser(new User(name, email.toLowerCase(), hash, "ADMIN"))) {
                    new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                            "ADMIN_CREATE", "admin", null, "Created admin " + email.toLowerCase());
                    request.getSession().setAttribute("adminAdminSuccess", "Admin account created.");
                } else {
                    request.getSession().setAttribute("adminAdminError", "Admin could not be created.");
                }
            }
        } else if ("delete".equals(action)) {
            try {
                int id = Integer.parseInt(request.getParameter("id"));
                if (adminId instanceof Integer && ((Integer) adminId) == id) {
                    request.getSession().setAttribute("adminAdminError", "You cannot remove your own admin account.");
                } else {
                    List<User> admins = userDAO.getAllAdmins();
                    if (admins.size() <= 1) {
                        request.getSession().setAttribute("adminAdminError", "The last admin account cannot be removed.");
                    } else if (userDAO.deleteAdmin(id)) {
                        new AuditDAO().log(adminId instanceof Integer ? (Integer) adminId : null, "ADMIN",
                                "ADMIN_DELETE", "admin", id, null);
                        request.getSession().setAttribute("adminAdminSuccess", "Admin removed.");
                    } else {
                        request.getSession().setAttribute("adminAdminError", "Admin could not be removed.");
                    }
                }
            } catch (NumberFormatException ignored) {
                request.getSession().setAttribute("adminAdminError", "Invalid admin selection.");
            }
        }
        response.sendRedirect(request.getContextPath() + "/admin/admins.jsp");
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }
}
