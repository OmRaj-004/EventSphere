<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title> Please try again - EventSphere</title>
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
                    <h1 class="error-code">429</h1>
                    <h2>Too many attempts</h2>
                    <p class="text-muted-small">
                        For your security, please wait a short while before trying again.
                    </p>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-primary">Back to Home</a>
                </div>
            </section>
        </main>
        <footer class="footer footer-compact">
            <div class="footer-container">
                <p>&copy; <%= java.time.Year.now() %> EventSphere. All rights reserved.</p>
            </div>
        </footer>
    </body>
</html>
