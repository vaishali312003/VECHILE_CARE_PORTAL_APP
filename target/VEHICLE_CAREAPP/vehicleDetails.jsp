<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.example.vehicleportal.util.DBConnection" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Vehicle Details - Your Space</title>
    <style>
        body {
            background: url('img/bg/gradient_overlay.jpg') no-repeat center center fixed;
            background-size: cover;
            font-family: 'Segoe UI', Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

        .container {
            margin: 60px auto;
            padding: 40px;
            max-width: 1200px;
            background: rgba(255,255,255,0.92);
            border-radius: 24px;
            box-shadow: 0 8px 36px rgba(0,0,0,0.12);
        }

        .header {
            display: flex;
            align-items: center;
            margin-bottom: 36px;
            justify-content: space-between;
        }
        .header h1 {
            color: #204060;
            font-size: 2.2rem;
        }
        .btn-secondary {
            background-color: #204060;
            color: #fff;
            text-decoration: none;
            border-radius: 20px;
            padding: 10px 26px;
            transition: background 0.2s;
        }
        .btn-secondary:hover {
            background: #102030;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: #fafcff;
        }

        th, td {
            padding: 16px 12px;
            text-align: left;
        }

        th {
            background-color: #1e3557;
            color: #fff;
            font-size: 1.08rem;
            letter-spacing: 0.2px;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
        }

        tr {
            transition: background 0.17s;
        }

        tr:nth-child(even) {
            background-color: #f0f6ff;
        }

        tr:hover {
            background-color: #dde8f7;
        }

        .vehicle-image-cell img {
            width: 80px;
            height: 48px;
            object-fit: cover;
            border-radius: 9px;
            border: 1.5px solid #c8d8ef;
            box-shadow: 0 2px 8px rgba(30,53,87,0.10);
        }

        .no-vehicles {
            width: 100%;
            text-align: center;
            margin: 64px 0;
        }

        .no-vehicles h2 {
            color: #204060;
            font-size: 1.5rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>My Vehicles</h1>
            <a href="dashboard.jsp" class="btn-secondary">&larr; Back to Dashboard</a>
        </div>

        <%
            Connection conn = null;
            PreparedStatement ps = null;
            ResultSet rs = null;
            try {
                conn = DBConnection.getConnection();
                String sql = "SELECT vehicle_id, vehicle_number, model, client_name, warranty_date, registration_date, service_date FROM vehicle_client";
                ps = conn.prepareStatement(sql);
                rs = ps.executeQuery();

                if (!rs.isBeforeFirst()) { // no data
        %>
            <div class="no-vehicles">
                <h2>No Vehicles Found</h2>
                <p>You haven't added any vehicles yet. Add your first vehicle to get started!</p>
                <a href="dashboard.jsp" class="btn-secondary">Add Vehicle</a>
            </div>
        <%
                } else {
        %>
            <table>
                <tr>
                    <th>Image</th>
                    <th>Vehicle ID</th>
                    <th>Registration Number</th>
                    <th>Model</th>
                    <th>Owner</th>
                    <th>Registration Date</th>
                    <th>Warranty Expiry</th>
                    <th>Last Service</th>
                </tr>
                <%
                    while (rs.next()) {
                        String model = rs.getString("model");
                        // Use default image for now, could customize image per model if desired
                        String imagePath = "img/bg/Abstract car silhouettes.jpg";
                %>
                <tr>
                    <td class="vehicle-image-cell">
                        <img src="<%= imagePath %>" alt="<%= model %>" />
                    </td>
                    <td><%= rs.getInt("vehicle_id") %></td>
                    <td><%= rs.getString("vehicle_number") %></td>
                    <td><%= model %></td>
                    <td><%= rs.getString("client_name") %></td>
                    <td><%= rs.getDate("registration_date") %></td>
                    <td><%= rs.getDate("warranty_date") %></td>
                    <td><%= rs.getDate("service_date") %></td>
                </tr>
                <%
                    }
                %>
            </table>
        <%
                }
            } catch(Exception e) {
                out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) try { rs.close(); } catch(Exception ignored) {}
                if (ps != null) try { ps.close(); } catch(Exception ignored) {}
                if (conn != null) try { conn.close(); } catch(Exception ignored) {}
            }
        %>
    </div>
</body>
</html>
