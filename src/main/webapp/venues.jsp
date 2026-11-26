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
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Browse Venues - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=11">
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
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
                        <span class="nav-welcome">
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
                        <form action="${pageContext.request.contextPath}/logout" method="post" class="nav-logout-form">
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
        <main>
        <!-- Page Content -->
        <section id="main" class="main-section">
            <div class="container">
                <h2>
                    Available Venues
                </h2>
                <div class="search-form search-form-compact">
                    <form id="venueFilterForm" action="${pageContext.request.contextPath}/venues">
                        <div class="search-form-row">
                            <div class="form-group">
                                <label for="eventType">
                                    Event Type
                                </label>
                                <select id="eventType" name="eventType">
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
                                <input type="number" id="maxCapacity" name="maxCapacity" placeholder="Capacity" min="1">
                            </div>
                            <div class="form-group">
                                <label for="priceRange">
                                    Max Price/Hour
                                </label>
                                <input type="number" id="priceRange" name="priceRange" placeholder="Price" min="0" step="100">
                            </div>
                        </div>
                        <button type="submit" class="btn btn-primary">
                            Filter
                        </button>
                        <button type="button" class="btn btn-outline clear-filters-btn" onclick="clearFilters()">
                            Clear Filters
                        </button>
                    </form>
                </div>
                <div id="venueResults">
                <%
                    List<Venue> venues = (List<Venue>) request.getAttribute("venues");
                    if (venues != null && !venues.isEmpty()) {
                %>
                    <form id="multiBookForm" method="get" action="${pageContext.request.contextPath}/booking" class="multi-book-form">
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
                                    <svg class="venue-pin" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false"><path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
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
                                <div class="venue-capacity">
                                    Capacity:
                                    <%= venue.getMaxCapacity() %>
                                    guests
                                </div>
                                <label class="venue-pick">
                                    <input type="checkbox" class="venue-pick-box" value="<%= venue.getId() %>" onchange="updateMultiBooking()">
                                    Select for multi-booking
                                </label>
                                <a href="${pageContext.request.contextPath}/venues?action=details&id=<%= venue.getId() %>" class="btn btn-primary btn-block">
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
                </div>
    </div>
</section>
<!-- Footer -->
        </main>
<footer class="footer">
    <div class="footer-container">
        <p>
            &copy;
            <%= java.time.Year.now() %>
            EventSphere. All rights reserved.
        </p>
    </div>
</footer>
<script src="${pageContext.request.contextPath}/js/script.js?v=12">
</script>
</body>
</html>
