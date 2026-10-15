<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="com.eventsphere.model.Venue" %>
<%@ page import="com.eventsphere.util.EscapeUtil" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
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
    String vStatus = isEdit ? formVenue.getStatus() : "AVAILABLE";
    boolean vAvail = !isEdit || formVenue.isAvailable();
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            <%= isEdit ? "Edit Venue" : "Add Venue" %>
            - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    </head>
    <body class="vf-page">
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
                        Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/analytics.jsp" class="btn btn-outline">
                        Analytics
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline">
                        Back to Venues
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container vf-wrap">
            <div class="vf-head">
                <div>
                    <p class="vf-eyebrow">
                        <%= isEdit ? "Edit venue #" + formVenue.getId() : "New venue" %>
                    </p>
                    <h1>
                        <%= isEdit ? "Edit Venue" : "Add Venue" %>
                    </h1>
                    <p class="vf-sub">
                        Fields marked * are required. Preview updates live on the right.
                    </p>
                </div>
                <div class="vf-head-actions">
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline">
                        Cancel
                    </a>
                    <% if (isEdit) { %>
                        <form method="post" action="${pageContext.request.contextPath}/admin/venues" style="display:inline;" onsubmit="return confirmAction('Delete this venue? All its bookings will be affected.')">
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
            <form method="post" action="${pageContext.request.contextPath}/admin/venues" enctype="multipart/form-data" onsubmit="return validateVenueForm(this)">
                <input type="hidden" name="id" value="<%= isEdit ? String.valueOf(formVenue.getId()) : "" %>">
                <input type="hidden" name="action" value="save">
                <div class="vf-layout">
                    <div class="vf-main">
                        <section class="vf-card">
                            <h2>
                                <span class="vf-step">
                                    1
                                </span>
                                Basic information
                            </h2>
                            <div class="vf-grid vf-grid-1">
                                <div class="vf-field">
                                    <label for="name">
                                        Venue name *
                                    </label>
                                    <input id="name" name="name" required maxlength="150" placeholder="e.g. Crystal Palace Banquet" value="<%= EscapeUtil.e(vName) %>">
                                </div>
                                <div class="vf-field">
                                    <label for="description">
                                        Description
                                    </label>
                                    <textarea id="description" name="description" rows="3" maxlength="2000" placeholder="What makes this venue special?">
                                        <%= EscapeUtil.e(vDesc) %>
                                    </textarea>
                                </div>
                                <div class="vf-grid vf-grid-2">
                                    <div class="vf-field">
                                        <label for="location">
                                            Location *
                                        </label>
                                        <input id="location" name="location" required maxlength="255" placeholder="e.g. 12 MG Road, Camp, Pune" value="<%= EscapeUtil.e(vLoc) %>">
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
                                </div>
                            </div>
                        </section>
                        <section class="vf-card">
                            <h2>
                                <span class="vf-step">
                                    2
                                </span>
                                Capacity &amp; pricing
                            </h2>
                            <div class="vf-grid vf-grid-2">
                                <div class="vf-field">
                                    <label for="capacity">
                                        Maximum capacity (guests) *
                                    </label>
                                    <input id="capacity" name="capacity" type="number" min="1" max="10000" step="1" required placeholder="e.g. 500" value="<%= vCap %>">
                                    <small>
                                        Customers cannot book more guests than this.
                                    </small>
                                </div>
                                <div class="vf-field">
                                    <label for="rate">
                                        Hourly rate (&#8377;) *
                                    </label>
                                    <input id="rate" name="rate" type="number" min="0" step="0.01" required placeholder="e.g. 2500" value="<%= vRate %>">
                                    <small>
                                        Booking total = rate &times; event hours.
                                    </small>
                                </div>
                            </div>
                        </section>
                        <section class="vf-card">
                            <h2>
                                <span class="vf-step">
                                    3
                                </span>
                                Facilities, photo &amp; availability
                            </h2>
                            <div class="vf-grid vf-grid-1">
                                <div class="vf-field">
                                    <label for="amenities">
                                        Amenities
                                    </label>
                                    <input id="amenities" name="amenities" maxlength="500" placeholder="e.g. AC, Parking, Catering, Stage" value="<%= EscapeUtil.e(vAmen) %>">
                                    <small>
                                        Comma-separated list shown on the venue card.
                                    </small>
                                </div>
                                <div class="vf-grid vf-grid-2">
                                    <div class="vf-field">
                                        <label for="imageUrl">
                                            Image
                                        </label>
                                        <input id="imageUrl" name="imageUrl" list="imageChoices" maxlength="255" placeholder="Pick or paste image path" value="<%= EscapeUtil.e(vImg) %>">
                                        <datalist id="imageChoices">
                                            <option value="/images/grand-ballroom.jpg">
                                            </option>
                                            <option value="/images/riverside-garden.jpg">
                                            </option>
                                            <option value="/images/conference-hall.jpg">
                                            </option>
                                            <option value="/images/homepage-banner.jpg">
                                            </option>
                                        </datalist>
                                    </div>
                                    <div class="vf-field">
                                        <label for="photo">
                                            Or upload a photo (max 5MB, overrides the path above)
                                        </label>
                                        <input type="file" id="photo" name="photo" accept="image/*">
                                    </div>
                                    <div class="vf-field">
                                        <label for="status">
                                            Status
                                        </label>
                                        <select id="status" name="status">
                                            <option value="AVAILABLE"<%= "AVAILABLE".equals(vStatus) ? " selected" : "" %> >
                                                Available - bookable
                                            </option>
                                            <option value="MAINTENANCE"<%= "MAINTENANCE".equals(vStatus) ? " selected" : "" %> >
                                                Maintenance - hidden from booking
                                            </option>
                                            <option value="INACTIVE"<%= "INACTIVE".equals(vStatus) ? " selected" : "" %> >
                                                Inactive - hidden from booking
                                            </option>
                                        </select>
                                    </div>
                                </div>
                                <label class="vf-switch">
                                    <input type="checkbox" name="available"<%= vAvail ? " checked" : "" %> >
                                    <span class="vf-track">
                                        <span class="vf-thumb">
                                        </span>
                                    </span>
                                    <span class="vf-switch-text">
                                        Available for booking
                                        <small>
                                            Off hides the "Book This Venue" button.
                                        </small>
                                    </span>
                                </label>
                            </div>
                        </section>
                        <div class="vf-submit-row">
                            <button class="btn btn-primary btn-lg" type="submit">
                                <%= isEdit ? "Save changes" : "Add venue" %>
                            </button>
                            <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/venues.jsp">
                                Cancel
                            </a>
                        </div>
                    </div>
                    <aside class="vf-side">
                        <section class="vf-card vf-preview">
                            <p class="vf-eyebrow">
                                Live preview
                            </p>
                            <div class="vf-preview-img">
                                <img id="pvImg" src="${pageContext.request.contextPath}<%= EscapeUtil.e(vImg.isEmpty() ? "/images/homepage-banner.jpg" : vImg) %>" alt="Venue preview" onerror="this.src='${pageContext.request.contextPath}/images/homepage-banner.jpg'">
                            </div>
                            <div class="vf-preview-body">
                                <h3 id="pvName">
                                    <%= vName.isEmpty() ? "Your venue name" : EscapeUtil.e(vName) %>
                                </h3>
                                <p class="vf-preview-loc" id="pvLoc">
                                    &#128205;
                                    <%= vLoc.isEmpty() ? "Venue location" : EscapeUtil.e(vLoc) %>
                                </p>
                                <p class="vf-preview-amen" id="pvAmen">
                                    <%= vAmen.isEmpty() ? "Amenities will appear here" : EscapeUtil.e(vAmen) %>
                                </p>
                                <div class="vf-preview-row">
                                    <span class="vf-preview-rate" id="pvRate">
                                        &#8377;
                                        <%= vRate.isEmpty() ? "0" : vRate %>
                                        /hour
                                    </span>
                                    <span class="vf-preview-cap" id="pvCap">
                                        Cap:
                                        <%= vCap.isEmpty() ? "-" : vCap %>
                                    </span>
                                </div>
                                <span class="vf-preview-status" id="pvStatus">
                                    <%= vStatus %>
                                </span>
                            </div>
                        </section>
                        <section class="vf-card vf-tips">
                            <h2>
                                Tips
                            </h2>
                            <ul>
                                <li>
                                    Use a clear photo path from the list - broken images fall back automatically.
                                </li>
                                <li>
                                    Capacity caps guest count at booking time.
                                </li>
                                <li>
                                    Set status to Maintenance while renovating instead of deleting.
                                </li>
                            </ul>
                        </section>
                    </aside>
                </div>
            </form>
        </main>
        <script src="${pageContext.request.contextPath}/js/script.js?v=5">
        </script>
        <script>
            var CTX='${pageContext.request.contextPath}', FALLBACK=CTX+'/images/homepage-banner.jpg';
            function pv(id,fn){var el=document.getElementById(id);
            if(el){el.addEventListener('input',fn);
            el.addEventListener('change',fn);
            }}
            function refreshPreview(){
            var name=document.getElementById('name').value.trim()||'Your venue name';
            var loc=document.getElementById('location').value.trim()||'Venue location';
            var amen=document.getElementById('amenities').value.trim()||'Amenities will appear here';
            var rate=document.getElementById('rate').value||'0';
            var cap=document.getElementById('capacity').value||'-';
            var img=document.getElementById('imageUrl').value.trim()||'/images/homepage-banner.jpg';
            var status=document.getElementById('status').value||'AVAILABLE';
            document.getElementById('pvName').textContent=name;
            document.getElementById('pvLoc').textContent='\uD83D\uDCCD '+loc;
            document.getElementById('pvAmen').textContent=amen;
            document.getElementById('pvRate').textContent='\u20B9'+rate+'/hour';
            document.getElementById('pvCap').textContent='Cap: '+cap;
            var st=document.getElementById('pvStatus');
            st.textContent=status;
            st.className='vf-preview-status st-'+status.toLowerCase();
            var im=document.getElementById('pvImg');
            var src=img.indexOf('/')===0?CTX+img:img;
            if(im.getAttribute('src')!==src)im.src=src;
            }
            ['name','location','amenities','rate','capacity','imageUrl','status'].forEach(function(id){pv(id,refreshPreview);
            });
            refreshPreview();
            function validateVenueForm(form){
            var cap=Number(form.capacity.value),rate=form.rate.value;
            if(!form.name.value.trim()){showError('Venue name is required.');
            return false;
            }
            if(!form.location.value.trim()){showError('Location is required.');
            return false;
            }
            if(!form.eventType.value){showError('Please select an event type.');
            return false;
            }
            if(!Number.isInteger(cap)||cap;
            <1){showError('Capacity must be a whole number of 1 or more.');
            return false;
            }
            if(rate===''||isNaN(Number(rate))||Number(rate)<0){showError('Hourly rate must be 0 or more.');
            return false;
            }
            return true;
            }
            </script>
            ;
            </body>
            </html>
