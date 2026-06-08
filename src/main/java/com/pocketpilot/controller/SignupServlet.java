package com.pocketpilot.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.FileWriter;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pocketpilot.dao.StudentCounsellorDAO;
import com.pocketpilot.util.DatabaseConnection;

/**
 * SignupServlet - Handle User Registration
 * 
 * Purpose: Process signup form submissions and create new user accounts
 * 
 * Features:
 *   - Validates user input (username, email, phone, role, password)
 *   - Checks for duplicate email and username
 *   - Inserts user into Registration table
 *   - Creates corresponding Student, Parent, or IT_Support record
 *   - Provides appropriate success/error messages
 * 
 * URL Mapping: POST /SignupServlet
 * 
 * Request Parameters:
 *   - username: String (3-50 chars, alphanumeric with . - _)
 *   - email: String (valid email address)
 *   - phoneNumber: String (10-11 digits)
 *   - role: String ('Student', 'Parent', 'IT_Support', 'Student_Counsellor')
 *   - password: String (6+ characters)
 * 
 * Response Messages:
 *   - Success: "Account created. Please log in."
 *   - Email exists: "Account already exists"
 *   - Username exists: "Username already taken. Please choose a different one."
 *   - Validation error: Appropriate error message
 *   - DB error: "An error occurred. Please try again later."
 * 
 * Database Operations:
 *   1. Check if email exists in Registration table
 *   2. Check if username exists in Registration table
 *   3. Insert into Registration table
 *   4. Get generated userID
 *   5. Insert into Student, Parent, or IT_Support table based on role
 *   6. Redirect to login page with success message
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class SignupServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Log message to both console and file
     */
    private void logDebug(String message) {
        System.out.println("[SignupServlet] " + message);
        try {
            String logFile = "C:\\xampp2\\tomcat\\logs\\signup_debug.log";
            FileWriter fw = new FileWriter(logFile, true);
            fw.write("[" + new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()) + "] " + message + "\n");
            fw.close();
        } catch (IOException e) {
            System.err.println("Failed to write to log file: " + e.getMessage());
        }
    }

    /**
     * Handle POST requests - Process signup
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        // ================================================
        // Step 1: Get parameters from request
        // ================================================
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String role = request.getParameter("role");
        String password = request.getParameter("password");

        // Trim whitespace
        if (username != null) username = username.trim();
        if (email != null) email = email.trim();
        if (phoneNumber != null) phoneNumber = phoneNumber.trim();
        if (role != null) role = role.trim();
        if (password == null) password = "";

        logDebug("=== SignupServlet ===");
        logDebug("Username: " + username);
        logDebug("Email: " + email);
        logDebug("Phone: " + phoneNumber);
        logDebug("Role: " + role);

        // ================================================
        // Step 2: Validate input data
        // ================================================
        String validationError = validateInput(username, email, phoneNumber, role, password);
        if (validationError != null) {
            logDebug("Validation error: " + validationError);
            redirectWithError(response, validationError);
            return;
        }

        // ================================================
        // Step 3: Check for duplicate email and username
        // ================================================
        try {
            // Check if email already exists
            if (emailExists(email)) {
                logDebug("Email already exists: " + email);
                redirectWithError(response, "Account already exists");
                return;
            }

            // Check if username already exists
            if (usernameExists(username)) {
                logDebug("Username already exists: " + username);
                redirectWithError(response, "Username already taken. Please choose a different one.");
                return;
            }

        } catch (SQLException e) {
            logDebug("Database error checking duplicates: " + e.getMessage());
            e.printStackTrace();
            redirectWithError(response, "An error occurred. Please try again later.");
            return;
        }

        // ================================================
        // Step 4: Register user in database
        // ================================================
        try {
            int userID = registerUser(username, email, phoneNumber, role, password);

            if (userID > 0) {
        // ================================================
        // ================================================
        // Step 5: Create Student, Parent, or IT_Support profile
        // ================================================
                boolean profileCreated = false;

                if ("Student".equals(role)) {
                    profileCreated = createStudentProfile(userID, username);
                    
                    // Auto-enroll student with all counsellors
                    if (profileCreated) {
                        try {
                            int studentID = getStudentIDByUserID(userID);
                            if (studentID > 0) {
                                StudentCounsellorDAO.autoEnrollStudentWithCounsellors(studentID);
                                logDebug("Auto-enrolled student " + studentID + " with all counsellors");
                            }
                        } catch (SQLException e) {
                            logDebug("Failed to auto-enroll student: " + e.getMessage());
                            // Don't fail signup if auto-enrollment fails
                        }
                    }
                } else if ("Parent".equals(role)) {
                    profileCreated = createParentProfile(userID, username);
                } else if ("Student_Counsellor".equals(role)) {
                    profileCreated = createStudentCounsellorProfile(userID, username);
                }

                if (profileCreated) {
                    logDebug("Signup successful for user: " + username + " (ID: " + userID + ", Role: " + role + ")");
                    redirectWithSuccess(response, "Account created. Please log in.");
                } else {
                    logDebug("Failed to create profile for user: " + username);
                    // Delete the user we just created since profile creation failed
                    deleteUser(userID);
                    redirectWithError(response, "An error occurred during profile creation. Please try again.");
                }
            } else {
                logDebug("Failed to register user: " + username);
                redirectWithError(response, "An error occurred. Please try again later.");
            }

        } catch (SQLException e) {
            logDebug("Registration error: " + e.getMessage());
            e.printStackTrace();
            redirectWithError(response, "An error occurred. Please try again later.");
        }
    }

    /**
     * Validate user input
     * 
     * @param username Username
     * @param email Email address
     * @param phoneNumber Phone number
     * @param role User role
     * @param password Password
     * @return Error message if invalid, null if valid
     */
    private String validateInput(String username, String email, String phoneNumber, String role, String password) {
        // Check for null/empty values
        if (username == null || username.isEmpty()) {
            return "Username is required";
        }
        if (email == null || email.isEmpty()) {
            return "Email is required";
        }
        if (phoneNumber == null || phoneNumber.isEmpty()) {
            return "Phone number is required";
        }
        if (role == null || role.isEmpty()) {
            return "Role is required";
        }
        if (password == null || password.isEmpty()) {
            return "Password is required";
        }

        // Username validation (3-50 chars, alphanumeric with . - _)
        if (username.length() < 3 || username.length() > 50) {
            return "Username must be 3-50 characters";
        }
        if (!username.matches("^[a-zA-Z0-9_.-]+$")) {
            return "Username can only contain letters, numbers, dots, dashes, and underscores";
        }

        // Email validation
        if (!email.matches("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")) {
            return "Invalid email format";
        }
        if (email.length() > 100) {
            return "Email is too long";
        }

        // Phone validation (10-11 digits)
        if (!phoneNumber.matches("^[0-9]{10,11}$")) {
            return "Phone number must be 10-11 digits";
        }

        // Role validation
        if (!role.equals("Student") && !role.equals("Parent") && !role.equals("IT_Support") && !role.equals("Student_Counsellor")) {
            return "Invalid role selected";
        }

        // Password validation (6+ chars)
        if (password.length() < 6 || password.length() > 50) {
            return "Password must be 6-50 characters";
        }

        return null; // All valid
    }

    /**
     * Check if email already exists in database
     */
    private boolean emailExists(String email) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM Registration WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Check if username already exists in database
     */
    private boolean usernameExists(String username) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM Registration WHERE username = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Register user in Registration table
     */
    private int registerUser(String username, String email, String phoneNumber, String role, String password)
            throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "INSERT INTO Registration (username, email, phone_number, role, password) " +
                        "VALUES (?, ?, ?, ?, ?)";

            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, username);
            stmt.setString(2, email);
            stmt.setString(3, phoneNumber);
            stmt.setString(4, role);
            stmt.setString(5, password); // TODO: Hash password with BCrypt

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

            return -1;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Create Student profile
     */
    private boolean createStudentProfile(int userID, String studentName) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "INSERT INTO Student (userID, studentName) VALUES (?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            stmt.setString(2, studentName);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Create Parent profile
     */
    private boolean createParentProfile(int userID, String parentName) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "INSERT INTO Parent (userID, parentName) VALUES (?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            stmt.setString(2, parentName);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Create IT_Support profile
     * Note: IT_Support users don't need a separate table entry,
     * they are identified by role in Registration table
     */
    private boolean createITSupportProfile(int userID) throws SQLException {
        // For IT_Support, we don't need to create a separate profile
        // They are identified by the 'IT_Support' role in Registration table
        // So we return true to indicate success
        return true;
    }

    /**
     * Create Student Counsellor profile
     */
    private boolean createStudentCounsellorProfile(int userID, String counsellorName) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "INSERT INTO Student_Counsellor (userID, staffName) VALUES (?, ?)";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            stmt.setString(2, counsellorName);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Delete user (used if profile creation fails)
     */
    private void deleteUser(int userID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "DELETE FROM Registration WHERE userID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);

            stmt.executeUpdate();
            System.out.println("User " + userID + " deleted due to profile creation failure");

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Get studentID by userID
     */
    private int getStudentIDByUserID(int userID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT studentID FROM Student WHERE userID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("studentID");
            }

            return -1;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Redirect to login page with error message
     */
    private void redirectWithError(HttpServletResponse response, String errorMessage) throws IOException {
        String encodedError = URLEncoder.encode(errorMessage, StandardCharsets.UTF_8);
        response.sendRedirect("signup.jsp?error=" + encodedError);
    }

    /**
     * Redirect to login page with success message
     */
    private void redirectWithSuccess(HttpServletResponse response, String successMessage) throws IOException {
        String encodedMessage = URLEncoder.encode(successMessage, StandardCharsets.UTF_8);
        response.sendRedirect("login.jsp?success=" + encodedMessage);
    }
}
