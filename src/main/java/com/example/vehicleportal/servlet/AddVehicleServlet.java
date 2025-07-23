package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class AddVehicleServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();
        

        String number = request.getParameter("vehicle_number");
        String model = request.getParameter("model");

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                    "INSERT INTO vehicle_client (vehicle_number, model) VALUES (?, ?)");
            ps.setString(1, number);
            ps.setString(2, model);
            ps.executeUpdate();

            response.sendRedirect("adminDashboard.jsp?status=added");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
