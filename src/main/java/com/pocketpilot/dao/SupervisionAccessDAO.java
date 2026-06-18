package com.pocketpilot.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SupervisionAccessDAO {
    // Database connection is managed by com.pocketpilot.util.DatabaseConnection

    /**
     * Validate if a supervision code exists and is valid
     */
    public boolean isValidSupervisionCode(String supervisionCode) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "SELECT supervisionCode FROM student WHERE UPPER(supervisionCode) = ? LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, supervisionCode.trim().toUpperCase());
            ResultSet rs = pstmt.executeQuery();
            
            boolean exists = rs.next();
            rs.close();
            pstmt.close();
            conn.close();
            
            return exists;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get Student ID by Supervision Code
     */
    public int getStudentIDBySupervisionCode(String supervisionCode) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "SELECT studentID FROM student WHERE UPPER(supervisionCode) = ? LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, supervisionCode.trim().toUpperCase());
            ResultSet rs = pstmt.executeQuery();
            
            int studentID = -1;
            if (rs.next()) {
                studentID = rs.getInt("studentID");
            }
            
            rs.close();
            pstmt.close();
            conn.close();
            
            return studentID;
        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }

    /**
     * Check if supervision link already exists
     */
    public boolean supervisionLinkExists(int studentID, int parentID) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "SELECT id FROM supervisionaccess WHERE studentID = ? AND parentID = ? LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, parentID);
            ResultSet rs = pstmt.executeQuery();
            
            boolean exists = rs.next();
            rs.close();
            pstmt.close();
            conn.close();
            
            return exists;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Create supervision access record
     */
    public boolean createSupervisionAccess(int studentID, int parentID, String accessCode) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "INSERT INTO supervisionaccess (code, studentID, parentID, approvalStatus) VALUES (?, ?, ?, 'Approved')";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, accessCode);
            pstmt.setInt(2, studentID);
            pstmt.setInt(3, parentID);
            
            int affectedRows = pstmt.executeUpdate();
            pstmt.close();
            conn.close();
            
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all supervision access records for a student
     */
    public List<Map<String, Object>> getStudentSupervisionAccess(int studentID) {
        List<Map<String, Object>> supervisionList = new ArrayList<>();
        
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "SELECT sa.id, sa.approvalStatus, s.supervisionCode, " +
                        "CONCAT(u.username, ' (', u.email, ')') as parentInfo " +
                        "FROM supervisionaccess sa " +
                        "JOIN student s ON sa.studentID = s.studentID " +
                        "LEFT JOIN parent p ON sa.parentID = p.parentID " +
                        "LEFT JOIN registration u ON p.userID = u.userID " +
                        "WHERE sa.studentID = ? " +
                        "ORDER BY sa.id DESC";
            
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();
            
            while (rs.next()) {
                Map<String, Object> record = new HashMap<>();
                record.put("id", rs.getInt("id"));
                record.put("approvalStatus", rs.getString("approvalStatus"));
                record.put("parentInfo", rs.getString("parentInfo"));
                record.put("supervisionCode", rs.getString("supervisionCode"));
                supervisionList.add(record);
            }
            
            rs.close();
            pstmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return supervisionList;
    }

    /**
     * Revoke supervision access
     */
    public boolean revokeSupervisionAccess(int supervisionID) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "DELETE FROM supervisionaccess WHERE id = ?";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, supervisionID);
            
            int affectedRows = pstmt.executeUpdate();
            pstmt.close();
            conn.close();
            
            return affectedRows > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Check if parent has access to student's data
     */
    public boolean hasSupervisionAccess(int studentID, int parentID) {
        try {
            Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
            String sql = "SELECT id FROM supervisionaccess WHERE studentID = ? AND parentID = ? AND approvalStatus = 'Approved' LIMIT 1";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, parentID);
            ResultSet rs = pstmt.executeQuery();
            
            boolean hasAccess = rs.next();
            rs.close();
            pstmt.close();
            conn.close();
            
            return hasAccess;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }
}
