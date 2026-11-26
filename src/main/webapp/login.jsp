<%-- EventSphere project (TYBCA) - login page with three separate forms (admin / customer / host), each posting its role. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Login - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=11">
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <ul class="nav-links">
                    <li>
                        <a href="${pageContext.request.contextPath}/">
                            Home
                        </a>
                    </li>
                </ul>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">
                        Register
                    </a>
                </div>
            </div>
        </nav>
        <main>
        <!-- Login Forms -->
        <section class="login-page">
            <div class="container">
                <div class="login-grid">
                    <div class="card">
                        <h2 class="card-header">
                            Admin Login
                        </h2>
                        <div class="alert alert-info">
                            Use this form for event administrators.
                        </div>
                        <form class="login-form" method="POST" action="${pageContext.request.contextPath}/login" onsubmit="return validateLoginForm(this)">
                            <input type="hidden" name="role" value="ADMIN">
                            <div class="form-group">
                                <label for="adminEmail">
                                    Email
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="email" id="adminEmail" name="email" required placeholder="Admin email address" autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="adminPassword">
                                    Password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="adminPassword" name="password" required placeholder="Admin password" autocomplete="current-password">
                            </div>
                            <div class="form-group">
                                <label>
                                    <input type="checkbox" name="rememberMe" value="1">
                                    Remember me for 30 days
                                </label>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Admin Login
                            </button>
                        </form>
                    </div>
                    <div class="card">
                        <h2 class="card-header">
                            Customer Login
                        </h2>
                        <div class="alert alert-info">
                            Use this form for normal event customers.
                        </div>
                        <form class="login-form" method="POST" action="${pageContext.request.contextPath}/login" onsubmit="return validateLoginForm(this)">
                            <input type="hidden" name="role" value="CUSTOMER">
                            <div class="form-group">
                                <label for="customerEmail">
                                    Email
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="email" id="customerEmail" name="email" required placeholder="Customer email address" autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="customerPassword">
                                    Password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="customerPassword" name="password" required placeholder="Customer password" autocomplete="current-password">
                            </div>
                            <div class="form-group">
                                <label>
                                    <input type="checkbox" name="rememberMe" value="1">
                                    Remember me for 30 days
                                </label>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Customer Login
                            </button>
                        </form>
                    </div>
                    <div class="card">
                        <h2 class="card-header">
                            Host Login
                        </h2>
                        <div class="alert alert-info">
                            Use this form for venue hosts.
                        </div>
                        <form class="login-form" method="POST" action="${pageContext.request.contextPath}/login" onsubmit="return validateLoginForm(this)">
                            <input type="hidden" name="role" value="HOST">
                            <div class="form-group">
                                <label for="hostEmail">
                                    Email
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="email" id="hostEmail" name="email" required placeholder="Host email address" autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="hostPassword">
                                    Password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="hostPassword" name="password" required placeholder="Host password" autocomplete="current-password">
                            </div>
                            <div class="form-group">
                                <label>
                                    <input type="checkbox" name="rememberMe" value="1">
                                    Remember me for 30 days
                                </label>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Host Login
                            </button>
                        </form>
                    </div>
                </div>
                <div class="login-footer">
                    <!-- Error Message -->
                    <%
                        String error = (String) request.getAttribute("error");
                        if (error != null) {
                    %>
                        <div class="alert alert-error">
                            <%= error %>
                        </div>
                    <% } %>
                    <%
                        String resetOk = (String) request.getAttribute("success");
                        if (resetOk != null) {
                    %>
                        <div class="alert alert-success">
                            <%= resetOk %>
                        </div>
                    <% } %>
                    <div id="error-message" class="alert alert-error hidden">
                    </div>
                    <div class="login-links">
                        <p>
                            Don't have an account?
                            <a href="${pageContext.request.contextPath}/register" class="login-link register-link">
                                Register here
                            </a>
                        </p>
                        <p class="login-link-text">
                            <a href="${pageContext.request.contextPath}/forgot-password" class="login-link forgot-link">
                                Forgot password? Reset it here
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </section>
        <!-- Footer -->
                </main>
<footer class="footer footer-compact">
            <div class="footer-container">
                <p>
                    &copy;
                    <%= java.time.Year.now() %>
                    EventSphere. All rights reserved.
                </p>
            </div>
        </footer>
        <script src="${pageContext.request.contextPath}/js/script.js?v=12">
        </script>
    </body>
</html>
