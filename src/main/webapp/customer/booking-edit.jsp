<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.eventsphere.model.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
Booking booking = (Booking) request.getAttribute("booking");
    Event event = (Event) request.getAttribute("event");
    Venue venue = (Venue) request.getAttribute("venue");
    if (booking == null || event == null || venue == null) { response.sendError(404);
    return;
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Edit
            <%= booking.getBookingNumber() %>
            - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
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
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container" style="padding-top:2rem; padding-bottom:3rem; max-width: 760px;">
            <h1>
                Edit
                <%= booking.getBookingNumber() %>
            </h1>
            <p style="color: var(--text-light);">
                <%= com.eventsphere.util.EscapeUtil.e(venue.getName()) %>
                &middot; Rs.
                <%= venue.getHourlyRate() %>
                /hour &middot; Cap
                <%= venue.getMaxCapacity() %>
                &middot; Status
                <%= booking.getStatus() %>
            </p>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <form method="post" action="${pageContext.request.contextPath}/bookings/edit?id=<%= booking.getId() %>" class="card" onsubmit="return validateBookingForm(this)">
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
                        <option<%= "WEDDING".equals(event.getEventType()) ? " selected" : "" %> >
                            WEDDING
                        </option>
                        <option<%= "CONFERENCE".equals(event.getEventType()) ? " selected" : "" %> >
                            CONFERENCE
                        </option>
                        <option<%= "PARTY".equals(event.getEventType()) ? " selected" : "" %> >
                            PARTY
                        </option>
                        <option<%= "CORPORATE".equals(event.getEventType()) ? " selected" : "" %> >
                            CORPORATE
                        </option>
                        <option<%= "OTHER".equals(event.getEventType()) ? " selected" : "" %> >
                            OTHER
                        </option>
                    </select>
                </div>
                <div class="search-form-row">
                    <div class="form-group">
                        <label for="bookingDate">
                            Date
                        </label>
                        <input id="bookingDate" name="bookingDate" type="date" required min="<%= java.time.LocalDate.now() %>" value=" <%= event.getEventDate() == null ? "" : event.getEventDate() %>">
                    </div>
                    <div class="form-group">
                        <label for="startTime">
                            Start time
                        </label>
                        <input id="startTime" name="startTime" type="time" required value="<%= event.getStartTime() == null ? "" : event.getStartTime() %>">
                    </div>
                    <div class="form-group">
                        <label for="endTime">
                            End time
                        </label>
                        <input id="endTime" name="endTime" type="time" required value="<%= event.getEndTime() == null ? "" : event.getEndTime() %>">
                    </div>
                    <div class="form-group">
                        <label for="expectedGuests">
                            Expected guests
                        </label>
                        <input id="expectedGuests" name="expectedGuests" type="number" min="1" max="<%= venue.getMaxCapacity() %>" required value=" <%= event.getExpectedGuests() %>">
                    </div>
                </div>
                <div class="form-group">
                    <label for="notes">
                        Notes
                    </label>
                    <textarea id="notes" name="notes" maxlength="2000" rows="4">
                        <%= event.getDescription() == null ? "" : com.eventsphere.util.EscapeUtil.e(event.getDescription()) %>
                    </textarea>
                </div>
                <div id="error-message" style="display: none;" class="alert alert-error">
                </div>
                <button type="submit" class="btn btn-primary">
                    Save Changes
                </button>
                <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-outline" style="margin-left: 0.75rem;">
                    Cancel
                </a>
            </form>
        </main>
        <script src="${pageContext.request.contextPath}/js/script.js">
        </script>
    </body>
</html>
