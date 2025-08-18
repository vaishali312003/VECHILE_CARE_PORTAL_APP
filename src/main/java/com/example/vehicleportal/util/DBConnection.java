package com.example.vehicleportal.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    public static Connection getConnection() throws Exception {
        // Load PostgreSQL JDBC driver
        Class.forName("org.postgresql.Driver");

        // PostgreSQL connection URL and credentials
        String url = "jdbc:postgresql://dpg-d2h1mrn5r7bs73fk9ef0-a.oregon-postgres.render.com:5432/vehicle_management_ntax";
        String username = "root";
        String password = "Le3SmqhmwlE9OkUWe0DE7MUenE5wyEmu";

        // Return connection
        return DriverManager.getConnection(url, username, password);
    }
}