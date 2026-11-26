<%-- EventSphere project (TYBCA) - new customer registration form. Public sign-up always creates CUSTOMER accounts only. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Register - EventSphere
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
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">
                        Login
                    </a>
                </div>
            </div>
        </nav>
        <main>
        <!-- Registration Form -->
        <section class="register-page">
            <div class="container">
                <div class="register-form-container">
                    <div class="card">
                        <h2 class="card-header">
                            Create Account
                        </h2>
                        <!-- Error Message -->
                        <%
                            String error = (String) request.getAttribute("error");
                            if (error != null) {
                        %>
                            <div class="alert alert-error">
                                <%= error %>
                            </div>
                        <% } %>
                        <!-- Success Message -->
                        <%
                            String success = (String) request.getAttribute("success");
                            if (success != null) {
                        %>
                            <div class="alert alert-success">
                                <%= success %>
                                <p class="register-success-link">
                                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary btn-block">
                                        Go to Login
                                    </a>
                                </p>
                            </div>
                        <% } %>
                        <form method="POST" action="${pageContext.request.contextPath}/register" onsubmit="return validateForm()">
                            <div class="form-group">
                                <label for="fullName">
                                    Full Name
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="text" id="fullName" name="fullName" required placeholder="Enter your full name" autocomplete="name">
                            </div>
                            <div class="form-group">
                                <label for="email">
                                    Email
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="email" id="email" name="email" required placeholder="Enter your email address" autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="password">
                                    Password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="password" name="password" required placeholder="Minimum 6 characters" autocomplete="new-password">
                                <small class="password-hint">
                                    Password must be at least 6 characters long
                                </small>
                            </div>
                            <div class="form-group">
                                <label for="confirmPassword">
                                    Confirm Password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter your password" autocomplete="new-password">
                            </div>
                            <div id="error-message" class="alert alert-error hidden">
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Create Account
                            </button>
                        </form>
                        <div class="register-login-link">
                            <p>
                                Already have an account?
                                <a href="${pageContext.request.contextPath}/login" class="login-link register-link">
                                    Login here
                                </a>
                            </p>
                        </div>
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
