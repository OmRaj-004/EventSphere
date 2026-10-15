<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
List<Venue> venues = new VenueDAO().getVenuesByAdmin((Integer) session.getAttribute("userId"));
    java.util.Set<String> types = new java.util.TreeSet<String>();
    for (Venue v : venues) { if (v.getEventType() != null && !v.getEventType().isBlank()) types.add(v.getEventType());
    }
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Manage Venues - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    </head>
    <body class="vm-page">
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
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container vm-wrap">
            <div class="vm-head">
                <div>
                    <p class="vm-eyebrow">
                        Venue management
                    </p>
                    <h1>
                        Manage Venues
                    </h1>
                    <p class="vm-sub">
                        <%= venues.size() %>
                        venue
                        <%= venues.size() == 1 ? "" : "s" %>
                        under your account.
                    </p>
                </div>
                <div class="vm-head-actions">
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                        Dashboard
                    </a>
                    <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                        + Add venue
                    </a>
                </div>
            </div>
            <section class="vm-toolbar">
                <div class="vm-search">
                    <input type="search" id="vmSearch" placeholder="Search name, location or amenity..." aria-label="Search venues">
                </div>
                <div class="vm-filters">
                    <select id="vmType" aria-label="Filter by event type">
                        <option value="">
                            All types
                        </option>
                        <% for (String t : types) { %>
                            <option value="<%= t %>">
                                <%= t %>
                            </option>
                        <% } %>
                    </select>
                    <select id="vmStatus" aria-label="Filter by status">
                        <option value="">
                            All statuses
                        </option>
                        <option value="on">
                            Available
                        </option>
                        <option value="off">
                            Unavailable
                        </option>
                    </select>
                    <select id="vmSort" aria-label="Sort venues">
                        <option value="name">
                            Sort: Name A-Z
                        </option>
                        <option value="cap-desc">
                            Capacity: high to low
                        </option>
                        <option value="cap-asc">
                            Capacity: low to high
                        </option>
                        <option value="rate-desc">
                            Rate: high to low
                        </option>
                        <option value="rate-asc">
                            Rate: low to high
                        </option>
                    </select>
                </div>
            </section>
            <p class="vm-count" id="vmCount">
            </p>
            <% if (venues.isEmpty()) { %>
                <div class="alert alert-info">
                    No venues yet.
                    <a href="${pageContext.request.contextPath}/admin/venue-form.jsp">
                        Add your first venue
                    </a>
                    .
                </div>
            <% } else { %>
                <div class="vm-grid" id="vmGrid">
                    <% for (Venue venue : venues) { %>
                        <article class="vm-card" data-name="<%= com.eventsphere.util.EscapeUtil.e(venue.getName().toLowerCase()) %> <%= com.eventsphere.util.EscapeUtil.e(venue.getLocation().toLowerCase()) %> <%= venue.getAmenities() == null ? "" : com.eventsphere.util.EscapeUtil.e(venue.getAmenities().toLowerCase()) %>" data-type=" <%= venue.getEventType() %>" data-avail=" <%= venue.isAvailable() ? "on" : "off" %>" data-cap=" <%= venue.getMaxCapacity() %>" data-rate=" <%= venue.getHourlyRate() %>">
                            <div class="vm-img">
                                <img src="${pageContext.request.contextPath}<%= com.eventsphere.util.EscapeUtil.e(venue.getImageUrl() == null || venue.getImageUrl().isBlank() ? "/images/homepage-banner.jpg" : venue.getImageUrl()) %>" alt=" <%= com.eventsphere.util.EscapeUtil.e(venue.getName()) %>" loading="lazy" onerror="this.src='${pageContext.request.contextPath}/images/homepage-banner.jpg'">
                                <span class="vm-status <%= venue.isAvailable() ? "vm-on" : "vm-off" %>">
                                    <%= venue.isAvailable() ? "Available" : "Unavailable" %>
                                </span>
                            </div>
                            <div class="vm-body">
                                <div class="vm-type-row">
                                    <span class="vm-type">
                                        <%= com.eventsphere.util.EscapeUtil.e(venue.getEventType()) %>
                                    </span>
                                    <span class="vm-cap">
                                        &#128101;
                                        <%= venue.getMaxCapacity() %>
                                    </span>
                                </div>
                                <h2>
                                    <%= com.eventsphere.util.EscapeUtil.e(venue.getName()) %>
                                </h2>
                                <p class="vm-loc">
                                    &#128205;
                                    <%= com.eventsphere.util.EscapeUtil.e(venue.getLocation()) %>
                                </p>
                                <p class="vm-amen">
                                    <%= venue.getAmenities() == null || venue.getAmenities().isBlank() ? "No amenities listed" : com.eventsphere.util.EscapeUtil.e(venue.getAmenities()) %>
                                </p>
                                <p class="vm-rate">
                                    &#8377;
                                    <%= venue.getHourlyRate() %>
                                    <span>
                                        /hour
                                    </span>
                                </p>
                            </div>
                            <div class="vm-foot">
                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/admin/venue-form.jsp?id=<%= venue.getId() %>">
                                    Edit
                                </a>
                                <form method="post" action="${pageContext.request.contextPath}/admin/venues" onsubmit="return confirmAction('Delete &quot;<%= venue.getName().replace("\"","") %>
                                    &quot;? Its bookings will be affected.')">
                                    <input type="hidden" name="id" value="<%= venue.getId() %>">
                                    <input type="hidden" name="action" value="delete">
                                    <button class="btn btn-danger btn-sm" type="submit">
                                        Delete
                                    </button>
                                </form>
                                <a class="btn btn-sm vm-view" href="${pageContext.request.contextPath}/venues?action=details&id=<%= venue.getId() %>">
                                    View live
                                </a>
                            </div>
                        </article>
                    <% } %>
                </div>
            <% } %>
        </main>
        <script src="${pageContext.request.contextPath}/js/script.js?v=5">
        </script>
        <script>
            var q=document.getElementById('vmSearch'),ft=document.getElementById('vmType'),fs=document.getElementById('vmStatus'),so=document.getElementById('vmSort'),grid=document.getElementById('vmGrid');
            function applyVm(){var query=(q.value||'').toLowerCase(),t=ft.value,s=fs.value,cards=Array.prototype.slice.call(grid.querySelectorAll('.vm-card'));
            var vis=0;
            cards.forEach(function(c){var ok=( !query||c.dataset.name.indexOf(query)>-1 )&&( !t||c.dataset.type===t )&&( !s||c.dataset.avail===s);
            c.style.display=ok?'':'none';
            if(ok)vis++;
            });
            var key=so.value;
            cards.sort(function(a,b){if(key==='name')return a.dataset.name.localeCompare(b.dataset.name);
            var av=parseFloat(a.dataset[key.split('-')[0]==='cap'?'cap':'rate'])||0,bv=parseFloat(b.dataset[key.split('-')[0]==='cap'?'cap':'rate'])||0;
            return key.indexOf('desc')>-1?bv-av:av-bv;
            });
            cards.forEach(function(c){grid.appendChild(c);
            });
            var el=document.getElementById('vmCount');
            if(el)el.textContent='Showing '+vis+' of '+cards.length+' venues.';
            }
            [q,ft,fs,so].forEach(function(el){if(el){el.addEventListener('input',applyVm);
            el.addEventListener('change',applyVm);
            }});
            if(grid)applyVm();
        </script>
    </body>
</html>
