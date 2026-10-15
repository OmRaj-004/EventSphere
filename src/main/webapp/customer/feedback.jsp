<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null || !user.isCustomer()) { response.sendRedirect(request.getContextPath()+"/login");
    return;
    }
FeedbackDAO feedbackDAO = new FeedbackDAO();
    VenueDAO venueDAO = new VenueDAO();
    List<Feedback> myFeedback = feedbackDAO.getFeedbackByCustomer(user.getId());
    String okMsg = (String) session.getAttribute("feedbackDeleteSuccess");
    session.removeAttribute("feedbackDeleteSuccess");
    String errMsg = (String) session.getAttribute("feedbackDeleteError");
    session.removeAttribute("feedbackDeleteError");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            My Reviews - EventSphere
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
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-outline">
                        Browse Venues
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
                        My reviews
                    </p>
                    <h1>
                        Reviews by
                        <%= com.eventsphere.util.EscapeUtil.e(user.getFullName()) %>
                    </h1>
                    <p class="cust-sub">
                        <%= myFeedback.size() %>
                        review
                        <%= myFeedback.size() == 1 ? "" : "s" %>
                        submitted
                    </p>
                </div>
                <div class="cust-banner-actions">
                    <a href="${pageContext.request.contextPath}/venues" class="btn btn-primary">
                        Review a Venue
                    </a>
                </div>
            </div>
            <% if (okMsg != null) { %>
                <div class="cust-toast cust-toast-success">
                    <%= okMsg %>
                </div>
            <% } else if (errMsg != null) { %>
                <div class="cust-toast cust-toast-error">
                    <%= errMsg %>
                </div>
            <% } %>
            <% if (myFeedback.isEmpty()) { %>
                <div class="alert alert-info">
                    You have not reviewed any venue yet. Reviews unlock after an approved booking -
                    <a href="${pageContext.request.contextPath}/venues">
                        browse venues
                    </a>
                    .
                </div>
            <% } else { %>
                <div class="cust-review-list">
                    <% for (Feedback fb : myFeedback) { Venue v = venueDAO.getVenueById(fb.getVenueId()); %>
                    <div class="cust-panel cust-review">
                        <div class="cust-review-head">
                            <strong>
                                <%= fb.getRating() %>
                                /5 -
                                <%= v == null ? "Venue" : com.eventsphere.util.EscapeUtil.e(v.getName()) %>
                            </strong>
                            <span class="cust-muted">
                                <%= com.eventsphere.util.FormatUtil.dt(fb.getCreatedAt()) %>
                            </span>
                        </div>
                        <% if (fb.getImageUrl() != null && !fb.getImageUrl().isBlank()) { %>
                            <img src="${pageContext.request.contextPath}<%= fb.getImageUrl() %>" alt="Review photo" class="cust-review-photo">
                        <% } %>
                        <p>
                            <%= fb.getComment() == null ? "" : com.eventsphere.util.EscapeUtil.e(fb.getComment()) %>
                        </p>
                        <% if (fb.getAdminReply() != null && !fb.getAdminReply().isBlank()) { %>
                            <div class="cust-host-reply">
                                <strong>
                                    Host reply:
                                </strong>
                                <%= com.eventsphere.util.EscapeUtil.e(fb.getAdminReply()) %>
                            </div>
                        <% } %>
                        <div class="cust-review-actions">
                            <% if (v != null) { %>
                                <a class="btn btn-outline btn-sm" href="${pageContext.request.contextPath}/venues?action=details&id=<%= v.getId() %>">
                                    View venue
                                </a>
                            <% } %>
                            <form method="post" action="${pageContext.request.contextPath}/feedback/delete" onsubmit="return confirmAction('Delete this review?')" style="display:inline;">
                                <input type="hidden" name="id" value="<%= fb.getId() %>">
                                <button class="btn btn-danger btn-sm" type="submit">
                                    Delete
                                </button>
                            </form>
                        </div>
                    </div>
                <% } %>
            </div>
        <% } %>
    </main>
    <script src="${pageContext.request.contextPath}/js/script.js?v=5">
    </script>
</body>
</html>
