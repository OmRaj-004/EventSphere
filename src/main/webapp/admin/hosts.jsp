<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
UserDAO userDAO = new UserDAO();
    VenueDAO venueDAO = new VenueDAO();
    List<User> hosts = userDAO.getAllHosts();
    String okMsg = (String) session.getAttribute("adminHostSuccess");
    session.removeAttribute("adminHostSuccess");
    String errMsg = (String) session.getAttribute("adminHostError");
    session.removeAttribute("adminHostError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Hosts - EventSphere
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
                        User management
                    </p>
                    <h1>
                        Venue Hosts
                    </h1>
                    <p class="bk-sub">
                        Hosts list their own venues; approvals stay with admins.
                    </p>
                </div>
            </div>
            <% if (okMsg != null) { %>
                <div class="bk-toast bk-toast-success">
                    <%= okMsg %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="bk-toast bk-toast-error">
                    <%= errMsg %>
                </div>
            <% } %>
            <div class="bk-grid-2">
                <section class="bk-panel">
                    <h2 class="panel-title">
                        Create host
                    </h2>
                    <form method="post" action="${pageContext.request.contextPath}/admin/hosts">
                        <input type="hidden" name="action" value="create">
                        <div class="form-group">
                            <label for="fullName">
                                Full name *
                            </label>
                            <input id="fullName" name="fullName" required maxlength="100">
                        </div>
                        <div class="form-group">
                            <label for="email">
                                Email *
                            </label>
                            <input id="email" name="email" type="email" required>
                        </div>
                        <div class="form-group">
                            <label for="password">
                                Password (min 6) *
                            </label>
                            <input id="password" name="password" type="password" required>
                        </div>
                        <button class="btn btn-primary" type="submit">
                            Create Host
                        </button>
                    </form>
                </section>
                <section class="bk-panel">
                    <h2 class="panel-title">
                        Existing hosts (
                        <%= hosts.size() %>
                        )
                    </h2>
                    <% if (hosts.isEmpty()) { %>
                        <div class="alert alert-info">
                            No hosts yet.
                        </div>
                    <% } else { %>
                        <div class="bk-table-scroll">
                            <table class="bk-table">
                                <thead>
                                    <tr>
                                        <th>
                                            Name
                                        </th>
                                        <th>
                                            Email
                                        </th>
                                        <th>
                                            Venues
                                        </th>
                                        <th>
                                            Action
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (User h : hosts) { %>
                                        <tr>
                                            <td>
                                                <strong>
                                                    <%= com.eventsphere.util.EscapeUtil.e(h.getFullName()) %>
                                                </strong>
                                            </td>
                                            <td>
                                                <%= com.eventsphere.util.EscapeUtil.e(h.getEmail()) %>
                                            </td>
                                            <td>
                                                <%= venueDAO.getVenuesByHost(h.getId()).size() %>
                                            </td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/hosts" onsubmit="return confirmAction('Remove this host? Their venues stay listed.')" style="display:inline;">
                                                    <input type="hidden" name="action" value="delete">
                                                    <input type="hidden" name="id" value="<%= h.getId() %>">
                                                    <button class="btn btn-danger btn-sm" type="submit">
                                                        Remove
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                    <% } %>
                </section>
            </div>
        </main>
<<<<<<< HEAD
        <script src="${pageContext.request.contextPath}/js/script.js">
=======
        <script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
        </script>
    </body>
</html>
