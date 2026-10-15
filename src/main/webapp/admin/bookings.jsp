<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*,com.eventsphere.util.EscapeUtil" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
BookingDAO bookingDAO = new BookingDAO();
    EventDAO eventDAO = new EventDAO();
    VenueDAO venueDAO = new VenueDAO();
    UserDAO userDAO = new UserDAO();
    int bkPage = 1;
    try { bkPage = Math.max(1, Integer.parseInt(request.getParameter("page")));
    } catch (NumberFormatException | NullPointerException e) { bkPage = 1;
    }
final int BK_SIZE = 15;
    long bkTotal = bookingDAO.countAllBookings();
    long bkPages = Math.max(1, (bkTotal + BK_SIZE - 1) / BK_SIZE);
    if (bkPage > bkPages) bkPage = (int) bkPages;
    List<Booking> bookings = bookingDAO.getBookingsPage((bkPage - 1) * BK_SIZE, BK_SIZE);
    long nPending = bookingDAO.countByStatus("PENDING"), nApproved = bookingDAO.countByStatus("APPROVED");
    long nRejected = bookingDAO.countByStatus("REJECTED"), nCancelled = bookingDAO.countByStatus("CANCELLED");
    String okMsg = (String) session.getAttribute("adminBookingSuccess");
    session.removeAttribute("adminBookingSuccess");
    String errMsg = (String) session.getAttribute("adminBookingError");
    session.removeAttribute("adminBookingError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Manage Bookings - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body class="bk-page">
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
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
                        Dashboard
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline">
                        Venues
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
        <main class="container bk-wrap">
            <div class="bk-head">
                <div>
                    <p class="bk-eyebrow">
                        Booking management
                    </p>
                    <h1>
                        Manage Bookings
                    </h1>
                    <p class="bk-sub">
                        <%= bkTotal %>
                        booking
                        <%= bkTotal == 1 ? "" : "s" %>
                        in the system.
                    </p>
                </div>
                <div class="bk-head-actions">
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                        Dashboard
                    </a>
                    <button class="btn btn-outline" type="button" onclick="location.reload()">
                        &#8635; Refresh
                    </button>
                </div>
            </div>
            <% if (okMsg != null) { %>
                <div class="bk-toast bk-toast-success" id="flashToast">
                    <%= okMsg %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="bk-toast bk-toast-error" id="flashToast">
                    <%= errMsg %>
                </div>
            <% } %>
            <section class="bk-stats">
                <button type="button" class="bk-stat" data-status="">
                    <span class="bk-stat-num">
                        <%= bkTotal %>
                    </span>
                    <span class="bk-stat-label">
                        Total
                    </span>
                </button>
                <button type="button" class="bk-stat bk-pending" data-status="PENDING">
                    <span class="bk-stat-num">
                        <%= nPending %>
                    </span>
                    <span class="bk-stat-label">
                        Pending
                    </span>
                </button>
                <button type="button" class="bk-stat" data-status="APPROVED">
                    <span class="bk-stat-num">
                        <%= nApproved %>
                    </span>
                    <span class="bk-stat-label">
                        Approved
                    </span>
                </button>
                <button type="button" class="bk-stat" data-status="REJECTED">
                    <span class="bk-stat-num">
                        <%= nRejected %>
                    </span>
                    <span class="bk-stat-label">
                        Rejected
                    </span>
                </button>
                <button type="button" class="bk-stat" data-status="CANCELLED">
                    <span class="bk-stat-num">
                        <%= nCancelled %>
                    </span>
                    <span class="bk-stat-label">
                        Cancelled
                    </span>
                </button>
            </section>
            <section class="bk-panel">
                <div class="bk-filters" role="group" aria-label="Filter by status">
                    <button type="button" class="bk-filter active" data-status="">
                        All
                    </button>
                    <button type="button" class="bk-filter" data-status="PENDING">
                        Pending
                    </button>
                    <button type="button" class="bk-filter" data-status="APPROVED">
                        Approved
                    </button>
                    <button type="button" class="bk-filter" data-status="REJECTED">
                        Rejected
                    </button>
                    <button type="button" class="bk-filter" data-status="CANCELLED">
                        Cancelled
                    </button>
                </div>
                <div class="bk-tools">
                    <div class="bk-search">
                        <input type="search" id="bkSearch" placeholder="Search booking no, customer, venue or event..." aria-label="Search bookings" value="<%= request.getParameter("q") == null ? "" : request.getParameter("q").replace("\"","&quot;") %>">
                    </div>
                    <select id="bkSort" aria-label="Sort bookings">
                        <option value="date-desc">
                            Sort: Newest first
                        </option>
                        <option value="date-asc">
                            Sort: Oldest first
                        </option>
                        <option value="total-desc">
                            Total: high to low
                        </option>
                        <option value="total-asc">
                            Total: low to high
                        </option>
                    </select>
                </div>
                <% if (bookings.isEmpty()) { %>
                    <div class="alert alert-info">
                        No bookings yet.
                    </div>
                <% } else { %>
                    <div class="bk-table-scroll">
                        <table class="bk-table" id="bkTable">
                            <colgroup>
                                <col class="b-booking">
                                <col class="b-customer">
                                <col class="b-venue">
                                <col class="b-event">
                                <col class="b-date">
                                <col class="b-total">
                                <col class="b-status">
                                <col class="b-placed">
                                <col class="b-action">
                            </colgroup>
                            <thead>
                                <tr>
                                    <th>
                                        Booking
                                    </th>
                                    <th>
                                        Customer
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
                                    User cust = userDAO.getCustomerById(booking.getCustomerId());
                                    String custName = cust == null ? ("#" + booking.getCustomerId()) : cust.getFullName();
                                %>
                                <tr data-status="<%= booking.getStatus() %>" data-date=" <%= booking.getBookingDate() %>" data-total=" <%= booking.getTotalAmount() %>" data-search=" <%= booking.getBookingNumber() %> <%= EscapeUtil.e(custName) %> <%= venue == null ? "" : EscapeUtil.e(venue.getName()) %> <%= event == null ? "" : EscapeUtil.e(event.getName()) %> <%= booking.getStatus() %>">
                                    <td class="nowrap">
                                        <strong>
                                            <%= booking.getBookingNumber() %>
                                        </strong>
                                    </td>
                                    <td class="ellipsis" title="<%= EscapeUtil.e(custName) %>">
                                        <%= EscapeUtil.e(custName) %>
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
                                    <td class="nowrap">
                                        Rs.
                                        <%= booking.getTotalAmount() %>
                                    </td>
                                    <td>
                                        <span class="bk-pill bk-pill-<%= booking.getStatus().toLowerCase() %>">
                                            <%= booking.getStatus() %>
                                        </span>
                                    </td>
                                    <td class="nowrap">
                                        <%= com.eventsphere.util.FormatUtil.dt(booking.getCreatedAt()) %>
                                    </td>
                                    <td>
                                        <% if ("PENDING".equals(booking.getStatus())) { %>
                                            <div class="bk-actions">
                                                <form method="post" action="${pageContext.request.contextPath}/admin/bookings" onsubmit="return confirmAction('Approve booking <%= booking.getBookingNumber() %> ?')">
                                                    <input type="hidden" name="id" value="<%= booking.getId() %>">
                                                    <input type="hidden" name="action" value="approve">
                                                    <button class="btn btn-success btn-sm" type="submit">
                                                        Approve
                                                    </button>
                                                </form>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/bookings" onsubmit="return confirmAction('Reject booking <%= booking.getBookingNumber() %> ?')">
                                                    <input type="hidden" name="id" value="<%= booking.getId() %>">
                                                    <input type="hidden" name="action" value="reject">
                                                    <button class="btn btn-danger btn-sm" type="submit">
                                                        Reject
                                                    </button>
                                                </form>
                                            </div>
                                        <% } else { %>
                                            <span class="bk-muted">
                                                -
                                            </span>
                                        <% } %>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <p class="bk-muted bk-count" id="bkCount">
                </p>
                <% if (bkPages > 1) { %>
                    <div class="pager">
                        <% if (bkPage > 1) { %>
                            <a class="btn btn-outline btn-sm" href="?page=<%= bkPage - 1 %>">
                                &larr; Prev
                            </a>
                        <% } %>
                        <span>
                            Page
                            <%= bkPage %>
                            of
                            <%= bkPages %>
                            (
                            <%= bkTotal %>
                            total)
                        </span>
                        <% if (bkPage < bkPages) { %>
                            <a class="btn btn-outline btn-sm" href="?page=<%= bkPage + 1 %>">
                                Next &rarr;
                            </a>
                        <% } %>
                    </div>
                <% } %>
            <% } %>
        </section>
    </main>
<<<<<<< HEAD
    <script src="${pageContext.request.contextPath}/js/script.js?v=5">
=======
    <script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </script>
    <script>
        var pills=document.querySelectorAll('.bk-filter'),stats=document.querySelectorAll('.bk-stat'),search=document.getElementById('bkSearch'),sort=document.getElementById('bkSort'),table=document.getElementById('bkTable');
        function bkApply(){var active=document.querySelector('.bk-filter.active');
        var s=active?active.dataset.status:'';
        var q=(search.value||'').toLowerCase();
        var rows=Array.prototype.slice.call(table.querySelectorAll('tbody tr'));
        var vis=0;
        rows.forEach(function(r){var okS=!s||r.dataset.status===s;
        var okQ=!q||(r.dataset.search||'').toLowerCase().indexOf(q)>-1;
        r.style.display=(okS&&okQ)?'':'none';
        if(okS&&okQ)vis++;
        });
        var key=sort.value,visRows=rows.filter(function(r){return r.style.display!=='none';
        });
        visRows.sort(function(a,b){if(key.indexOf('date')===0){var d=a.dataset.date;
        <b.dataset.date?-1:(a.dataset.date>
        b.dataset.date?1:0);
        return key==='date-desc'?-d:d;
        }var x=parseFloat(a.dataset.total)||0,y=parseFloat(b.dataset.total)||0;
        return key==='total-desc'?y-x:x-y;
        });
        var tb=table.querySelector('tbody');
        visRows.forEach(function(r){tb.appendChild(r);
        });
        var el=document.getElementById('bkCount');
        if(el)el.textContent='Showing '+vis+' of '+rows.length+' bookings.';
        }
        function bkStatus(s){pills.forEach(function(p){p.classList.toggle('active',p.dataset.status===s);
        });
        bkApply();
        }
        pills.forEach(function(p){p.addEventListener('click',function(){bkStatus(p.dataset.status);
        });
        });
        stats.forEach(function(c){c.addEventListener('click',function(){bkStatus(c.dataset.status);
        table.scrollIntoView({behavior:'smooth',block:'start'});
        });
        });
        search.addEventListener('input',bkApply);
        sort.addEventListener('change',bkApply);
        bkApply();
        var toast=document.getElementById('flashToast');
        if(toast){setTimeout(function(){toast.classList.add('hide');
        },4500);
        };
    </script>
</body>
</html>
