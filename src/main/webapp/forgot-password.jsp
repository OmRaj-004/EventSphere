<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Forgot Password - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=11">
    </head>
    <body>
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
                <div class="auth-buttons">
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline">
                        Login
                    </a>
                </div>
            </div>
        </nav>
        <main>
        <section class="forgot-page">
            <div class="container">
                <div class="register-form-container">
                    <div class="card">
                        <h2 class="card-header">
                            Reset Your Password
                        </h2>
                        <p class="text-muted-small">
                            Enter your account email and type. A single-use reset link valid for 30 minutes will be generated.
                        </p>
                        <%
                            String error = (String) request.getAttribute("error");
                            if (error != null) {
                        %>
                            <div class="alert alert-error">
                                <%= error %>
                            </div>
                        <% } %>
                        <%
                            String success = (String) request.getAttribute("success");
                            if (success != null) {
                        %>
                            <div class="alert alert-success">
                                <%= success %>
                            </div>
                        <% } %>
                        <form method="POST" action="${pageContext.request.contextPath}/forgot-password">
                            <div class="form-group">
                                <label for="email">
                                    Email
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="email" id="email" name="email" required placeholder="Your account email" autocomplete="email">
                            </div>
                            <div class="form-group">
                                <label for="role">
                                    Account type
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <select id="role" name="role" required>
                                    <option value="CUSTOMER">
                                        Customer
                                    </option>
                                    <option value="HOST">
                                        Host
                                    </option>
                                    <option value="ADMIN">
                                        Admin
                                    </option>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Send Reset Link
                            </button>
                        </form>
                        <div class="register-login-link">
                            <p>
                                <a href="${pageContext.request.contextPath}/login" class="login-link register-link">
                                    Back to login
                                </a>
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </section>
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
    </body>
</html>
