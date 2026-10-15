<%-- EventSphere project (TYBCA) - home page: hero with venue search, live platform statistics, popular venues from the database, about section and contact form. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List" %>
<%@ page import="com.eventsphere.model.Venue" %>
<%@ page import="com.eventsphere.dao.VenueDAO" %>
<%@ page import="com.eventsphere.util.EscapeUtil" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            EventSphere - Event & Venue Booking Platform
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=3">
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
                        <a href="${pageContext.request.contextPath}/#venues">
                            Venues
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/#about">
                            About Us
                        </a>
                    </li>
                    <li>
                        <a href="${pageContext.request.contextPath}/#contact">
                            Contact
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
        <!-- Hero Section with Background Image -->
        <section class="hero" style="background-image: url('${pageContext.request.contextPath}/images/EventSphere%20background.png');">
            <div class="hero-overlay" aria-hidden="true">
            </div>
            <div class="hero-content">
                <div class="hero-badge">
                    <span class="badge-dot">
                    </span>
                    <span>
                        Trusted by 10,000+ event organizers
                    </span>
                </div>
                <h1 class="hero-title">
                    Find The Perfect Venue
                    <br>
                    For Your Next Event
                </h1>
                <p class="hero-subtitle">
                    Discover premium venues for weddings, conferences, parties, and more. Book with confidence.
                </p>
                <div class="hero-cta">
                    <%
                        Object heroUser = session.getAttribute("user");
                        Object heroRole = session.getAttribute("userRole");
                        if (heroUser != null && "ADMIN".equals(heroRole)) {
                    %>
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-primary">
                            Open Admin Dashboard
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-outline">
                            Review Bookings
                        </a>
                    <% } else if (heroUser != null) { %>
                        <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-primary">
                            My Bookings
                        </a>
                        <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                            Browse Venues
                        </a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/venues" class="btn btn-primary">
                            Browse Venues
                        </a>
                        <a href="${pageContext.request.contextPath}/register" class="btn btn-outline">
                            Create Free Account
                        </a>
                    <% } %>
                </div>
                <!-- Search Form Integrated in Hero -->
                <form class="hero-search" action="${pageContext.request.contextPath}/venues" onsubmit="searchVenues(event)">
                    <div class="hero-search-row">
                        <div class="hero-search-field">
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
                                <option value="OTHER">
                                    Other
                                </option>
                            </select>
                        </div>
                        <div class="hero-search-field">
                            <label for="maxCapacity">
                                Guests
                            </label>
                            <input type="number" id="maxCapacity" name="maxCapacity" placeholder="e.g. 100" min="1" max="5000">
                        </div>
                        <div class="hero-search-field">
                            <label for="priceRange">
                                Budget (&#8377;/hr)
                            </label>
                            <input type="number" id="priceRange" name="priceRange" placeholder="e.g. 5000" min="0" step="500">
                        </div>
                        <div class="hero-search-field">
                            <label for="eventDate">
                                Event Date
                            </label>
                            <input type="date" id="eventDate" name="eventDate">
                        </div>
                        <div class="hero-search-action">
                            <button type="submit" class="btn btn-primary hero-search-btn">
                                <span>
                                    Search Venues
                                </span>
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"/>
                                </svg>
                            </button>
                        </div>
                    </div>
                </form>
                <!-- Trust Indicators (live platform data) -->
                <%
                    long heroVenues = new com.eventsphere.dao.VenueDAO().countVenues();
                    long heroBookings = new com.eventsphere.dao.BookingDAO().countAllBookings();
                    double heroAvg = new com.eventsphere.dao.FeedbackDAO().getOverallAverageRating();
                    long heroReviews = new com.eventsphere.dao.FeedbackDAO().countAllFeedback();
                %>
                <div class="hero-stats">
                    <div class="stat">
                        <strong class="stat-number">
                            <%= heroVenues %>
                            +
                        </strong>
                        <span class="stat-label">
                            Venues
                        </span>
                    </div>
                    <div class="stat-divider">
                    </div>
                    <div class="stat">
                        <strong class="stat-number">
                            <%= heroBookings %>
                            +
                        </strong>
                        <span class="stat-label">
                            Events Booked
                        </span>
                    </div>
                    <div class="stat-divider">
                    </div>
                    <div class="stat">
                        <strong class="stat-number">
                            <%= heroReviews == 0 ? "-★" : String.format("%.1f★", heroAvg) %>
                        </strong>
                        <span class="stat-label">
                            Avg Rating (
                            <%= heroReviews %>
                            )
                        </span>
                    </div>
                    <div class="stat-divider">
                    </div>
                    <div class="stat">
                        <strong class="stat-number">
                            24/7
                        </strong>
                        <span class="stat-label">
                            Support
                        </span>
                    </div>
                </div>
            </div>
        </section>
        <!-- Popular Venues Section -->
        <section id="venues">
            <div class="container">
                <div class="section-header">
                    <h2>
                        Popular Venues
                    </h2>
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                        View All Venues
                    </a>
                </div>
                <%
                    List<Venue> popularVenues = new com.eventsphere.dao.VenueDAO().getAllVenues();
                    com.eventsphere.dao.FeedbackDAO homeRatingDAO = new com.eventsphere.dao.FeedbackDAO();
                    if (popularVenues != null && !popularVenues.isEmpty()) {
                %>
                    <div class="grid grid-3">
                        <%
                            int count = 0;
                            for (Venue venue : popularVenues) {
                        if (count >= 6) break;
                            // Show max 6 on home page
                        double homeAvg = homeRatingDAO.getAverageRatingByVenue(venue.getId());
                            long homeCount = homeRatingDAO.countByVenue(venue.getId());
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
                                <% if (homeCount > 0) { %>
                                    <div class="venue-rating">
                                        ★
                                        <%= String.format("%.1f", homeAvg) %>
                                        <span>
                                            (
                                            <%= homeCount %>
                                            )
                                        </span>
                                    </div>
                                <% } %>
                                <div class="venue-amenities">
                                    <%= venue.getAmenities() != null ? EscapeUtil.e(venue.getAmenities()) : "No amenities listed" %>
                                </div>
                                <div class="venue-rate">
                                    ₹
                                    <%= String.format("%,.0f", venue.getHourlyRate()) %>
                                    /hour
                                </div>
                                <a href="${pageContext.request.contextPath}/venues?action=details&id=<%= venue.getId() %>" class="btn btn-primary" style="width: 100%;">
                                    View Details
                                </a>
                            </div>
                        </div>
                        <% count++; } %>
                    </div>
                <% } else { %>
                    <div class="alert alert-info" style="text-align: center; padding: 3rem;">
                        No venues available at the moment.
                        <a href="${pageContext.request.contextPath}/venues" style="color: var(--primary-color);">
                            Check back later
                        </a>
                    </div>
                <% } %>
            </div>
        </section>
        <!-- About Us Section -->
        <section id="about">
            <div class="container">
                <h2>
                    About EventSphere
                </h2>
                <div class="grid grid-2" style="margin-top: 2rem; align-items: center;">
                    <div>
                        <p style="font-size: 1.1rem; line-height: 1.8; color: var(--text-dark);">
                            EventSphere is your one-stop platform for finding and booking the perfect venue for any event. Whether you're planning a wedding, corporate conference, or private party, we connect you with premium venues that match your needs and budget.
                        </p>
                        <p style="margin-top: 1rem; font-size: 1.1rem; line-height: 1.8; color: var(--text-dark);">
                            Our platform makes event planning simple and hassle-free with secure bookings, competitive pricing, and verified venue information.
                        </p>
                    </div>
                    <div style="text-align: center;">
                        <div style="display: inline-flex; align-items: center; justify-content: center; width: 120px; height: 120px; border-radius: 50%; background: linear-gradient(135deg, var(--primary-color), var(--primary-dark)); color: white; font-size: 3rem; box-shadow: 0 20px 40px rgba(99, 102, 241, 0.3);">
                            🎯
                        </div>
                    </div>
                </div>
            </div>
        </section>
        <!-- Contact Section -->
        <section id="contact">
            <div class="container">
                <h2>
                    Contact Us
                </h2>
                <div class="grid grid-2" style="margin-top: 2rem; gap: 3rem;">
                    <div class="card" style="background: linear-gradient(135deg, var(--gray-lighter) 0%, white 100%);">
                        <h3 style="margin-bottom: 1.5rem; color: var(--text-dark);">
                            Get in Touch
                        </h3>
                        <div style="display: flex; flex-direction: column; gap: 1rem;">
                            <div style="display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <div style="width: 44px; height: 44px; border-radius: 10px; background: linear-gradient(135deg, var(--primary-color), var(--primary-light)); display: flex; align-items: center; justify-content: center; color: white;">
                                    ✉️
                                </div>
                                <div>
                                    <strong style="color: var(--text-dark);">
                                        Email
                                    </strong>
                                    <p style="margin: 0; color: var(--text-light); font-size: 0.95rem;">
                                        support@eventsphere.com
                                    </p>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <div style="width: 44px; height: 44px; border-radius: 10px; background: linear-gradient(135deg, var(--success-color), #34d399); display: flex; align-items: center; justify-content: center; color: white;">
                                    👤
                                </div>
                                <div>
                                    <strong style="color: var(--text-dark);">
                                        Name
                                    </strong>
                                    <p style="margin: 0; color: var(--text-light); font-size: 0.95rem;">
                                        Omraj Chaudhary
                                    </p>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <div style="width: 44px; height: 44px; border-radius: 10px; background: linear-gradient(135deg, var(--secondary-color), #fbbf24); display: flex; align-items: center; justify-content: center; color: white;">
                                    📞
                                </div>
                                <div>
                                    <strong style="color: var(--text-dark);">
                                        Phone
                                    </strong>
                                    <p style="margin: 0; color: var(--text-light); font-size: 0.95rem;">
                                        +91 8421 68766
                                    </p>
                                </div>
                            </div>
                            <div style="display: flex; align-items: center; gap: 0.75rem; padding: 1rem; background: white; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.05);">
                                <div style="width: 44px; height: 44px; border-radius: 10px; background: linear-gradient(135deg, var(--danger-color), #f87171); display: flex; align-items: center; justify-content: center; color: white;">
                                    📍
                                </div>
                                <div>
                                    <strong style="color: var(--text-dark);">
                                        Address
                                    </strong>
                                    <p style="margin: 0; color: var(--text-light); font-size: 0.95rem;">
                                        410511 Kuran, Pune, Maharashtra
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="card">
                        <h3 style="margin-bottom: 1.5rem; color: var(--text-dark);">
                            Send a Message
                        </h3>
                        <% if ("sent".equals(request.getParameter("contact"))) { %>
                            <div class="alert alert-success">
                                Thanks! Your message has been received. We will reply within 24 hours.
                            </div>
                        <% } else if ("error".equals(request.getParameter("contact"))) { %>
                            <div class="alert alert-error">
                                Please fill all fields correctly (message needs at least 10 characters).
                            </div>
                        <% } %>
                        <form class="search-form" method="post" action="${pageContext.request.contextPath}/contact">
                            <div class="form-group">
                                <label for="contactName">
                                    Your Name
                                </label>
                                <input type="text" id="contactName" name="contactName" placeholder="Your Name" required maxlength="100" autocomplete="name">
                            </div>
                            <div class="form-group">
                                <label for="contactEmail">
                                    Your Email
                                </label>
                                <input type="email" id="contactEmail" name="contactEmail" placeholder="Your Email" required autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="contactMessage">
                                    Your Message
                                </label>
                                <textarea id="contactMessage" name="contactMessage" placeholder="Your Message" rows="4" required maxlength="2000">
                                </textarea>
                            </div>
                            <div id="error-message" style="display: none;" class="alert alert-error">
                            </div>
                            <button type="submit" class="btn btn-primary" style="width: 100%;">
                                Send Message
                            </button>
                        </form>
                    </div>
                </div>
            </div>
        </section>
        <!-- Footer -->
        <footer class="footer">
            <div class="footer-container">
                <div class="footer-content">
                    <div class="footer-section">
                        <h3>
                            EventSphere
                        </h3>
                        <p>
                            Your premier event venue booking platform
                        </p>
                    </div>
                    <div class="footer-section">
                        <h3>
                            Quick Links
                        </h3>
                        <ul>
                            <li>
                                <a href="#venues">
                                    Browse Venues
                                </a>
                            </li>
                            <li>
                                <a href="#about">
                                    About Us
                                </a>
                            </li>
                            <li>
                                <a href="#contact">
                                    Contact
                                </a>
                            </li>
                        </ul>
                    </div>
                    <div class="footer-section">
                        <h3>
                            For Hosts
                        </h3>
                        <ul>
                            <% if ("ADMIN".equals(navRole)) { %>
                                <li>
                                    <a href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                                        List Your Venue
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/admin/bookings.jsp">
                                        Manage Bookings
                                    </a>
                                </li>
                            <% } else if (user != null) { %>
                                <li>
                                    <a href="${pageContext.request.contextPath}/#contact">
                                        List Your Venue
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/customer/dashboard.jsp">
                                        Manage Bookings
                                    </a>
                                </li>
                            <% } else { %>
                                <li>
                                    <a href="${pageContext.request.contextPath}/login">
                                        List Your Venue
                                    </a>
                                </li>
                                <li>
                                    <a href="${pageContext.request.contextPath}/login">
                                        Manage Bookings
                                    </a>
                                </li>
                            <% } %>
                        </ul>
                    </div>
                </div>
                <hr style="border: none; border-top: 1px solid #374151; margin: 2rem 0;">
                <p>
                    &copy;
                    <%= java.time.Year.now() %>
                    EventSphere. All rights reserved.
                </p>
            </div>
        </footer>
        <script src="${pageContext.request.contextPath}/js/script.js">
        </script>
    </body>
</html>
