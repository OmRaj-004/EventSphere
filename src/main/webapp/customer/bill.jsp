<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.math.BigDecimal,com.eventsphere.model.*" %>
<%
    User customer = (User) session.getAttribute("user");
    if (customer == null || !customer.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
Booking booking = (Booking) request.getAttribute("booking");
    if (booking == null) { response.sendError(404);
    return;
    }
Bill bill = (Bill) request.getAttribute("bill");
    Event event = (Event) request.getAttribute("event");
    Venue venue = (Venue) request.getAttribute("venue");
    BigDecimal hours = (BigDecimal) request.getAttribute("hours");
    BigDecimal rate = (BigDecimal) request.getAttribute("rate");
    BigDecimal advance = (BigDecimal) request.getAttribute("advance");
    BigDecimal total = (BigDecimal) request.getAttribute("total");
    BigDecimal balance = (BigDecimal) request.getAttribute("balance");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Bill
            <%= bill == null ? booking.getBookingNumber() : bill.getBillNumber() %>
            - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body class="bill-page">
        <nav class="navbar no-print">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
<<<<<<< HEAD
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
=======
                    <img src="${pageContext.request.contextPath}/images/EventSphere Logo.png" alt="EventSphere" class="brand-logo">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
                </a>
                <div class="auth-buttons">
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
        <main class="container bill-wrap">
            <div class="bill-actions no-print">
                <a href="${pageContext.request.contextPath}/customer/dashboard.jsp" class="btn btn-outline">
                    &larr; Back to My Bookings
                </a>
                <span>
                    <a href="${pageContext.request.contextPath}/bill.pdf?id=<%= booking.getId() %>" class="btn btn-outline">
                        Download PDF
                    </a>
                    <button class="btn btn-primary" type="button" onclick="window.print()" style="margin-left:0.5rem;">
                        Print
                    </button>
                </span>
            </div>
            <section class="bill-sheet">
                <div class="bill-head">
                    <div>
                        <img src="${pageContext.request.contextPath}/images/EventSphere Logo.png" alt="EventSphere" class="bill-logo">
                        <p class="bill-company">
                            EventSphere Venue Bookings
                            <br>
                            <span>
                                support@eventsphere.com &middot; +91 8421 68766
                            </span>
                        </p>
                    </div>
                    <div class="bill-title">
                        <h1>
                            INVOICE
                        </h1>
                        <p>
                            <strong>
                                <%= bill == null ? booking.getBookingNumber() : bill.getBillNumber() %>
                            </strong>
                        </p>
                        <p style="font-size:0.85rem;">
                            Booking ref:
                            <%= booking.getBookingNumber() %>
                            <% if (bill != null && bill.getCreatedAt() != null) { %>
                                <br>
                                Issued:
                                <%= bill.getCreatedAt().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm")) %>
                            <% } %>
                        </p>
                        <span class="bill-pill bill-pill-<%= booking.getStatus().toLowerCase() %>">
                            <%= booking.getStatus() %>
                        </span>
                    </div>
                </div>
                <div class="bill-grid">
                    <div>
                        <h2>
                            Billed To
                        </h2>
                        <p>
                            <strong>
                                <%= com.eventsphere.util.EscapeUtil.e(customer.getFullName()) %>
                            </strong>
                            <br>
                            <%= com.eventsphere.util.EscapeUtil.e(customer.getEmail()) %>
                        </p>
                    </div>
                    <div>
                        <h2>
                            Booking Info
                        </h2>
                        <p>
                            Booking date:
                            <strong>
                                <%= booking.getBookingDate() %>
                            </strong>
                            <br>
                            Payment:
                            <strong>
                                <%= booking.getPaymentMethod() == null ? "Not specified" : booking.getPaymentMethod() %>
                            </strong>
                            <% if (booking.getTransactionId() != null) { %>
                                <br>
                                Txn:
                                <%= booking.getTransactionId() %>
                            <% } %>
                        </p>
                    </div>
                    <div>
                        <h2>
                            Event
                        </h2>
                        <p>
                            <strong>
                                <%= event == null ? "-" : com.eventsphere.util.EscapeUtil.e(event.getName()) %>
                            </strong>
                            <br>
                            <%= event == null ? "" : com.eventsphere.util.EscapeUtil.e(event.getEventType()) %>
                            <% if (event != null && event.getEventDate() != null) { %>
                                <br>
                                <%= event.getEventDate() %>
                                &middot;
                                <%= event.getStartTime() %>
                                -
                                <%= event.getEndTime() %>
                            <% } %>
                            <% if (event != null) { %>
                                <br>
                                <%= event.getExpectedGuests() %>
                                guests
                            <% } %>
                        </p>
                    </div>
                    <div>
                        <h2>
                            Venue
                        </h2>
                        <p>
                            <strong>
                                <%= venue == null ? "-" : com.eventsphere.util.EscapeUtil.e(venue.getName()) %>
                            </strong>
                            <br>
                            <%= venue == null ? "" : com.eventsphere.util.EscapeUtil.e(venue.getLocation()) %>
                        </p>
                    </div>
                </div>
                <table class="bill-table">
                    <thead>
                        <tr>
                            <th>
                                Description
                            </th>
                            <th>
                                Hours
                            </th>
                            <th>
                                Rate (&#8377;/hr)
                            </th>
                            <th>
                                Amount (&#8377;)
                            </th>
                        </tr>
                    </thead>
                    <tbody>
                        <% java.math.BigDecimal gross = total.add(booking.getDiscountAmount() == null ? java.math.BigDecimal.ZERO : booking.getDiscountAmount()); %>
                        <tr>
                            <td>
                                Venue hire -
                                <%= venue == null ? "Venue" : com.eventsphere.util.EscapeUtil.e(venue.getName()) %>
                                <%= event == null ? "" : " (" + com.eventsphere.util.EscapeUtil.e(event.getName()) + ")" %>
                            </td>
                            <td>
                                <%= hours %>
                            </td>
                            <td>
                                <%= rate %>
                            </td>
                            <td>
                                Rs.
                                <%= gross %>
                            </td>
                        </tr>
                    </tbody>
                    <tfoot>
                        <% if (booking.getDiscountAmount() != null && booking.getDiscountAmount().signum() > 0) { %>
                            <tr>
                                <td colspan="3">
                                    Promo discount
                                </td>
                                <td>
                                    - Rs.
                                    <%= booking.getDiscountAmount() %>
                                </td>
                            </tr>
                        <% } %>
                        <tr>
                            <td colspan="3">
                                Subtotal
                            </td>
                            <td>
                                Rs.
                                <%= total %>
                            </td>
                        </tr>
                        <tr>
                            <td colspan="3">
                                Advance paid
                            </td>
                            <td>
                                Rs.
                                <%= advance %>
                            </td>
                        </tr>
                        <tr class="bill-due">
                            <td colspan="3">
                                Balance due
                            </td>
                            <td>
                                Rs.
                                <%= balance %>
                            </td>
                        </tr>
                    </tfoot>
                </table>
                <% if (booking.getNotes() != null && !booking.getNotes().isBlank()) { %>
                    <p class="bill-notes">
                        <strong>
                            Notes:
                        </strong>
                        <%= com.eventsphere.util.EscapeUtil.e(booking.getNotes()) %>
                    </p>
                <% } %>
                <p class="bill-foot">
                    Thank you for booking with EventSphere. This is a computer-generated invoice for booking
                    <%= booking.getBookingNumber() %>
                    . For support, contact support@eventsphere.com.
                </p>
            </section>
        </main>
    </body>
</html>
