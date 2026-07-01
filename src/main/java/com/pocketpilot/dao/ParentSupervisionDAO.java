package com.pocketpilot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.pocketpilot.util.DatabaseConnection;
public class ParentSupervisionDAO {
    
    // Generate a unique 8-character supervision code
    private static String generateSupervisionCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        StringBuilder code = new StringBuilder();
        Random random = new Random();
        
        for (int i = 0; i < 8; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }
        
        return code.toString();
    }

    // Create a new supervision code for a student to share with a parent
    public static String createSupervisionCode(int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        String code = null;
        boolean isUnique = false;

        try {
            // Generate unique code
            while (!isUnique) {
                code = generateSupervisionCode();
                conn = DatabaseConnection.getConnection();

                String checkSQL = "SELECT COUNT(*) FROM parentchildaccess WHERE supervisionCode = ?";
                stmt = conn.prepareStatement(checkSQL);
                stmt.setString(1, code);
                ResultSet rs = stmt.executeQuery();

                if (rs.next() && rs.getInt(1) == 0) {
                    isUnique = true;
                }

                rs.close();
                stmt.close();
                conn.close();
            }

            // Store the code (pending parent entry)
            conn = DatabaseConnection.getConnection();
            String insertSQL = "INSERT INTO parentchildaccess (studentID, supervisionCode, connectionStatus) " +
                              "VALUES (?, ?, 'pending')";
            stmt = conn.prepareStatement(insertSQL);
            stmt.setInt(1, studentID);
            stmt.setString(2, code);
            stmt.executeUpdate();

            return code;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // Connect a parent to a student using supervision code
    public static boolean connectParentToStudent(int parentID, String supervisionCode) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Find the student associated with this code
            String findSQL = "SELECT studentID, connectionStatus FROM parentchildaccess WHERE supervisionCode = ?";
            stmt = conn.prepareStatement(findSQL);
            stmt.setString(1, supervisionCode);
            rs = stmt.executeQuery();

            if (!rs.next()) {
                return false; // Code doesn't exist
            }

            int studentID = rs.getInt("studentID");
            String status = rs.getString("connectionStatus");

            rs.close();
            stmt.close();

            // Check if parent already connected to this student
            String checkSQL = "SELECT COUNT(*) FROM parentchildaccess WHERE parentID = ? AND studentID = ?";
            stmt = conn.prepareStatement(checkSQL);
            stmt.setInt(1, parentID);
            stmt.setInt(2, studentID);
            rs = stmt.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                rs.close();
                stmt.close();
                return false; // Already connected
            }

            rs.close();
            stmt.close();

            // Update the code record with parentID and mark as active
            String updateSQL = "UPDATE parentchildaccess SET parentID = ?, connectionStatus = 'active', connectedDate = NOW() " +
                              "WHERE supervisionCode = ?";
            stmt = conn.prepareStatement(updateSQL);
            stmt.setInt(1, parentID);
            stmt.setString(2, supervisionCode);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    // Get all students connected to a parent
    public static List<Integer> getConnectedStudentIDs(int parentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Integer> studentIDs = new ArrayList<>();

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT DISTINCT studentID FROM parentchildaccess " +
                        "WHERE parentID = ? AND connectionStatus = 'active'";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, parentID);
            rs = stmt.executeQuery();

            while (rs.next()) {
                studentIDs.add(rs.getInt("studentID"));
            }

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }

        return studentIDs;
    }

    // Get all pending supervision codes for a student (codes not yet claimed by parent)
    public static List<String> getPendingCodesForStudent(int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<String> codes = new ArrayList<>();

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT supervisionCode, createdDate FROM parentchildaccess " +
                        "WHERE studentID = ? AND connectionStatus = 'pending' " +
                        "ORDER BY createdDate DESC";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, studentID);
            rs = stmt.executeQuery();

            while (rs.next()) {
                codes.add(rs.getString("supervisionCode"));
            }

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }

        return codes;
    }

    // Get parent's access to a specific student
    public static boolean hasAccessToStudent(int parentID, int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT COUNT(*) FROM parentchildaccess " +
                        "WHERE parentID = ? AND studentID = ? AND connectionStatus = 'active'";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, parentID);
            stmt.setInt(2, studentID);
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

    // Revoke parent's access to a student
    public static boolean revokeAccess(int parentID, int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "UPDATE parentchildaccess SET connectionStatus = 'inactive' " +
                        "WHERE parentID = ? AND studentID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, parentID);
            stmt.setInt(2, studentID);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
