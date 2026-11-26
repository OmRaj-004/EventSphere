<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="description" content="EventSphere is a premium venue booking platform for weddings, conferences and events. Discover and book the perfect venue.">
        <title>
            Page Not Found - EventSphere
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
            </div>
        </nav>
        <main>
        <section class="error-page">
            <div class="container">
                <h1 class="error-code">
                    404
                </h1>
                <h2>
                    Page Not Found
                </h2>
                <p class="text-muted-small">
                    The page you are looking for could not be found.
                </p>
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary btn-block">
                    Back to Home
                </a>
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
