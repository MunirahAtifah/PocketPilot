package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;

/**
 * RevokeSupervisionAccessServlet - Revoke Supervision Links
 * 
 * Purpose: Allow students and parents to revoke supervision relationships
 * 
 * Features:
 *   - Students can revoke parent access to their account
 *   - Parents can revoke student supervision links  
 *   - Verifies authorization (security check)
 *   - Deletes supervision access record
 *   - Provides appropriate redirects for each role
 * 
 * URL Mapping: POST /RevokeSupervisionAccessServlet
 * 
 * Request Parameters:
 *   - accessId: String (supervision code to revoke)
 * 
 * Session Requirements:
 *   - userID: Must be set in session
 *   - role: Must be "Student" or "Parent"
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class RevokeSupervisionAccessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle POST requests - Revoke supervision access
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // ================================================
        // Step 1: Check if user is logged in
        // ================================================
        HttpSession session = request.getSession(false);
        Integer userID = (Integer) (session != null ? session.getAttribute("userID") : null);
        String role = (String) (session != null ? session.getAttribute("role") : null);

        if (userID == null) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        try {
            // ================================================
            // Step 2: Get supervision code from parameter
            // ================================================
            String supervisionCode = request.getParameter("accessId");
            if (supervisionCode == null || supervisionCode.trim().isEmpty()) {
                // Redirect to appropriate page based on role
                if ("Student".equals(role)) {
                    response.sendRedirect("supervisionAccess.jsp?error=Invalid+request");
                } else {
                    response.sendRedirect("parentSupervisionLink.jsp?error=Invalid+request");
                }
                return;
            }

            supervisionCode = supervisionCode.trim();

            // ================================================
            // Step 3: Handle based on user role
            // ================================================
            if ("Student".equals(role)) {
                // ================================================
                // STUDENT REVOCATION: Student revoking parent access
                // ================================================
                
                // Verify student owns this supervision link
                if (!isStudentAuthorized(userID, supervisionCode)) {
                    response.sendRedirect("supervisionAccess.jsp?error=You+are+not+authorized+to+revoke+this+link");
                    return;
                }
                
                // Revoke the supervision access
                if (revokeSupervisionByCode(supervisionCode)) {
                    response.sendRedirect("supervisionAccess.jsp?success=Supervision+access+revoked+successfully");
                } else {
                    response.sendRedirect("supervisionAccess.jsp?error=Failed+to+revoke+supervision+access");
                }
                
            } else if ("Parent".equals(role)) {
                // ================================================
                // PARENT REVOCATION: Parent unlink from student
                // ================================================
                
                // Verify parent owns this supervision link
                if (!isParentAuthorized(userID, supervisionCode)) {
                    response.sendRedirect("parentSupervisionLink.jsp?error=You+are+not+authorized+to+revoke+this+link");
                    return;
                }
                
                // Revoke the supervision access
                if (revokeSupervisionByCode(supervisionCode)) {
                    response.sendRedirect("parentSupervisionLink.jsp?success=Student+account+unlinked+successfully");
                } else {
                    response.sendRedirect("parentSupervisionLink.jsp?error=Failed+to+unlink+student+account");
                }
                
            } else {
                // User is neither student nor parent
                response.sendRedirect("dashboard.jsp?error=Only+students+and+parents+can+revoke+supervision");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            // Redirect to appropriate page based on role
            if ("Student".equals(role)) {
                response.sendRedirect("supervisionAccess.jsp?error=An+error+occurred");
            } else {
                response.sendRedirect("parentSupervisionLink.jsp?error=An+error+occurred");
            }
        }
    }

    /**
     * Check if student owns the supervision link
     * 
     * Verifies that the supervision code belongs to this student
     * This prevents students from revoking other students' supervision links
     * 
     * @param userID User ID of student
     * @param code Supervision code
     * @return true if student owns this link, false otherwise
     * @throws SQLException if database error
     */
    private boolean isStudentAuthorized(int userID, String code) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to check if student owns this supervision link
            // Joins SupervisionAccess with Student table using studentID
            String sql = "SELECT COUNT(*) FROM SupervisionAccess sa " +
                        "JOIN Student s ON sa.studentID = s.studentID " +
                        "WHERE s.userID = ? AND sa.code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userID);
            pstmt.setString(2, code);
            ResultSet rs = pstmt.executeQuery();

            boolean authorized = false;
            // If count > 0, student owns this link
            if (rs.next()) {
                authorized = rs.getInt(1) > 0;
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return authorized;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Check if parent owns the supervision link
     * 
     * Verifies that the supervision code belongs to this parent
     * This prevents parents from revoking other parents' supervision links
     * 
     * @param userID User ID of parent
     * @param code Supervision code
     * @return true if parent owns this link, false otherwise
     * @throws SQLException if database error
     */
    private boolean isParentAuthorized(int userID, String code) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to check if parent owns this supervision link
            // Joins SupervisionAccess with Parent table using parentID
            String sql = "SELECT COUNT(*) FROM SupervisionAccess sa " +
                        "JOIN Parent p ON sa.parentID = p.parentID " +
                        "WHERE p.userID = ? AND sa.code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userID);
            pstmt.setString(2, code);
            ResultSet rs = pstmt.executeQuery();

            boolean authorized = false;
            // If count > 0, parent owns this link
            if (rs.next()) {
                authorized = rs.getInt(1) > 0;
            }

            // Close all resources
            rs.close();
            pstmt.close();
            conn.close();

            return authorized;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    /**
     * Revoke supervision access by code
     * 
     * Deletes the SupervisionAccess record, effectively removing the link
     * 
     * @param code Supervision code to revoke
     * @return true if successful, false otherwise
     * @throws SQLException if database error
     */
    private boolean revokeSupervisionByCode(String code) throws SQLException {
        try {
            // Load MySQL JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Create database connection
            Connection conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/PP", "root", "");
            
            // SQL query to delete supervision access record
            String sql = "DELETE FROM SupervisionAccess WHERE code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, code);

            // Execute delete and get number of affected rows
            int result = pstmt.executeUpdate();
            pstmt.close();
            conn.close();

            // Return true if at least one row was deleted
            return result > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
}

