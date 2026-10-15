<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.math.BigDecimal,com.eventsphere.model.*,com.eventsphere.dao.*,com.eventsphere.util.EscapeUtil" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
BookingDAO bookingDAO = new BookingDAO();
    List<Booking> bookings = bookingDAO.getBookingsByCustomer(user.getId());
    EventDAO eventDAO = new EventDAO();
    VenueDAO venueDAO = new VenueDAO();
    long pendingCount = bookingDAO.countByCustomerAndStatus(user.getId(), "PENDING");
    long approvedCount = bookingDAO.countByCustomerAndStatus(user.getId(), "APPROVED");
    long rejectedCount = bookingDAO.countByCustomerAndStatus(user.getId(), "REJECTED");
    BigDecimal spent = BigDecimal.ZERO;
    Booking upcoming = null;
    for (Booking b : bookings) { if ("APPROVED".equals(b.getStatus())) { if (b.getTotalAmount() != null) spent = spent.add(b.getTotalAmount());
    if (b.getBookingDate() != null && !b.getBookingDate().isBefore(java.time.LocalDate.now()) && (upcoming == null || b.getBookingDate().isBefore(upcoming.getBookingDate()))) upcoming = b;
    } }
Event upcomingEvent = upcoming == null ? null : eventDAO.getEventById(upcoming.getEventId());
    Venue upcomingVenue = upcoming == null ? null : venueDAO.getVenueById(upcoming.getVenueId());
    String okMsg = (String) session.getAttribute("bookingSuccess");
    session.removeAttribute("bookingSuccess");
    String errMsg = (String) session.getAttribute("bookingError");
    session.removeAttribute("bookingError");
    String paramSuccess = request.getParameter("success");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            My Bookings - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
    </head>
    <body class="cust-page">
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <span style="color:#cbd5e1;margin-right:0.5rem;">
                        Hi,
                        <%= EscapeUtil.e(user.getFullName()) %>
                    </span>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                        Browse Venues
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/feedback.jsp" class="btn btn-outline">
                        My Reviews
                    </a>
                    <a href="${pageContext.request.contextPath}/customer/notifications.jsp" class="btn btn-outline">
                        Notifications
                        <%
                            long bellUnread = new com.eventsphere.dao.NotificationDAO().unreadCount(user.getId(), "CUSTOMER");
                            if (bellUnread > 0) {
                        %>
                            (
                            <%= bellUnread %>
                            )
                        <% } %>
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container cust-wrap">
            <!-- user data below is HTML-escaped -->
            <section class="cust-banner">
                <div>
                    <p class="cust-eyebrow">
                        My bookings
                    </p>
                    <h1>
                        Welcome,
                        <%= EscapeUtil.e(user.getFullName()) %>
                    </h1>
                    <p class="cust-sub">
                        <%= EscapeUtil.e(user.getEmail()) %>
                        &middot;
                        <%= bookings.size() %>
                        bookings so far
                    </p>
                </div>
                <div class="cust-banner-actions">
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-primary">
                        + New Booking
                    </a>
                </div>
            </section>
            <% if (paramSuccess != null) { %>
                <div class="cust-toast cust-toast-success" id="flashToast">
                    <%= EscapeUtil.e(paramSuccess) %>
                </div>
            <% } else if (okMsg != null) { %>
                <div class="cust-toast cust-toast-success" id="flashToast">
                    <%= okMsg %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="cust-toast cust-toast-error" id="flashToast">
                    <%= errMsg %>
                </div>
            <% } %>
            <section class="cust-stats">
                <button type="button" class="cust-stat" data-status="">
                    <span class="cust-stat-icon cust-bg-indigo">
                        &#128179;
                    </span>
                    <span class="cust-stat-text">
                        <strong>
                            <%= bookings.size() %>
                        </strong>
                        <span>
                            Total bookings
                        </span>
                    </span>
                </button>
                <button type="button" class="cust-stat" data-status="PENDING">
                    <span class="cust-stat-icon cust-bg-amber">
                        &#9201;
                    </span>
                    <span class="cust-stat-text">
                        <strong>
                            <%= pendingCount %>
                        </strong>
                        <span>
                            Pending
                        </span>
                    </span>
                </button>
                <button type="button" class="cust-stat" data-status="APPROVED">
                    <span class="cust-stat-icon cust-bg-green">
                        &#10003;
                    </span>
                    <span class="cust-stat-text">
                        <strong>
                            <%= approvedCount %>
                        </strong>
                        <span>
                            Approved
                        </span>
                    </span>
                </button>
                <button type="button" class="cust-stat" data-status="REJECTED">
                    <span class="cust-stat-icon cust-bg-red">
                        &#10007;
                    </span>
                    <span class="cust-stat-text">
                        <strong>
                            <%= rejectedCount %>
                        </strong>
                        <span>
                            Rejected
                        </span>
                    </span>
                </button>
            </section>
            <div class="cust-layout">
                <section class="cust-panel cust-history">
                    <div class="cust-history-head">
                        <h2>
                            Booking history
                        </h2>
                    </div>
                    <div class="cust-filters" role="group" aria-label="Filter by status">
                        <button type="button" class="cust-filter active" data-status="">
                            All
                        </button>
                        <button type="button" class="cust-filter" data-status="PENDING">
                            Pending
                        </button>
                        <button type="button" class="cust-filter" data-status="APPROVED">
                            Approved
                        </button>
                        <button type="button" class="cust-filter" data-status="REJECTED">
                            Rejected
                        </button>
                        <button type="button" class="cust-filter" data-status="CANCELLED">
                            Cancelled
                        </button>
                    </div>
                    <div class="cust-search">
                        <input type="search" id="custSearch" placeholder="Search booking no, event or venue..." aria-label="Search bookings">
                    </div>
                    <% if (bookings.isEmpty()) { %>
                        <div class="alert alert-info">
                            No bookings yet.
                            <a href="${pageContext.request.contextPath}/venues">
                                Browse venues
                            </a>
                            to make your first booking.
                        </div>
                    <% } else { %>
                        <div class="cust-table-scroll">
                            <table class="cust-table" id="historyTable">
                                <colgroup>
                                    <col class="c-booking">
                                    <col class="c-venue">
                                    <col class="c-event">
                                    <col class="c-date">
                                    <col class="c-guests">
                                    <col class="c-total">
                                    <col class="c-status">
                                    <col class="c-placed">
                                    <col class="c-action">
                                </colgroup>
                                <thead>
                                    <tr>
                                        <th>
                                            Booking
                                        </th>
                                        <th>
                                            Venue
                                        </th>
                                        <th>
                                            Event
                                        </th>
                                        <th>
                                            Date
                                        </th>
                                        <th>
                                            Guests
                                        </th>
                                        <th>
                                            Total
                                        </th>
                                        <th>
                                            Status
                                        </th>
                                        <th>
                                            Placed On
                                        </th>
                                        <th>
                                            Action
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        for (Booking booking : bookings) { Event event = eventDAO.getEventById(booking.getEventId());
                                        Venue venue = venueDAO.getVenueById(booking.getVenueId());
                                    %>
                                    <tr data-status="<%= booking.getStatus() %>" data-search=" <%= EscapeUtil.e(booking.getBookingNumber()) %> <%= venue == null ? "" : EscapeUtil.e(venue.getName()) %> <%= event == null ? "" : EscapeUtil.e(event.getName()) %> <%= booking.getStatus() %>">
                                        <td class="nowrap">
                                            <strong>
                                                <%= booking.getBookingNumber() %>
                                            </strong>
                                        </td>
                                        <td class="ellipsis" title="<%= venue == null ? "" : EscapeUtil.e(venue.getName()) %>">
                                            <%= venue == null ? "-" : EscapeUtil.e(venue.getName()) %>
                                        </td>
                                        <td class="ellipsis" title="<%= event == null ? "" : EscapeUtil.e(event.getName()) %>">
                                            <%= event == null ? "-" : EscapeUtil.e(event.getName()) %>
                                        </td>
                                        <td class="nowrap">
                                            <%= booking.getBookingDate() %>
                                        </td>
                                        <td class="center">
                                            <%= event == null ? "-" : String.valueOf(event.getExpectedGuests()) %>
                                        </td>
                                        <td class="nowrap">
                                            Rs.
                                            <%= booking.getTotalAmount() %>
                                        </td>
                                        <td>
                                            <span class="cust-pill cust-pill-<%= booking.getStatus().toLowerCase() %>">
                                                <%= booking.getStatus() %>
                                            </span>
                                        </td>
                                        <td class="nowrap">
                                            <%= com.eventsphere.util.FormatUtil.dt(booking.getCreatedAt()) %>
                                        </td>
                                        <td>
                                            <% if ("PENDING".equals(booking.getStatus())) { %>
                                                <form method="post" action="${pageContext.request.contextPath}/bookings" onsubmit="return confirmAction('Cancel this booking? This cannot be undone.')">
                                                    <input type="hidden" name="action" value="cancel">
                                                    <input type="hidden" name="id" value="<%= booking.getId() %>">
                                                    <button class="btn btn-danger btn-sm" type="submit">
                                                        Cancel
                                                    </button>
                                                </form>
                                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/bookings/edit?id=<%= booking.getId() %>">
                                                    Edit
                                                </a>
                                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/bill?id=<%= booking.getId() %>">
                                                    Bill
                                                </a>
                                            <% } else if ("APPROVED".equals(booking.getStatus())) { %>
                                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/venues?action=details&id=<%= booking.getVenueId() %>">
                                                    Review venue
                                                </a>
                                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/bill?id=<%= booking.getId() %>">
                                                    Bill
                                                </a>
                                            <% } else { %>
                                                <span class="cust-muted">
                                                    -
                                                </span>
                                            <% } %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <p class="cust-muted cust-count" id="resultCount">
                    </p>
                <% } %>
            </section>
            <aside class="cust-side">
                <% if (upcoming != null) { %>
                    <section class="cust-panel cust-upcoming">
                        <p class="cust-eyebrow">
                            Next event
                        </p>
                        <h2>
                            <%= upcomingEvent == null ? "Upcoming booking" : EscapeUtil.e(upcomingEvent.getName()) %>
                        </h2>
                        <p class="cust-upcoming-venue">
                            <%= upcomingVenue == null ? "" : EscapeUtil.e(upcomingVenue.getName()) %>
                        </p>
                        <ul class="cust-upcoming-meta">
                            <li>
                                <span>
                                    &#128197;
                                </span>
                                <%= upcoming.getBookingDate() %>
                            </li>
                            <% if (upcomingEvent != null) { %>
                                <li>
                                    <span>
                                        &#128101;
                                    </span>
                                    <%= upcomingEvent.getExpectedGuests() %>
                                    guests
                                </li>
                            <% } %>
                            <li>
                                <span>
                                    &#8377;
                                </span>
                                Rs.
                                <%= upcoming.getTotalAmount() %>
                            </li>
                        </ul>
                        <p class="cust-muted">
                            <%= upcoming.getBookingNumber() %>
                            &middot; APPROVED
                        </p>
                    </section>
                <% } %>
                <section class="cust-panel">
                    <h2>
                        Total spent
                    </h2>
                    <p class="cust-revenue">
                        Rs.
                        <%= spent %>
                    </p>
                    <p class="cust-muted">
                        Across
                        <%= approvedCount %>
                        approved bookings.
                    </p>
                </section>
                <section class="cust-panel">
                    <h2>
                        Quick actions
                    </h2>
                    <div class="cust-actions">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/venues">
                            Browse venues
                        </a>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/">
                            Home
                        </a>
                    </div>
                </section>
            </aside>
        </div>
    </main>
    <script src="${pageContext.request.contextPath}/js/script.js?v=5">
    </script>
    <script>
        var pills=document.querySelectorAll('.cust-filter'),cards=document.querySelectorAll('.cust-stat'),search=document.getElementById('custSearch');
        function setStatus(s){pills.forEach(function(p){p.classList.toggle('active',p.dataset.status===s);
        });
        document.querySelectorAll('#historyTable tbody tr').forEach(function(r){var okS=!s||r.dataset.status===s;
        var q=(search&&search.value||'').toLowerCase();
        var okQ=!q||(r.dataset.search||'').toLowerCase().indexOf(q)>-1;
        r.style.display=(okS&&okQ)?'':'none';
        });
        updateCount();
        }
        function updateCount(){var rows=document.querySelectorAll('#historyTable tbody tr'),vis=0;
        rows.forEach(function(r){if(r.style.display!=='none')vis++;
        });
        var el=document.getElementById('resultCount');
        if(el)el.textContent='Showing '+vis+' of '+rows.length+' bookings.';
        }
        pills.forEach(function(p){p.addEventListener('click',function(){setStatus(p.dataset.status);
        });
        });
        cards.forEach(function(c){c.addEventListener('click',function(){setStatus(c.dataset.status);
        document.getElementById('historyTable').scrollIntoView({behavior:'smooth',block:'start'});
        });
        });
        if(search){search.addEventListener('input',function(){var active=document.querySelector('.cust-filter.active');
        setStatus(active?active.dataset.status:'');
        });
        }
        updateCount();
        var toast=document.getElementById('flashToast');
        if(toast){setTimeout(function(){toast.classList.add('hide');
        },4500);
        };
    </script>
</body>
</html>
