<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,java.util.Map,java.util.LinkedHashMap,java.util.ArrayList,java.util.Collections,java.util.Comparator,java.math.BigDecimal,com.eventsphere.dao.*,com.eventsphere.model.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
VenueDAO venueDAO = new VenueDAO();
    UserDAO userDAO = new UserDAO();
    BookingDAO bookingDAO = new BookingDAO();
    BillDAO billDAO = new BillDAO();
    List<Booking> allBookings = bookingDAO.getAllBookings();
    List<Bill> allBills = billDAO.getAllBills();
    BigDecimal billedTotal = BigDecimal.ZERO;
    BigDecimal outstanding = BigDecimal.ZERO;
    long billsIssued = 0, billsPaid = 0, billsCancelled = 0;
    Map<String, BigDecimal> revenueByVenue = new LinkedHashMap<String, BigDecimal>();
    Map<String, Integer> bookingsByMonth = new LinkedHashMap<String, Integer>();
    Map<Integer, BigDecimal> spendByCustomer = new LinkedHashMap<Integer, BigDecimal>();
    Map<Integer, Integer> bookingsByCustomer = new LinkedHashMap<Integer, Integer>();
    for (Bill bl : allBills) {
    if (bl.getSubtotal() != null) billedTotal = billedTotal.add(bl.getSubtotal());
    if ("ISSUED".equals(bl.getStatus())) { billsIssued++;
    if (bl.getBalanceDue() != null) outstanding = outstanding.add(bl.getBalanceDue());
    }
    else if ("PAID".equals(bl.getStatus())) billsPaid++;
    else if ("CANCELLED".equals(bl.getStatus())) billsCancelled++;
    Booking bb = bookingDAO.getBookingById(bl.getBookingId());
    if (bb != null) {
        Venue bv = venueDAO.getVenueById(bb.getVenueId());
    String vName = bv == null ? "Unknown venue" : bv.getName();
    BigDecimal prev = revenueByVenue.get(vName);
    if (prev == null) prev = BigDecimal.ZERO;
    revenueByVenue.put(vName, prev.add(bl.getSubtotal() == null ? BigDecimal.ZERO : bl.getSubtotal()));
    if (bb.getBookingDate() != null) { String m = bb.getBookingDate().getYear() + "-" + String.format("%02d", bb.getBookingDate().getMonthValue());
    Integer c = bookingsByMonth.get(m);
    bookingsByMonth.put(m, c == null ? 1 : c + 1);
    }
    }
}
for (Booking b : allBookings) {
    if (b.getTotalAmount() == null) continue;
    BigDecimal s = spendByCustomer.get(b.getCustomerId());
    spendByCustomer.put(b.getCustomerId(), (s == null ? BigDecimal.ZERO : s).add(b.getTotalAmount()));
    Integer c = bookingsByCustomer.get(b.getCustomerId());
    bookingsByCustomer.put(b.getCustomerId(), c == null ? 1 : c + 1);
    }
List<Map.Entry<Integer, BigDecimal>> topCustomers = new ArrayList<Map.Entry<Integer, BigDecimal>>(spendByCustomer.entrySet());
    Collections.sort(topCustomers, new Comparator<Map.Entry<Integer, BigDecimal>>() { public int compare(Map.Entry<Integer, BigDecimal> a, Map.Entry<Integer, BigDecimal> b) { return b.getValue().compareTo(a.getValue());
    } });
    BigDecimal maxVenueRevenue = BigDecimal.ONE;
    for (BigDecimal v : revenueByVenue.values()) { if (v.compareTo(maxVenueRevenue) > 0) maxVenueRevenue = v;
    }
int maxMonthCount = 1;
    for (Integer c : bookingsByMonth.values()) { if (c > maxMonthCount) maxMonthCount = c;
    }
BigDecimal avgBooking = allBookings.isEmpty() ? BigDecimal.ZERO : billedTotal.divide(BigDecimal.valueOf(Math.max(allBills.size(), 1)), 2, BigDecimal.ROUND_HALF_UP);
    long bPending = 0, bApproved = 0, bRejected = 0, bCancelled = 0;
    for (Booking b : allBookings) { if ("PENDING".equals(b.getStatus())) bPending++;
    else if ("APPROVED".equals(b.getStatus())) bApproved++;
    else if ("REJECTED".equals(b.getStatus())) bRejected++;
    else if ("CANCELLED".equals(b.getStatus())) bCancelled++;
    }
long bTotal = Math.max(allBookings.size(), 1);
    long pPending = Math.round(bPending * 100.0 / bTotal), pApproved = Math.round(bApproved * 100.0 / bTotal), pRejected = Math.round(bRejected * 100.0 / bTotal), pCancelled = Math.max(0, 100 - pPending - pApproved - pRejected);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Analytics - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body class="an-page">
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
                    <a href="${pageContext.request.contextPath}/admin/bookings.jsp" class="btn btn-outline">
                        Bookings
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/venues.jsp" class="btn btn-outline">
                        Venues
                    </a>
                    <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;">
                        <button type="submit" class="btn btn-primary">
                            Logout
                        </button>
                    </form>
                </div>
            </div>
        </nav>
        <main class="container an-wrap">
            <div class="an-head">
                <div>
                    <p class="an-eyebrow">
                        Business intelligence
                    </p>
                    <h1>
                        Analytics
                    </h1>
                    <p class="an-sub">
                        Revenue, bookings and customer insights across the platform.
                    </p>
                </div>
                <div class="an-head-actions">
                    <a class="btn btn-outline" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                        Dashboard
                    </a>
                    <button class="btn btn-outline" type="button" onclick="window.print()">
                        Print report
                    </button>
                </div>
            </div>
            <section class="an-kpis">
                <div class="an-kpi">
                    <span>
                        Total billed
                    </span>
                    <strong>
                        &#8377;
                        <%= billedTotal %>
                    </strong>
                    <small>
                        <%= allBills.size() %>
                        invoices
                    </small>
                </div>
                <div class="an-kpi">
                    <span>
                        Outstanding
                    </span>
                    <strong>
                        &#8377;
                        <%= outstanding %>
                    </strong>
                    <small>
                        <%= billsIssued %>
                        open bills
                    </small>
                </div>
                <div class="an-kpi">
                    <span>
                        Total bookings
                    </span>
                    <strong>
                        <%= allBookings.size() %>
                    </strong>
                    <span>
                        <%= bPending %>
                        awaiting approval
                    </span>
                </div>
                <div class="an-kpi">
                    <span>
                        Avg booking value
                    </span>
                    <strong>
                        &#8377;
                        <%= avgBooking %>
                    </strong>
                    <small>
                        per invoice
                    </small>
                </div>
            </section>
            <div class="an-grid">
                <section class="an-panel">
                    <h2>
                        Revenue by venue
                    </h2>
                    <% if (revenueByVenue.isEmpty()) { %>
                        <p class="an-muted">
                            No billing data yet.
                        </p>
                    <% } else { %>
                        <div class="an-bars">
                            <% for (Map.Entry<String, BigDecimal> e : revenueByVenue.entrySet()) { int pct = e.getValue().multiply(BigDecimal.valueOf(100)).divide(maxVenueRevenue, 0, BigDecimal.ROUND_DOWN).intValue(); %>
                            <div class="an-bar-row">
                                <span class="an-bar-label" title="<%= com.eventsphere.util.EscapeUtil.e(e.getKey()) %>">
                                    <%= com.eventsphere.util.EscapeUtil.e(e.getKey()) %>
                                </span>
                                <span class="an-bar-track">
                                    <span class="an-bar-fill" style="width: <%= Math.max(pct, 3) %> %;">
                                    </span>
                                </span>
                                <span class="an-bar-value">
                                    &#8377;
                                    <%= e.getValue() %>
                                </span>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </section>
            <section class="an-panel">
                <h2>
                    Bookings by status
                </h2>
                <div class="an-donut" style="background: conic-gradient(#10b981 0 <%= pApproved %> %, #f59e0b <%= pApproved %> % <%= pApproved + pPending %> %, #ef4444 <%= pApproved + pPending %> % <%= pApproved + pPending + pRejected %> %, #94a3b8 <%= pApproved + pPending + pRejected %> % 100%);">
                    <span>
                        <%= allBookings.size() %>
                        <small>
                            bookings
                        </small>
                    </span>
                </div>
                <ul class="an-legend">
                    <li>
                        <i class="an-dot an-green">
                        </i>
                        Approved
                        <strong>
                            <%= bApproved %>
                        </strong>
                        (
                        <%= pApproved %>
                        %)
                    </li>
                    <li>
                        <i class="an-dot an-amber">
                        </i>
                        Pending
                        <strong>
                            <%= bPending %>
                        </strong>
                        (
                        <%= pPending %>
                        %)
                    </li>
                    <li>
                        <i class="an-dot an-red">
                        </i>
                        Rejected
                        <strong>
                            <%= bRejected %>
                        </strong>
                        (
                        <%= pRejected %>
                        %)
                    </li>
                    <li>
                        <i class="an-dot an-gray">
                        </i>
                        Cancelled
                        <strong>
                            <%= bCancelled %>
                        </strong>
                        (
                        <%= pCancelled %>
                        %)
                    </li>
                </ul>
                <h2 class="an-gap">
                    Bills by status
                </h2>
                <ul class="an-legend">
                    <li>
                        <i class="an-dot an-amber">
                        </i>
                        Issued
                        <strong>
                            <%= billsIssued %>
                        </strong>
                    </li>
                    <li>
                        <i class="an-dot an-green">
                        </i>
                        Paid
                        <strong>
                            <%= billsPaid %>
                        </strong>
                    </li>
                    <li>
                        <i class="an-dot an-gray">
                        </i>
                        Cancelled
                        <strong>
                            <%= billsCancelled %>
                        </strong>
                    </li>
                </ul>
            </section>
            <section class="an-panel">
                <h2>
                    Bookings per month
                </h2>
                <% if (bookingsByMonth.isEmpty()) { %>
                    <p class="an-muted">
                        No booking dates yet.
                    </p>
                <% } else { %>
                    <div class="an-cols">
                        <% for (Map.Entry<String, Integer> e : bookingsByMonth.entrySet()) { int h = Math.max(8, Math.round(e.getValue() * 120.0f / maxMonthCount)); %>
                        <div class="an-col" title="<%= e.getKey() %> : <%= e.getValue() %> bookings">
                            <span class="an-col-val">
                                <%= e.getValue() %>
                            </span>
                            <span class="an-col-bar" style="height: <%= h %> px;">
                            </span>
                            <span class="an-col-label">
                                <%= e.getKey().substring(2) %>
                            </span>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </section>
        <section class="an-panel">
            <h2>
                Top customers by spend
            </h2>
            <% if (topCustomers.isEmpty()) { %>
                <p class="an-muted">
                    No customer spending yet.
                </p>
            <% } else { %>
                <div class="an-table-scroll">
                    <table class="an-table">
                        <thead>
                            <tr>
                                <th>
                                    Customer
                                </th>
                                <th>
                                    Bookings
                                </th>
                                <th>
                                    Total spent
                                </th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                int r = 0;
                                for (Map.Entry<Integer, BigDecimal> e : topCustomers) { if (r++ >= 8) break;
                                User cu = userDAO.getCustomerById(e.getKey());
                            %>
                            <tr>
                                <td>
                                    <strong>
                                        <%= cu == null ? ("#" + e.getKey()) : com.eventsphere.util.EscapeUtil.e(cu.getFullName()) %>
                                    </strong>
                                </td>
                                <td>
                                    <%= bookingsByCustomer.get(e.getKey()) %>
                                </td>
                                <td>
                                    &#8377;
                                    <%= e.getValue() %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        <% } %>
    </section>
</div>
<section class="an-panel" style="margin-top: 1.25rem;">
    <h2>
        Recent admin activity
    </h2>
    <%
        java.util.List<com.eventsphere.model.AuditLog> activity = new com.eventsphere.dao.AuditDAO().latest(20);
        if (activity.isEmpty()) {
    %>
        <p class="an-muted">
            No admin actions recorded yet. Approvals, venue changes, promos and host actions appear here.
        </p>
    <% } else { %>
        <div class="an-table-scroll">
            <table class="an-table">
                <thead>
                    <tr>
                        <th>
                            When
                        </th>
                        <th>
                            Actor
                        </th>
                        <th>
                            Action
                        </th>
                        <th>
                            Target
                        </th>
                        <th>
                            Detail
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <% for (com.eventsphere.model.AuditLog a : activity) { %>
                        <tr>
                            <td style="white-space:nowrap;" title="<%= a.getCreatedAt() == null ? "" : com.eventsphere.util.EscapeUtil.e(a.getCreatedAt().toString()) %>">
                                <%= a.getCreatedAt() == null ? "-" : a.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                            </td>
                            <td>
                                <%= a.getActorRole() %>
                                <%= a.getActorId() == null ? "" : " #" + a.getActorId() %>
                            </td>
                            <td>
                                <strong>
                                    <%= a.getAction() %>
                                </strong>
                            </td>
                            <td>
                                <%= a.getTargetType() == null ? "-" : a.getTargetType() + (a.getTargetId() == null ? "" : " #" + a.getTargetId()) %>
                            </td>
                            <td>
                                <%= a.getDetail() == null ? "-" : com.eventsphere.util.EscapeUtil.e(a.getDetail()) %>
                            </td>
                        </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    <% } %>
</section>
</main>
</body>
</html>
