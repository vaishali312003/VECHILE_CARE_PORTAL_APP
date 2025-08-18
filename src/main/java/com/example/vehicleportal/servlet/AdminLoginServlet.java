package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AdminLoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Basic input validation
        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Username and password cannot be empty.");
            RequestDispatcher rd = request.getRequestDispatcher("adminLogin.jsp");
            rd.forward(request, response);
            return;
        }

        // Authenticate user
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT username FROM admin WHERE username = ? AND password = ?")) {

            ps.setString(1, username.trim());
            ps.setString(2, password); // Note: Ideally passwords should be hashed!

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Successful login: create session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("admin", username.trim());
                    session.setAttribute("adminName", rs.getString("username"));
                    session.setMaxInactiveInterval(30 * 60);  // Session expires in 30 minutes

                    response.sendRedirect("adminDashboard.jsp");
                } else {
                    // Invalid credentials
                    response.sendRedirect("adminLogin.jsp?error=invalid");
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Server error occurred. Please try again.");
            RequestDispatcher rd = request.getRequestDispatcher("adminLogin.jsp");
            rd.forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to login page on GET requests
        response.sendRedirect("adminLogin.jsp");
    }
}
