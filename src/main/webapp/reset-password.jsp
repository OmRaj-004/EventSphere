<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Set New Password - EventSphere
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
        <section class="reset-page">
            <div class="container">
                <div class="register-form-container">
                    <div class="card">
                        <h2 class="card-header">
                            Choose a New Password
                        </h2>
                        <%
                            String error = (String) request.getAttribute("error");
                            if (error != null) {
                        %>
                            <div class="alert alert-error">
                                <%= error %>
                            </div>
                        <% } %>
                        <form method="POST" action="${pageContext.request.contextPath}/reset-password" onsubmit="return validateResetForm(this)">
                            <input type="hidden" name="token" value="<%= request.getAttribute("token") == null ? "" : request.getAttribute("token") %>">
                            <div class="form-group">
                                <label for="password">
                                    New password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="password" name="password" required placeholder="Minimum 6 characters" autocomplete="new-password">
                            </div>
                            <div class="form-group">
                                <label for="confirmPassword">
                                    Confirm password
                                    <span class="required">
                                        *
                                    </span>
                                </label>
                                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Re-enter password" autocomplete="new-password">
                            </div>
                            <div id="error-message" class="alert alert-error hidden">
                            </div>
                            <button type="submit" class="btn btn-primary btn-block">
                                Update Password
                            </button>
                        </form>
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
        <script src="${pageContext.request.contextPath}/js/script.js?v=12">
        </script>
        <script>
            function validateResetForm(form) {
            var p = form.querySelector('[name="password"]').value;
            var c = form.querySelector('[name="confirmPassword"]').value;
            if (!p || p.length
            < 6) { showError('Password must be at least 6 characters'); return false; }
            if (p !== c) { showError('Passwords do not match'); return false; }
            return true;
            }
        </script>
        </body>
        </html>
