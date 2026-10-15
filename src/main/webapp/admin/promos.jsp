<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403);
    return;
    }
PromoDAO promoDAO = new PromoDAO();
    List<PromoCode> promos = promoDAO.getAllPromos();
    String okMsg = (String) session.getAttribute("adminPromoSuccess");
    session.removeAttribute("adminPromoSuccess");
    String errMsg = (String) session.getAttribute("adminPromoError");
    session.removeAttribute("adminPromoError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Promo Codes - EventSphere
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
                        Discounts
                    </p>
                    <h1>
                        Promo Codes
                    </h1>
                    <p class="bk-sub">
                        Customers apply these at booking time for a percentage discount.
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
                        Create promo
                    </h2>
                    <form method="post" action="${pageContext.request.contextPath}/admin/promos">
                        <input type="hidden" name="action" value="create">
                        <div class="form-group">
                            <label for="code">
                                Code *
                            </label>
                            <input id="code" name="code" required maxlength="30" placeholder="e.g. DIWALI25" style="text-transform:uppercase">
                        </div>
                        <div class="form-group">
                            <label for="percent">
                                Percent off (1-90) *
                            </label>
                            <input id="percent" name="percent" type="number" min="1" max="90" required value="10">
                        </div>
                        <div class="form-group">
                            <label for="maxUses">
                                Max uses *
                            </label>
                            <input id="maxUses" name="maxUses" type="number" min="1" required value="100">
                        </div>
                        <button class="btn btn-primary" type="submit">
                            Create
                        </button>
                    </form>
                </section>
                <section class="bk-panel">
                    <h2 class="panel-title">
                        Existing codes
                    </h2>
                    <% if (promos.isEmpty()) { %>
                        <div class="alert alert-info">
                            No promo codes yet.
                        </div>
                    <% } else { %>
                        <div class="bk-table-scroll">
                            <table class="bk-table">
                                <thead>
                                    <tr>
                                        <th>
                                            Code
                                        </th>
                                        <th>
                                            Off
                                        </th>
                                        <th>
                                            Used
                                        </th>
                                        <th>
                                            Status
                                        </th>
                                        <th>
                                            Action
                                        </th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (PromoCode p : promos) { %>
                                        <tr>
                                            <td>
                                                <strong>
                                                    <%= p.getCode() %>
                                                </strong>
                                            </td>
                                            <td>
                                                <%= p.getPercentOff() %>
                                                %
                                            </td>
                                            <td>
                                                <%= p.getUsedCount() %>
                                                /
                                                <%= p.getMaxUses() %>
                                            </td>
                                            <td>
                                                <span class="bk-pill <%= p.isUsable() ? "bk-pill-approved" : "bk-pill-cancelled" %>">
                                                    <%= p.isUsable() ? "Active" : "Exhausted" %>
                                                </span>
                                            </td>
                                            <td>
                                                <form method="post" action="${pageContext.request.contextPath}/admin/promos" style="display:inline;">
                                                    <input type="hidden" name="action" value="toggle">
                                                    <input type="hidden" name="id" value="<%= p.getId() %>">
                                                    <% if (p.isActive()) { %>
                                                        <button class="btn btn-outline btn-sm" type="submit">
                                                            Disable
                                                        </button>
                                                    <% } else { %>
                                                        <input type="hidden" name="active" value="1">
                                                        <button class="btn btn-success btn-sm" type="submit">
                                                            Enable
                                                        </button>
                                                    <% } %>
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
    </body>
</html>
