package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
@WebServlet("/RemoveSupervisionServlet")
public class RemoveSupervisionServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Handle POST requests - Remove supervision link
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Step 1: Check if user is logged in
        HttpSession session = request.getSession(false);
        Integer userID = (Integer) (session != null ? session.getAttribute("userID") : null);
        String role = (String) (session != null ? session.getAttribute("role") : null);

        if (userID == null) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        try {
            // Step 2: Get accessId (supervision code) from parameter
            String accessId = request.getParameter("accessId");
            if (accessId == null || accessId.trim().isEmpty()) {
                response.sendRedirect("supervisionAccess.jsp?error=Invalid+request");
                return;
            }

            accessId = accessId.trim();
            // Step 3: Verify parent has permission to remove this link (SECURITY)
            if (!isParentAuthorized(userID, accessId)) {
                response.sendRedirect("supervisionAccess.jsp?error=You+are+not+authorized+to+remove+this+link");
                return;
            }
            // Step 4: Remove the supervision access from database
            if (removeSupervisionAccess(accessId)) {
                // Success - redirect with success message
                response.sendRedirect("supervisionAccess.jsp?success=Child+supervision+access+removed+successfully");
            } else {
                // Failed - redirect with error message
                response.sendRedirect("supervisionAccess.jsp?error=Failed+to+remove+supervision+access");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("supervisionAccess.jsp?error=An+error+occurred+while+removing+supervision+access");
        }
    }

    /**
     * Check if parent owns the supervision access link
     * 
     * Verifies that the supervision code belongs to this parent
     * This prevents parents from deleting other parents' supervision links
     * 
     * @param userID User ID of parent
     * @param accessId Supervision code (access ID)
     * @return true if parent owns this link, false otherwise
     * @throws SQLException if database error
     */
    private boolean isParentAuthorized(int userID, String accessId) throws SQLException {
        try {
            // Create database connection
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            
            // SQL query to check if parent owns this supervision link
            // Joins SupervisionAccess with Parent table using parentID
            String sql = "SELECT COUNT(*) FROM supervisionaccess sa " +
                        "JOIN parent p ON sa.parentID = p.parentID " +
                        "WHERE p.userID = ? AND sa.code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, userID);
            pstmt.setString(2, accessId);
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
     * Remove supervision access by code
     * 
     * Deletes the SupervisionAccess record, effectively removing the parent-student link
     * 
     * @param code Supervision code to delete
     * @return true if successful, false otherwise
     * @throws SQLException if database error
     */
    private boolean removeSupervisionAccess(String code) throws SQLException {
        try {
            // Create database connection
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            
            // SQL query to delete supervision access record
            String sql = "DELETE FROM supervisionaccess WHERE code = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, code);
            
            // Execute delete and get number of affected rows
            int rowsAffected = pstmt.executeUpdate();
            
            // Close all resources
            pstmt.close();
            conn.close();

            // Return true if at least one row was deleted
            return rowsAffected > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
}
