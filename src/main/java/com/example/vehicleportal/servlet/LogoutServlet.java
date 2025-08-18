package com.example.vehicleportal.servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.*;

public class LogoutServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Prevent caching of this page
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        response.setHeader("Pragma", "no-cache");
        response.setDateHeader("Expires", 0);

        // Get the session
        HttpSession session = request.getSession(false);

        if (session != null) {
            // Clear all session attributes
            session.invalidate();
        }

        // Clear any authentication cookies if you're using them
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if ("JSESSIONID".equals(cookie.getName()) ||
                        "authToken".equals(cookie.getName())) {
                    cookie.setValue("");
                    cookie.setPath("/");
                    cookie.setMaxAge(0);
                    response.addCookie(cookie);
                }
            }
        }

        // Redirect to login page with a logout success message
        response.sendRedirect("login.jsp?logout=success");
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
