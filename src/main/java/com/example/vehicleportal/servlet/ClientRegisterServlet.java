package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class ClientRegisterServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String clientName = request.getParameter("name");
        String vehicleNumber = request.getParameter("vehicle_number");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {
            // Check if the vehicle exists and not already registered
            PreparedStatement checkStmt = conn.prepareStatement("SELECT client_name FROM vehicle_client WHERE vehicle_number = ?");
            checkStmt.setString(1, vehicleNumber);
            ResultSet rs = checkStmt.executeQuery();

            if (rs.next()) {
                String existingName = rs.getString("client_name");
                if (existingName != null && !existingName.trim().isEmpty()) {
                    out.println("<script>alert('This vehicle is already registered.'); window.location='register.jsp';</script>");
                } else {
                    PreparedStatement ps = conn.prepareStatement(
                            "UPDATE vehicle_client SET client_name=?, client_password=? WHERE vehicle_number=?"
                    );
                    ps.setString(1, clientName);
                    ps.setString(2, password);
                    ps.setString(3, vehicleNumber);
                    int updated = ps.executeUpdate();

                    if (updated > 0) {
                        response.sendRedirect("login.jsp");
                    } else {
                        out.println("<script>alert('Registration failed. Try again.'); window.location='register.jsp';</script>");
                    }
                }
            } else {
                out.println("<script>alert('Vehicle not found. Please contact support.'); window.location='register.jsp';</script>");
            }

        } catch (Exception e) {
            out.println("<script>alert('Error: " + e.getMessage().replace("'", "") + "'); window.location='register.jsp';</script>");
        }
    }
}
