<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
User adminUser = (User) session.getAttribute("user");
    NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> notes = adminUser == null ? new java.util.ArrayList<Notification>() : notificationDAO.listForUser(adminUser.getId(), "ADMIN", 50);
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Notifications - EventSphere
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
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline">
                        Home
                    </a>
                    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">
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
        <main class="container bk-wrap">
            <div class="bk-head">
                <div>
                    <p class="bk-eyebrow">
                        Inbox
                    </p>
                    <h1>
                        Notifications
                    </h1>
                    <p class="bk-sub">
                        System updates for administrators
                    </p>
                </div>
                <div class="bk-head-actions">
                    <a href="${pageContext.request.contextPath}/notifications?do=all&back=/admin/notifications.jsp" class="btn btn-primary">
                        Mark all read
                    </a>
                </div>
            </div>
            <% if (notes.isEmpty()) { %>
                <div class="alert alert-info">
                    No notifications yet.
                </div>
            <% } else { %>
                <div class="bk-panel">
                    <% for (Notification n : notes) { %>
                        <div class="bk-note<%= n.isRead() ? "" : " bk-note-unread" %>">
                            <div>
                                <strong>
                                    <%= com.eventsphere.util.EscapeUtil.e(n.getTitle()) %>
                                </strong>
                                <br>
                                <span class="bk-muted">
                                    <%= n.getBody() == null ? "" : com.eventsphere.util.EscapeUtil.e(n.getBody()) %>
                                </span>
                            </div>
                            <div class="bk-note-side">
                                <span class="bk-muted">
                                    <%= com.eventsphere.util.FormatUtil.dt(n.getCreatedAt()) %>
                                </span>
                                <% if (n.getLink() != null && !n.getLink().isBlank()) { %>
                                    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}<%= n.getLink() %>">
                                        Open
                                    </a>
                                <% } %>
                                <% if (!n.isRead()) { %>
                                    <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/notifications?read=<%= n.getId() %> &back=/admin/notifications.jsp">
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
