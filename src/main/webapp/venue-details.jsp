<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventsphere.model.Venue,com.eventsphere.model.Booking,com.eventsphere.model.Feedback" %>
<%@ page import="com.eventsphere.dao.FeedbackDAO" %>
<%@ page import="com.eventsphere.util.EscapeUtil" %>
<% Venue venue = (Venue) request.getAttribute("venue"); %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            <%= EscapeUtil.e(venue.getName()) %>
            - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body>
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
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                        All Venues
                    </a>
                    <%
                        Object user = session.getAttribute("user");
                        Object navRole = session.getAttribute("userRole");
                        if (user != null) {
                    %>
                        <span style="color: white; margin-right: 1rem;">
                            Welcome,
                            <%= EscapeUtil.e(session.getAttribute("userName")) %>
                        </span>
                        <% if ("ADMIN".equals(navRole)) { %>
                            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
                                Dashboard
                            </a>
                        <% } else if ("HOST".equals(navRole)) { %>
                            <a href="${pageContext.request.contextPath}/host/dashboard.jsp" class="btn btn-outline">
                                Host Panel
                            </a>
                        <% } else { %>
                            <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-outline">
                                My Bookings
                            </a>
                        <% } %>
                        <form action="${pageContext.request.contextPath}/logout" method="post" style="display: inline;">
                            <button type="submit" class="btn btn-primary">
                                Logout
                            </button>
                        </form>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
                            Login
                        </a>
                    <% } %>
                </div>
            </div>
        </nav>
<<<<<<< HEAD
        <main id="main" class="container" style="padding-top:2rem;">
=======
        <main class="container" style="padding-top:2rem;">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
            <% if (request.getParameter("feedbackSuccess") != null) { %>
                <div class="alert alert-success">
                    <%= EscapeUtil.e(request.getParameter("feedbackSuccess")) %>
                </div>
            <% } %>
            <% if (request.getParameter("feedbackError") != null) { %>
                <div class="alert alert-error">
                    <%= EscapeUtil.e(request.getParameter("feedbackError")) %>
                </div>
            <% } %>
            <div class="grid grid-2">
                <img src="${pageContext.request.contextPath}<%= EscapeUtil.e(venue.getImageUrl() == null ? "/images/homepage-banner.jpg" : venue.getImageUrl()) %>" alt="Venue image for <%= EscapeUtil.e(venue.getName()) %>" class="venue-image">
                <div class="card">
                    <h1>
                        <%= EscapeUtil.e(venue.getName()) %>
                    </h1>
                    <p>
                        <%= EscapeUtil.e(venue.getDescription()) %>
                    </p>
                    <p>
                        <strong>
                            Location:
                        </strong>
                        <%= EscapeUtil.e(venue.getLocation()) %>
                    </p>
                    <p>
                        <strong>
                            Event type:
                        </strong>
                        <%= EscapeUtil.e(venue.getEventType()) %>
                    </p>
                    <p>
                        <strong>
                            Capacity:
                        </strong>
                        <%= venue.getMaxCapacity() %>
                        guests
                    </p>
                    <p>
                        <strong>
                            Rate:
                        </strong>
                        Rs.
                        <%= venue.getHourlyRate() %>
                        /hour
                    </p>
                    <p>
                        <strong>
                            Amenities:
                        </strong>
                        <%= venue.getAmenities() == null ? "Not specified" : EscapeUtil.e(venue.getAmenities()) %>
                    </p>
                    <p>
                        <strong>
                            Status:
                        </strong>
                        <%= venue.isAvailable() ? "Available" : "Unavailable" %>
                    </p>
                    <%
                        boolean viewerIsAdmin = "ADMIN".equals(session.getAttribute("userRole"));
                        if (venue.isAvailable() && !viewerIsAdmin) {
                    %>
                        <a href="${pageContext.request.contextPath}/booking?venueId=<%= venue.getId() %>" class="btn btn-primary">
                            Book This Venue
                        </a>
                    <% } else if (viewerIsAdmin) { %>
                        <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-outline">
                            Manage bookings
                        </a>
                    <% } %>
                </div>
            </div>
            <section>
                <h2>
                    Availability
                </h2>
                <%
                    java.util.Set<java.time.LocalDate> bookedDates = new java.util.HashSet<java.time.LocalDate>();
                    for (com.eventsphere.model.Event ev : new com.eventsphere.dao.EventDAO().getEventsByVenue(venue.getId())) {
                if (ev.getEventDate() != null && !ev.getEventDate().isBefore(java.time.LocalDate.now())) bookedDates.add(ev.getEventDate());
                    }
            java.time.LocalDate calStart = java.time.LocalDate.now().withDayOfMonth(1);
                %>
                <div class="cal-grid">
                    <%
                        for (int m = 0;
                        m < 2;
                        m++) {
            java.time.LocalDate month = calStart.plusMonths(m);
                        java.time.LocalDate first = month.withDayOfMonth(1);
                        int lead = (first.getDayOfWeek().getValue() + 6) % 7;
                    %>
                    <div class="card cal-month">
                        <h3>
                            <%= month.getMonth() %>
                            <%= month.getYear() %>
                        </h3>
                        <div class="cal-days">
                            <span>
                                M
                            </span>
                            <span>
                                T
                            </span>
                            <span>
                                W
                            </span>
                            <span>
                                T
                            </span>
                            <span>
                                F
                            </span>
                            <span>
                                S
                            </span>
                            <span>
                                S
                            </span>
                        </div>
                        <div class="cal-cells">
                            <% for (int i = 0; i < lead; i++) { %>
                                <span class="cal-empty">
                                </span>
                            <% } %>
                            <%
                                for (int d = 1;
                                d <= month.lengthOfMonth();
                                d++) {
                    java.time.LocalDate date = month.withDayOfMonth(d);
                                boolean past = date.isBefore(java.time.LocalDate.now());
                                boolean booked = bookedDates.contains(date);
                            %>
                            <span class="cal-cell<%= booked ? " cal-booked" : "" %> <%= past ? " cal-past" : "" %>" title=" <%= date %> <%= booked ? " - booked" : "" %>">
                                <%= d %>
                            </span>
                        <% } %>
                    </div>
                </div>
            <% } %>
        </div>
        <p class="cal-legend">
            <span class="cal-cell cal-booked">
                ##
            </span>
            booked &nbsp;
            <span class="cal-cell">
                ##
            </span>
            free
        </p>
    </section>
    <section>
        <h2>
            Feedback
        </h2>
        <%
            FeedbackDAO feedbackDAO = new FeedbackDAO();
            double venueAvg = feedbackDAO.getAverageRatingByVenue(venue.getId());
            long venueCount = feedbackDAO.countByVenue(venue.getId());
            if (venueCount > 0) {
        %>
            <p class="venue-rating" style="font-size: 1.1rem;">
                ★
                <%= String.format("%.1f", venueAvg) %>
                average from
                <%= venueCount %>
                review
                <%= venueCount == 1 ? "" : "s" %>
            </p>
        <% } %>
        <%
            List<Feedback> feedbackList = feedbackDAO.getFeedbackByVenue(venue.getId());
            if (feedbackList.isEmpty()) {
        %>
            <p>
                No feedback yet.
            </p>
        <% } else { for (Feedback feedback : feedbackList) { %>
            <div class="card feedback-card">
                <strong>
                    <%= feedback.getRating() %>
                    /5
                </strong>
                <small style="color: var(--text-light);">
                    <%= com.eventsphere.util.FormatUtil.dt(feedback.getCreatedAt()) %>
                </small>
                <% if (feedback.getImageUrl() != null && !feedback.getImageUrl().isBlank()) { %>
                    <img src="${pageContext.request.contextPath}<%= EscapeUtil.e(feedback.getImageUrl()) %>" alt="Review photo" class="feedback-photo">
                <% } %>
                <p>
                    <%= EscapeUtil.e(feedback.getComment()) %>
                </p>
                <% if (feedback.getAdminReply() != null && !feedback.getAdminReply().isBlank()) { %>
                    <div class="feedback-reply">
                        <strong>
                            Host reply:
                        </strong>
                        <%= EscapeUtil.e(feedback.getAdminReply()) %>
                    </div>
                <% } else if (viewerIsAdmin) { %>
                    <form method="post" action="${pageContext.request.contextPath}/admin/feedback" class="feedback-reply-form">
                        <input type="hidden" name="id" value="<%= feedback.getId() %>">
                        <input type="hidden" name="returnTo" value="/venues?action=details&id=<%= venue.getId() %>">
                        <input type="text" name="reply" maxlength="2000" placeholder="Write a host reply..." required>
                        <button class="btn btn-outline btn-sm" type="submit">
                            Reply
                        </button>
                    </form>
                <% } %>
            </div>
        <% } } %>
        <% if (request.getAttribute("feedbackBookings") != null && !((List<Booking>) request.getAttribute("feedbackBookings")).isEmpty()) { %>
            <form method="post" action="${pageContext.request.contextPath}/feedback" enctype="multipart/form-data" class="card mt-3">
                <h3>
                    Leave feedback
                </h3>
                <input type="hidden" name="venueId" value="<%= venue.getId() %>">
                <div class="form-group">
                    <label for="bookingId">
                        Approved booking
                    </label>
                    <select id="bookingId" name="bookingId" required>
                        <% for (Booking booking : (List<Booking>) request.getAttribute("feedbackBookings")) { %>
                            <option value="<%= booking.getId() %>">
                                <%= booking.getBookingNumber() %>
                                -
                                <%= booking.getBookingDate() %>
                            </option>
                        <% } %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="rating">
                        Rating
                    </label>
                    <select id="rating" name="rating" required>
                        <option value="5">
                            5
                        </option>
                        <option value="4">
                            4
                        </option>
                        <option value="3">
                            3
                        </option>
                        <option value="2">
                            2
                        </option>
                        <option value="1">
                            1
                        </option>
                    </select>
                </div>
                <div class="form-group">
                    <label for="comment">
                        Comment
                    </label>
                    <textarea id="comment" name="comment" maxlength="2000" required>
                    </textarea>
                </div>
                <div class="form-group">
                    <label for="photo">
                        Photo (optional, max 5MB)
                    </label>
                    <input type="file" id="photo" name="photo" accept="image/*">
                </div>
                <button class="btn btn-primary" type="submit">
                    Submit feedback
                </button>
            </form>
        <% } %>
    </section>
</main>
</body>
</html>
