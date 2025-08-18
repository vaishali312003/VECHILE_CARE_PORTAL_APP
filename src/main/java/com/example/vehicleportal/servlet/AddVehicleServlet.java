package com.example.vehicleportal.servlet;

import com.example.vehicleportal.util.DBConnection;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.Date;
import java.text.SimpleDateFormat;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AddVehicleServlet")
public class AddVehicleServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public AddVehicleServlet() {
        super();
    }

    /**
     * Helper method to convert string date to SQL Date
     * @param dateString - Date string in yyyy-MM-dd format
     * @return SQL Date object or null if invalid/empty
     */
    private Date convertStringToSqlDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            return null;
        }
        try {
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            sdf.setLenient(false); // Strict date parsing
            java.util.Date utilDate = sdf.parse(dateString.trim());
            return new Date(utilDate.getTime());
        } catch (Exception e) {
            System.err.println("Date conversion error for: " + dateString + " - " + e.getMessage());
            return null;
        }
    }

    /**
     * Handles GET requests - redirects to admin dashboard
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.sendRedirect("adminDashboard.jsp");
    }

    /**
     * Handles POST requests for adding vehicles
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        // Get form parameters
        String number = request.getParameter("vehicle_number");
        String model = request.getParameter("model");
        String warrantyDateStr = request.getParameter("warranty_date");
        String registrationDateStr = request.getParameter("registration_date");
        String serviceDateStr = request.getParameter("service_date");

        // Validate required fields
        if (number == null || number.trim().isEmpty()) {
            response.sendRedirect("adminDashboard.jsp?status=error&message=Vehicle number is required");
            return;
        }

        if (model == null || model.trim().isEmpty()) {
            response.sendRedirect("adminDashboard.jsp?status=error&message=Vehicle model is required");
            return;
        }

        // Clean and format vehicle number
        number = number.trim().toUpperCase();
        model = model.trim();

        // Convert string dates to SQL dates
        Date warrantyDate = convertStringToSqlDate(warrantyDateStr);
        Date registrationDate = convertStringToSqlDate(registrationDateStr);
        Date serviceDate = convertStringToSqlDate(serviceDateStr);

        Connection conn = null;
        PreparedStatement ps = null;

        try {
            // Get database connection
            conn = DBConnection.getConnection();

            if (conn == null) {
                throw new Exception("Unable to establish database connection");
            }

            // Prepare SQL statement
            String sql = "INSERT INTO vehicle_client (vehicle_number, model, warranty_date, registration_date, service_date) VALUES (?, ?, ?, ?, ?)";
            ps = conn.prepareStatement(sql);

            // Set parameters
            ps.setString(1, number);
            ps.setString(2, model);
            ps.setDate(3, warrantyDate);        // Using setDate for proper DATE type handling
            ps.setDate(4, registrationDate);    // Using setDate for proper DATE type handling
            ps.setDate(5, serviceDate);         // Using setDate for proper DATE type handling

            // Execute the update
            int result = ps.executeUpdate();

            if (result > 0) {
                // Success - redirect with success message
                String successMessage = "Vehicle '" + number + "' added successfully!";
                response.sendRedirect("adminDashboard.jsp?status=added&message=" + java.net.URLEncoder.encode(successMessage, "UTF-8"));
            } else {
                // No rows affected - this shouldn't happen normally
                response.sendRedirect("adminDashboard.jsp?status=error&message=Failed to add vehicle - no rows affected");
            }

        } catch (java.sql.SQLIntegrityConstraintViolationException e) {
            // Handle duplicate vehicle number
            System.err.println("Duplicate vehicle number error: " + e.getMessage());
            String errorMessage = "Vehicle number '" + number + "' already exists. Please use a different vehicle number.";
            response.sendRedirect("adminDashboard.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));

        } catch (java.sql.SQLException e) {
            // Handle other SQL errors
            System.err.println("SQL error in AddVehicleServlet: " + e.getMessage());
            e.printStackTrace();
            String errorMessage = "Database error: " + e.getMessage();
            response.sendRedirect("adminDashboard.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));

        } catch (Exception e) {
            // Handle any other errors
            System.err.println("General error in AddVehicleServlet: " + e.getMessage());
            e.printStackTrace();
            String errorMessage = "Error adding vehicle: " + e.getMessage();
            response.sendRedirect("adminDashboard.jsp?status=error&message=" + java.net.URLEncoder.encode(errorMessage, "UTF-8"));

        } finally {
            // Clean up resources in reverse order
            try {
                if (ps != null) {
                    ps.close();
                }
            } catch (Exception e) {
                System.err.println("Error closing PreparedStatement: " + e.getMessage());
            }

            try {
                if (conn != null) {
                    conn.close();
                }
            } catch (Exception e) {
                System.err.println("Error closing Connection: " + e.getMessage());
            }
        }
    }
}