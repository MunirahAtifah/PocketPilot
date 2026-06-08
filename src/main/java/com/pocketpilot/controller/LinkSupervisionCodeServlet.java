package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

/**
 * LinkSupervisionCodeServlet - Link Parent to Student via Supervision Code
 * 
 * Purpose: Allow parents to link themselves to a student account using a code
 * 
 * Features:
 *   - Validates parent login
 *   - Accepts supervision code and relationship from parent
 *   - Validates code exists and student can be found
 *   - Prevents duplicate links
 *   - Updates SupervisionAccess table with parentID and relationship
 *   - Provides success/error messages
 * 
 * URL Mapping: POST /LinkSupervisionCodeServlet
 * 
 * Request Parameters:
 *   - supervisionCode: String (code provided by student, converted to uppercase)
 *   - relationship: String (e.g., "Father", "Mother", "Guardian")
 * 
 * Session Requirements:
 *   - userID: Must be set in session
 *   - role: Must be "Parent"
 *   - username: Used for logging
 * 
 * Flow:
 *   1. Validate parent is logged in
 *   2. Get parent profile from Parent table
 *   3. Validate supervision code exists
 *   4. Get student ID associated with code
 *   5. Check if link doesn't already exist
 *   6. Update SupervisionAccess with parent info and relationship
 *   7. Redirect with success or error message
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class LinkSupervisionCodeServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle POST requests - Link parent to student via code
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ================================================
        // Step 1: Check if user is logged in and is a parent
        // ================================================
        HttpSession session = request.getSession(false);
        Integer userID = (Integer) (session != null ? session.getAttribute("userID") : null);
        String role = (String) (session != null ? session.getAttribute("role") : null);
        String username = (String) (session != null ? session.getAttribute("username") : null);

        // If user not logged in, deny access
        if (userID == null) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        // If user is not a parent, deny access
        if (!"Parent".equals(role)) {
            response.sendRedirect("parentDashboard.jsp?error=Only+parents+can+link+supervision+codes");
            return;
        }

        try {
            // ================================================
            // Step 2: Get parameters from request
            // ================================================
            String supervisionCode = request.getParameter("supervisionCode");
            String relationship = request.getParameter("relationship");
            
            System.out.println("[LinkSupervisionCodeServlet] Code: " + supervisionCode + ", Relationship: " + relationship);
            
            // ================================================
            // Step 3: Validate supervision code is provided
            // ================================================
            if (supervisionCode == null || supervisionCode.trim().isEmpty()) {
                response.sendRedirect("parentSupervisionAccess.jsp?error=Please+enter+a+supervision+code");
                return;
            }
            
            // ================================================
            // Step 4: Validate relationship is provided
            // ================================================
            if (relationship == null || relationship.trim().isEmpty()) {
                response.sendRedirect("parentSupervisionAccess.jsp?error=Please+select+your+relationship");
                return;
            }

            // ================================================
            // Step 5: Normalize input (trim and convert to uppercase)
            // ================================================
            supervisionCode = supervisionCode.trim().toUpperCase();
            relationship = relationship.trim();
            
            System.out.println("[LinkSupervisionCodeServlet] Processed Code: " + supervisionCode + ", Relationship: " + relationship);

            // ================================================
            // Step 6: Get parent ID from userID
            // ================================================
            int parentID = getParentID(userID);
            System.out.println("[LinkSupervisionCodeServlet] Parent ID: " + parentID);
            if (parentID <= 0) {
                response.sendRedirect("parentSupervisionAccess.jsp?error=Parent+profile+not+found");
                return;
            }

            // ================================================
            // Step 7: Validate code exists and get student ID
            // ================================================
            int studentID = getStudentIDByCode(supervisionCode);
            System.out.println("[LinkSupervisionCodeServlet] Student ID: " + studentID);
            if (studentID <= 0) {
                response.sendRedirect("parentSupervisionAccess.jsp?error=Invalid+supervision+code");
                return;
            }

            // ================================================
            // Step 8: Check if parent-student link already exists
            // ================================================
            if (alreadyLinked(studentID, parentID)) {
                response.sendRedirect("parentSupervisionAccess.jsp?error=You+are+already+linked+to+this+child");
                return;
            }

            // ================================================
            // Step 9: Get student username for display in success message
            // ================================================
            String studentUsername = getStudentUsername(studentID);

            // ================================================
            // Step 10: Update SupervisionAccess with parentID and relationship
            // ================================================
            System.out.println("[LinkSupervisionCodeServlet] Updating with Code: " + supervisionCode + ", ParentID: " + parentID + ", Relationship: " + relationship);
            if (updateSupervisionLink(supervisionCode, parentID, relationship)) {
                // Success - redirect to parent supervision page with success message
                response.sendRedirect("parentSupervisionAccess.jsp?success=Successfully+linked+to+" + studentUsername);
            } else {
                // Failed - redirect with error message
                response.sendRedirect("parentSupervisionAccess.jsp?error=Failed+to+link+account");
            }

        } catch (Exception e) {
            // Catch all other exceptions and log them
            e.printStackTrace();
            response.sendRedirect("parentSupervisionAccess.jsp?error=An+error+occurred");
        }
    }

    /**
     * Get Parent ID from User ID
     * 
     * Queries Parent table to find parentID for logged-in parent
     * 
     * @param userID User ID from session
     * @return parentID if found, -1 if not found
     * @throws SQLException if database error
     */
    private int getParentID(int userID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to get parentID from userID
            String sql = "SELECT parentID FROM Parent WHERE userID = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userID);
            ResultSet rs = pstmt.executeQuery();

            int parentID = -1;
            // If parent found, extract parentID
            if (rs.next()) {
                parentID = rs.getInt("parentID");
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return parentID;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Get Student ID by supervision code
     * 
     * Looks up student in SupervisionAccess table using the code provided by parent
     * 
     * @param code Supervision code from student
     * @return studentID if found, -1 if not found
     * @throws SQLException if database error
     */
    private int getStudentIDByCode(String code) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to get studentID from code in SupervisionAccess table
            String sql = "SELECT studentID FROM SupervisionAccess WHERE code = ? LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, code);
            ResultSet rs = pstmt.executeQuery();

            int studentID = -1;
            // If code found, extract studentID
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
     * Check if parent is already linked to student
     * 
     * Prevents duplicate supervision links between same parent-student pair
     * 
     * @param studentID Student ID
     * @param parentID Parent ID
     * @return true if already linked, false if not
     * @throws SQLException if database error
     */
    private boolean alreadyLinked(int studentID, int parentID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to check if link exists
            String sql = "SELECT COUNT(*) FROM SupervisionAccess WHERE studentID = ? AND parentID = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, parentID);
            ResultSet rs = pstmt.executeQuery();

            boolean linked = false;
            // If count > 0, link already exists
            if (rs.next()) {
                linked = rs.getInt(1) > 0;
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return linked;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Get student username by student ID
     * 
     * Used to display student name in success message
     * Joins Student table with Registration table to get username
     * 
     * @param studentID Student ID
     * @return Student's username if found, empty string if not found
     * @throws SQLException if database error
     */
    private String getStudentUsername(int studentID) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to get username by joining Student and Registration tables
            String sql = "SELECT r.username FROM Registration r " +
                        "JOIN Student s ON r.userID = s.userID " +
                        "WHERE s.studentID = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();

            String username = "";
            // If student found, extract username
            if (rs.next()) {
                username = rs.getString("username");
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return username;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Update SupervisionAccess with parentID and relationship
     * 
     * Updates the SupervisionAccess record to complete the parent-student link
     * Sets approvalStatus to 'Approved' and stores the relationship (Father, Mother, etc.)
     * 
     * @param code Supervision code
     * @param parentID Parent ID to link
     * @param relationship Relationship description (e.g., "Father", "Mother")
     * @return true if successful, false otherwise
     * @throws SQLException if database error
     */
    private boolean updateSupervisionLink(String code, int parentID, String relationship) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to update SupervisionAccess record
            // Set parentID, mark as Approved, and store relationship
            String sql = "UPDATE SupervisionAccess SET parentID = ?, approvalStatus = 'Approved', relationship = ? WHERE code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, parentID);
            pstmt.setString(2, relationship);
            pstmt.setString(3, code);

            // Execute update and check if successful
            int result = pstmt.executeUpdate();
            pstmt.close();
            conn.close();

            return result > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
}
