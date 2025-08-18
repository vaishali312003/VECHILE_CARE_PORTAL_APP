<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8"
         import="java.sql.*, java.util.*, java.util.Date" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    // --- Session Validation and Cache Prevention ---
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("clientName") == null) {
        response.sendRedirect("login.jsp?error=session_expired");
        return;
    }

    String clientName = (String) userSession.getAttribute("clientName");

    // Fetch vehicle data for the logged-in client
    List<Map<String, Object>> vehicles = new ArrayList<>();
    int totalVehicles = 0;
    int pendingServices = 0;
    int serviceHistory = 0;

    // Database connection details
    String url = "jdbc:postgresql://dpg-d2h1mrn5r7bs73fk9ef0-a.oregon-postgres.render.com:5432/vehicle_management_ntax";
    String username = "root";
    String password = "Le3SmqhmwlE9OkUWe0DE7MUenE5wyEmu";

    try {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection(url, username, password);

        PreparedStatement stmt = conn.prepareStatement(
            "SELECT vehicle_id, vehicle_number, model, client_name, client_password, " +
            "warranty_date, registration_date, service_date FROM vehicle_client WHERE client_name = ?"
        );
        stmt.setString(1, clientName);
        ResultSet rs = stmt.executeQuery();

        while (rs.next()) {
            Map<String, Object> vehicle = new HashMap<>();
            vehicle.put("vehicle_id", rs.getInt("vehicle_id"));
            vehicle.put("vehicle_number", rs.getString("vehicle_number"));
            vehicle.put("model", rs.getString("model"));
            vehicle.put("client_name", rs.getString("client_name"));
            vehicle.put("warranty_date", rs.getDate("warranty_date"));
            vehicle.put("registration_date", rs.getDate("registration_date"));
            vehicle.put("service_date", rs.getDate("service_date"));
            vehicles.add(vehicle);
        }

        totalVehicles = vehicles.size();
        for (Map<String, Object> vehicle : vehicles) {
            java.sql.Date serviceDate = (java.sql.Date) vehicle.get("service_date");
            if (serviceDate != null) {
                long daysSince = (System.currentTimeMillis() - serviceDate.getTime()) / (1000 * 60 * 60 * 24);
                if (daysSince > 180) { // 6 months
                    pendingServices++;
                }
                serviceHistory++;
            }
        }

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Pragma" content="no-cache" />
    <meta http-equiv="Expires" content="0" />
    <title>AutoSpace - Vehicle Dashboard</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 20px;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.15);
            overflow: hidden;
        }

        .header {
            background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
            color: white;
            padding: 40px;
            text-align: center;
            position: relative;
            overflow: hidden;
        }

        .header::before {
            content: '';
            position: absolute;
            top: -50%;
            left: -50%;
            width: 200%;
            height: 200%;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 1px, transparent 1px);
            background-size: 50px 50px;
            animation: float 20s infinite linear;
        }

        @keyframes float {
            0% { transform: translate(-50px, -50px); }
            100% { transform: translate(0, 0); }
        }

        .header-content {
            position: relative;
            z-index: 1;
        }

        .header h1 {
            font-size: 2.8rem;
            margin-bottom: 10px;
            font-weight: 800;
        }

        .header p {
            opacity: 0.9;
            font-size: 1.2rem;
            font-weight: 300;
        }

        .welcome-section {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 30px 40px;
            border-bottom: 1px solid #e1e5e9;
        }

        .welcome-text {
            font-size: 1.4rem;
            color: #333;
            margin-bottom: 10px;
        }

        .user-name {
            color: #4a90e2;
            font-weight: 700;
        }

        .stats-container {
            padding: 40px;
            background: #f8f9fa;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }

        .stat-card {
            background: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
            transition: transform 0.3s, box-shadow 0.3s;
            border-top: 4px solid #4a90e2;
        }

        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0, 0, 0, 0.12);
        }

        .stat-card.warning {
            border-top-color: #ffc107;
        }

        .stat-card.success {
            border-top-color: #28a745;
        }

        .stat-icon {
            font-size: 2.5rem;
            margin-bottom: 15px;
            color: #4a90e2;
        }

        .stat-card.warning .stat-icon {
            color: #ffc107;
        }

        .stat-card.success .stat-icon {
            color: #28a745;
        }

        .stat-value {
            font-size: 2.2rem;
            font-weight: 800;
            color: #333;
            margin-bottom: 8px;
        }

        .stat-label {
            color: #666;
            font-size: 1rem;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .content {
            padding: 40px;
        }

        .vehicles-section h2 {
            color: #333;
            margin-bottom: 30px;
            font-size: 2rem;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 15px;
        }

        .vehicles-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
            gap: 30px;
            margin-top: 30px;
        }

        .vehicle-card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.1);
            overflow: hidden;
            transition: transform 0.3s, box-shadow 0.3s;
        }

        .vehicle-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
        }

        .vehicle-header {
            background: linear-gradient(135deg, #4a90e2 0%, #357abd 100%);
            color: white;
            padding: 20px;
            text-align: center;
        }

        .vehicle-number {
            font-size: 1.5rem;
            font-weight: 700;
            margin-bottom: 5px;
        }

        .vehicle-model {
            opacity: 0.9;
            font-size: 1rem;
        }

        .vehicle-details {
            padding: 25px;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 0;
            border-bottom: 1px solid #f0f0f0;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: #666;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .detail-value {
            font-weight: 500;
            color: #333;
        }

        .status-badge {
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8rem;
            font-weight: 600;
            text-transform: uppercase;
        }

        .status-active {
            background: #d4edda;
            color: #155724;
        }

        .status-warning {
            background: #fff3cd;
            color: #856404;
        }

        .status-expired {
            background: #f8d7da;
            color: #721c24;
        }

        .actions {
            margin-top: 40px;
            padding: 40px;
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            border-radius: 15px;
            text-align: center;
        }

        .actions h3 {
            margin-bottom: 25px;
            color: #333;
            font-size: 1.5rem;
            font-weight: 600;
        }

        .action-buttons {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
        }

        .action-btn {
            background: linear-gradient(135deg, #28a745 0%, #20963d 100%);
            color: white;
            padding: 15px 25px;
            border: none;
            border-radius: 10px;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            font-size: 1rem;
            font-weight: 600;
            transition: all 0.3s;
        }

        .action-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 25px rgba(40, 167, 69, 0.3);
        }

        .action-btn.secondary {
            background: linear-gradient(135deg, #6c757d 0%, #545b62 100%);
        }

        .action-btn.secondary:hover {
            box-shadow: 0 10px 25px rgba(108, 117, 125, 0.3);
        }

        .action-btn.danger {
            background: linear-gradient(135deg, #dc3545 0%, #c82333 100%);
        }

        .action-btn.danger:hover {
            box-shadow: 0 10px 25px rgba(220, 53, 69, 0.3);
        }

        .no-vehicles {
            text-align: center;
            padding: 60px;
            color: #666;
        }

        .no-vehicles i {
            font-size: 4rem;
            margin-bottom: 20px;
            color: #ccc;
        }

        @media (max-width: 768px) {
            .container {
                margin: 10px;
            }

            .header, .content, .welcome-section, .stats-container {
                padding: 20px;
            }

            .header h1 {
                font-size: 2rem;
            }

            .stats-grid {
                grid-template-columns: 1fr;
            }

            .vehicles-grid {
                grid-template-columns: 1fr;
            }

            .action-buttons {
                flex-direction: column;
                align-items: center;
            }

            .action-btn {
                width: 100%;
                max-width: 300px;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="header-content">
                <h1><i class="fas fa-car"></i> AutoSpace Dashboard</h1>
                <p>Your complete vehicle management center</p>
            </div>
        </div>

        <div class="welcome-section">
            <div class="welcome-text">
                Welcome back, <span class="user-name"><%= clientName %></span>!
            </div>
            <p style="color: #666; margin-top: 5px; font-size: 1.1rem;">
                <i class="fas fa-calendar-alt"></i> Last login: <%= new java.text.SimpleDateFormat("MMM dd, yyyy 'at' hh:mm a").format(new Date()) %>
            </p>
        </div>

        <div class="stats-container">
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-car"></i></div>
                    <div class="stat-value"><%= totalVehicles %></div>
                    <div class="stat-label">Total Vehicles</div>
                </div>

                <div class="stat-card <%= pendingServices > 0 ? "warning" : "success" %>">
                    <div class="stat-icon">
                        <i class="fas <%= pendingServices > 0 ? "fa-exclamation-triangle" : "fa-check-circle" %>"></i>
                    </div>
                    <div class="stat-value"><%= pendingServices %></div>
                    <div class="stat-label">Pending Services</div>
                </div>

                <div class="stat-card success">
                    <div class="stat-icon"><i class="fas fa-wrench"></i></div>
                    <div class="stat-value"><%= serviceHistory %></div>
                    <div class="stat-label">Service Records</div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon"><i class="fas fa-shield-alt"></i></div>
                    <div class="stat-value">
                        <%= vehicles.stream().mapToInt(v -> {
                            java.sql.Date warrantyDate = (java.sql.Date) v.get("warranty_date");
                            return (warrantyDate != null && warrantyDate.after(new Date())) ? 1 : 0;
                        }).sum() %>
                    </div>
                    <div class="stat-label">Active Warranties</div>
                </div>
            </div>
        </div>

        <div class="content">
            <div class="vehicles-section">
                <h2><i class="fas fa-list"></i> Your Vehicles</h2>

                <% if (vehicles.isEmpty()) { %>
                    <div class="no-vehicles">
                        <i class="fas fa-car"></i>
                        <h3>No vehicles found</h3>
                        <p>Contact administrator to register your vehicles.</p>
                    </div>
                <% } else { %>
                    <div class="vehicles-grid">
                        <% for (Map<String, Object> vehicle : vehicles) { %>
                            <div class="vehicle-card">
                                <div class="vehicle-header">
                                    <div class="vehicle-number">
                                        <i class="fas fa-car"></i> <%= vehicle.get("vehicle_number") %>
                                    </div>
                                    <div class="vehicle-model"><%= vehicle.get("model") %></div>
                                </div>

                                <div class="vehicle-details">
                                    <div class="detail-row">
                                        <span class="detail-label">
                                            <i class="fas fa-hashtag"></i> Vehicle ID
                                        </span>
                                        <span class="detail-value">#<%= vehicle.get("vehicle_id") %></span>
                                    </div>

                                    <div class="detail-row">
                                        <span class="detail-label">
                                            <i class="fas fa-calendar-plus"></i> Registration
                                        </span>
                                        <span class="detail-value">
                                            <%= vehicle.get("registration_date") != null ?
                                                new java.text.SimpleDateFormat("MMM dd, yyyy").format((Date)vehicle.get("registration_date")) : "N/A" %>
                                        </span>
                                    </div>

                                    <div class="detail-row">
                                        <span class="detail-label">
                                            <i class="fas fa-shield-alt"></i> Warranty
                                        </span>
                                        <span class="detail-value">
                                            <%
                                                java.sql.Date warrantyDate = (java.sql.Date) vehicle.get("warranty_date");
                                                if (warrantyDate != null) {
                                                    boolean isActive = warrantyDate.after(new Date());
                                            %>
                                                <span class="status-badge <%= isActive ? "status-active" : "status-expired" %>">
                                                    <%= isActive ? "Active" : "Expired" %>
                                                </span>
                                                <br><small style="margin-top: 5px; display: block;">
                                                    <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(warrantyDate) %>
                                                </small>
                                            <% } else { %>
                                                <span class="status-badge status-warning">No Warranty</span>
                                            <% } %>
                                        </span>
                                    </div>

                                    <div class="detail-row">
                                        <span class="detail-label">
                                            <i class="fas fa-wrench"></i> Last Service
                                        </span>
                                        <span class="detail-value">
                                            <%
                                                java.sql.Date serviceDate = (java.sql.Date) vehicle.get("service_date");
                                                if (serviceDate != null) {
                                                    long daysSince = (System.currentTimeMillis() - serviceDate.getTime()) / (1000 * 60 * 60 * 24);
                                            %>
                                                <%= new java.text.SimpleDateFormat("MMM dd, yyyy").format(serviceDate) %>
                                                <br><small style="margin-top: 5px; display: block;
                                                    color: <%= daysSince > 180 ? "#dc3545" : "#28a745" %>;">
                                                    <%= daysSince %> days ago
                                                    <%= daysSince > 180 ? "(Due for service)" : "" %>
                                                </small>
                                            <% } else { %>
                                                <span class="status-badge status-warning">No Service Record</span>
                                            <% } %>
                                        </span>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>

                <div class="actions">
                    <h3><i class="fas fa-tools"></i> Quick Actions</h3>
                    <div class="action-buttons">
                        <a href="serviceRequests.jsp" class="action-btn">
                            <i class="fas fa-calendar-plus"></i> Schedule Service
                        </a>
                        <a href="serviceRequests.jsp"" class="action-btn">
                            <i class="fas fa-history"></i> Service History
                        </a>


                        <a href="logout" class="action-btn danger">
                            <i class="fas fa-sign-out-alt"></i> Logout
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>