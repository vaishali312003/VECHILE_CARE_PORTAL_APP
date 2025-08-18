<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.example.vehicleportal.util.DBConnection, javax.servlet.http.HttpSession, java.text.SimpleDateFormat" %>
<%
    // Prevent caching of admin pages
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    // Authentication check
    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("admin") == null) {
        response.sendRedirect("adminLogin.jsp?error=session_expired");
        return;
    }

    String adminName = (String) currentSession.getAttribute("admin");
    String message = null;
    String messageClass = "success";

    try (Connection con = DBConnection.getConnection()) {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");

            // Debug: Print all parameters
            System.out.println("=== DEBUG PARAMETERS ===");
            System.out.println("Action: " + action);
            java.util.Enumeration<String> paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String paramName = paramNames.nextElement();
                String paramValue = request.getParameter(paramName);
                System.out.println(paramName + " = " + paramValue);
            }
            System.out.println("========================");

            String requestIdStr = request.getParameter("request_id");
            Integer requestId = null;

            // Better request ID parsing
            if (requestIdStr != null && !requestIdStr.trim().isEmpty()) {
                try {
                    requestId = Integer.parseInt(requestIdStr.trim());
                } catch (NumberFormatException e) {
                    message = "Invalid request ID format: " + requestIdStr;
                    messageClass = "error";
                }
            }

            if ("update_status".equals(action)) {
                String newStatus = request.getParameter("new_status");
                if (requestId != null && newStatus != null && !newStatus.trim().isEmpty()) {
                    try (PreparedStatement ps = con.prepareStatement("UPDATE service_requests SET status = ?, approval_date = NOW() WHERE request_id = ?")) {
                        ps.setString(1, newStatus.trim());
                        ps.setInt(2, requestId);
                        int updated = ps.executeUpdate();
                        if (updated > 0) {
                            message = "Request " + requestId + " status updated to: " + newStatus;
                            if ("Cancelled".equals(newStatus) || "Rejected".equals(newStatus)) {
                                try (PreparedStatement clearPs = con.prepareStatement("UPDATE service_requests SET client_selected_option = NULL, final_service_datetime = NULL WHERE request_id = ?")) {
                                    clearPs.setInt(1, requestId);
                                    clearPs.executeUpdate();
                                }
                                if ("Cancelled".equals(newStatus)) {
                                    message += " - Client can now request reschedule.";
                                } else {
                                    message += " - Client can submit a new request.";
                                }
                            }
                        } else {
                            message = "Failed to update status.";
                            messageClass = "error";
                        }
                    }
                } else {
                    message = "Missing request ID (" + requestId + ") or status (" + newStatus + ").";
                    messageClass = "error";
                }
            } else if ("assign_slots".equals(action)) {
                String serviceType = request.getParameter("service_type");
                String opt1Date = request.getParameter("option_1_date");
                String opt1Time = request.getParameter("option_1_time");
                String opt2Date = request.getParameter("option_2_date");
                String opt2Time = request.getParameter("option_2_time");
                String opt3Date = request.getParameter("option_3_date");
                String opt3Time = request.getParameter("option_3_time");

                if (requestId != null && serviceType != null && !serviceType.trim().isEmpty() &&
                    opt1Date != null && !opt1Date.trim().isEmpty() &&
                    opt1Time != null && !opt1Time.trim().isEmpty() &&
                    opt2Date != null && !opt2Date.trim().isEmpty() &&
                    opt2Time != null && !opt2Time.trim().isEmpty() &&
                    opt3Date != null && !opt3Date.trim().isEmpty() &&
                    opt3Time != null && !opt3Time.trim().isEmpty()) {

                    try (PreparedStatement ps = con.prepareStatement(
                        "UPDATE service_requests SET option_1_date=?, option_1_time=?, option_2_date=?, option_2_time=?, option_3_date=?, option_3_time=?, service_type=?, date_selection_deadline = NOW() + INTERVAL '3 days', status = 'Awaiting Client Selection', approval_date = NOW() WHERE request_id=?")) {
                        ps.setDate(1, Date.valueOf(opt1Date));
                        ps.setTime(2, Time.valueOf(opt1Time + ":00"));
                        ps.setDate(3, Date.valueOf(opt2Date));
                        ps.setTime(4, Time.valueOf(opt2Time + ":00"));
                        ps.setDate(5, Date.valueOf(opt3Date));
                        ps.setTime(6, Time.valueOf(opt3Time + ":00"));
                        ps.setString(7, serviceType);
                        ps.setInt(8, requestId);

                        int updated = ps.executeUpdate();
                        if (updated > 0) {
                            message = "Service slots assigned successfully for Request ID: " + requestId + "! Client can now select a preferred option.";
                        } else {
                            message = "Failed to assign slots for Request ID: " + requestId;
                            messageClass = "error";
                        }
                    }
                } else {
                    message = "Please fill all slot details. Missing: " +
                              (requestId == null ? "Request ID " : "") +
                              (serviceType == null || serviceType.trim().isEmpty() ? "Service Type " : "") +
                              (opt1Date == null || opt1Date.trim().isEmpty() ? "Option 1 Date " : "") +
                              (opt1Time == null || opt1Time.trim().isEmpty() ? "Option 1 Time " : "") +
                              (opt2Date == null || opt2Date.trim().isEmpty() ? "Option 2 Date " : "") +
                              (opt2Time == null || opt2Time.trim().isEmpty() ? "Option 2 Time " : "") +
                              (opt3Date == null || opt3Date.trim().isEmpty() ? "Option 3 Date " : "") +
                              (opt3Time == null || opt3Time.trim().isEmpty() ? "Option 3 Time " : "");
                    messageClass = "error";
                }
            }
        }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin - Manage Service Requests</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            color: #fff;
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 1400px;
            margin: 0 auto;
            background: rgba(22, 33, 62, 0.95);
            padding: 25px;
            border-radius: 18px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            backdrop-filter: blur(10px);
        }
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid rgba(255, 149, 0, 0.3);
        }
        .page-header h2 {
            color: #ff9500;
            margin: 0;
            font-size: 1.8em;
        }
        .admin-badge {
            background: linear-gradient(45deg, #ff9500, #ff6b35);
            color: #000;
            padding: 8px 16px;
            border-radius: 20px;
            font-weight: 600;
        }
        .success {
            background: rgba(40, 167, 69, 0.2);
            color: #28a745;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid rgba(40, 167, 69, 0.3);
        }
        .error {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            padding: 12px 20px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid rgba(220, 53, 69, 0.3);
        }
        .table-container {
            max-height: 70vh;
            overflow-y: auto;
            border-radius: 12px;
            background: rgba(15, 15, 35, 0.6);
            border: 1px solid rgba(255,255,255,0.1);
        }
        table {
            border-collapse: separate;
            border-spacing: 0;
            width: 100%;
            margin: 0;
        }
        th, td {
            padding: 12px 10px;
            border-bottom: 1px solid rgba(255,255,255,0.08);
            text-align: left;
            vertical-align: top;
        }
        th {
            background: rgba(255, 149, 0, 0.15);
            color: #ff9500;
            font-weight: 600;
            position: sticky;
            top: 0;
            z-index: 10;
            border-bottom: 2px solid rgba(255, 149, 0, 0.3);
        }
        tr:hover {
            background: rgba(255,255,255,0.05);
        }
        .client-info {
            max-width: 150px;
        }
        .client-info .client-name {
            font-weight: 600;
            color: #ff9500;
            font-size: 0.95em;
        }
        .client-info .vehicle-info {
            font-size: 0.85em;
            color: #d1d1d1;
            margin-top: 2px;
        }
        .center-info {
            max-width: 160px;
        }
        .center-info .center-name {
            font-weight: 600;
            color: #4fc3f7;
            font-size: 0.9em;
            display: flex;
            align-items: center;
            gap: 4px;
        }
        .center-info .center-location {
            font-size: 0.8em;
            color: #b0b0b0;
            margin-top: 2px;
            line-height: 1.2;
        }
        .service-details {
            max-width: 180px;
            font-size: 0.85em;
        }
        .service-details > div {
            margin-bottom: 4px;
        }
        .service-details .service-label {
            color: #ff9500;
            font-weight: 500;
        }
        .service-details .service-value {
            color: #e0e0e0;
        }
        .btn {
            background: linear-gradient(45deg, #ff9500, #ff6b35);
            color: #000;
            padding: 8px 16px;
            border: none;
            border-radius: 20px;
            cursor: pointer;
            margin: 2px;
            font-weight: 600;
            font-size: 0.85em;
            transition: all 0.3s;
        }
        .btn:hover {
            filter: brightness(1.1);
            transform: translateY(-1px);
        }
        .btn-approve {
            background: linear-gradient(45deg, #28a745, #20c997);
            color: #fff;
        }
        .btn-reject {
            background: linear-gradient(45deg, #dc3545, #fd7e14);
            color: #fff;
        }
        .btn-complete {
            background: linear-gradient(45deg, #28a745, #20c997);
            color: #fff;
        }
        .btn-secondary {
            background: rgba(255,255,255,0.1);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.2);
        }
        .action-info {
            font-size: 0.8em;
            text-align: center;
            padding: 4px 8px;
        }
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #ffc107;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-approved {
            background: rgba(40, 167, 69, 0.2);
            color: #28a745;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-awaiting {
            background: rgba(13, 202, 240, 0.2);
            color: #0dcaf0;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-scheduled {
            background: rgba(111, 66, 193, 0.2);
            color: #6f42c1;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-cancelled {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-completed {
            background: rgba(25, 135, 84, 0.2);
            color: #198754;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .status-rejected {
            background: rgba(220, 53, 69, 0.2);
            color: #dc3545;
            padding: 4px 8px;
            border-radius: 12px;
            font-size: 0.8em;
            font-weight: 500;
        }
        .modal {
            display: none;
            position: fixed;
            top: 0; left: 0;
            width: 100%; height: 100%;
            background: rgba(0,0,0,0.7);
            backdrop-filter: blur(5px);
            z-index: 1000;
        }
        .modal-content {
            background: rgba(22, 33, 62, 0.95);
            margin: 5% auto;
            padding: 25px;
            width: 85%;
            max-width: 700px;
            border-radius: 18px;
            box-sizing: border-box;
            border: 1px solid rgba(255,255,255,0.1);
            color: #fff;
            max-height: 85vh;
            overflow-y: auto;
            position: relative;
        }
        .close {
            position: absolute;
            top: 15px;
            right: 20px;
            font-size: 28px;
            font-weight: bold;
            cursor: pointer;
            color: #ff9500;
        }
        .close:hover {
            color: #ff6b35;
        }
        .form-group {
            margin: 15px 0;
        }
        label {
            font-weight: 600;
            display: block;
            margin-bottom: 5px;
            color: #d1d1d1;
        }
        select, input, textarea {
            padding: 10px;
            border-radius: 6px;
            border: 1px solid rgba(255,255,255,0.2);
            background: rgba(255,255,255,0.05);
            color: #fff;
            width: 100%;
            box-sizing: border-box;
            font-size: 1em;
            font-family: inherit;
        }
        select:focus, input:focus, textarea:focus {
            outline: none;
            border-color: #ff9500;
            background: rgba(255,255,255,0.1);
        }
        fieldset {
            margin: 10px 0;
            padding: 15px;
            border: 1px solid rgba(255,255,255,0.2);
            border-radius: 8px;
            background: rgba(255,255,255,0.02);
        }
        legend {
            font-weight: 600;
            padding: 0 10px;
            color: #ff9500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="page-header">
            <h2>Service Request Management</h2>
            <div class="admin-badge">👨‍💼 <%= adminName %></div>
        </div>

        <% if (message != null) { %>
          <div class="<%=messageClass %>"><%=message %></div>
        <% } %>

        <h3>📋 All Service Requests</h3>
        <div class="table-container">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Client & Vehicle</th>
                        <th>Request Date</th>
                        <th>Status</th>
                        <th>Service Center</th>
                        <th>Service Details</th>
                        <th>Admin Actions</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    try (Statement stmt = con.createStatement()) {
                        ResultSet rs = stmt.executeQuery(
                            "SELECT DISTINCT " +
                                "sr.request_id, sr.vehicle_id, sr.request_date, sr.remarks, sr.status, " +
                                "sr.approval_date, sr.service_type, sr.date_selection_deadline, " +
                                "sr.option_1_date, sr.option_1_time, sr.option_2_date, sr.option_2_time, " +
                                "sr.option_3_date, sr.option_3_time, sr.final_service_datetime, sr.client_selected_option, " +
                                "vc.vehicle_number, vc.model, vc.client_name, " +
                                "sc.center_name, sc.location, " +
                                "(CASE " +
                                    "WHEN sr.status = 'Pending' THEN 1 " +
                                    "WHEN sr.status = 'Awaiting Client Selection' THEN 2 " +
                                    "WHEN sr.status = 'Scheduled' THEN 3 " +
                                    "WHEN sr.status = 'Approved' THEN 4 " +
                                    "WHEN sr.status = 'Completed' THEN 5 ELSE 6 END) AS sort_order " +
                            "FROM service_requests sr " +
                            "JOIN vehicle_client vc ON sr.vehicle_id = vc.vehicle_id " +
                            "LEFT JOIN service_centers sc ON sr.center_id = sc.center_id " +
                            "ORDER BY sort_order, sr.request_date DESC"
                        );
                        boolean hasRequests = false;
                        while(rs.next()) {
                            hasRequests = true;
                            String status = rs.getString("status");
                            String statusClass = "";
                            switch (status) {
                                case "Pending": statusClass = "status-pending"; break;
                                case "Approved": statusClass = "status-approved"; break;
                                case "Awaiting Client Selection": statusClass = "status-awaiting"; break;
                                case "Scheduled": statusClass = "status-scheduled"; break;
                                case "Cancelled": statusClass = "status-cancelled"; break;
                                case "Completed": statusClass = "status-completed"; break;
                                case "Rejected": statusClass = "status-rejected"; break;
                            }

                            // Store data in JavaScript-accessible format
                            String clientName = rs.getString("client_name");
                            String model = rs.getString("model");
                            String vehicleNumber = rs.getString("vehicle_number");
                %>
                <tr data-client="<%=clientName%>" data-vehicle="<%=model%> - <%=vehicleNumber%>">
                    <td><strong><%=rs.getInt("request_id")%></strong></td>
                    <td class="client-info">
                        <div class="client-name"><%=clientName%></div>
                        <div class="vehicle-info"><%=model%><br /><%=vehicleNumber%></div>
                    </td>
                    <td style="font-size: 0.85em;"><%= new SimpleDateFormat("MMM dd, yyyy").format(rs.getTimestamp("request_date")) %></td>
                    <td><span class="<%=statusClass%>"><%=status%></span></td>
                    <td class="center-info">
                    <% if(rs.getString("center_name") != null) { %>
                        <div class="center-name">📍 <%=rs.getString("center_name")%></div>
                        <div class="center-location"><%=rs.getString("location")%></div>
                    <% } else { %>
                        <em style="color:#888;">No center assigned</em>
                    <% } %>
                    </td>
                    <td class="service-details">
                        <% if(rs.getString("service_type") != null) { %>
                        <div><span class="service-label">Type:</span> <span class="service-value"><%=rs.getString("service_type")%></span></div>
                        <% } %>
                        <% if(rs.getTimestamp("final_service_datetime") != null) { %>
                        <div><span class="service-label">Scheduled:</span> <span class="service-value"><%=new SimpleDateFormat("MMM dd, HH:mm").format(rs.getTimestamp("final_service_datetime")) %></span></div>
                        <% } %>
                        <% if(rs.getObject("client_selected_option") != null) { %>
                        <div><span class="service-label">Selected:</span> <span class="service-value">Option <%=rs.getInt("client_selected_option")%></span></div>
                        <% } %>
                        <% if(rs.getTimestamp("date_selection_deadline") != null) { %>
                        <div><span class="service-label">Deadline:</span> <span class="service-value"><%=new SimpleDateFormat("MMM dd").format(rs.getTimestamp("date_selection_deadline"))%></span></div>
                        <% } %>
                        <% if(rs.getString("remarks") != null && !rs.getString("remarks").trim().isEmpty()) { %>
                        <div><span class="service-label">Notes:</span> <span class="service-value"><%= rs.getString("remarks").length() > 30 ? rs.getString("remarks").substring(0,30) + "..." : rs.getString("remarks") %></span></div>
                        <% } %>
                    </td>
                    <td>
                        <div class="action-buttons">
                            <%
                            int currentRequestId = rs.getInt("request_id");
                            %>
                            <% if("Pending".equals(status)) { %>
                                <button class="btn btn-approve" onclick="updateStatus(<%=currentRequestId%>, 'Approved')">✓ Approve</button>
                                <button class="btn" onclick="openAssignModal(<%=currentRequestId%>)">📅 Assign Slots</button>
                                <button class="btn btn-reject" onclick="updateStatus(<%=currentRequestId%>, 'Rejected')">✗ Reject</button>
                            <% } else if("Approved".equals(status)) { %>
                                <button class="btn" onclick="openAssignModal(<%=currentRequestId%>)">📅 Assign Slots</button>
                                <button class="btn btn-reject" onclick="updateStatus(<%=currentRequestId%>, 'Rejected')">✗ Reject</button>
                            <% } else if("Awaiting Client Selection".equals(status)) { %>
                                <div class="action-info">⏳ Waiting for client</div>
                                <button class="btn btn-reject" onclick="updateStatus(<%=currentRequestId%>, 'Cancelled')">Cancel</button>
                            <% } else if("Scheduled".equals(status)) { %>
                                <div class="action-info" style="color:#28a745;">✅ Confirmed</div>
                                <button class="btn btn-complete" onclick="updateStatus(<%=currentRequestId%>, 'Completed')">✓ Complete</button>
                                <button class="btn btn-reject" onclick="updateStatus(<%=currentRequestId%>, 'Cancelled')">Cancel</button>
                            <% } else if("Cancelled".equals(status)) { %>
                                <div class="action-info" style="color:#dc3545;">⌫ Cancelled<br /><small>Can reschedule</small></div>
                            <% } else if("Completed".equals(status)) { %>
                                <div class="action-info" style="color:#28a745;">✅ Completed</div>
                            <% } else if("Rejected".equals(status)) { %>
                                <div class="action-info" style="color:#dc3545;">⌫ Rejected<br /><small>Can resubmit</small></div>
                            <% } else { %>
                                <em>No actions</em>
                            <% } %>
                        </div>
                    </td>
                </tr>
                <% } // end while

                if(!hasRequests){ %>
                <tr>
                    <td colspan="7" style="text-align:center; color:#888; padding:40px;">
                        No service requests found.
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
            <% } // end try stmt %>
        </div>
    </div>

    <!-- Assign Slot Modal -->
    <div id="assignModal" class="modal">
        <div class="modal-content">
            <span class="close" onclick="closeModal()">&times;</span>
            <h3 id="modal_title">📅 Assign Service Slots</h3>
            <form method="POST" action="" onsubmit="return validateAssignForm();">
                <input type="hidden" name="action" value="assign_slots" />
                <input type="hidden" id="modal_request_id" name="request_id" />

                <div class="form-group">
                    <label for="service_type">Service Type *</label>
                    <select name="service_type" id="service_type" required>
                        <option value="">--Select Service Type--</option>
                        <option value="Oil Change & Filter">🛢️ Oil Change & Filter</option>
                        <option value="Brake Inspection">🛑 Brake Inspection</option>
                        <option value="General Maintenance">🔧 General Maintenance</option>
                        <option value="Tire Rotation">🛞 Tire Rotation</option>
                        <option value="Engine Diagnostic">🔍 Engine Diagnostic</option>
                        <option value="Transmission Service">⚙️ Transmission Service</option>
                        <option value="AC Service">❄️ AC Service</option>
                        <option value="Battery Check">🔋 Battery Check</option>
                        <option value="Wheel Alignment">📐 Wheel Alignment</option>
                    </select>
                </div>

                <fieldset>
                    <legend>Option 1</legend>
                    <label for="option_1_date">Date *</label>
                    <input type="date" name="option_1_date" id="option_1_date" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" />
                   <br /><br />
                    <label for="option_1_time">Time *</label>
                    <input type="time" name="option_1_time" id="option_1_time" required />
                </fieldset>

                <fieldset>
                    <legend>Option 2</legend>
                    <label for="option_2_date">Date *</label>
                    <input type="date" name="option_2_date" id="option_2_date" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" />
                   <br /><br />
                    <label for="option_2_time">Time *</label>
                    <input type="time" name="option_2_time" id="option_2_time" required />
                </fieldset>

                <fieldset>
                    <legend>Option 3</legend>
                    <label for="option_3_date">Date *</label>
                    <input type="date" name="option_3_date" id="option_3_date" required min="<%= new SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" />
                   <br /><br />
                    <label for="option_3_time">Time *</label>
                    <input type="time" name="option_3_time" id="option_3_time" required />
                </fieldset>

                <input type="submit" class="btn" value="📤 Assign Slots & Notify Client" />
                <button type="button" class="btn btn-secondary" onclick="closeModal()">Cancel</button>
            </form>
        </div>
    </div>

<script>
function openAssignModal(requestId){
    const row = event.target.closest('tr');
    const clientName = row.getAttribute('data-client');
    const vehicleInfo = row.getAttribute('data-vehicle');

    document.getElementById('modal_request_id').value = requestId;
    document.getElementById('modal_title').innerHTML = '📅 Assign Service Slots for: ' + clientName + ' - ' + vehicleInfo;
    document.getElementById('assignModal').style.display = 'block';
    document.body.style.overflow = 'hidden';

    // Debug: Log the request ID being set
    console.log('Setting request ID to:', requestId);
    console.log('Hidden input value:', document.getElementById('modal_request_id').value);
}

function closeModal(){
    document.getElementById('assignModal').style.display = 'none';
    document.body.style.overflow = '';
}

function validateAssignForm(){
    const requestId = document.getElementById('modal_request_id').value;
    const serviceType = document.getElementById('service_type').value;

    // Debug: Check form values before submission
    console.log('Form validation - Request ID:', requestId);
    console.log('Form validation - Service Type:', serviceType);

    if (!requestId || requestId === '') {
        alert('Error: Request ID is missing. Please close the modal and try again.');
        return false;
    }

    if (!serviceType || serviceType === '') {
        alert('Please select a service type.');
        return false;
    }

    const dates = [
        document.getElementById('option_1_date').value,
        document.getElementById('option_2_date').value,
        document.getElementById('option_3_date').value
    ];
    const times = [
        document.getElementById('option_1_time').value,
        document.getElementById('option_2_time').value,
        document.getElementById('option_3_time').value
    ];

    // Check if all fields are filled
    for(let i = 0; i < dates.length; i++) {
        if (!dates[i] || !times[i]) {
            alert(`Please fill in all date and time fields for Option ${i + 1}.`);
            return false;
        }
    }

    // Check for duplicate slots
    for(let i = 0; i < dates.length; i++){
        for(let j = i + 1; j < dates.length; j++){
            if(dates[i] === dates[j] && times[i] === times[j]){
                alert(`Options ${i+1} and ${j+1} have the same date and time. Please choose different slots.`);
                return false;
            }
        }
    }

    console.log('Form validation passed - submitting form');
    return true;
}

function updateStatus(requestId, newStatus){
    // Debug logging
    console.log('updateStatus called with:', requestId, newStatus);

    // Validate parameters
    if (!requestId || requestId === '' || requestId === null || requestId === undefined) {
        alert('Error: Invalid request ID: ' + requestId);
        return;
    }

    if (!newStatus || newStatus === '' || newStatus === null || newStatus === undefined) {
        alert('Error: Invalid status: ' + newStatus);
        return;
    }

    let msg = '';
    switch(newStatus){
        case 'Cancelled':
            msg = "Are you sure you want to CANCEL this appointment? The client will be able to request reschedule.";
            break;
        case 'Completed':
            msg = "Mark this service as COMPLETED?";
            break;
        case 'Rejected':
            msg = "Are you sure you want to REJECT this request? The client will be able to submit a new request.";
            break;
        case 'Approved':
            msg = "Are you sure you want to APPROVE this request?";
            break;
        default:
            msg = "Are you sure you want to update status to: "+newStatus+"?";
    }

    if(confirm(msg)){
        // Create form with explicit action
        const form = document.createElement('form');
        form.method = 'POST';
        form.action = window.location.pathname; // Explicit action to current page

        // Create hidden inputs individually for better debugging
        const actionInput = document.createElement('input');
        actionInput.type = 'hidden';
        actionInput.name = 'action';
        actionInput.value = 'update_status';
        form.appendChild(actionInput);

        const requestIdInput = document.createElement('input');
        requestIdInput.type = 'hidden';
        requestIdInput.name = 'request_id';
        requestIdInput.value = requestId;
        form.appendChild(requestIdInput);

        const statusInput = document.createElement('input');
        statusInput.type = 'hidden';
        statusInput.name = 'new_status';
        statusInput.value = newStatus;
        form.appendChild(statusInput);

        // Debug: Log form contents before submission
        console.log('Form being submitted:');
        console.log('Action:', actionInput.value);
        console.log('Request ID:', requestIdInput.value);
        console.log('New Status:', statusInput.value);

        document.body.appendChild(form);
        form.submit();
    }
}

window.onclick = function(event){
    const modal = document.getElementById('assignModal');
    if(event.target === modal){
        closeModal();
    }
}

document.addEventListener('keydown', function(e){
    if(e.key === "Escape" && document.getElementById('assignModal').style.display === 'block'){
        closeModal();
    }
});

// Additional debugging - log form submission
document.addEventListener('DOMContentLoaded', function() {
    const assignForm = document.querySelector('#assignModal form');
    if (assignForm) {
        assignForm.addEventListener('submit', function(e) {
            console.log('Form being submitted with action:', this.action);
            console.log('Form method:', this.method);

            // Log all form data
            const formData = new FormData(this);
            for (let [key, value] of formData.entries()) {
                console.log(key + ': ' + value);
            }
        });
    }
});
</script>
</body>
</html>

<%
    } catch (Exception e) {
        out.println("<div class='error'>Database error: " + e.getMessage() + "</div>");
        e.printStackTrace();
    }
%>