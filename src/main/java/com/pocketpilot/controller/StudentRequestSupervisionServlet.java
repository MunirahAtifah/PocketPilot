package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
@WebServlet("/StudentRequestSupervisionServlet")
public class StudentRequestSupervisionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Handle POST requests - Request supervision access
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Step 1: Get session and validate authentication
        HttpSession session = request.getSession();
        Integer userID = (Integer) session.getAttribute("userID");
        String role = (String) session.getAttribute("role");
        
        // Check if user is authenticated and is a student
        if (userID == null || !"Student".equals(role)) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }
        // Step 2: Get supervision code from parameter
        String supervisionCode = request.getParameter("supervisionCode");
        
        // Validate code is provided
        if (supervisionCode == null || supervisionCode.isEmpty()) {
            response.sendRedirect("supervisionAccess.jsp?error=Please+enter+a+supervision+code");
            return;
        }
        // Step 3: Normalize input (trim and convert to uppercase for case-insensitive comparison)
        supervisionCode = supervisionCode.trim().toUpperCase();
        
        try {
            // Step 4: Get database connection from utility
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            // Step 5: Validate the supervision code exists in Student table
            String validateSql = "SELECT s.studentID, s.supervisionCode FROM student s WHERE UPPER(s.supervisionCode) = ?";
            PreparedStatement validateStmt = conn.prepareStatement(validateSql);
            validateStmt.setString(1, supervisionCode);
            ResultSet validateRs = validateStmt.executeQuery();
            
            // If code not found, reject
            if (!validateRs.next()) {
                validateRs.close();
                validateStmt.close();
                conn.close();
                response.sendRedirect("supervisionAccess.jsp?error=Invalid+supervision+code");
                return;
            }
            
            // Extract target student ID (student to supervise)
            int targetStudentID = validateRs.getInt("studentID");
            validateRs.close();
            validateStmt.close();
            // Step 6: Get current student ID from userID
            String getStudentIdSql = "SELECT studentID FROM student WHERE userID = ?";
            PreparedStatement getStudentStmt = conn.prepareStatement(getStudentIdSql);
            getStudentStmt.setInt(1, userID);
            ResultSet studentRs = getStudentStmt.executeQuery();
            
            // If current student not found, error
            if (!studentRs.next()) {
                studentRs.close();
                getStudentStmt.close();
                conn.close();
                response.sendRedirect("supervisionAccess.jsp?error=Student+profile+not+found");
                return;
            }
            
            // Extract current student ID
            int currentStudentID = studentRs.getInt("studentID");
            studentRs.close();
            getStudentStmt.close();
            // Step 7: Prevent self-supervision (security check)
            if (currentStudentID == targetStudentID) {
                conn.close();
                response.sendRedirect("supervisionAccess.jsp?error=You+cannot+supervise+yourself");
                return;
            }
            // Step 8: Check if supervision link already exists (prevent duplicates)
            String checkExistingSql = "SELECT id FROM supervisionaccess WHERE studentID = ? AND parentID = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkExistingSql);
            checkStmt.setInt(1, currentStudentID);  // Current student is the supervised one
            checkStmt.setInt(2, targetStudentID);   // Target student is the supervisor
            ResultSet checkRs = checkStmt.executeQuery();
            
            // If link exists, reject
            if (checkRs.next()) {
                checkRs.close();
                checkStmt.close();
                conn.close();
                response.sendRedirect("supervisionAccess.jsp?error=Supervision+link+already+exists");
                return;
            }
            
            checkRs.close();
            checkStmt.close();
            // Step 9: Create supervision access record
            String insertSql = "INSERT INTO supervisionaccess (code, studentID, parentID, approvalStatus) VALUES (?, ?, ?, 'Approved')";
            PreparedStatement insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, generateAccessCode(10));  // Generate unique 10-char code
            insertStmt.setInt(2, currentStudentID);           // Student being supervised
            insertStmt.setInt(3, targetStudentID);            // Student as supervisor (parent role)
            int affectedRows = insertStmt.executeUpdate();
            
            // Close resources
            insertStmt.close();
            conn.close();
            // Step 10: Redirect based on success or failure
            if (affectedRows > 0) {
                // Success - redirect with success message
                response.sendRedirect("supervisionAccess.jsp?success=Supervision+access+granted+successfully");
            } else {
                // Failed - redirect with error message
                response.sendRedirect("supervisionAccess.jsp?error=Failed+to+establish+supervision+link");
            }
            
        } catch (Exception e) {
            // Catch all exceptions and log them
            e.printStackTrace();
            response.sendRedirect("supervisionAccess.jsp?error=An+error+occurred+while+processing+your+request");
        }
    }
    
    /**
     * Generate a random access code for supervision relationship
     * 
     * Creates a unique code that can be used to identify supervision access records
     * Uses uppercase letters and digits for easy reading
     * 
     * @param length Length of code to generate (typically 10)
     * @return Generated random code
     */
    private String generateAccessCode(int length) {
        // Characters available for code generation
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder code = new StringBuilder();
        java.util.Random random = new java.util.Random();
        
        // Generate 'length' random characters
        for (int i = 0; i < length; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return code.toString();
    }
}
