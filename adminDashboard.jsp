<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         import="java.sql.*, com.example.vehicleportal.util.DBConnection" %>

<%
    // Use the already available implicit session object
    if (session == null || session.getAttribute("adminUser") == null) {
        response.sendRedirect("adminLogin.jsp");
        return;
    }
%>

<html>
<head>
    <title>Admin Dashboard - Vehicle Care</title>
</head>
<body>
    <h2>Welcome Admin</h2>

    <!-- Add New Vehicle -->
    <h3>Add New Vehicle</h3>
    <form action="addVehicle" method="post">
        Vehicle Number: <input type="text" name="vehicle_number" required>
        Model: <input type="text" name="model" required>
        <input type="submit" value="Add">
    </form>

    <!-- Update Vehicle -->
    <h3>Update Vehicle Model</h3>
    <form action="updateVehicle" method="post">
        Vehicle Number: <input type="text" name="vehicle_number" required>
        New Model: <input type="text" name="model" required>
        <input type="submit" value="Update">
    </form>

    <!-- Delete Vehicle -->
    <h3>Delete Vehicle</h3>
    <form action="deleteVehicle" method="post">
        Vehicle Number: <input type="text" name="vehicle_number" required>
        <input type="submit" value="Delete">
    </form>

    <!-- View All Vehicles -->
    <h3>All Registered Vehicles</h3>
    <table border="1">
        <tr>
            <th>Vehicle Number</th>
            <th>Model</th>
        </tr>
        <%
            try (Connection conn = DBConnection.getConnection()) {
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT vehicle_number, model FROM vehicle_client");
                while (rs.next()) {
        %>
        <tr>
            <td><%= rs.getString("vehicle_number") %></td>
            <td><%= rs.getString("model") %></td>
        </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<tr><td colspan='2'>Error: " + e.getMessage() + "</td></tr>");
            }
        %>
    </table>
<a href="dashboard.jsp">Go to Dashboard</a>

   <a href="LogoutServlet">Logout</a>

</body>
</html>
