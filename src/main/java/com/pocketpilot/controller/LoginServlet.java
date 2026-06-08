package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.model.User;
import com.pocketpilot.util.DatabaseConnection;

/**
 * LoginServlet - Handle User Login
 * * Purpose: Process login form submissions and authenticate users
 * * Features:
 * - Validates user credentials against Registration table
 * - Creates session with user information
 * - Redirects based on user role
 * - Handles login failures with error messages
 * * URL Mapping: POST /LoginServlet
 * * Request Parameters:
 * - email: String (user's email address)
 * - password: String (user password)
 * - rememberMe: boolean (optional, for future cookie implementation)
 * * Session Attributes Created:
 * - userID: Integer (user's unique ID)
 * - username: String (user's username)
 * - role: String ('Student', 'Parent', 'IT_Support', 'Student_Counsellor')
 * - email: String (user's email)
 * * Redirect Destinations:
 * - Student → studentDashboard.jsp
 * - Parent → parentDashboard.jsp
 * - IT_Support → staffDashboard.jsp
 * - Student_Counsellor → studentCounsellorDashboard.jsp
 * - Failed → login.jsp?error=Invalid+credentials
 * * @author PocketPilot Development Team
 * @version 1.0
 */
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle GET requests - Show login page
     * Redirect to login.jsp
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Redirect to login page
        response.sendRedirect("login.jsp");
    }

    /**
     * Handle POST requests - Process login
     * * Flow:
     * 1. Get email and password from request
     * 2. Query Registration table for user
     * 3. If user exists and password matches, create session
     * 4. Redirect based on user role
     * 5. If login fails, redirect to login page with error
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        // ================================================
        // Step 1: Get parameters from request
        // ================================================
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        // Trim whitespace
        if (email != null) {
            email = email.trim();
        }
        if (password == null) {
            password = "";
        }

        System.out.println("=== LoginServlet ===");
        System.out.println("Email/Username: " + email);
        System.out.println("Remember Me: " + rememberMe);

        // ================================================
        // Step 2: Validate input
        // ================================================
        if (email == null || email.isEmpty()) {
            redirectWithError(response, "Email is required");
            return;
        }

        if (password.isEmpty()) {
            redirectWithError(response, "Password is required");
            return;
        }

        // ================================================
        // Step 3: Query database for user
        // ================================================
        try {
            User user = authenticateUser(email, password);

            if (user != null) {
                // ================================================
                // Step 4: Create session with user information
                // ================================================
                HttpSession session = request.getSession(true);
                session.setAttribute("userID", user.getUserID());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());
                session.setAttribute("email", user.getEmail());

                System.out.println("Login successful for: " + user.getUsername() + 
                                   " (Role: " + user.getRole() + ")");

                // ================================================
                // Step 5: Redirect based on user role
                // ================================================
                String role = user.getRole();
                String redirectUrl = "";

                if ("Student".equals(role)) {
                    redirectUrl = "studentDashboard.jsp";
                } else if ("Parent".equals(role)) {
                    redirectUrl = "parentDashboard.jsp";
                } else if ("Student_Counsellor".equals(role)) {
                    redirectUrl = "studentCounsellorDashboard.jsp";
                } else {
                    redirectUrl = "login.jsp?error=Unknown+user+role";
                }

                System.out.println("Redirecting to: " + redirectUrl);
                response.sendRedirect(redirectUrl);

            } else {
                // ================================================
                // Step 6: Login failed - invalid credentials
                // ================================================
                System.out.println("Login failed for email: " + email);
                redirectWithError(response, "Invalid credentials");
            }

        } catch (SQLException e) {
            System.err.println("Database error during login: " + e.getMessage());
            e.printStackTrace();
            redirectWithError(response, "An error occurred. Please try again later.");
        }
    }

    /**
     * Authenticate user by checking Registration table
     * * @param email Email address
     * @param password Password to verify
     * @return User object if authenticated, null if not
     * @throws SQLException if database error
     */
    private User authenticateUser(String email, String password) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // CHANGED: Fixed case-sensitivity issue for Linux Docker container (Registration -> registration)
            String sql = "SELECT userID, username, email, role, password FROM registration " +
                        "WHERE email = ? LIMIT 1";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);

            rs = stmt.executeQuery();

            if (rs.next()) {
                // User found - verify password
                String storedPassword = rs.getString("password");

                // TODO: In production, use BCrypt.checkpw(password, storedPassword)
                // For now, we're doing plain text comparison (not secure!)
                if (password.equals(storedPassword)) {
                    // Password matches - return User object
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));

                    return user;
                }
            }

            // User not found or password doesn't match
            return null;

        } finally {
            // Close resources
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Redirect to login page with error message
     * * @param response HttpServletResponse
     * @param errorMessage Error message to display
     * @throws IOException if error
     */
    private void redirectWithError(HttpServletResponse response, String errorMessage) 
            throws IOException {
        String encodedError = errorMessage.replace(" ", "+");
        response.sendRedirect("login.jsp?error=" + encodedError);
    }
}