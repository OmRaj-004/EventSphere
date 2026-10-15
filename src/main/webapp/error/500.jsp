<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>
            Server Error - EventSphere
        </title>
        <link rel="icon" type="image/svg+xml" href="${pageContext.request.contextPath}/images/eventsphere-icon.svg">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    </head>
    <body>
        <nav class="navbar">
            <div class="navbar-container">
                <a href="${pageContext.request.contextPath}/" class="navbar-brand">
                    <img src="${pageContext.request.contextPath}/images/eventsphere-logo.svg" alt="EventSphere" class="brand-logo">
                </a>
            </div>
        </nav>
        <section style="padding: 3rem 2rem; text-align: center;">
            <div class="container">
                <h1 style="font-size: 3rem; color: var(--danger-color); margin-bottom: 1rem;">
                    500
                </h1>
                <h2>
                    Internal Server Error
                </h2>
                <p style="color: var(--text-light); margin: 1rem 0;">
                    An error occurred while processing your request. Our team has been notified.
                </p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary" style="margin-top: 1rem;">
                    Back to Home
                </a>
            </div>
        </section>
        <footer class="footer" style="margin-top: 3rem;">
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
