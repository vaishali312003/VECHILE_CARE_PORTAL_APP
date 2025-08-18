<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.sql.*, com.example.vehicleportal.util.DBConnection, javax.servlet.http.HttpSession, java.text.SimpleDateFormat" %>
<%!
    public java.sql.Date convertStringToSqlDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false);
            java.util.Date utilDate = sdf.parse(dateString.trim());
            return new java.sql.Date(utilDate.getTime());
        } catch (Exception e) {
            System.err.println("Date conversion error for: " + dateString + " - " + e.getMessage());
            return null;
        }
    }
%>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    HttpSession currentSession = request.getSession(false);
    if (currentSession == null || currentSession.getAttribute("admin") == null) {
        response.sendRedirect("adminLogin.jsp?error=session_expired");
        return;
    }
    String adminName = (String) currentSession.getAttribute("admin");
    String message = null;
    String messageClass = "success";
    int pendingRequests = 0, totalRequests = 0, approvedRequests = 0;

    try (Connection conn = DBConnection.getConnection()) {
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String action = request.getParameter("action");
            if ("add_vehicle".equals(action)) {
                String vehicleNumber = request.getParameter("vehicle_number");
                String model = request.getParameter("model");
                String warrantyDateStr = request.getParameter("warranty_date");
                String registrationDateStr = request.getParameter("registration_date");
                String serviceDateStr = request.getParameter("service_date");
                if (vehicleNumber != null) vehicleNumber = vehicleNumber.trim().toUpperCase();
                if (model != null) model = model.trim();
                java.sql.Date warrantyDate = convertStringToSqlDate(warrantyDateStr);
                java.sql.Date registrationDate = convertStringToSqlDate(registrationDateStr);
                java.sql.Date serviceDate = convertStringToSqlDate(serviceDateStr);
                PreparedStatement ps = null;
                try {
                    ps = conn.prepareStatement(
                        "INSERT INTO vehicle_client (vehicle_number, model, warranty_date, registration_date, service_date) VALUES (?, ?, ?, ?, ?)"
                    );
                    ps.setString(1, vehicleNumber);
                    ps.setString(2, model);
                    ps.setDate(3, warrantyDate);
                    ps.setDate(4, registrationDate);
                    ps.setDate(5, serviceDate);
                    int inserted = ps.executeUpdate();
                    if (inserted > 0) {
                        message = "Vehicle '" + vehicleNumber + "' added successfully!";
                    } else {
                        message = "Failed to add vehicle.";
                        messageClass = "error";
                    }
                } catch (SQLException e) {
                    if ("23505".equals(e.getSQLState())) {
                        message = "Vehicle number '" + vehicleNumber + "' already exists!";
                    } else {
                        message = "Database error: " + e.getMessage();
                    }
                    messageClass = "error";
                    System.err.println("Add vehicle error: " + e.getMessage());
                } finally {
                    if (ps != null) ps.close();
                }
            }
            else if ("update_vehicle".equals(action)) {
                String vehicleNumber = request.getParameter("vehicle_number");
                String model = request.getParameter("model");
                String warrantyDateStr = request.getParameter("warranty_date");
                String registrationDateStr = request.getParameter("registration_date");
                String serviceDateStr = request.getParameter("service_date");
                if (vehicleNumber != null) vehicleNumber = vehicleNumber.trim().toUpperCase();
                if (model != null) model = model.trim();
                java.sql.Date warrantyDate = convertStringToSqlDate(warrantyDateStr);
                java.sql.Date registrationDate = convertStringToSqlDate(registrationDateStr);
                java.sql.Date serviceDate = convertStringToSqlDate(serviceDateStr);
                PreparedStatement ps = null;
                try {
                    ps = conn.prepareStatement(
                        "UPDATE vehicle_client SET model=?, warranty_date=?, registration_date=?, service_date=? WHERE vehicle_number=?"
                    );
                    ps.setString(1, model);
                    ps.setDate(2, warrantyDate);
                    ps.setDate(3, registrationDate);
                    ps.setDate(4, serviceDate);
                    ps.setString(5, vehicleNumber);
                    int updated = ps.executeUpdate();
                    if (updated > 0) {
                        message = "Vehicle '" + vehicleNumber + "' updated successfully!";
                    } else {
                        message = "Vehicle not found or no changes made.";
                        messageClass = "error";
                    }
                } catch (SQLException e) {
                    message = "Error updating vehicle: " + e.getMessage();
                    messageClass = "error";
                    System.err.println("Update vehicle error: " + e.getMessage());
                } finally {
                    if (ps != null) ps.close();
                }
            }
            else if ("delete_vehicle".equals(action)) {
                String vehicleNumber = request.getParameter("vehicle_number");
                if (vehicleNumber != null) vehicleNumber = vehicleNumber.trim().toUpperCase();
                PreparedStatement checkPs = null;
                PreparedStatement deletePs = null;
                try {
                    checkPs = conn.prepareStatement(
                        "SELECT COUNT(*) FROM service_requests WHERE vehicle_id = (SELECT vehicle_id FROM vehicle_client WHERE vehicle_number = ?) AND status IN ('Pending', 'Awaiting Client Selection', 'Scheduled')"
                    );
                    checkPs.setString(1, vehicleNumber);
                    ResultSet checkRs = checkPs.executeQuery();
                    if (checkRs.next() && checkRs.getInt(1) > 0) {
                        message = "Cannot delete vehicle: It has active service requests. Please complete or cancel them first.";
                        messageClass = "error";
                    } else {
                        deletePs = conn.prepareStatement("DELETE FROM vehicle_client WHERE vehicle_number = ?");
                        deletePs.setString(1, vehicleNumber);
                        int deleted = deletePs.executeUpdate();
                        if (deleted > 0) {
                            message = "Vehicle '" + vehicleNumber + "' deleted successfully!";
                        } else {
                            message = "Vehicle not found.";
                            messageClass = "error";
                        }
                    }
                } catch (SQLException e) {
                    message = "Error deleting vehicle: " + e.getMessage();
                    messageClass = "error";
                    System.err.println("Delete vehicle error: " + e.getMessage());
                } finally {
                    if (checkPs != null) checkPs.close();
                    if (deletePs != null) deletePs.close();
                }
            }
        }
        Statement s = conn.createStatement();
        ResultSet rs = s.executeQuery("SELECT COUNT(*) FROM service_requests WHERE status='PENDING'");
        if (rs.next()) pendingRequests = rs.getInt(1);
        rs = s.executeQuery("SELECT COUNT(*) FROM service_requests");
        if (rs.next()) totalRequests = rs.getInt(1);
        rs = s.executeQuery("SELECT COUNT(*) FROM service_requests WHERE status='APPROVED'");
        if (rs.next()) approvedRequests = rs.getInt(1);
        s.close();
    } catch (Exception e) {
        System.err.println("Dashboard stats error: " + e.getMessage());
        e.printStackTrace();
        if (message == null) {
            message = "Error loading dashboard data. Please try again.";
            messageClass = "error";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Admin Dashboard - Vehicle Care</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
    <meta http-equiv="Pragma" content="no-cache">
    <meta http-equiv="Expires" content="0">
    <link href="https://fonts.googleapis.com/css?family=Roboto:400,700|Montserrat:600" rel="stylesheet">
    <style>
        body { margin:0; font-family: 'Roboto', Arial, sans-serif; background:#f7f9fb;}
        .dashboard-container { display:flex; min-height:100vh; }
        .sidebar {
            background:#283646; color:#fff; width:240px; padding:32px 20px 0; flex-shrink:0; height:100vh;
            box-shadow:2px 0 10px rgba(40,54,70,0.08);
            display:flex; flex-direction:column; justify-content:space-between;
        }
        .logo { font-size:2em; font-family:'Montserrat',sans-serif; font-weight:600; margin-bottom:28px; color:#ff6b35;}
        .admin-info h4 { margin:0 0 4px 0; font-weight:400; }
        .admin-info p { margin:0 0 24px 0; font-size:1em; }
        .nav-menu { list-style:none; padding:0; margin:0; }
        .nav-item { margin-bottom:16px; }
        .nav-link {
            display:flex; align-items:center; gap:10px;
            color:#fff; text-decoration:none; padding:10px 16px; border-radius:6px;
            font-weight:500; transition:background 0.2s;
        }
        .nav-link.active, .nav-link:hover { background:#384963; }
        .logout-btn { background:#FB4D3D; color:#fff; border:0; padding:8px 22px; border-radius:24px; font-weight:600; margin-left:auto; text-decoration:none;}
        .main-content { flex:1; padding:38px 40px 32px; }
        .header { display:flex; align-items:center; justify-content:space-between; margin-bottom:32px;}
        h2 { margin:0; font-family:'Montserrat',sans-serif; color:#283646;}
        .cards-container { display:flex; gap:36px; }
        .feature-card {
            background:#fff; border-radius:18px; box-shadow:0 1px 10px rgba(40,54,70,0.09);
            padding:28px 28px 20px 28px; width:355px; flex-direction:column; min-height:330px;
            display:flex; flex-shrink:0;
        }
        .feature-card .card-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:6px;}
        .card-title { font-size:1.18em; color:#283646; margin:0;}
        .card-badge { background:#ff7500; color:#fff; padding:3px 14px; border-radius:16px; font-weight:600; font-size:1em; }
        .action-buttons { margin-top:auto; }
        .btn { display:inline-block; padding:8px 22px; border-radius:22px; text-decoration:none; font-weight:600; border:0; cursor:pointer; box-shadow:0 1px 4px rgba(40,54,70,.05); transition:background 0.15s;}
        .btn-primary { background:linear-gradient(90deg,#42a5f5,#0d47a1); color:#fff;}
        .btn-primary:hover { background:linear-gradient(90deg,#0d47a1,#1565c0);}
        .alert { padding:9px 23px; border-radius:14px; margin-bottom:24px; font-size:1.05em;}
        .alert.success { background:#e5f8e6; color:#08752e; }
        .alert.error { background:#fff5eb; color:#d0322c; }
        /* Tabs styling */
        .tab-container { width:100%;}
        .tabs {list-style:none;padding:0;display:flex;gap:0;margin:0 0 24px 0;}
        .tab {
            padding:10px 26px; background:#f1f3f6; margin-right:2px; border-radius:14px 14px 0 0;
            font-weight:600; cursor:pointer; transition:background 0.2s; color:#283646;
            border-bottom:0; position:relative;
        }
        .tab.active { background:linear-gradient(90deg,#42a5f5,#0d47a1); color:#fff; }
        .tab-content { background:#f9fbfd; border-radius:0 0 14px 14px; padding:24px 16px 8px; }
        .form-group { margin-bottom:15px; }
        .form-group label { display:block; margin-bottom:4px; font-weight:500; color:#283646;}
        .form-group input[type="text"], .form-group input[type="date"] {
            width:98%; padding:7px 12px; border-radius:8px; border:1.4px solid #bcd0ed; font-size:1.04em;
        }
        .form-group input[type="submit"] { margin-top:6px;}
        @media (max-width:1160px) {.cards-container {flex-wrap:wrap;}}
        @media (max-width:800px) {.sidebar {display:none;} .main-content{padding:26px 5vw;}}
        /* Notification badge styling */
        .notification-badge { background:#fa2929; color:#fff; border-radius:50%; font-size:0.95em; padding:3px 10px; margin-left:7px;}
    </style>
    <script>
        function showTab(tabName) {
            document.querySelectorAll('.tab-content').forEach(el=>el.style.display="none");
            document.querySelectorAll('.tab').forEach(el=>el.classList.remove("active"));
            document.getElementById('tab-'+tabName).style.display="block";
            const tab = document.querySelector('.tab.'+tabName);
            if(tab) tab.classList.add("active");
        }
        window.onload = function() {
            showTab('add'); // Default
        }
        window.history.pushState(null,null,window.location.href);
        window.onpopstate = function(){window.history.pushState(null,null,window.location.href);}
        // Session timeout handling (same as you used)
        let sessionTimeout = 30*60*1000;
        let warningTime = 5*60*1000;
        setTimeout(function() {
            if(confirm("Your session will expire in 5 minutes. Click OK to stay logged in.")){window.location.reload();}
        }, sessionTimeout-warningTime);
        setTimeout(function(){
            alert("Session expired. You will be redirected to login page.");window.location.href="logout";
        }, sessionTimeout);
        // Success message auto-hide
        document.addEventListener('DOMContentLoaded',function(){
            const successAlerts=document.querySelectorAll('.alert.success');
            successAlerts.forEach(function(alert){
                setTimeout(function(){
                    alert.style.transition='opacity 0.5s';alert.style.opacity='0';
                    setTimeout(function(){alert.remove();},500);
                },5000);
            });
        });
        function validateVehicleNumber(input){
            let value=input.value.toUpperCase().replace(/[^A-Z0-9]/g,'');
            input.value=value;
            if(value.length<4)input.style.borderColor='rgba(239,68,68,0.6)';
            else input.style.borderColor='rgba(34,197,94,0.6)';
        }
        function validateForm(form){
            const vehicleNumber=form.querySelector('input[name="vehicle_number"]');
            const model=form.querySelector('input[name="model"]');
            if(vehicleNumber&&vehicleNumber.value.trim().length<4){
                alert('Vehicle number must be at least 4 characters long.');vehicleNumber.focus();return false;
            }
            if(model&&model.value.trim().length<2){
                alert('Model name must be at least 2 characters long.');model.focus();return false;
            }
            return true;
        }
        document.addEventListener('DOMContentLoaded', function() {
            const forms=document.querySelectorAll('form');
            forms.forEach(function(form){
                form.addEventListener('submit', function(e){
                    if(!validateForm(form)){e.preventDefault();}
                });
            });
        });
    </script>
</head>
<body>
<div class="dashboard-container">
    <!-- Sidebar -->
    <div class="sidebar">
        <div>
            <div class="logo">Vehicle Care <span style="font-size:0.83em; color:#fff;">ADMIN</span></div>
            <div class="admin-info">
                <h4>Welcome Admin</h4>
                <p><%= adminName %></p>
            </div>
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="adminDashboard.jsp" class="nav-link active">
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="serviceRequests.jsp" class="nav-link">
                        Service Requests <% if (pendingRequests>0) { %>
                        <span class="notification-badge"><%= pendingRequests %></span><% } %>
                    </a>
                </li>
                <li class="nav-item">
                    <a href="vehicleDetails.jsp" class="nav-link">
                        All Vehicles
                    </a>
                </li>
            </ul>
        </div>
        <div>
            <a href="logout" class="logout-btn" style="margin-bottom:28px; display:block;">Logout</a>
        </div>
    </div>
    <!-- Main area -->
    <div class="main-content">
        <div class="header">
            <h2>Admin Dashboard</h2>
            <a href="logout" class="logout-btn">Logout</a>
        </div>
        <% if (message != null) { %>
        <div class="alert <%= messageClass %>">
            <%= message %>
        </div>
        <% } %>
        <div class="cards-container">
            <!-- Service Requests Card -->
            <div class="feature-card">
                <div class="card-header">
                    <h3 class="card-title">Service Requests</h3>
                    <span class="card-badge"><%= pendingRequests %> Pending</span>
                </div>
                <div class="card-content">
                    <p>Manage client service requests and approvals efficiently.</p>
                    <div class="stats-mini">
                        <span>Total: <%= totalRequests %></span><br>
                        <span>Pending: <%= pendingRequests %></span><br>
                        <span>Approved: <%= approvedRequests %></span>
                    </div>
                </div>
                <div class="action-buttons">
                    <a href="serviceRequests.jsp" class="btn btn-primary">Manage Requests</a>
                </div>
            </div>
            <!-- Vehicle Management Card: Tabs UI -->
            <div class="feature-card" style="flex:1;min-width:320px;">
                <div class="card-header">
                    <h3 class="card-title">Vehicle Management</h3>
                </div>
                <div class="card-content">
                    <div class="tab-container">
                        <ul class="tabs">
                            <li class="tab add active" onclick="showTab('add')">Add</li>
                            <li class="tab update" onclick="showTab('update')">Update</li>
                            <li class="tab delete" onclick="showTab('delete')">Delete</li>
                        </ul>
                        <div class="tab-content" id="tab-add">
                            <h4 style="margin-top:0;">Add Vehicle</h4>
                            <form method="post">
                                <input type="hidden" name="action" value="add_vehicle">
                                <div class="form-group">
                                    <label for="add_vehicle_number">Vehicle Number:</label>
                                    <input type="text" id="add_vehicle_number" name="vehicle_number" required
                                        onkeyup="validateVehicleNumber(this)" placeholder="e.g., ABC1234" maxlength="12">
                                </div>
                                <div class="form-group">
                                    <label for="add_model">Model:</label>
                                    <input type="text" id="add_model" name="model" required
                                        placeholder="e.g., Toyota Camry" maxlength="50">
                                </div>
                                <div class="form-group">
                                    <label for="add_warranty_date">Warranty Date:</label>
                                    <input type="date" id="add_warranty_date" name="warranty_date">
                                </div>
                                <div class="form-group">
                                    <label for="add_registration_date">Registration Date:</label>
                                    <input type="date" id="add_registration_date" name="registration_date">
                                </div>
                                <div class="form-group">
                                    <label for="add_service_date">Service Date:</label>
                                    <input type="date" id="add_service_date" name="service_date">
                                </div>
                                <div class="form-group">
                                    <input type="submit" value="Add Vehicle" class="btn btn-primary">
                                </div>
                            </form>
                        </div>
                        <div class="tab-content" id="tab-update" style="display:none;">
                            <h4 style="margin-top:0;">Update Vehicle</h4>
                            <form method="post">
                                <input type="hidden" name="action" value="update_vehicle">
                                <div class="form-group">
                                    <label for="update_vehicle_number">Vehicle Number:</label>
                                    <input type="text" id="update_vehicle_number" name="vehicle_number" required
                                        onkeyup="validateVehicleNumber(this)" placeholder="Existing vehicle number" maxlength="12">
                                </div>
                                <div class="form-group">
                                    <label for="update_model">New Model:</label>
                                    <input type="text" id="update_model" name="model" required
                                        placeholder="Updated model" maxlength="50">
                                </div>
                                <div class="form-group">
                                    <label for="update_warranty_date">Warranty Date:</label>
                                    <input type="date" id="update_warranty_date" name="warranty_date">
                                </div>
                                <div class="form-group">
                                    <label for="update_registration_date">Registration Date:</label>
                                    <input type="date" id="update_registration_date" name="registration_date">
                                </div>
                                <div class="form-group">
                                    <label for="update_service_date">Service Date:</label>
                                    <input type="date" id="update_service_date" name="service_date">
                                </div>
                                <div class="form-group">
                                    <input type="submit" value="Update Vehicle" class="btn btn-primary">
                                </div>
                            </form>
                        </div>
                        <div class="tab-content" id="tab-delete" style="display:none;">
                            <h4 style="margin-top:0;">Delete Vehicle</h4>
                            <form method="post">
                                <input type="hidden" name="action" value="delete_vehicle">
                                <div class="form-group">
                                    <label for="delete_vehicle_number">Vehicle Number:</label>
                                    <input type="text" id="delete_vehicle_number" name="vehicle_number" required
                                        onkeyup="validateVehicleNumber(this)" placeholder="Enter vehicle number to delete" maxlength="12">
                                </div>
                                <div class="form-group">
                                    <input type="submit" value="Delete Vehicle" class="btn btn-primary"
                                        onclick="return confirm('Are you sure you want to delete this vehicle?');">
                                </div>
                            </form>
                        </div>
                    </div>
                    <div style="margin-top:14px;text-align:right;">
                        <a href="vehicleDetails.jsp" class="btn btn-primary">View All Vehicles</a>
                    </div>
                </div>
            </div>
        </div><!-- cards-container -->
    </div><!-- main-content -->
</div>
</body>
</html>
