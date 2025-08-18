package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;


public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        String vehicleNumber = request.getParameter("vehicle_number");
        String password = request.getParameter("password");

        // Input validation
        if (vehicleNumber == null || password == null ||
                vehicleNumber.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Vehicle number and password cannot be empty.");
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
            rd.forward(request, response);
            return;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT client_name FROM vehicle_client WHERE vehicle_number=? AND client_password=?")) {

            ps.setString(1, vehicleNumber.trim());
            ps.setString(2, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    // Successful login - create session
                    HttpSession session = request.getSession(true);
                    session.setAttribute("clientName", rs.getString("client_name"));
                    session.setAttribute("vehicleNumber", vehicleNumber.trim());

                    // Redirect to dashboard
                    response.sendRedirect("dashboard.jsp");
                } else {
                    // Invalid credentials
                    request.setAttribute("error", "Invalid vehicle number or password.");
                    RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
                    rd.forward(request, response);
                }
            }

        } catch (Exception e) {
            // Database or server error
            e.printStackTrace(); // Log the error for debugging
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            request.setAttribute("error", "Server error occurred. Please try again.");
            RequestDispatcher rd = request.getRequestDispatcher("login.jsp");
            rd.forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect GET requests to login page
        response.sendRedirect("login.jsp");
    }
}