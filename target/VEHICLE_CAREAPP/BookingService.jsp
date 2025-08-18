<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.example.vehicleportal.util.DBConnection, javax.servlet.http.HttpSession, java.util.*, java.text.SimpleDateFormat" %>
<%
    // Session check
    HttpSession userSession = request.getSession(false);
    if (userSession == null || userSession.getAttribute("clientName") == null) {
        out.println("<script>alert('Please login first');window.location='login.jsp';</script>");
        return;
    }
    String clientName = (String) userSession.getAttribute("clientName");
    String message = null;
    String messageClass = "error";

    // Handle client actions
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String action = request.getParameter("action");

        // 1. New request with location selection
        if ("submit_request".equals(action)) {
            String vehicleIdStr = request.getParameter("vehicle_id");
            String remarks = request.getParameter("remarks");
            String centerIdStr = request.getParameter("center_id");

            if (vehicleIdStr != null && !vehicleIdStr.trim().isEmpty() && centerIdStr != null && !centerIdStr.trim().isEmpty()) {
                try (Connection conn = DBConnection.getConnection()) {
                    int vehicleId = Integer.parseInt(vehicleIdStr);
                    int centerId = Integer.parseInt(centerIdStr);

                    String checkSql = "SELECT status FROM service_requests WHERE vehicle_id = ? AND status IN ('Pending', 'Awaiting Client Selection', 'Scheduled')";
                    try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                        checkStmt.setInt(1, vehicleId);
                        try (ResultSet rs = checkStmt.executeQuery()) {
                            if (rs.next()) {
                                String status = rs.getString("status");
                                if ("Pending".equalsIgnoreCase(status)) {
                                    message = "You already have a pending request for this vehicle.";
                                } else if ("Awaiting Client Selection".equalsIgnoreCase(status)) {
                                    message = "Your request is approved! Please select your preferred service date below.";
                                    messageClass = "success";
                                } else if ("Scheduled".equalsIgnoreCase(status)) {
                                    message = "Your service is already scheduled for this vehicle.";
                                    messageClass = "success";
                                }
                            } else {
                                String insertSql = "INSERT INTO service_requests (vehicle_id, center_id, request_date, status, remarks) VALUES (?, ?, NOW(), 'Pending', ?)";
                                try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                                    stmt.setInt(1, vehicleId);
                                    stmt.setInt(2, centerId);
                                    stmt.setString(3, remarks != null ? remarks : "");
                                    int rows = stmt.executeUpdate();
                                    if (rows > 0) {
                                        message = "Service request submitted successfully! Please wait for admin approval.";
                                        messageClass = "success";
                                    } else {
                                        message = "Failed to submit request.";
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Submit request error: " + e.getMessage());
                    message = "Error: " + e.getMessage();
                }
            } else {
                message = "Please select both a vehicle and a service center location.";
            }
        }
        // 2. Date Option Selection - FIXED VERSION
        else if ("select_option".equals(action)) {
            String requestId = request.getParameter("request_id");
            String selectedOption = request.getParameter("selected_option");
            if (requestId != null && selectedOption != null) {
                try (Connection conn = DBConnection.getConnection()) {
                    // Fixed SQL to properly combine date and time into timestamp
                    String getOptionSql = "SELECT " +
                        "CASE " +
                        "WHEN ? = '1' THEN (option_1_date + option_1_time)::timestamp " +
                        "WHEN ? = '2' THEN (option_2_date + option_2_time)::timestamp " +
                        "WHEN ? = '3' THEN (option_3_date + option_3_time)::timestamp " +
                        "END as selected_datetime " +
                        "FROM service_requests WHERE request_id = ?";
                    Timestamp selectedDateTime = null;
                    try (PreparedStatement getStmt = conn.prepareStatement(getOptionSql)) {
                        getStmt.setString(1, selectedOption);
                        getStmt.setString(2, selectedOption);
                        getStmt.setString(3, selectedOption);
                        getStmt.setInt(4, Integer.parseInt(requestId));
                        try (ResultSet rs = getStmt.executeQuery()) {
                            if (rs.next()) {
                                selectedDateTime = rs.getTimestamp("selected_datetime");
                            }
                        }
                    }
                    if (selectedDateTime != null) {
                        // Fixed UPDATE to use timestamp parameter instead of string
                        String updateSql = "UPDATE service_requests SET client_selected_option = ?, final_service_datetime = ?, status = 'Scheduled' WHERE request_id = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                            stmt.setInt(1, Integer.parseInt(selectedOption));
                            stmt.setTimestamp(2, selectedDateTime); // Use setTimestamp instead of setString
                            stmt.setInt(3, Integer.parseInt(requestId));
                            int rows = stmt.executeUpdate();
                            if (rows > 0) {
                                message = "Service date selected successfully! Your appointment has been confirmed for " + selectedDateTime;
                                messageClass = "success";
                            } else {
                                message = "Failed to select service date.";
                            }
                        }
                    } else {
                        message = "Error: Could not retrieve selected date/time option.";
                    }
                } catch (Exception e) {
                    System.err.println("Select option error: " + e.getMessage());
                    message = "Error: " + e.getMessage();
                }
            } else {
                message = "Please select a valid option.";
            }
        }
        // 3. Reschedule Request after Cancel/Reject
        else if ("request_reschedule".equals(action)) {
            String vehicleIdStr = request.getParameter("vehicle_id");
            String remarks = request.getParameter("remarks");
            String centerIdStr = request.getParameter("center_id");

            if (vehicleIdStr != null && !vehicleIdStr.trim().isEmpty() && centerIdStr != null && !centerIdStr.trim().isEmpty()) {
                try (Connection conn = DBConnection.getConnection()) {
                    int vehicleId = Integer.parseInt(vehicleIdStr);
                    int centerId = Integer.parseInt(centerIdStr);
                    String insertSql = "INSERT INTO service_requests (vehicle_id, center_id, request_date, status, remarks) VALUES (?, ?, NOW(), 'Pending', ?)";
                    try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                        stmt.setInt(1, vehicleId);
                        stmt.setInt(2, centerId);
                        stmt.setString(3, remarks != null ? remarks : "Reschedule request");
                        int rows = stmt.executeUpdate();
                        if (rows > 0) {
                            message = "Reschedule request submitted successfully! Please wait for admin approval.";
                            messageClass = "success";
                        } else {
                            message = "Failed to submit reschedule request.";
                        }
                    }
                } catch (Exception e) {
                    System.err.println("Reschedule error: " + e.getMessage());
                    message = "Error: " + e.getMessage();
                }
            } else {
                message = "Please select both a valid vehicle and service center.";
            }
        }
    }

    // Get all service centers and vehicles
    List<Map<String, Object>> serviceCenters = new ArrayList<>();
    List<Map<String, Object>> vehicles = new ArrayList<>();
    List<Map<String, Object>> pendingSelections = new ArrayList<>();

    try (Connection conn = DBConnection.getConnection()) {
        // Get service centers
        String centerSql = "SELECT center_id, center_name, location, contact_phone FROM service_centers ORDER BY center_name";
        try (PreparedStatement stmt = conn.prepareStatement(centerSql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> center = new HashMap<>();
                    center.put("center_id", rs.getInt("center_id"));
                    center.put("center_name", rs.getString("center_name"));
                    center.put("location", rs.getString("location"));
                    center.put("contact_phone", rs.getString("contact_phone"));
                    serviceCenters.add(center);
                }
            }
        }

        // Get vehicles and request status
        String sql = "SELECT v.vehicle_id, v.vehicle_number, v.model, " +
            "sr.request_id, sr.status, sr.final_service_datetime, sr.service_type, " +
            "sr.option_1_date, sr.option_1_time, sr.option_2_date, sr.option_2_time, " +
            "sr.option_3_date, sr.option_3_time, sr.date_selection_deadline, " +
            "sr.client_selected_option, " +
            "sc.center_name, sc.location " +
            "FROM vehicle_client v " +
            "LEFT JOIN service_requests sr ON v.vehicle_id = sr.vehicle_id " +
            "AND sr.request_id = (SELECT MAX(request_id) FROM service_requests WHERE vehicle_id = v.vehicle_id) " +
            "LEFT JOIN service_centers sc ON sr.center_id = sc.center_id " +
            "WHERE TRIM(v.client_name) = TRIM(?) " +
            "ORDER BY v.vehicle_id";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, clientName);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> vehicle = new HashMap<>();
                    vehicle.put("vehicle_id", rs.getInt("vehicle_id"));
                    vehicle.put("vehicle_number", rs.getString("vehicle_number"));
                    vehicle.put("model", rs.getString("model"));
                    vehicle.put("request_id", rs.getObject("request_id"));
                    vehicle.put("status", rs.getString("status"));
                    vehicle.put("final_service_datetime", rs.getTimestamp("final_service_datetime"));
                    vehicle.put("service_type", rs.getString("service_type"));
                    vehicle.put("option_1_date", rs.getDate("option_1_date"));
                    vehicle.put("option_1_time", rs.getTime("option_1_time"));
                    vehicle.put("option_2_date", rs.getDate("option_2_date"));
                    vehicle.put("option_2_time", rs.getTime("option_2_time"));
                    vehicle.put("option_3_date", rs.getDate("option_3_date"));
                    vehicle.put("option_3_time", rs.getTime("option_3_time"));
                    vehicle.put("date_selection_deadline", rs.getTimestamp("date_selection_deadline"));
                    vehicle.put("client_selected_option", rs.getObject("client_selected_option"));
                    vehicle.put("center_name", rs.getString("center_name"));
                    vehicle.put("center_location", rs.getString("location"));
                    vehicles.add(vehicle);
                    String vehicleStatus = rs.getString("status");
                    if ("Awaiting Client Selection".equals(vehicleStatus)) {
                        pendingSelections.add(vehicle);
                    }
                }
            }
        }
    } catch (Exception e) {
        System.err.println("Database error: " + e.getMessage());
        message = "Database connection error. Please try again later.";
    }
%>

<!DOCTYPE html>
<html>
<head>
    <title>Book Service</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f8f8f8; padding: 20px; }
        .container { max-width: 1000px; margin: 0 auto; }
        table { border-collapse: collapse; width: 100%; background: #fff; margin: 20px 0; }
        th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }
        th { background-color: #f5f5f5; font-weight: bold; }
        .error { color: red; font-weight: bold; padding: 10px; background: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; margin: 10px 0; }
        .success { color: green; font-weight: bold; padding: 10px; background: #d4edda; border: 1px solid #c3e6cb; border-radius: 4px; margin: 10px 0; }
        textarea { width: 90%; height: 60px; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        select { width: 95%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; margin: 5px 0; }
        button { background: #007BFF; color: #fff; border: none; padding: 10px 15px; cursor: pointer; border-radius: 4px; }
        button:hover { background: #0056b3; }
        .btn-success { background: #28a745; }
        .btn-success:hover { background: #218838; }
        .option-card { background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 4px; padding: 10px; margin: 5px 0; }
        .deadline-warning { color: #856404; background: #fff3cd; border: 1px solid #ffeaa7; padding: 8px; border-radius: 4px; margin: 5px 0; }
        .scheduled { color: #155724; background: #d4edda; padding: 8px; border-radius: 4px; }
        .pending { color: #721c24; background: #f8d7da; padding: 8px; border-radius: 4px; }
        .cancelled-status { color: #721c24; background: #f8d7da; padding: 8px; border-radius: 4px; border-left: 4px solid #dc3545; }
        .rejected-status { color: #721c24; background: #f8d7da; padding: 8px; border-radius: 4px; border-left: 4px solid #dc3545; }
        .service-center-info { font-style: italic; font-size: 0.9em; color: #555; margin-top: 4px; }
        .form-row { display: flex; flex-direction: column; gap: 10px; }
    </style>
</head>
<body>
<div class="container">
    <h1>Book Service - Welcome, <%= clientName %></h1>

    <% if (message != null) { %>
        <div class="<%= messageClass %>"><%= message %></div>
    <% } %>

    <% if (!pendingSelections.isEmpty()) { %>
        <h2>⚠️ Action Required: Select Your Service Date</h2>
        <% for (Map<String, Object> vehicle : pendingSelections) { %>
            <div style="background: #fff; border: 2px solid #ffc107; padding: 20px; margin: 10px 0; border-radius: 8px;">
                <h3><%= vehicle.get("model") %> - <%= vehicle.get("vehicle_number") %></h3>
                <p><strong>Service Type:</strong> <%= vehicle.get("service_type") %></p>
                <% if (vehicle.get("center_name") != null) { %>
                    <p class="service-center-info">
                        📍 <strong><%= vehicle.get("center_name") %></strong><br/>
                        <small><%= vehicle.get("center_location") %></small>
                    </p>
                <% } %>
                <% if (vehicle.get("date_selection_deadline") != null) { %>
                    <div class="deadline-warning">
                        <strong>⏰ Deadline to choose:</strong> <%= vehicle.get("date_selection_deadline") %>
                    </div>
                <% } %>
                <form method="post">
                    <input type="hidden" name="action" value="select_option">
                    <input type="hidden" name="request_id" value="<%= vehicle.get("request_id") %>">
                    <div class="option-card">
                        <label>
                            <input type="radio" name="selected_option" value="1" required>
                            <strong>Option 1:</strong> <%= vehicle.get("option_1_date") %> at <%= vehicle.get("option_1_time") %>
                        </label>
                    </div>
                    <div class="option-card">
                        <label>
                            <input type="radio" name="selected_option" value="2" required>
                            <strong>Option 2:</strong> <%= vehicle.get("option_2_date") %> at <%= vehicle.get("option_2_time") %>
                        </label>
                    </div>
                    <div class="option-card">
                        <label>
                            <input type="radio" name="selected_option" value="3" required>
                            <strong>Option 3:</strong> <%= vehicle.get("option_3_date") %> at <%= vehicle.get("option_3_time") %>
                        </label>
                    </div>
                    <button type="submit" class="btn-success">Confirm Selected Date</button>
                </form>
            </div>
        <% } %>
    <% } %>

    <h2>Your Vehicles</h2>
    <table>
        <tr>
            <th>Vehicle</th>
            <th>Current Status</th>
            <th>Service Center</th>
            <th>Action</th>
        </tr>
        <% for (Map<String, Object> vehicle : vehicles) { %>
            <tr>
                <td><strong><%= vehicle.get("model") %></strong> - <%= vehicle.get("vehicle_number") %></td>
                <td>
                    <% String status = (String) vehicle.get("status");
                       if (status == null || status.trim().isEmpty()) { %>
                        <span>No Active Request</span>
                    <% } else if ("Pending".equalsIgnoreCase(status)) { %>
                        <div class="pending">⏳ Pending Admin Approval</div>
                    <% } else if ("Awaiting Client Selection".equalsIgnoreCase(status)) { %>
                        <div class="deadline-warning">⚠️ Choose Your Service Date Above</div>
                    <% } else if ("Scheduled".equalsIgnoreCase(status)) { %>
                        <div class="scheduled">
                            ✅ Scheduled<br>
                            <strong>Service:</strong> <%= vehicle.get("service_type") %><br>
                            <strong>Date:</strong> <%= vehicle.get("final_service_datetime") %>
                            <% Object selectedOption = vehicle.get("client_selected_option");
                               if (selectedOption != null) { %>
                                <br><strong>Selected:</strong> Option <%= selectedOption %>
                            <% } %>
                        </div>
                    <% } else if ("Cancelled".equalsIgnoreCase(status)) { %>
                        <div class="cancelled-status">
                            ❌ Appointment Cancelled<br>
                            <% if (vehicle.get("service_type") != null) { %>
                                <strong>Previous Service:</strong> <%= vehicle.get("service_type") %><br>
                            <% } %>
                            <% if (vehicle.get("final_service_datetime") != null) { %>
                                <strong>Was Scheduled:</strong> <%= vehicle.get("final_service_datetime") %><br>
                            <% } %>
                            <small>You can request a new appointment below</small>
                        </div>
                    <% } else if ("Rejected".equalsIgnoreCase(status)) { %>
                        <div class="rejected-status">
                            ❌ Request Rejected<br>
                            <small>You can submit a new request below</small>
                        </div>
                    <% } else if ("Completed".equalsIgnoreCase(status)) { %>
                        <div style="color: #28a745; background: #d4edda; padding: 8px; border-radius: 4px;">
                            ✅ Service Completed<br>
                            <% if (vehicle.get("service_type") != null) { %>
                                <strong>Service:</strong> <%= vehicle.get("service_type") %><br>
                            <% } %>
                            <% if (vehicle.get("final_service_datetime") != null) { %>
                                <strong>Completed on:</strong> <%= vehicle.get("final_service_datetime") %>
                            <% } %>
                        </div>
                    <% } else { %>
                        <span>Status: <%= status %></span>
                    <% } %>
                </td>
                <td>
                    <% String centerName = (String) vehicle.get("center_name");
                       String centerLocation = (String) vehicle.get("center_location");
                       if (centerName != null && !centerName.trim().isEmpty()) { %>
                        <div class="service-center-info">
                            <strong><%= centerName %></strong><br/>
                            <%= centerLocation %>
                        </div>
                    <% } else { %>
                        <em>No Service Center Assigned</em>
                    <% } %>
                </td>
                <td>
                    <% if (status == null || status.trim().isEmpty() ||
                           "Cancelled".equalsIgnoreCase(status) ||
                           "Rejected".equalsIgnoreCase(status) ||
                           "Completed".equalsIgnoreCase(status)) { %>
                        <form method="post" style="margin: 0;">
                            <input type="hidden" name="action" value="<%= ("Cancelled".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(status)) ? "request_reschedule" : "submit_request" %>">
                            <input type="hidden" name="vehicle_id" value="<%= vehicle.get("vehicle_id") %>" />

                            <div class="form-row">
                                <label><strong>📍 Select Service Center:</strong></label>
                                <select name="center_id" required>
                                    <option value="">-- Choose Location --</option>
                                    <% for (Map<String, Object> center : serviceCenters) { %>
                                        <option value="<%= center.get("center_id") %>">
                                            <%= center.get("center_name") %> - <%= center.get("location") %>
                                            <% if (center.get("contact_phone") != null) { %>
                                                (📞 <%= center.get("contact_phone") %>)
                                            <% } %>
                                        </option>
                                    <% } %>
                                </select>

                                <textarea name="remarks" placeholder="<%= ("Cancelled".equalsIgnoreCase(status)) ? "Enter reason for reschedule or new requirements..." : "Enter service requirements or remarks..." %>"></textarea>

                                <button type="submit">
                                    <%= ("Cancelled".equalsIgnoreCase(status) || "Rejected".equalsIgnoreCase(status)) ? "Request Reschedule" : "Submit Service Request" %>
                                </button>
                            </div>
                        </form>
                    <% } else if ("Awaiting Client Selection".equalsIgnoreCase(status)) { %>
                        <strong>👆 Select date above</strong>
                    <% } else if ("Scheduled".equalsIgnoreCase(status)) { %>
                        <em style="color: green;">✅ Service confirmed</em>
                    <% } else if ("Pending".equalsIgnoreCase(status)) { %>
                        <em style="color: orange;">⏳ Awaiting approval</em>
                    <% } else { %>
                        <em>No action needed</em>
                    <% } %>
                </td>
            </tr>
        <% } %>
    </table>

    <% if (vehicles.isEmpty()) { %>
        <p>No vehicles found for your account. Please contact admin to add vehicles.</p>
    <% } %>

    <% if (serviceCenters.isEmpty()) { %>
        <div class="error">
            <strong>Notice:</strong> No service centers are available. Please contact admin to set up service locations.
        </div>
    <% } %>
</div>
</body>
</html>