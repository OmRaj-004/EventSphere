<%-- EventSphere project (TYBCA) - login page with three separate forms (admin / customer / host), each posting its role. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Login - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
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
        <!-- Login Forms -->
        <section style="padding: 3rem 2rem; background-color: var(--gray-lighter);">
            <div class="container">
                <div class="login-grid" style="display: grid; grid-template-columns: repeat(3, minmax(260px, 1fr)); gap: 2rem; align-items: stretch; max-width: 1200px; margin: 0 auto;">
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
                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
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
                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
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
                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
                                Host Login
                            </button>
                        </form>
                    </div>
                </div>
                <div style="max-width: 500px; margin: 1rem auto 0;">
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
                    <div id="error-message" style="display: none;" class="alert alert-error">
                    </div>
                    <div style="margin-top: 1.5rem; text-align: center;">
                        <p>
                            Don't have an account?
                            <a href="${pageContext.request.contextPath}/register" style="color: var(--primary-color); font-weight: bold;">
                                Register here
                            </a>
                        </p>
                        <p style="margin-top: 0.5rem;">
                            <a href="${pageContext.request.contextPath}/forgot-password" style="color: var(--text-light); font-size: 0.9rem;">
                                Forgot password? Reset it here
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </section>
        <!-- Footer -->
        <footer class="footer" style="margin-top: 3rem;">
            <div class="footer-container">
                <p>
                    &copy;
                    <%= java.time.Year.now() %>
                    EventSphere. All rights reserved.
                </p>
            </div>
        </footer>
        <script src="${pageContext.request.contextPath}/js/script.js">
        </script>
    </body>
</html>
