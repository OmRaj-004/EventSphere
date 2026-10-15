<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> notes = notificationDAO.listForUser(user.getId(), "CUSTOMER", 50);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Notifications - EventSphere
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
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
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
        <main class="container cust-wrap">
            <div class="cust-banner">
                <div>
                    <p class="cust-eyebrow">
                        Inbox
                    </p>
                    <h1>
                        Notifications
                    </h1>
                    <p class="cust-sub">
                        Booking updates and replies
                    </p>
                </div>
                <div class="cust-banner-actions">
                    <a href="${pageContext.request.contextPath}/notifications?do=all&back=/customer/notifications.jsp" class="btn btn-primary">
                        Mark all read
                    </a>
                </div>
            </div>
            <% if (notes.isEmpty()) { %>
                <div class="alert alert-info">
                    No notifications yet.
                </div>
            <% } else { %>
                <div class="cust-review-list">
                    <% for (Notification n : notes) { %>
                        <div class="cust-panel cust-note<%= n.isRead() ? "" : " cust-note-unread" %>">
                            <div class="cust-review-head">
                                <strong>
                                    <%= com.eventsphere.util.EscapeUtil.e(n.getTitle()) %>
                                </strong>
                                <span class="cust-muted">
                                    <%= com.eventsphere.util.FormatUtil.dt(n.getCreatedAt()) %>
                                </span>
                            </div>
                            <p>
                                <%= n.getBody() == null ? "" : com.eventsphere.util.EscapeUtil.e(n.getBody()) %>
                            </p>
                            <div class="cust-review-actions">
                                <% if (n.getLink() != null && !n.getLink().isBlank()) { %>
                                    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}<%= n.getLink() %>">
                                        Open
                                    </a>
                                <% } %>
                                <% if (!n.isRead()) { %>
                                    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/notifications?read=<%= n.getId() %> &back=/customer/notifications.jsp">
                                        Mark read
                                    </a>
                                <% } %>
                            </div>
                        </div>
                    <% } %>
                </div>
            <% } %>
        </main>
    </body>
</html>
