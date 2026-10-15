<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.eventsphere.model.Venue" %>
<%@ page import="com.eventsphere.model.Event" %>
<%@ page import="com.eventsphere.util.EscapeUtil" %>
<%
    Venue venue = (Venue) request.getAttribute("venue");
    Event event = (Event) request.getAttribute("event");
    if (event == null) event = new Event();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Book
            <%= venue.getName() %>
            - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                        Browse Venues
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-outline">
                        My Bookings
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display: inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main id="main" class="container" style="padding-top:2rem;">
            <h1>
                Book
                <%= EscapeUtil.e(venue.getName()) %>
            </h1>
            <p>
                <%= EscapeUtil.e(venue.getLocation()) %>
                | Capacity
                <%= venue.getMaxCapacity() %>
                | Rs.
                <%= venue.getHourlyRate() %>
                /hour
            </p>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline mb-3">
                ← Back to Venues
            </a>
            <form id="bookingForm" method="post" action="${pageContext.request.contextPath}/booking" class="card" data-hourly-rate="<%= venue.getHourlyRate() %>" onsubmit="return validateBookingForm(this)">
                <input type="hidden" name="venueId" value="<%= venue.getId() %>">
                <div class="form-group">
                    <label for="eventName">
                        Event name
                    </label>
                    <input id="eventName" name="eventName" required maxlength="150" value="<%= event.getName() == null ? "" : com.eventsphere.util.EscapeUtil.e(event.getName()) %>">
                </div>
                <div class="form-group">
                    <label for="eventType">
                        Event type
                    </label>
                    <select id="eventType" name="eventType" required>
                        <option value="">
                            Select type
                        </option>
                        <option>
                            WEDDING
                        </option>
                        <option>
                            CONFERENCE
                        </option>
                        <option>
                            PARTY
                        </option>
                        <option>
                            CORPORATE
                        </option>
                        <option>
                            OTHER
                        </option>
                    </select>
                </div>
                <div class="search-form-row">
                    <div class="form-group">
                        <label for="bookingDate">
                            Date
                        </label>
                        <input id="bookingDate" name="bookingDate" type="date" required min="<%= java.time.LocalDate.now() %>">
                    </div>
                    <div class="form-group">
                        <label for="startTime">
                            Start time
                        </label>
                        <input id="startTime" name="startTime" type="time" required>
                    </div>
                    <div class="form-group">
                        <label for="endTime">
                            End time
                        </label>
                        <input id="endTime" name="endTime" type="time" required>
                    </div>
                    <div class="form-group">
                        <label for="expectedGuests">
                            Expected guests
                        </label>
                        <input id="expectedGuests" name="expectedGuests" type="number" min="1" max="<%= venue.getMaxCapacity() %>" required>
                    </div>
                </div>
                <div class="search-form-row">
                    <div class="form-group">
                        <label for="promoCode">
                            Promo code (optional)
                        </label>
                        <input id="promoCode" name="promoCode" maxlength="30" placeholder="e.g. WELCOME10" style="text-transform:uppercase">
                    </div>
                </div>
                <div class="form-group">
                    <label for="notes">
                        Notes
                    </label>
                    <textarea id="notes" name="notes" maxlength="2000" rows="4">
                    </textarea>
                </div>
                <div class="price-estimate" id="priceEstimate" hidden>
                </div>
                <button type="submit" class="btn btn-primary">
                    Submit Booking
                </button>
            </form>
        </main>
        <script src="${pageContext.request.contextPath}/js/script.js">
        </script>
    </body>
</html>
