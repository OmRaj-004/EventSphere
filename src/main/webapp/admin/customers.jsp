<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.math.BigDecimal,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
UserDAO userDAO = new UserDAO();
    BookingDAO bookingDAO = new BookingDAO();
    List<User> customers = userDAO.getAllCustomers();
    String okMsg = (String) session.getAttribute("adminCustomerSuccess"); session.removeAttribute("adminCustomerSuccess");
    String errMsg = (String) session.getAttribute("adminCustomerError"); session.removeAttribute("adminCustomerError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Customers - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    </head>
    <body class="bk-page">
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
                        Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/analytics.jsp" class="btn btn-outline">
                        Analytics
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container bk-wrap">
            <div class="bk-head">
                <div>
                    <p class="bk-eyebrow">
                        User management
                    </p>
                    <h1>
                        Customers
                    </h1>
                    <p class="bk-sub">
                        <%= customers.size() %>
                        registered customers.
                    </p>
                </div>
            </div>
            <% if (okMsg != null) { %>
                <div class="bk-toast bk-toast-success">
                    <%= com.eventsphere.util.EscapeUtil.e(okMsg) %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="bk-toast bk-toast-error">
                    <%= com.eventsphere.util.EscapeUtil.e(errMsg) %>
                </div>
            <% } %>
            <section class="bk-panel">
                <div class="bk-tools">
                    <div class="bk-search">
                        <input type="search" id="custAdminSearch" placeholder="Search name or email..." aria-label="Search customers">
                    </div>
                </div>
                <% if (customers.isEmpty()) { %>
                    <div class="alert alert-info">
                        No customers yet.
                    </div>
                <% } else { %>
                    <div class="bk-table-scroll">
                        <table class="bk-table" id="custTable">
                            <colgroup>
                                <col style="width:24%">
                                <col style="width:26%">
                                <col style="width:10%">
                                <col style="width:13%">
                                <col style="width:13%">
                                <col style="width:14%">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>
                                        Name
                                    </th>
                                    <th>
                                        Email
                                    </th>
                                    <th>
                                        Bookings
                                    </th>
                                    <th>
                                        Total spent
                                    </th>
                                    <th>
                                        Joined
                                    </th>
                                    <th>
                                        Action
                                    </th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    for (User cu : customers) { List<Booking> cb = bookingDAO.getBookingsByCustomer(cu.getId());
                                    BigDecimal spent = BigDecimal.ZERO;
                                    for (Booking b : cb) { if (b.getTotalAmount() != null) spent = spent.add(b.getTotalAmount());
                                    }
                                %>
                                <tr data-search="<%= com.eventsphere.util.EscapeUtil.e(cu.getFullName().toLowerCase()) %> <%= com.eventsphere.util.EscapeUtil.e(cu.getEmail().toLowerCase()) %>">
                                    <td>
                                        <strong>
                                            <%= com.eventsphere.util.EscapeUtil.e(cu.getFullName()) %>
                                        </strong>
                                    </td>
                                    <td>
                                        <%= com.eventsphere.util.EscapeUtil.e(cu.getEmail()) %>
                                    </td>
                                    <td>
                                        <%= cb.size() %>
                                    </td>
                                    <td>
                                        Rs.
                                        <%= spent %>
                                    </td>
                                    <td>
                                        <%= cu.getCreatedAt() == null ? "-" : cu.getCreatedAt().toLocalDate() %>
                                    </td>
                                    <td>
                                        <form method="post" action="${pageContext.request.contextPath}/admin/customers" onsubmit="return confirmAction('Remove this customer? All their bookings, bills and reviews will be deleted too.')" style="display:inline;">
                                            <input type="hidden" name="id" value="<%= cu.getId() %>">
                                            <button class="btn btn-danger btn-sm" type="submit">
                                                Remove
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            <% } %>
        </section>
    </main>
    <script>
        document.getElementById('custAdminSearch').addEventListener('input', function() {
        var q = this.value.toLowerCase();
        document.querySelectorAll('#custTable tbody tr').forEach(function(r) {
        r.style.display = (!q || (r.dataset.search || '').indexOf(q) > -1) ? '' : 'none';
        });
        });
    </script>
</body>
</html>
