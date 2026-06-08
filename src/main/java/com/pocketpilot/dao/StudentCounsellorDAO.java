package com.pocketpilot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.pocketpilot.model.StudentCounsellorAccess;
import com.pocketpilot.util.DatabaseConnection;

/**
 * StudentCounsellorDAO - Data Access Object for Student Counsellor
 * 
 * Purpose: Handle all database operations for Student_Counsellor and StudentCounsellorAccess
 * 
 * New Workflow: Student approves/disapproves counsellors
 *   - All students auto-enrolled with all counsellors (pending approval from STUDENT)
 *   - Student sees list of pending counsellor requests
 *   - Student can approve or disapprove each counsellor
 *   - Only approved counsellors can view student's budget/expense
 */
public class StudentCounsellorDAO {
    
    /**
     * Auto-enroll a new student with all existing counsellors
     * Creates StudentCounsellorAccess records with status "pending"
     * Student must approve the counsellor for access
     */
    public static void autoEnrollStudentWithCounsellors(int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Get all active Student_Counsellor users
            String getCounsellorsSQL = "SELECT staffID FROM Student_Counsellor";
            stmt = conn.prepareStatement(getCounsellorsSQL);
            rs = stmt.executeQuery();

            List<Integer> counsellorIDs = new ArrayList<>();
            while (rs.next()) {
                counsellorIDs.add(rs.getInt("staffID"));
            }

            rs.close();
            stmt.close();

            // Create access records for each counsellor (pending student approval)
            for (Integer staffID : counsellorIDs) {
                String insertSQL = "INSERT INTO StudentCounsellorAccess (studentID, staffID, accessStatus, approvedByStudent) " +
                                   "VALUES (?, ?, 'pending', 0)";
                stmt = conn.prepareStatement(insertSQL);
                stmt.setInt(1, studentID);
                stmt.setInt(2, staffID);
                stmt.executeUpdate();
                stmt.close();
            }

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Get all pending counsellor approval requests for a specific student
     * Used by student to see which counsellors want access
     */
    public static List<StudentCounsellorAccess> getPendingCounsellorRequestsForStudent(int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<StudentCounsellorAccess> requests = new ArrayList<>();

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT sca.accessID, sca.studentID, sca.staffID, sca.accessStatus, sca.createdDate, " +
                        "sca.approvedByStudent, sca.studentApprovalDate, sc.staffName " +
                        "FROM StudentCounsellorAccess sca " +
                        "JOIN Student_Counsellor sc ON sca.staffID = sc.staffID " +
                        "WHERE sca.studentID = ? " +
                        "ORDER BY sca.createdDate DESC";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, studentID);
            rs = stmt.executeQuery();

            while (rs.next()) {
                StudentCounsellorAccess access = new StudentCounsellorAccess();
                access.setAccessID(rs.getInt("accessID"));
                access.setStudentID(rs.getInt("studentID"));
                access.setStaffID(rs.getInt("staffID"));
                access.setAccessStatus(rs.getString("accessStatus"));
                access.setCreatedDate(rs.getTimestamp("createdDate"));
                access.setApprovedByStudent(rs.getBoolean("approvedByStudent"));
                if (rs.getTimestamp("studentApprovalDate") != null) {
                    access.setStudentApprovalDate(rs.getTimestamp("studentApprovalDate"));
                }
                requests.add(access);
            }

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }

        return requests;
    }

    /**
     * Student approves a counsellor for access
     */
    public static boolean approveCounsellor(int accessID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "UPDATE StudentCounsellorAccess " +
                        "SET approvedByStudent = 1, studentApprovalDate = NOW() " +
                        "WHERE accessID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, accessID);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Student disapproves a counsellor
     */
    public static boolean disapproveCounsellor(int accessID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "UPDATE StudentCounsellorAccess " +
                        "SET approvedByStudent = 0, studentApprovalDate = NULL " +
                        "WHERE accessID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, accessID);

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Check if counsellor has access to student (must be student approved)
     */
    public static boolean hasAccessToStudent(int staffID, int studentID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT COUNT(*) FROM StudentCounsellorAccess " +
                        "WHERE staffID = ? AND studentID = ? AND approvedByStudent = 1";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, staffID);
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

    /**
     * Get approved students for a counsellor (students who approved them)
     */
    public static List<Integer> getApprovedStudentIDs(int staffID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;
        List<Integer> studentIDs = new ArrayList<>();

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT DISTINCT studentID FROM StudentCounsellorAccess " +
                        "WHERE staffID = ? AND approvedByStudent = 1";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, staffID);
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

    /**
     * Get student counsellor by userID
     */
    public static Integer getStaffIDByUserID(int userID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "SELECT staffID FROM Student_Counsellor WHERE userID = ?";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            rs = stmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("staffID");
            }

            return null;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
