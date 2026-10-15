<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.math.BigDecimal,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    User host = (User) session.getAttribute("user");
    if (host == null || !host.isHost()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
VenueDAO venueDAO = new VenueDAO();
    BookingDAO bookingDAO = new BookingDAO();
    EventDAO eventDAO = new EventDAO();
    UserDAO userDAO = new UserDAO();
    NotificationDAO notificationDAO = new NotificationDAO();
    List<Venue> myVenues = venueDAO.getVenuesByHost(host.getId());
    List<Booking> myBookings = new java.util.ArrayList<Booking>();
    for (Venue v : myVenues) { myBookings.addAll(bookingDAO.getBookingsByVenue(v.getId()));
    }
BigDecimal hostRevenue = BigDecimal.ZERO;
    long hostPending = 0;
    for (Booking b : myBookings) { if ("APPROVED".equals(b.getStatus()) && b.getTotalAmount() != null) hostRevenue = hostRevenue.add(b.getTotalAmount());
    if ("PENDING".equals(b.getStatus())) hostPending++;
    }
long hostUnread = notificationDAO.unreadCount(host.getId(), "HOST");
    String okMsg = (String) session.getAttribute("hostVenueSuccess");
    session.removeAttribute("hostVenueSuccess");
    String errMsg = (String) session.getAttribute("hostVenueError");
    session.removeAttribute("hostVenueError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Host Dashboard - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    </head>
    <body class="host-page">
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <span style="color:#cbd5e1;margin-right:0.5rem;">
                        Hi,
                        <%= com.eventsphere.util.EscapeUtil.e(host.getFullName()) %>
                    </span>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/host/notifications.jsp" class="btn btn-outline">
                        Notifications
                        <% if (hostUnread > 0) { %>
                            (
                            <%= hostUnread %>
                            )
                        <% } %>
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container host-wrap">
            <div class="host-banner">
                <div>
                    <p class="host-eyebrow">
                        Host dashboard
                    </p>
                    <h1>
                        Welcome,
                        <%= com.eventsphere.util.EscapeUtil.e(host.getFullName()) %>
                    </h1>
                    <p class="host-sub">
                        <%= com.eventsphere.util.EscapeUtil.e(host.getEmail()) %>
                        &middot;
                        <%= myVenues.size() %>
                        venues,
                        <%= myBookings.size() %>
                        bookings
                    </p>
                </div>
                <div class="host-banner-actions">
                    <a href="${pageContext.request.contextPath}/host/venues" class="btn btn-primary">
                        + List a Venue
                    </a>
                </div>
            </div>
            <% if (okMsg != null) { %>
                <div class="host-toast host-toast-success">
                    <%= okMsg %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="host-toast host-toast-error">
                    <%= errMsg %>
                </div>
            <% } %>
            <section class="host-stats">
                <div class="host-stat">
                    <strong>
                        <%= myVenues.size() %>
                    </strong>
                    <span>
                        My venues
                    </span>
                </div>
                <div class="host-stat">
                    <strong>
                        <%= myBookings.size() %>
                    </strong>
                    <span>
                        Total bookings
                    </span>
                </div>
                <div class="host-stat">
                    <strong>
                        <%= hostPending %>
                    </strong>
                    <span>
                        Pending
                    </span>
                </div>
                <div class="host-stat">
                    <strong>
                        &#8377;
                        <%= hostRevenue %>
                    </strong>
                    <span>
                        Approved revenue
                    </span>
                </div>
            </section>
            <div class="host-layout">
                <section class="host-panel">
                    <div class="host-panel-head">
                        <h2>
                            My venues
                        </h2>
                        <a class="btn btn-primary btn-sm" href="${pageContext.request.contextPath}/host/venues">
                            + List a Venue
                        </a>
                    </div>
                    <% if (myVenues.isEmpty()) { %>
                        <div class="alert alert-info">
                            No venues yet. List your first venue to start receiving bookings.
                        </div>
                    <% } else { %>
                        <div class="host-venue-list">
                            <% for (Venue v : myVenues) { %>
                                <div class="host-venue-row">
                                    <img src="${pageContext.request.contextPath}<%= com.eventsphere.util.EscapeUtil.e(v.getImageUrl() == null || v.getImageUrl().isBlank() ? "/images/homepage-banner.jpg" : v.getImageUrl()) %>" alt=" <%= com.eventsphere.util.EscapeUtil.e(v.getName()) %>" onerror="this.src='${pageContext.request.contextPath}/images/homepage-banner.jpg'">
                                    <div>
                                        <strong>
                                            <%= com.eventsphere.util.EscapeUtil.e(v.getName()) %>
                                        </strong>
                                        <span>
                                            <%= com.eventsphere.util.EscapeUtil.e(v.getLocation()) %>
                                            &middot; Cap
                                            <%= v.getMaxCapacity() %>
                                            &middot; Rs.
                                            <%= v.getHourlyRate() %>
                                            /hr
                                        </span>
                                    </div>
                                    <span class="host-pill <%= v.isAvailable() ? "host-pill-on" : "host-pill-off" %>">
                                        <%= v.isAvailable() ? "Available" : "Unavailable" %>
                                    </span>
                                    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/host/venues?id=<%= v.getId() %>">
                                        Edit
                                    </a>
                                </div>
                            <% } %>
                        </div>
                    <% } %>
                </section>
                <section class="host-panel">
                    <div class="host-panel-head">
                        <h2>
                            Bookings for my venues
                        </h2>
                    </div>
                    <% if (myBookings.isEmpty()) { %>
                        <div class="alert alert-info">
                            No bookings yet.
                        </div>
                    <% } else { %>
                        <div class="host-table-scroll">
                            <table class="host-table">
                                <thead>
                                    <tr>
                                        <th>
                                            Booking
                                        </th>
                                        <th>
                                            Venue
                                        </th>
                                        <th>
                                            Event
                                        </th>
                                        <th>
                                            Date
                                        </th>
                                        <th>
                                            Total
                                        </th>
                                        <th>
                                            Status
                                        </th>
                                        <th>
                                            Placed On
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (Booking b : myBookings) { Event e = eventDAO.getEventById(b.getEventId());
                                        Venue v = venueDAO.getVenueById(b.getVenueId());
                                    %>
                                    <tr>
                                        <td>
                                            <strong>
                                                <%= b.getBookingNumber() %>
                                            </strong>
                                        </td>
                                        <td>
                                            <%= v == null ? "-" : com.eventsphere.util.EscapeUtil.e(v.getName()) %>
                                        </td>
                                        <td>
                                            <%= e == null ? "-" : com.eventsphere.util.EscapeUtil.e(e.getName()) %>
                                        </td>
                                        <td>
                                            <%= b.getBookingDate() %>
                                        </td>
                                        <td>
                                            Rs.
                                            <%= b.getTotalAmount() %>
                                        </td>
                                        <td>
                                            <span class="host-pill host-pill-<%= b.getStatus().toLowerCase() %>">
                                                <%= b.getStatus() %>
                                            </span>
                                        </td>
                                        <td>
                                            <%= com.eventsphere.util.FormatUtil.dt(b.getCreatedAt()) %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <p class="host-muted">
                        Approvals are handled by EventSphere admins.
                    </p>
                <% } %>
            </section>
        </div>
    </main>
</body>
</html>
