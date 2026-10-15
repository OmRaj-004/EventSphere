<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.math.BigDecimal,com.eventsphere.dao.*,com.eventsphere.model.*,com.eventsphere.util.EscapeUtil" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
VenueDAO venueDAO = new VenueDAO();
    UserDAO userDAO = new UserDAO();
    BookingDAO bookingDAO = new BookingDAO();
    EventDAO eventDAO = new EventDAO();
    long totalVenues = venueDAO.countVenues();
    long totalCustomers = userDAO.countCustomers();
    List<Booking> allBookings = bookingDAO.getAllBookings();
    List<Booking> pendingBookings = bookingDAO.getBookingsByStatus("PENDING");
    long totalBookings = allBookings.size();
    long pendingCount = bookingDAO.countByStatus("PENDING");
    long approvedCount = bookingDAO.countByStatus("APPROVED");
    long rejectedCount = bookingDAO.countByStatus("REJECTED");
    long cancelledCount = bookingDAO.countByStatus("CANCELLED");
    BigDecimal revenue = BigDecimal.ZERO;
    for (Booking b : allBookings) { if ("APPROVED".equals(b.getStatus()) && b.getTotalAmount() != null) revenue = revenue.add(b.getTotalAmount());
    }
List<Venue> allVenues = venueDAO.getAllVenues();
    BillDAO billDAO = new BillDAO();
    List<Bill> allBills = billDAO.getAllBills();
    List<User> dashCustomers = userDAO.getAllCustomers();
    List<User> dashHosts = userDAO.getAllHosts();
    String adminName = session.getAttribute("userName") == null ? "Admin" : String.valueOf(session.getAttribute("userName"));
    String flashSuccess = (String) session.getAttribute("adminBookingSuccess");
    session.removeAttribute("adminBookingSuccess");
    String flashError = (String) session.getAttribute("adminBookingError");
    session.removeAttribute("adminBookingError");
    long donutTotal = approvedCount + pendingCount + rejectedCount + cancelledCount;
    if (donutTotal == 0) donutTotal = 1;
    long pctApproved = Math.round(approvedCount * 100.0 / donutTotal);
    long pctPending = Math.round(pendingCount * 100.0 / donutTotal);
    long pctRejected = Math.round(rejectedCount * 100.0 / donutTotal);
    long pctCancelled = Math.max(0, 100 - pctApproved - pctPending - pctRejected);
    java.time.LocalDate today = java.time.LocalDate.now();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Admin Dashboard - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body class="admin-page">
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
<<<<<<< HEAD
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
=======
                    <img src="${pageContext.request.contextPath}/images/EventSphere Logo.png" alt="EventSphere" class="brand-logo">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                </a>
                <div class="auth-buttons">
                    <span style="color:#cbd5e1;margin-right:0.5rem;">
                        Hi,
                        <%= EscapeUtil.e(adminName) %>
                    </span>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-outline">
                        Bookings
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline">
                        Venues
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/analytics.jsp" class="btn btn-outline">
                        Analytics
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/notifications.jsp" class="btn btn-outline">
                        Notifications
                        <%
                            long adminUnread = new com.eventsphere.dao.NotificationDAO().unreadCount(((com.eventsphere.model.User) session.getAttribute("user")).getId(), "ADMIN");
                            if (adminUnread > 0) {
                        %>
                            (
                            <%= adminUnread %>
                            )
                        <% } %>
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/admins.jsp" class="btn btn-outline">
                        Admins
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container admin-wrap">
            <div class="dash-head">
                <div>
                    <p class="dash-eyebrow">
                        <%= today.getDayOfWeek() %>
                        ,
                        <%= today %>
                    </p>
                    <h1>
                        Admin Dashboard
                    </h1>
                    <p class="dash-sub">
                        Monitor venues, bookings and approvals at a glance.
                    </p>
                </div>
                <div class="dash-head-actions">
                    <button class="btn btn-outline" type="button" onclick="location.reload()">
                        &#8635; Refresh
                    </button>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                        + Add Venue
                    </a>
                </div>
            </div>
            <% if (flashSuccess != null) { %>
                <div class="toast toast-success" id="flashToast">
                    <%= flashSuccess %>
                </div>
            <% } else if (flashError != null) { %>
                <div class="toast toast-error" id="flashToast">
                    <%= flashError %>
                </div>
            <% } %>
            <%
                String extraSuccess = (String) session.getAttribute("adminFeedbackSuccess");
                session.removeAttribute("adminFeedbackSuccess");
                String extraError = (String) session.getAttribute("adminFeedbackError");
                session.removeAttribute("adminFeedbackError");
                if (extraSuccess != null) {
            %>
                <div class="toast toast-success">
                    <%= extraSuccess %>
                </div>
            <% } else if (extraError != null) { %>
                <div class="toast toast-error">
                    <%= extraError %>
                </div>
            <% } %>
            <section class="stat-grid">
                <button type="button" class="stat-card" data-goto="tab-venues">
                    <span class="stat-icon icon-indigo">
                        &#127978;
                    </span>
                    <span class="stat-body">
                        <strong>
                            <%= totalVenues %>
                        </strong>
                        <span>
                            Total venues
                        </span>
                    </span>
                    <span class="stat-link">
                        View &rsaquo;
                    </span>
                </button>
                <button type="button" class="stat-card" data-goto="tab-recent">
                    <span class="stat-icon icon-green">
                        &#128101;
                    </span>
                    <span class="stat-body">
                        <strong>
                            <%= totalCustomers %>
                        </strong>
                        <span>
                            Customers
                        </span>
                    </span>
                    <span class="stat-link">
                        View &rsaquo;
                    </span>
                </button>
                <button type="button" class="stat-card" data-goto="tab-recent">
                    <span class="stat-icon icon-amber">
                        &#128179;
                    </span>
                    <span class="stat-body">
                        <strong>
                            <%= totalBookings %>
                        </strong>
                        <span>
                            Total bookings
                        </span>
                    </span>
                    <span class="stat-link">
                        View &rsaquo;
                    </span>
                </button>
                <button type="button" class="stat-card stat-alert" data-goto="tab-pending">
                    <span class="stat-icon icon-red">
                        &#9201;
                    </span>
                    <span class="stat-body">
                        <strong>
                            <%= pendingCount %>
                        </strong>
                        <span>
                            Pending approvals
                        </span>
                    </span>
                    <span class="stat-link">
                        Review &rsaquo;
                    </span>
                </button>
            </section>
            <div class="dash-grid">
                <section class="panel">
                    <div class="tab-bar" role="tablist">
                        <button class="tab active" data-tab="tab-pending" role="tab">
                            Pending (
                            <%= pendingBookings.size() %>
                            )
                        </button>
                        <button class="tab" data-tab="tab-recent" role="tab">
                            Recent bookings
                        </button>
                        <button class="tab" data-tab="tab-venues" role="tab">
                            Venues
                        </button>
                        <button class="tab" data-tab="tab-bills" role="tab">
                            Bills (
                            <%= allBills.size() %>
                            )
                        </button>
                        <button class="tab" data-tab="tab-customers" role="tab">
                            Customers (
                            <%= dashCustomers.size() %>
                            )
                        </button>
                        <button class="tab" data-tab="tab-hosts" role="tab">
                            Hosts (
                            <%= dashHosts.size() %>
                            )
                        </button>
                    </div>
                    <div class="panel-tools">
                        <input type="search" id="dashSearch" placeholder="Search booking no, event or venue..." aria-label="Search bookings">
                        <select id="statusFilter" aria-label="Filter by status">
                            <option value="">
                                All statuses
                            </option>
                            <option value="PENDING">
                                Pending
                            </option>
                            <option value="APPROVED">
                                Approved
                            </option>
                            <option value="REJECTED">
                                Rejected
                            </option>
                            <option value="CANCELLED">
                                Cancelled
                            </option>
                        </select>
                    </div>
                    <div class="tab-pane active" id="tab-pending">
                        <% if (pendingBookings.isEmpty()) { %>
                            <div class="alert alert-success">
                                All caught up! No pending approvals.
                            </div>
                        <% } else { %>
                            <div class="table-scroll">
                                <table class="dash-table">
                                    <thead>
                                        <tr>
                                            <th>
                                                Booking
                                            </th>
                                            <th>
                                                Event
                                            </th>
                                            <th>
                                                Venue
                                            </th>
                                            <th>
                                                Date
                                            </th>
                                            <th>
                                                Total
                                            </th>
                                            <th>
                                                Placed On
                                            </th>
                                            <th>
                                                Decision
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%
                                            int n = 0;
                                            for (Booking b : pendingBookings) { if (n++ >= 10) break;
                                            Event e = eventDAO.getEventById(b.getEventId());
                                            Venue v = venueDAO.getVenueById(b.getVenueId());
                                        %>
                                        <tr data-search="<%= b.getBookingNumber() %> <%= e == null ? "" : EscapeUtil.e(e.getName()) %> <%= v == null ? "" : EscapeUtil.e(v.getName()) %> PENDING">
                                            <td>
                                                <strong>
                                                    <%= b.getBookingNumber() %>
                                                </strong>
                                            </td>
                                            <td>
                                                <%= e == null ? "-" : EscapeUtil.e(e.getName()) %>
                                            </td>
                                            <td>
                                                <%= v == null ? "-" : EscapeUtil.e(v.getName()) %>
                                            </td>
                                            <td>
                                                <%= b.getBookingDate() %>
                                            </td>
                                            <td>
                                                &#8377;
                                                <%= b.getTotalAmount() %>
                                            </td>
                                            <td class="nowrap">
                                                <%= com.eventsphere.util.FormatUtil.dt(b.getCreatedAt()) %>
                                            </td>
                                            <td>
                                                <div class="row-actions">
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/bookings" onsubmit="return confirmAction('Approve this booking?')">
                                                        <input type="hidden" name="id" value="<%= b.getId() %>">
                                                        <input type="hidden" name="action" value="approve">
                                                        <input type="hidden" name="returnTo" value="/admin/dashboard.jsp">
                                                        <button class="btn btn-success btn-sm" type="submit">
                                                            Approve
                                                        </button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/admin/bookings" onsubmit="return confirmAction('Reject this booking?')">
                                                        <input type="hidden" name="id" value="<%= b.getId() %>">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="returnTo" value="/admin/dashboard.jsp">
                                                        <button class="btn btn-danger btn-sm" type="submit">
                                                            Reject
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </div>
                <div class="tab-pane" id="tab-recent">
                    <% if (allBookings.isEmpty()) { %>
                        <div class="alert alert-info">
                            No bookings yet.
                        </div>
                    <% } else { %>
                        <div class="table-scroll">
                            <table class="dash-table" id="recentTable">
                                <thead>
                                    <tr>
                                        <th>
                                            Booking
                                        </th>
                                        <th>
                                            Event
                                        </th>
                                        <th>
                                            Venue
                                        </th>
                                        <th>
                                            Date
                                        </th>
                                        <th>
                                            Total
                                        </th>
                                        <th>
                                            Placed On
                                        </th>
                                        <th>
                                            Status
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        int m = 0;
                                        for (Booking b : allBookings) { if (m++ >= 8) break;
                                        Event e = eventDAO.getEventById(b.getEventId());
                                        Venue v = venueDAO.getVenueById(b.getVenueId());
                                    %>
                                    <tr data-search="<%= b.getBookingNumber() %> <%= e == null ? "" : EscapeUtil.e(e.getName()) %> <%= v == null ? "" : EscapeUtil.e(v.getName()) %> <%= b.getStatus() %>" data-status=" <%= b.getStatus() %>">
                                        <td>
                                            <strong>
                                                <%= b.getBookingNumber() %>
                                            </strong>
                                        </td>
                                        <td>
                                            <%= e == null ? "-" : EscapeUtil.e(e.getName()) %>
                                        </td>
                                        <td>
                                            <%= v == null ? "-" : EscapeUtil.e(v.getName()) %>
                                        </td>
                                        <td>
                                            <%= b.getBookingDate() %>
                                        </td>
                                        <td>
                                            &#8377;
                                            <%= b.getTotalAmount() %>
                                        </td>
                                        <td class="nowrap">
                                            <%= com.eventsphere.util.FormatUtil.dt(b.getCreatedAt()) %>
                                        </td>
                                        <td>
                                            <span class="pill pill-<%= b.getStatus().toLowerCase() %>">
                                                <%= b.getStatus() %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <p class="mt-2">
                        <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-outline btn-sm">
                            Open full booking list
                        </a>
                    </p>
                <% } %>
            </div>
            <div class="tab-pane" id="tab-venues">
                <% if (allVenues.isEmpty()) { %>
                    <div class="alert alert-info">
                        No venues yet.
                        <a href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                            Add the first one
                        </a>
                        .
                    </div>
                <% } else { %>
                    <div class="venue-mini-list">
                        <%
                            int k = 0;
                            for (Venue v : allVenues) { if (k++ >= 6) break;
                            User vOwner = v.getHostId() == null ? null : userDAO.getHostById(v.getHostId());
                        %>
                        <div class="venue-mini">
                            <div>
                                <strong>
                                    <%= EscapeUtil.e(v.getName()) %>
                                </strong>
                                <span>
                                    <%= EscapeUtil.e(v.getLocation()) %>
                                    &middot; Cap
                                    <%= v.getMaxCapacity() %>
                                    &middot; Owner:
                                    <%= vOwner == null ? "Admin" : ("Host " + EscapeUtil.e(vOwner.getFullName())) %>
                                    <%= v.getHostId() != null ? " (host-managed)" : "" %>
                                </span>
                            </div>
                            <div class="venue-mini-action">
                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/admin/venue-form.jsp?id=<%= v.getId() %>" title="<%= v.getHostId() != null ? "Host-owned venue: editing as admin override" : "Edit venue" %>">
                                    Edit
                                </a>
                            </div>
                            <div class="venue-mini-status">
                                <span class="pill <%= v.isAvailable() ? "pill-approved" : "pill-rejected" %>">
                                    <%= v.isAvailable() ? "Available" : "Unavailable" %>
                                </span>
                            </div>
                        </div>
                    <% } %>
                </div>
                <p class="mt-2">
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline btn-sm">
                        Manage venues
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/venue-form.jsp" class="btn btn-primary btn-sm">
                        + Add venue
                    </a>
                </p>
            <% } %>
        </div>
        <div class="tab-pane" id="tab-customers">
            <% if (dashCustomers.isEmpty()) { %>
                <div class="alert alert-info">
                    No customers yet.
                </div>
            <% } else { %>
                <div class="table-scroll">
                    <table class="dash-table">
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
                                    Joined
                                </th>
                                <th>
                                    Action
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User cu : dashCustomers) { %>
                                <tr data-search="<%= EscapeUtil.e(cu.getFullName()) %> <%= EscapeUtil.e(cu.getEmail()) %>">
                                    <td>
                                        <strong>
                                            <%= EscapeUtil.e(cu.getFullName()) %>
                                        </strong>
                                    </td>
                                    <td>
                                        <%= EscapeUtil.e(cu.getEmail()) %>
                                    </td>
                                    <td>
                                        <%= bookingDAO.getBookingsByCustomer(cu.getId()).size() %>
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
                <p class="mt-2">
                    <a href="${pageContext.request.contextPath}/admin/customers.jsp" class="btn btn-outline btn-sm">
                        Open full customer list
                    </a>
                </p>
            <% } %>
        </div>
        <div class="tab-pane" id="tab-hosts">
            <% if (dashHosts.isEmpty()) { %>
                <div class="alert alert-info">
                    No hosts yet.
                    <a href="${pageContext.request.contextPath}/admin/hosts.jsp">
                        Create one
                    </a>
                    .
                </div>
            <% } else { %>
                <div class="table-scroll">
                    <table class="dash-table">
                        <thead>
                            <tr>
                                <th>
                                    Name
                                </th>
                                <th>
                                    Email
                                </th>
                                <th>
                                    Venues
                                </th>
                                <th>
                                    Joined
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (User h : dashHosts) { %>
                                <tr data-search="<%= EscapeUtil.e(h.getFullName()) %> <%= EscapeUtil.e(h.getEmail()) %>">
                                    <td>
                                        <strong>
                                            <%= EscapeUtil.e(h.getFullName()) %>
                                        </strong>
                                    </td>
                                    <td>
                                        <%= EscapeUtil.e(h.getEmail()) %>
                                    </td>
                                    <td>
                                        <%= venueDAO.getVenuesByHost(h.getId()).size() %>
                                    </td>
                                    <td>
                                        <%= h.getCreatedAt() == null ? "-" : h.getCreatedAt().toLocalDate() %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <p class="mt-2">
                    <a href="${pageContext.request.contextPath}/admin/hosts.jsp" class="btn btn-outline btn-sm">
                        Manage hosts
                    </a>
                </p>
            <% } %>
        </div>
        <div class="tab-pane" id="tab-bills">
            <% if (allBills.isEmpty()) { %>
                <div class="alert alert-info">
                    No bills yet. Bills are created automatically with each booking.
                </div>
            <% } else { %>
                <div class="table-scroll">
                    <table class="dash-table" id="billsTable">
                        <thead>
                            <tr>
                                <th>
                                    Bill
                                </th>
                                <th>
                                    Booking
                                </th>
                                <th>
                                    Customer
                                </th>
                                <th>
                                    Venue
                                </th>
                                <th>
                                    Amount
                                </th>
                                <th>
                                    Balance
                                </th>
                                <th>
                                    Bill status
                                </th>
                                <th>
                                    Issued
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                for (Bill bl : allBills) { Booking bb = bookingDAO.getBookingById(bl.getBookingId());
                                User cu = userDAO.getCustomerById(bl.getCustomerId());
                                Venue bv = bb == null ? null : venueDAO.getVenueById(bb.getVenueId());
                                String cuName = cu == null ? ("#" + bl.getCustomerId()) : cu.getFullName();
                            %>
                            <tr data-search="<%= bl.getBillNumber() %> <%= bb == null ? "" : bb.getBookingNumber() %> <%= EscapeUtil.e(cuName) %> <%= bv == null ? "" : bv.getName() %> <%= bl.getStatus() %>" data-status=" <%= bl.getStatus() %>">
                                <td>
                                    <strong>
                                        <%= bl.getBillNumber() %>
                                    </strong>
                                </td>
                                <td>
                                    <%= bb == null ? "-" : bb.getBookingNumber() %>
                                </td>
                                <td>
                                    <%= EscapeUtil.e(cuName) %>
                                </td>
                                <td>
                                    <%= bv == null ? "-" : EscapeUtil.e(bv.getName()) %>
                                </td>
                                <td>
                                    &#8377;
                                    <%= bl.getSubtotal() %>
                                </td>
                                <td>
                                    &#8377;
                                    <%= bl.getBalanceDue() %>
                                </td>
                                <td>
                                    <span class="pill pill-<%= "ISSUED".equals(bl.getStatus()) ? "pending" : bl.getStatus().toLowerCase() %>">
                                        <%= bl.getStatus() %>
                                    </span>
                                </td>
                                <td>
                                    <%= com.eventsphere.util.FormatUtil.dt(bl.getCreatedAt()) %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </div>
</section>
<aside class="dash-side">
    <section class="panel">
        <h2 class="panel-title">
            Booking status
        </h2>
        <div class="donut-wrap">
            <div class="donut" style="background: conic-gradient(#10b981 0 <%= pctApproved %> %, #f59e0b <%= pctApproved %> % <%= pctApproved + pctPending %> %, #ef4444 <%= pctApproved + pctPending %> % <%= pctApproved + pctPending + pctRejected %> %, #94a3b8 <%= pctApproved + pctPending + pctRejected %> % 100%);">
                <span>
                    <%= totalBookings %>
                    <small>
                        bookings
                    </small>
                </span>
            </div>
            <ul class="legend">
                <li>
                    <i class="dot dot-green">
                    </i>
                    Approved
                    <strong>
                        <%= approvedCount %>
                    </strong>
                    (
                    <%= pctApproved %>
                    %)
                </li>
                <li>
                    <i class="dot dot-amber">
                    </i>
                    Pending
                    <strong>
                        <%= pendingCount %>
                    </strong>
                    (
                    <%= pctPending %>
                    %)
                </li>
                <li>
                    <i class="dot dot-red">
                    </i>
                    Rejected
                    <strong>
                        <%= rejectedCount %>
                    </strong>
                    (
                    <%= pctRejected %>
                    %)
                </li>
                <li>
                    <i class="dot dot-gray">
                    </i>
                    Cancelled
                    <strong>
                        <%= cancelledCount %>
                    </strong>
                    (
                    <%= pctCancelled %>
                    %)
                </li>
            </ul>
        </div>
    </section>
    <section class="panel">
        <h2 class="panel-title">
            Approved revenue
        </h2>
        <p class="revenue">
            &#8377;
            <%= revenue %>
        </p>
        <p class="muted">
            Across
            <%= approvedCount %>
            approved bookings.
        </p>
    </section>
    <section class="panel">
        <h2 class="panel-title">
            Quick actions
        </h2>
        <div class="quick-grid">
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/bookings.jsp">
                Manage bookings
            </a>
            <a class="btn btn-secondary" href="${pageContext.request.contextPath}/admin/venues.jsp">
                Manage venues
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/analytics.jsp">
                Analytics
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/customers.jsp">
                Customers
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/hosts.jsp">
                Hosts
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/promos.jsp">
                Promos
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/notifications.jsp">
                Notifications
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/admins.jsp">
                Admins
            </a>
            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                + Add venue
            </a>
        </div>
    </section>
</aside>
</div>
</main>
<<<<<<< HEAD
<script src="${pageContext.request.contextPath}/js/script.js?v=5">
=======
<script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
</script>
<script>
    document.querySelectorAll('.tab').forEach(function(btn){btn.addEventListener('click',function(){activateTab(btn.dataset.tab);
    });
    });
    document.querySelectorAll('.stat-card').forEach(function(card){card.addEventListener('click',function(){activateTab(card.dataset.goto);
    document.querySelector('.panel').scrollIntoView({behavior:'smooth',block:'start'});
    });
    });
    function activateTab(id){document.querySelectorAll('.tab').forEach(function(t){t.classList.toggle('active',t.dataset.tab===id);
    });
    document.querySelectorAll('.tab-pane').forEach(function(p){p.classList.toggle('active',p.id===id);
    });
    }
    var search=document.getElementById('dashSearch'),statusSel=document.getElementById('statusFilter');
    function applyFilter(){var q=(search.value||'').toLowerCase(),s=statusSel.value;
    document.querySelectorAll('.dash-table tbody tr').forEach(function(r){var okQ=!q||(r.dataset.search||'').toLowerCase().indexOf(q)>-1;
    var okS=!s||r.dataset.status===s||(r.dataset.search||'').indexOf(s)>-1&&!r.dataset.status;
    if(r.dataset.status){okS=!s||r.dataset.status===s;
    }r.style.display=(okQ&&okS)?'':'none';
    });
    }
    if(search){search.addEventListener('input',applyFilter);
    }if(statusSel){statusSel.addEventListener('change',applyFilter);
    }
    var toast=document.getElementById('flashToast');
    if(toast){setTimeout(function(){toast.classList.add('hide');
    },4500);
    };
</script>
</body>
</html>
