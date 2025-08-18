<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, com.example.vehicleportal.util.DBConnection, java.util.*, java.util.Date, java.util.List, java.util.ArrayList" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // --- Session Validation and Cache Prevention ---
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    if (session == null || session.getAttribute("clientName") == null) {
        response.sendRedirect("login.jsp?error=session_expired");
        return;
    }

    String clientName = (String) session.getAttribute("clientName");

    // Fetch all vehicle numbers for this client (similar to dashboard)
    List<String> vehicleNumbers = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement stmt = conn.prepareStatement(
            "SELECT vehicle_number FROM vehicle_client WHERE client_name = ?"
        );
        stmt.setString(1, clientName);
        ResultSet rs = stmt.executeQuery();
        while (rs.next()) {
            vehicleNumbers.add(rs.getString("vehicle_number"));
        }
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <!-- Cache prevention meta tags -->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>AutoSpace - Profile</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <style>
        /* Use your dashboard's CSS styles here for consistent UI */

        :root {
            --primary-gradient: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            --dark-gradient: linear-gradient(135deg, #0c0c0c 0%, #1a1a1a 50%, #2d2d2d 100%);
            --glass-bg: rgba(255, 255, 255, 0.1);
            --glass-border: rgba(255, 255, 255, 0.2);
            --text-primary: #ffffff;
            --text-secondary: #b0b0b0;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            background: var(--dark-gradient);
            color: var(--text-primary);
            min-height: 100vh;
            overflow-x: hidden;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            background: rgba(0, 0, 0, 0.8);
            backdrop-filter: blur(20px);
            border-right: 1px solid var(--glass-border);
            padding: 1.5rem 0;
            position: fixed;
            height: 100vh;
            width: 260px;
            z-index: 1000;
            overflow-y: auto;
        }

        .logo {
            text-align: center;
            margin-bottom: 2rem;
            padding: 0 1.5rem;
        }

        .logo h1 {
            font-size: 1.8rem;
            font-weight: 800;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 0.3rem;
        }

        .logo p {
            color: var(--text-secondary);
            font-size: 0.8rem;
            font-weight: 300;
        }

        .nav-menu {
            list-style: none;
            padding: 0 1rem;
        }

        .nav-item {
            margin-bottom: 0.3rem;
        }

        .nav-link {
            display: flex;
            align-items: center;
            padding: 0.8rem 1rem;
            color: var(--text-secondary);
            text-decoration: none;
            border-radius: 12px;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }

        .nav-link.active,
        .nav-link:hover {
            background: var(--primary-gradient);
            color: var(--text-primary);
            transform: translateX(5px);
        }

        .nav-link i {
            margin-right: 0.8rem;
            font-size: 1rem;
            width: 18px;
        }

        .main-content {
            flex: 1;
            padding: 1.5rem;
            min-height: 100vh;
            margin-left: 260px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding: 1.5rem 2rem;
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid var(--glass-border);
            width: 100%;
        }

        .welcome-section h1 {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 0.3rem;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .welcome-section p {
            color: var(--text-secondary);
            font-size: 1rem;
        }

        .user-actions {
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .user-avatar {
            width: 45px;
            height: 45px;
            border-radius: 50%;
            background: var(--primary-gradient);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            font-size: 1.1rem;
        }

        .profile-container {
            max-width: 600px;
            margin: 0 auto;
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            border: 1px solid var(--glass-border);
            padding: 2rem;
        }

        .profile-header {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: var(--primary-gradient);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .profile-item {
            margin-bottom: 1rem;
            font-size: 1.1rem;
        }

        .profile-label {
            font-weight: 600;
            color: var(--text-secondary);
            margin-right: 0.5rem;
            display: inline-block;
            width: 140px;
            vertical-align: top;
        }

        ul.vehicle-list {
            margin: 0;
            padding-left: 1.2rem;
            list-style-type: disc;
            display: inline-block;
        }

        .btn {
            padding: 0.7rem 1.5rem;
            border: none;
            border-radius: 25px;
            font-weight: 600;
            text-decoration: none;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 0.8rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .btn-primary {
            background: var(--primary-gradient);
            color: white;
        }

        .btn-secondary {
            background: transparent;
            color: var(--text-primary);
            border: 2px solid var(--glass-border);
        }

        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.3);
        }

        /* Mobile menu button */
        .mobile-menu-btn {
            position: fixed;
            top: 1rem;
            left: 1rem;
            z-index: 1001;
            background: var(--primary-gradient);
            border: none;
            color: white;
            padding: 0.8rem;
            border-radius: 50%;
            font-size: 1.1rem;
            cursor: pointer;
            display: none;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.3);
        }

        @media (max-width: 1024px) {
            .mobile-menu-btn {
                display: block;
            }
            .sidebar {
                transform: translateX(-100%);
                transition: transform 0.3s ease;
            }
            .sidebar.open {
                transform: translateX(0);
            }
            .main-content {
                margin-left: 0;
                padding: 1rem;
                width: 100%;
            }
            .header {
                flex-direction: column;
                gap: 1rem;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <button class="mobile-menu-btn" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <div class="dashboard-container">
        <!-- Sidebar -->
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <h1>AutoSpace</h1>
                <p>Vehicle Portal</p>
            </div>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="dashboard.jsp" class="nav-link">
                        <i class="fas fa-tachometer-alt"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="profile.jsp" class="nav-link active">
                        <i class="fas fa-user-circle"></i> Profile
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#vehicles" class="nav-link">
                        <i class="fas fa-car"></i> My Vehicles
                    </a>
                </li>
                <li class="nav-item">
                    <a href="BookingService.jsp" class="nav-link">
                        <i class="fas fa-calendar-check"></i> Book Service
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#centers" class="nav-link">
                        <i class="fas fa-tools"></i> Service Centers
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="header">
                <div class="welcome-section">
                    <h1>Profile - <%= clientName %></h1>
                    <p>Manage your profile details</p>
                </div>
                <div class="user-actions">
                    <div class="user-avatar">
                        <%= clientName.substring(0, 1).toUpperCase() %>
                    </div>
                    <a href="logout" class="btn btn-secondary" onclick="return confirmLogout();">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </div>
            </div>

            <div class="profile-container">
                <div class="profile-header">User Information</div>
                <div class="profile-item">
                    <span class="profile-label">Client Name:</span>
                    <span><%= clientName %></span>
                </div>
                <div class="profile-item">
                    <span class="profile-label">Vehicle Numbers:</span>
                    <span>
                        <% if (vehicleNumbers.isEmpty()) { %>
                            No vehicles registered.
                        <% } else { %>
                            <ul class="vehicle-list">
                                <% for (String vn : vehicleNumbers) { %>
                                    <li><%= vn %></li>
                                <% } %>
                            </ul>
                        <% } %>
                    </span>
                </div>

              
            </div>
        </div>
    </div>

    <!-- Floating Action Button -->
    <button class="floating-fab" onclick="location.href='BookingService.jsp'" title="Book Service">
        <i class="fas fa-calendar-plus"></i>
    </button>

    <!-- SESSION & SECURITY SCRIPTS -->
    <script>
        // Prevent back-navigation after logout
        window.history.pushState(null, null, window.location.href);
        window.onpopstate = function () {
            window.history.pushState(null, null, window.location.href);
        };

        // Auto logout after 30 minutes inactivity
        let inactivityTimer;
        const INACTIVITY_TIME = 30 * 60 * 1000; // 30 minutes

        function resetInactivityTimer() {
            clearTimeout(inactivityTimer);
            inactivityTimer = setTimeout(function () {
                alert("Session expired due to inactivity.");
                window.location.href = "logout";
            }, INACTIVITY_TIME);
        }

        document.addEventListener("mousedown", resetInactivityTimer);
        document.addEventListener("keypress", resetInactivityTimer);
        window.onload = resetInactivityTimer;

        // Logout confirmation dialog
        function confirmLogout() {
            return confirm("Are you sure you want to logout?");
        }

        // Sidebar mobile toggle
        function toggleSidebar() {
            const sidebar = document.getElementById("sidebar");
            sidebar.classList.toggle("open");
        }

        // Close sidebar when clicking outside on mobile
        document.addEventListener("click", function (event) {
            const sidebar = document.getElementById("sidebar");
            const menuBtn = document.querySelector(".mobile-menu-btn");
            if (
                window.innerWidth <= 1024 &&
                !sidebar.contains(event.target) &&
                !menuBtn.contains(event.target)
            ) {
                sidebar.classList.remove("open");
            }
        });
    </script>
</body>
</html>
