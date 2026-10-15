<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    User host = (User) session.getAttribute("user");
    if (host == null || !host.isHost()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
NotificationDAO notificationDAO = new NotificationDAO();
    List<Notification> notes = notificationDAO.listForUser(host.getId(), "HOST", 50);
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
    <body class="host-page">
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
                        Inbox
                    </p>
                    <h1>
                        Notifications
                    </h1>
                </div>
                <div class="host-banner-actions">
                    <a href="${pageContext.request.contextPath}/notifications?do=all&back=/host/notifications.jsp" class="btn btn-primary">
                        Mark all read
                    </a>
                </div>
            </div>
            <% if (notes.isEmpty()) { %>
                <div class="alert alert-info">
                    No notifications yet.
                </div>
            <% } else { %>
                <% for (Notification n : notes) { %>
                    <div class="host-panel host-note<%= n.isRead() ? "" : " host-note-unread" %>">
                        <div class="host-panel-head">
                            <strong>
                                <%= com.eventsphere.util.EscapeUtil.e(n.getTitle()) %>
                            </strong>
                            <span class="host-muted">
                                <%= com.eventsphere.util.FormatUtil.dt(n.getCreatedAt()) %>
                            </span>
                        </div>
                        <p>
                            <%= n.getBody() == null ? "" : com.eventsphere.util.EscapeUtil.e(n.getBody()) %>
                        </p>
                        <% if (n.getLink() != null && !n.getLink().isBlank()) { %>
                            <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}<%= n.getLink() %>">
                                Open
                            </a>
                        <% } %>
                        <% if (!n.isRead()) { %>
                            <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/notifications?read=<%= n.getId() %> &back=/host/notifications.jsp">
                                Mark read
                            </a>
                        <% } %>
                    </div>
                <% } %>
            <% } %>
        </main>
    </body>
</html>
