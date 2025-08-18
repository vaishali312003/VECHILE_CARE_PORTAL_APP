package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class UpdateVehicleServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        PrintWriter out = response.getWriter();

        String number = request.getParameter("vehicle_number");
        String model = request.getParameter("model");
        String warrantyDate = request.getParameter("warranty_date");
        String registrationDate = request.getParameter("registration_date");
        String serviceDate = request.getParameter("service_date");

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                    "UPDATE vehicle_client SET model=?, warranty_date=?, registration_date=?, service_date=? WHERE vehicle_number=?"
            );
            ps.setString(1, model);
            ps.setString(2, warrantyDate);
            ps.setString(3, registrationDate);
            ps.setString(4, serviceDate);
            ps.setString(5, number);
            ps.executeUpdate();

            response.sendRedirect("adminDashboard.jsp?status=updated");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
