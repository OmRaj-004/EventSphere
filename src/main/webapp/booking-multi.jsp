<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*" %>
<%
    User multiUser = (User) session.getAttribute("user");
    if (multiUser == null || !multiUser.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
List<Venue> multiVenues = (List<Venue>) request.getAttribute("venues");
    if (multiVenues == null || multiVenues.isEmpty()) { response.sendError(404);
    return;
    }
StringBuilder multiIds = new StringBuilder();
    for (int i = 0;
    i < multiVenues.size();
    i++) { if (i > 0) multiIds.append(',');
    multiIds.append(multiVenues.get(i).getId());
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Book Multiple Venues - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
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
        <main class="container" style="padding-top:2rem; padding-bottom:3rem;">
            <h1>
                Book
                <%= multiVenues.size() %>
                Venues Together
            </h1>
            <p style="color: var(--text-light);">
                One event request is created per venue for the same date and time. Venues that clash are skipped and reported.
            </p>
            <% if (request.getAttribute("error") != null) { %>
                <div class="alert alert-error">
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>
            <div class="grid grid-3" style="margin-bottom: 2rem;">
                <% for (Venue v : multiVenues) { %>
                    <div class="card">
                        <strong>
                            <%= v.getName() %>
                        </strong>
                        <br>
                        <span style="color: var(--text-light); font-size: 0.9rem;">
                            <%= v.getLocation() %>
                            &middot; Cap
                            <%= v.getMaxCapacity() %>
                            &middot; Rs.
                            <%= v.getHourlyRate() %>
                            /hr
                        </span>
                    </div>
                <% } %>
            </div>
            <form method="post" action="${pageContext.request.contextPath}/booking" class="card" onsubmit="return validateBookingForm(this)">
                <input type="hidden" name="venueIds" value="<%= multiIds %>">
                <div class="form-group">
                    <label for="eventName">
                        Event name
                    </label>
                    <input id="eventName" name="eventName" required maxlength="150">
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
                            Expected guests (per venue)
                        </label>
                        <input id="expectedGuests" name="expectedGuests" type="number" min="1" required>
                    </div>
                </div>
                <div class="form-group">
                    <label for="promoCode">
                        Promo code (optional, applied to each booking)
                    </label>
                    <input id="promoCode" name="promoCode" maxlength="30" placeholder="e.g. WELCOME10" style="text-transform:uppercase">
                </div>
                <div class="form-group">
                    <label for="notes">
                        Notes
                    </label>
                    <textarea id="notes" name="notes" maxlength="2000" rows="4">
                    </textarea>
                </div>
                <button type="submit" class="btn btn-primary">
                    Submit
                    <%= multiVenues.size() %>
                    Bookings
                </button>
            </form>
        </main>
<<<<<<< HEAD
        <script src="${pageContext.request.contextPath}/js/script.js">
=======
        <script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
        </script>
    </body>
</html>
