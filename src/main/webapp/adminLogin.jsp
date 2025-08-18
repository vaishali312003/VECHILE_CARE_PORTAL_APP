<%@ page language="java" import="javax.servlet.http.HttpSession" %>
<%
    // Prevent caching of login page
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // If admin is already logged in, redirect to dashboard
    HttpSession currentSession = request.getSession(false);
    if (currentSession != null && currentSession.getAttribute("admin") != null) {
        response.sendRedirect("adminDashboard.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <title>Admin Login - Vehicle Care App</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: url("img/bg/gradient_overlay.jpg") no-repeat center center fixed;
            background-size: cover;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            color: #fff;
        }
        .navbar {
            background-color: rgba(0,0,0,0.85);
            padding: 20px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.6);
        }
        .navbar h2 {
            font-size: 28px; font-weight: bold;
            display: flex; align-items: center; gap: 12px;
        }
        .navbar h2 img { width: 40px; }
        .back-btn {
            padding: 8px 16px;
            background-color: #00bcd4;
            color: #fff;
            text-decoration: none;
            border-radius: 4px;
            font-size: 14px;
            transition: background-color 0.3s ease;
        }
        .back-btn:hover { background-color: #0097a7; }
        .container {
            background: rgba(0,0,0,0.75);
            padding: 60px 50px;
            margin: 80px auto;
            max-width: 500px;
            border-radius: 20px;
            box-shadow: 0 0 30px rgba(0,0,0,0.6);
            text-align: center;
        }
        .container h1 { font-size: 36px; margin-bottom: 40px; font-weight: 600; }
        .message {
            padding: 12px; border-radius: 6px;
            margin-bottom: 20px; font-weight: bold;
        }
        .success-message {
            background-color: rgba(76,175,80,0.2);
            border: 1px solid #4caf50;
            color: #4caf50;
        }
        .error-message {
            background-color: rgba(244,67,54,0.2);
            border: 1px solid #f44336;
            color: #f44336;
        }
        form { display: flex; flex-direction: column; gap: 20px; }
        input[type="text"], input[type="password"] {
            padding: 12px 15px; font-size: 16px;
            border: none; border-radius: 6px; outline: none;
        }
        button[type="submit"] {
            padding: 12px 15px;
            font-size: 18px;
            font-weight: bold;
            color: #fff;
            background-color: #00bcd4;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }
        button[type="submit"]:hover { background-color: #0097a7; }
        @media (max-width: 600px) {
            .container h1 { font-size: 28px; }
        }
    </style>
    <script>
        // Prevent back button after logout
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function() { window.history.pushState(null, null, window.location.href); };

        // Clear form on page load
        window.onload = function() {
            document.querySelector('form').reset();
        };
    </script>
</head>
<body>

    <div class="navbar">
        <h2>
            <img src="img/icon/dashboard_icon.png" alt="Logo">
            Vehicle Care App
        </h2>
        <a href="index.jsp" class="back-btn">🔙 Back to Home</a>
    </div>

    <div class="container">
        <h1>Admin Login</h1>

        <%-- Success Messages --%>
        <% if ("success".equals(request.getParameter("logout"))) { %>
            <div class="message success-message">You have been successfully logged out.</div>
        <% } %>

        <%-- Error Messages from URL parameters --%>
        <% if ("session_expired".equals(request.getParameter("error"))) { %>
            <div class="message error-message">Your session has expired. Please login again.</div>
        <% } %>
        <% if ("invalid".equals(request.getParameter("error"))) { %>
            <div class="message error-message">Invalid username or password. Please try again.</div>
        <% } %>

        <%-- Error Messages from request attributes (forwarded from servlet) --%>
        <% if (request.getAttribute("error") != null) { %>
            <div class="message error-message"><%= request.getAttribute("error") %></div>
        <% } %>

        <form action="adminLogin" method="post">
            <input type="text" name="username" placeholder="Admin Username" required autocomplete="username">
            <input type="password" name="password" placeholder="Password" required autocomplete="current-password">
            <button type="submit">Login</button>
        </form>

        <div style="margin-top: 20px; font-size: 14px; color: #ccc;">
            <p>For testing: admin/admin123</p>
        </div>
    </div>

</body>
</html>