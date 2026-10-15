<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.eventsphere.model.*" %>
<%
    User host = (User) session.getAttribute("user");
    if (host == null || !host.isHost()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
Venue formVenue = (Venue) request.getAttribute("venue");
    boolean isEdit = formVenue != null && formVenue.getId() > 0;
    String vName = isEdit && formVenue.getName() != null ? formVenue.getName() : "";
    String vDesc = isEdit && formVenue.getDescription() != null ? formVenue.getDescription() : "";
    String vLoc = isEdit && formVenue.getLocation() != null ? formVenue.getLocation() : "";
    String vType = isEdit && formVenue.getEventType() != null ? formVenue.getEventType() : "";
    String vCap = isEdit ? String.valueOf(formVenue.getMaxCapacity()) : "";
    String vRate = isEdit && formVenue.getHourlyRate() != null ? String.valueOf(formVenue.getHourlyRate()) : "";
    String vAmen = isEdit && formVenue.getAmenities() != null ? formVenue.getAmenities() : "";
    String vImg = isEdit && formVenue.getImageUrl() != null ? formVenue.getImageUrl() : "";
    boolean vAvail = !isEdit || formVenue.isAvailable();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            <%= isEdit ? "Edit Venue" : "List a Venue" %>
            - EventSphere
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
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/host/dashboard.jsp" class="btn btn-outline">
                        Dashboard
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
                        <%= isEdit ? "Edit venue" : "New venue" %>
                    </p>
                    <h1>
                        <%= isEdit ? "Edit Venue" : "List a Venue" %>
                    </h1>
                    <p class="host-sub">
                        Fields marked * are required.
                    </p>
                </div>
                <div class="host-banner-actions">
                    <a href="${pageContext.request.contextPath}/host/dashboard.jsp" class="btn btn-outline">
                        Cancel
                    </a>
                    <% if (isEdit) { %>
                        <form method="post" action="${pageContext.request.contextPath}/host/venues" style="display:inline;" onsubmit="return confirmAction('Delete this venue?')">
                            <input type="hidden" name="id" value="<%= formVenue.getId() %>">
                            <input type="hidden" name="action" value="delete">
                            <button class="btn btn-danger" type="submit">
                                Delete
                            </button>
                        </form>
                    <% } %>
                </div>
            </div>
            <div id="error-message" style="display:none;" class="alert alert-error">
            </div>
            <form method="post" action="${pageContext.request.contextPath}/host/venues" enctype="multipart/form-data" class="host-panel" onsubmit="return validateVenueForm(this)">
                <input type="hidden" name="id" value="<%= isEdit ? String.valueOf(formVenue.getId()) : "" %>">
                <input type="hidden" name="action" value="save">
                <div class="host-form-grid">
                    <div class="vf-field">
                        <label for="name">
                            Venue name *
                        </label>
                        <input id="name" name="name" required maxlength="150" value="<%= com.eventsphere.util.EscapeUtil.e(vName) %>">
                    </div>
                    <div class="vf-field">
                        <label for="location">
                            Location *
                        </label>
                        <input id="location" name="location" required maxlength="255" value="<%= com.eventsphere.util.EscapeUtil.e(vLoc) %>">
                    </div>
                    <div class="vf-field">
                        <label for="description">
                            Description
                        </label>
                        <textarea id="description" name="description" rows="3" maxlength="2000">
                            <%= com.eventsphere.util.EscapeUtil.e(vDesc) %>
                        </textarea>
                    </div>
                    <div class="vf-field">
                        <label for="eventType">
                            Event type *
                        </label>
                        <select id="eventType" name="eventType" required>
                            <option value="">
                                Select type
                            </option>
                            <option value="WEDDING"<%= "WEDDING".equals(vType) ? " selected" : "" %> >
                                Wedding
                            </option>
                            <option value="CONFERENCE"<%= "CONFERENCE".equals(vType) ? " selected" : "" %> >
                                Conference
                            </option>
                            <option value="PARTY"<%= "PARTY".equals(vType) ? " selected" : "" %> >
                                Party
                            </option>
                            <option value="CORPORATE"<%= "CORPORATE".equals(vType) ? " selected" : "" %> >
                                Corporate
                            </option>
                            <option value="OTHER"<%= "OTHER".equals(vType) ? " selected" : "" %> >
                                Other
                            </option>
                        </select>
                    </div>
                    <div class="vf-field">
                        <label for="capacity">
                            Maximum capacity *
                        </label>
                        <input id="capacity" name="capacity" type="number" min="1" max="10000" required value="<%= vCap %>">
                    </div>
                    <div class="vf-field">
                        <label for="rate">
                            Hourly rate (&#8377;) *
                        </label>
                        <input id="rate" name="rate" type="number" min="0" step="0.01" required value="<%= vRate %>">
                    </div>
                    <div class="vf-field">
                        <label for="amenities">
                            Amenities
                        </label>
                        <input id="amenities" name="amenities" maxlength="500" value="<%= com.eventsphere.util.EscapeUtil.e(vAmen) %>">
                    </div>
                    <div class="vf-field">
                        <label for="imageUrl">
                            Image path (optional if uploading)
                        </label>
                        <input id="imageUrl" name="imageUrl" maxlength="255" value="<%= com.eventsphere.util.EscapeUtil.e(vImg) %>">
                    </div>
                    <div class="vf-field">
                        <label for="photo">
                            Upload photo (optional, max 5MB)
                        </label>
                        <input type="file" id="photo" name="photo" accept="image/*">
                    </div>
                    <label class="vf-switch">
                        <input type="checkbox" name="available"<%= vAvail ? " checked" : "" %> >
                        <span class="vf-track">
                            <span class="vf-thumb">
                            </span>
                        </span>
                        <span class="vf-switch-text">
                            Available for booking
                        </span>
                    </label>
                </div>
                <p style="margin-top:1.25rem;">
                    <button class="btn btn-primary btn-lg" type="submit">
                        <%= isEdit ? "Save changes" : "List Venue" %>
                    </button>
                </p>
            </form>
        </main>
        <script src="${pageContext.request.contextPath}/js/script.js">
        </script>
        <script>
            function validateVenueForm(form) {
            var cap = Number(form.capacity.value), rate = form.rate.value;
            if (!form.name.value.trim()) { showError('Venue name is required.');
            return false;
            }
            if (!form.location.value.trim()) { showError('Location is required.');
            return false;
            }
            if (!form.eventType.value) { showError('Please select an event type.');
            return false;
            }
            if (!Number.isInteger(cap) || cap;
            < 1) { showError('Capacity must be 1 or more.');
            return false;
            }
            if (rate === '' || isNaN(Number(rate)) || Number(rate) < 0) { showError('Hourly rate must be 0 or more.');
            return false;
            }
            return true;
            }
            </script>
            ;
            </body>
            </html>
