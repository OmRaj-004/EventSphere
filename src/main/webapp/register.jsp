<%-- EventSphere project (TYBCA) - new customer registration form. Public sign-up always creates CUSTOMER accounts only. --%>
<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Register - EventSphere
        </title>
<<<<<<< HEAD
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
=======
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/images/EventSphere Logo.png">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
    </head>
    <body>
        <!-- Navigation Bar -->
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
<<<<<<< HEAD
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
=======
                    <img src="${pageContext.request.contextPath}/images/EventSphere Logo.png" alt="EventSphere" class="brand-logo">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
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
        <!-- Registration Form -->
        <section style="padding: 3rem 2rem; background-color: var(--gray-lighter);">
            <div class="container">
                <div style="max-width: 500px; margin: 0 auto;">
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
                                <p style="margin-top: 1rem;">
                                    <a href="${pageContext.request.contextPath}/login" class="btn btn-primary">
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
                                <small style="color: var(--text-light); margin-top: 0.25rem; display: block;">
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
                            <div id="error-message" style="display: none;" class="alert alert-error">
                            </div>
                            <button type="submit" class="btn btn-primary" style="width: 100%; margin-top: 1rem;">
                                Create Account
                            </button>
                        </form>
                        <div style="margin-top: 1.5rem; text-align: center;">
                            <p>
                                Already have an account?
                                <a href="${pageContext.request.contextPath}/login" style="color: var(--primary-color); font-weight: bold;">
                                    Login here
                                </a>
                            </p>
                        </div>
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
<<<<<<< HEAD
        <script src="${pageContext.request.contextPath}/js/script.js">
=======
        <script src="${pageContext.request.contextPath}/js/script.js?v=6">
>>>>>>> 83a82695c72a46a2fa46013eb6b785b5572bcbbd
        </script>
    </body>
</html>
