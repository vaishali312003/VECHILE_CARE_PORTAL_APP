package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;
import java.sql.*;

public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        PrintWriter out = response.getWriter();

        String vehicleNumber = request.getParameter("vehicle_number");
        String password = request.getParameter("password");

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement("SELECT * FROM vehicle_client WHERE vehicle_number=? AND client_password=?");
            ps.setString(1, vehicleNumber);
            ps.setString(2, password);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                HttpSession session = request.getSession();
                session.setAttribute("clientName", rs.getString("client_name"));
                session.setAttribute("vehicleNumber", vehicleNumber);
                response.sendRedirect("adminDashboard.jsp");
            } else {
                out.println("Invalid login credentials.");
            }
        } catch (Exception e) {
            out.println("Error: " + e.getMessage());
        }
    }
}
