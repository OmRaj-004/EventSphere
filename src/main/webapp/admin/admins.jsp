<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ page import="java.util.List,com.eventsphere.model.*,com.eventsphere.dao.*,com.eventsphere.util.EscapeUtil" %>
<% if (!"ADMIN".equals(session.getAttribute("userRole"))) { response.sendError(403); return; }
UserDAO userDAO = new UserDAO();
List<User> admins = userDAO.getAllAdmins();
Object selfId = session.getAttribute("userId");
String okMsg = (String) session.getAttribute("adminAdminSuccess"); session.removeAttribute("adminAdminSuccess");
String errMsg = (String) session.getAttribute("adminAdminError"); session.removeAttribute("adminAdminError"); %>
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Admins - EventSphere</title><link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg"><link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=5"></head>
<body class="bk-page"><nav class="navbar"><div class="navbar-container"><a href="${pageContext.request.contextPath}/" class="navbar-brand"><img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo"></a><div class="auth-buttons"><a href="${pageContext.request.contextPath}/" class="btn btn-outline">Home</a><a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-outline">Dashboard</a><a href="${pageContext.request.contextPath}/admin/analytics.jsp" class="btn btn-outline">Analytics</a><form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline;"><button type="submit" class="btn btn-primary">Logout</button></form></div></div></nav>
<main class="container bk-wrap">
<div class="bk-head"><div><p class="bk-eyebrow">User management</p><h1>Administrators</h1><p class="bk-sub">All admins are equal. Nobody can remove their own account or the last admin.</p></div></div>
<% if (okMsg != null) { %><div class="bk-toast bk-toast-success"><%= EscapeUtil.e(okMsg) %></div><% } else if (errMsg != null) { %><div class="bk-toast bk-toast-error"><%= EscapeUtil.e(errMsg) %></div><% } %>
<div class="bk-grid-2">
<section class="bk-panel"><h2 class="panel-title">Add new admin</h2>
<form method="post" action="${pageContext.request.contextPath}/admin/admins">
<input type="hidden" name="action" value="create">
<div class="form-group"><label for="fullName">Full name *</label><input id="fullName" name="fullName" required maxlength="100" autocomplete="name"></div>
<div class="form-group"><label for="email">Email *</label><input id="email" name="email" type="email" required autocomplete="email"></div>
<div class="form-group"><label for="password">Password (min 6) *</label><input id="password" name="password" type="password" required autocomplete="new-password"></div>
<button class="btn btn-primary" type="submit">Create Admin</button>
</form></section>
<section class="bk-panel"><h2 class="panel-title">Existing admins (<%= admins.size() %>)</h2>
<% if (admins.isEmpty()) { %><div class="alert alert-info">No admins found.</div><% } else { %>
<div class="bk-table-scroll"><table class="bk-table"><thead><tr><th>Name</th><th>Email</th><th>Joined</th><th>Action</th></tr></thead><tbody>
<% for (User ad : admins) { boolean isSelf = selfId instanceof Integer && ((Integer) selfId) == ad.getId(); %>
<tr><td><strong><%= EscapeUtil.e(ad.getFullName()) %></strong><%= isSelf ? " (you)" : "" %></td><td><%= EscapeUtil.e(ad.getEmail()) %></td><td style="white-space:nowrap;"><%= ad.getCreatedAt() == null ? "-" : ad.getCreatedAt().toLocalDate() %></td>
<td><% if (!isSelf) { %><form method="post" action="${pageContext.request.contextPath}/admin/admins" onsubmit="return confirmAction('Remove this admin? They will lose all admin access immediately.')" style="display:inline;"><input type="hidden" name="action" value="delete"><input type="hidden" name="id" value="<%= ad.getId() %>"><button class="btn btn-danger btn-sm" type="submit">Remove</button></form><% } else { %><span class="bk-muted">current login</span><% } %></td></tr>
<% } %>
</tbody></table></div>
<% } %>
</section>
</div>
</main>
<script src="${pageContext.request.contextPath}/js/script.js"></script>
</body></html>
