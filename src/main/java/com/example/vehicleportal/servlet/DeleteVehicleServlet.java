package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class DeleteVehicleServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        PrintWriter out = response.getWriter();

        String number = request.getParameter("vehicle_number");

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                    "DELETE FROM vehicle_client WHERE vehicle_number=?");
            ps.setString(1, number);
            ps.executeUpdate();

            response.sendRedirect("adminDashboard.jsp?status=deleted");
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
