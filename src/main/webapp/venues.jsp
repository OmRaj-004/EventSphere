<%-- EventSphere project (TYBCA) - browse venues page: filter form, venue cards with ratings, multi-venue selection and pagination. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventsphere.model.Venue" %>
<%@ page import="com.eventsphere.dao.FeedbackDAO" %>
<%@ page import="com.eventsphere.util.EscapeUtil" %>
<%! private final FeedbackDAO venueRatingDAO = new FeedbackDAO(); %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Browse Venues - EventSphere
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
        <!-- Navigation Bar -->
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
<<<<<<< HEAD
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
=======
                    <img src="${pageContext.request.contextPath}/images/EventSphere Logo.png" alt="EventSphere" class="brand-logo">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                </a>
                <ul class="nav-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/">
                            Home
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/venues">
                            Venues
                        </a>
                    </li>
                </ul>
                <div class="auth-buttons">
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
                        <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">
                            Login
                        </a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">
                            Register
                        </a>
                    <% } %>
                </div>
            </div>
        </nav>
        <!-- Page Content -->
<<<<<<< HEAD
        <section id="main" style="padding: 2rem;">
=======
        <section style="padding: 2rem;">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
            <div class="container">
                <h2>
                    Available Venues
                </h2>
                <div class="search-form" style="margin-bottom: 2rem;">
<<<<<<< HEAD
                    <form id="venueFilterForm" action="${pageContext.request.contextPath}/venues">
=======
                    <form action="${pageContext.request.contextPath}/venues" onsubmit="searchVenues(event)">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                        <div class="search-form-row">
                            <div class="form-group">
                                <label for="eventType">
                                    Event Type
                                </label>
<<<<<<< HEAD
                                <select id="eventType" name="eventType">
=======
                                <select id="eventType">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                                    <option value="">
                                        All Types
                                    </option>
                                    <option value="WEDDING">
                                        Wedding
                                    </option>
                                    <option value="CONFERENCE">
                                        Conference
                                    </option>
                                    <option value="PARTY">
                                        Party
                                    </option>
                                    <option value="CORPORATE">
                                        Corporate
                                    </option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="maxCapacity">
                                    Min Capacity
                                </label>
<<<<<<< HEAD
                                <input type="number" id="maxCapacity" name="maxCapacity" placeholder="Capacity" min="1">
=======
                                <input type="number" id="maxCapacity" placeholder="Capacity" min="1">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                            </div>
                            <div class="form-group">
                                <label for="priceRange">
                                    Max Price/Hour
                                </label>
<<<<<<< HEAD
                                <input type="number" id="priceRange" name="priceRange" placeholder="Price" min="0" step="100">
=======
                                <input type="number" id="priceRange" placeholder="Price" min="0" step="100">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            Filter
                        </button>
                        <button type="button" class="btn btn-outline" onclick="clearFilters()" style="margin-left: 1rem;">
                            Clear Filters
                        </button>
                    </form>
                </div>
<<<<<<< HEAD
                <div id="venueResults">
=======
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                <%
                    List<Venue> venues = (List<Venue>) request.getAttribute("venues");
                    if (venues != null && !venues.isEmpty()) {
                %>
                    <form id="multiBookForm" method="get" action="${pageContext.request.contextPath}/booking" style="margin-bottom: 1rem;">
                        <input type="hidden" name="venueIds" id="multiVenueIds" value="">
                        <button type="submit" id="multiBookBtn" class="btn btn-secondary" style="display: none;" onclick="return submitMultiBooking(event)">
                            Book Selected Together
                        </button>
                    </form>
                    <div class="grid grid-3">
                        <%
                            for (Venue venue : venues) {
                            double avgRating = venueRatingDAO.getAverageRatingByVenue(venue.getId());
                            long ratingCount = venueRatingDAO.countByVenue(venue.getId());
                        %>
                        <div class="card venue-card">
                            <img src="<%= request.getContextPath() + EscapeUtil.e(venue.getImageUrl() != null ? venue.getImageUrl() : "/images/homepage-banner.jpg") %>" alt=" <%= EscapeUtil.e(venue.getName()) %>" class="venue-image">
                            <div class="venue-details">
                                <div class="venue-name">
                                    <%= EscapeUtil.e(venue.getName()) %>
                                </div>
                                <div class="venue-location">
                                    📍
                                    <%= EscapeUtil.e(venue.getLocation()) %>
                                </div>
                                <% if (ratingCount > 0) { %>
                                    <div class="venue-rating">
                                        ★
                                        <%= String.format("%.1f", avgRating) %>
                                        <span>
                                            (
                                            <%= ratingCount %>
                                            review
                                            <%= ratingCount == 1 ? "" : "s" %>
                                            )
                                        </span>
                                    </div>
                                <% } else { %>
                                    <div class="venue-rating venue-rating-none">
                                        No reviews yet
                                    </div>
                                <% } %>
                                <div class="venue-amenities">
                                    <%= venue.getAmenities() != null ? EscapeUtil.e(venue.getAmenities()) : "No amenities" %>
                                </div>
                                <div class="venue-rate">
                                    ₹
                                    <%= String.format("%.2f", venue.getHourlyRate()) %>
                                    /hour
                                </div>
                                <div style="font-size: 0.9rem; color: var(--text-light); margin-bottom: 1rem;">
                                    Capacity:
                                    <%= venue.getMaxCapacity() %>
                                    guests
                                </div>
                                <label class="venue-pick">
                                    <input type="checkbox" class="venue-pick-box" value="<%= venue.getId() %>" onchange="updateMultiBooking()">
                                    Select for multi-booking
                                </label>
                                <a href="${pageContext.request.contextPath}/venues?action=details&id=<%= venue.getId() %>" class="btn btn-primary" style="width: 100%;">
                                    View Details
                                </a>
                            </div>
                        </div>
                    <% } %>
                </div>
                <%
                    int currentPage = request.getAttribute("currentPage") == null ? 1 : (Integer) request.getAttribute("currentPage");
                    int totalPages = request.getAttribute("totalPages") == null ? 1 : (Integer) request.getAttribute("totalPages");
                    boolean filtering = Boolean.TRUE.equals(request.getAttribute("filtering"));
                    if (!filtering && totalPages > 1) {
                        String qs = request.getQueryString() == null ? "" : java.util.regex.Matcher.quoteReplacement(request.getQueryString().replaceAll("&?page=\\d+", ""));
                    if (!qs.isEmpty() && !qs.startsWith("&")) qs = "&" + qs;
                %>
                <div class="pager">
                    <% if (currentPage > 1) { %>
                        <a class="btn btn-outline btn-sm" href="?page=<%= currentPage - 1 %> <%= qs %>">
                            &larr; Prev
                        </a>
                    <% } %>
                    <span>
                        Page
                        <%= currentPage %>
                        of
                        <%= totalPages %>
                    </span>
                    <% if (currentPage < totalPages) { %>
                        <a class="btn btn-outline btn-sm" href="?page=<%= currentPage + 1 %> <%= qs %>">
                            Next &rarr;
                        </a>
                    <% } %>
                </div>
            <% } %>
        <% } else { %>
            <div class="alert alert-info">
                No venues found matching your criteria.
                <a href="${pageContext.request.contextPath}/venues">
                    Clear filters
                </a>
            </div>
        <% } %>
<<<<<<< HEAD
                </div>
=======
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </div>
</section>
<!-- Footer -->
<footer class="footer">
    <div class="footer-container">
        <p>
            &copy;
            <%= java.time.Year.now() %>
            EventSphere. All rights reserved.
        </p>
    </div>
</footer>
<<<<<<< HEAD
<script src="${pageContext.request.contextPath}/js/script.js">
=======
<script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
</script>
</body>
</html>
