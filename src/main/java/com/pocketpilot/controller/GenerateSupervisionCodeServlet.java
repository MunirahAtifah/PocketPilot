package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.*;
import java.util.Random;
import javax.servlet.*;
import javax.servlet.http.*;

/**
 * GenerateSupervisionCodeServlet - Generate Supervision Code for Student
 * 
 * Purpose: Allow students to generate a unique code that parents can use to link supervision
 * 
 * Features:
 *   - Generates unique 6-character alphanumeric codes
 *   - Validates user is logged in and is a student
 *   - Checks for existing codes (prevent duplicates)
 *   - Inserts code into SupervisionAccess table
 *   - Provides success/error messages
 * 
 * URL Mapping: POST /GenerateSupervisionCodeServlet
 * 
 * Session Requirements:
 *   - userID: Must be set in session
 *   - role: Must be "Student"
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class GenerateSupervisionCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle POST requests - Generate supervision code
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ================================================
        // Step 1: Check if user is logged in and is a student
        // ================================================
        HttpSession session = request.getSession(false);
        Integer userID = (Integer) (session != null ? session.getAttribute("userID") : null);
        String role = (String) (session != null ? session.getAttribute("role") : null);

        // If user not logged in, deny access
        if (userID == null) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        // If user is not a student, deny access
        if (!"Student".equals(role)) {
            response.sendRedirect("supervisionAccess.jsp?error=Only+students+can+generate+codes");
            return;
        }

        try {
            // ================================================
            // Step 2: Get student ID from the userID
            // ================================================
            int studentID = getStudentID(userID);
            if (studentID <= 0) {
                response.sendRedirect("supervisionAccess.jsp?error=Student+profile+not+found");
                return;
            }

            // ================================================
            // Step 3: Check if student already has a code
            // ================================================
            String existingCode = getExistingCode(studentID);
            if (existingCode != null && !existingCode.isEmpty()) {
                // Student already has a code - inform them
                response.sendRedirect("supervisionAccess.jsp?success=Code+already+exists");
                return;
            }

            // ================================================
            // Step 4: Generate unique 6-character alphanumeric code
            // ================================================
            String generatedCode = generateUniqueCode();

            // ================================================
            // Step 5: Insert code into SupervisionAccess table
            // ================================================
            if (insertSupervisionCode(generatedCode, studentID)) {
                // Success - redirect with success message
                response.sendRedirect("supervisionAccess.jsp?success=Code+created+successfully");
            } else {
                // Failed - redirect with error message
                response.sendRedirect("supervisionAccess.jsp?error=Failed+to+generate+code");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("supervisionAccess.jsp?error=An+error+occurred");
        }
    }

    /**
     * Get Student ID from User ID
     * 
     * Queries Student table to find studentID for the logged-in user
     * 
     * @param userID User ID from session
     * @return studentID if found, -1 if not found
     * @throws SQLException if database error
     */
    private int getStudentID(int userID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to get studentID from userID
            String sql = "SELECT studentID FROM Student WHERE userID = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userID);
            ResultSet rs = pstmt.executeQuery();

            int studentID = -1;
            // If student found, extract studentID
            if (rs.next()) {
                studentID = rs.getInt("studentID");
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return studentID;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Get existing supervision code for student
     * 
     * Checks if student already has a supervision code in SupervisionAccess table
     * 
     * @param studentID Student ID
     * @return Code string if exists, null if not
     * @throws SQLException if database error
     */
    private String getExistingCode(int studentID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to get existing code for student
            String sql = "SELECT code FROM SupervisionAccess WHERE studentID = ? LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();

            String code = null;
            // If code found, extract it
            if (rs.next()) {
                code = rs.getString("code");
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return code;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Generate unique 6-character alphanumeric code
     * 
     * Creates a random code using uppercase letters and digits
     * Example: ABC123, XYZ789, etc.
     * 
     * @return Generated 6-character code
     */
    private String generateUniqueCode() {
        // Characters available for code generation (no confusing letters like O, I, 1)
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder code = new StringBuilder();
        Random random = new Random();

        // Generate 6 random characters
        for (int i = 0; i < 6; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }

        return code.toString();
    }

    /**
     * Insert supervision code into database
     * 
     * Inserts new row into SupervisionAccess table with generated code
     * 
     * @param code Generated supervision code
     * @param studentID Student ID who owns the code
     * @return true if successful, false otherwise
     * @throws SQLException if database error
     */
    private boolean insertSupervisionCode(String code, int studentID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to insert new supervision access record
            // Default status is 'Approved' for self-generated codes
            String sql = "INSERT INTO SupervisionAccess (code, studentID, approvalStatus) VALUES (?, ?, 'Approved')";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, code);
            pstmt.setInt(2, studentID);

            // Execute insert and check if successful
            int result = pstmt.executeUpdate();
            pstmt.close();
            conn.close();

            return result > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
}
