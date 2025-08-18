package com.example.vehicleportal.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;

public class AuthenticationFilter implements Filter {

    // Pages that don't require authentication
    private static final List<String> EXCLUDED_PATHS = Arrays.asList(
            "/login.jsp", "/LoginServlet", "/LogoutServlet", "/register.jsp"
    );

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Initialization code if needed
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {

        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpServletResponse httpResponse = (HttpServletResponse) response;

        String requestPath = httpRequest.getRequestURI();
        String contextPath = httpRequest.getContextPath();
        String path = requestPath.substring(contextPath.length());

        // Set cache control headers for all protected pages
        httpResponse.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        httpResponse.setHeader("Pragma", "no-cache");
        httpResponse.setDateHeader("Expires", 0);

        // Check if the path is excluded from authentication
        boolean isExcluded = EXCLUDED_PATHS.stream()
                .anyMatch(excludedPath -> path.startsWith(excludedPath));

        if (isExcluded) {
            chain.doFilter(request, response);
            return;
        }

        // Check if user is authenticated
        HttpSession session = httpRequest.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("user") != null);

        if (isLoggedIn) {
            // User is authenticated, continue with the request
            chain.doFilter(request, response);
        } else {
            // User is not authenticated, redirect to login
            httpResponse.sendRedirect(contextPath + "/login.jsp?error=session_expired");
        }
    }

    @Override
    public void destroy() {
        // Cleanup code if needed
    }
}
