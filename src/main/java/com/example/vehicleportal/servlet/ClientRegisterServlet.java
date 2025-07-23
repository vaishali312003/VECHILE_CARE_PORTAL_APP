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
            PreparedStatement ps = conn.prepareStatement("UPDATE vehicle_client SET client_name=?, client_password=? WHERE vehicle_number=?");
            ps.setString(1, clientName);
            ps.setString(2, password);
            ps.setString(3, vehicleNumber);
            int updated = ps.executeUpdate();
            if (updated > 0) {
                response.sendRedirect("login.jsp");
            } else {
                out.println("Vehicle not found or already registered.");
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
