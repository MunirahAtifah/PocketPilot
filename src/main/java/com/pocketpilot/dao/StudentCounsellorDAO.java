package com.pocketpilot.dao;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import com.pocketpilot.model.StudentCounsellorAccess;
import com.pocketpilot.util.DatabaseConnection;

public class StudentCounsellorDAO {

    // Fixed: table name 'StudentCounsellorAccess' to 'studentcounselloraccess'
    public static List<StudentCounsellorAccess> getPendingApprovalsForCounsellor(Integer staffID) throws SQLException {
        List<StudentCounsellorAccess> requests = new ArrayList<>();
        String sql = "SELECT * FROM studentcounselloraccess WHERE staffID = ? AND approvedByStudent = 0";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, staffID);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudentCounsellorAccess access = new StudentCounsellorAccess();
                    access.setAccessID(rs.getInt("accessID"));
                    access.setStudentID(rs.getInt("studentID"));
                    requests.add(access);
                }
            }
        }
        return requests;
    }

    // Fixed: table name 'StudentCounsellorAccess' to 'studentcounselloraccess'
    public static List<StudentCounsellorAccess> getPendingCounsellorRequestsForStudent(Integer studentID) throws SQLException {
        List<StudentCounsellorAccess> requests = new ArrayList<>();
        String sql = "SELECT * FROM studentcounselloraccess WHERE studentID = ? ORDER BY accessID DESC";
        
        try (Connection conn = DatabaseConnection.getConnection(); 
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentID);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    StudentCounsellorAccess access = new StudentCounsellorAccess();
                    access.setAccessID(rs.getInt("accessID"));
                    access.setStaffID(rs.getInt("staffID"));
                    access.setStudentID(rs.getInt("studentID"));
                    access.setApprovedByStudent(rs.getInt("approvedByStudent") == 1);
                    requests.add(access);
                }
            }
        }
        return requests;
    }

    // Fixed: table name 'StudentCounsellorAccess' to 'studentcounselloraccess'
    public static boolean approveStudent(int accessID) throws SQLException {
        String sql = "UPDATE studentcounselloraccess SET approvedByStudent = 1, studentApprovalDate = NOW() WHERE accessID = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accessID);
            return stmt.executeUpdate() > 0;
        }
    }

    // Fixed: table name 'StudentCounsellorAccess' to 'studentcounselloraccess'
    public static boolean disapproveStudent(int accessID) throws SQLException {
        String sql = "UPDATE studentcounselloraccess SET approvedByStudent = 0, studentApprovalDate = NULL WHERE accessID = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accessID);
            return stmt.executeUpdate() > 0;
        }
    }

    public static boolean approveCounsellor(int accessID) throws SQLException {
        String sql = "UPDATE studentcounselloraccess SET accessStatus = 'Approved', approvedDate = NOW() WHERE accessID = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accessID);
            return stmt.executeUpdate() > 0;
        }
    }

    public static boolean disapproveCounsellor(int accessID) throws SQLException {
        String sql = "UPDATE studentcounselloraccess SET accessStatus = 'Disapproved', approvedDate = NULL WHERE accessID = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, accessID);
            return stmt.executeUpdate() > 0;
        }
    }

    public static boolean createAccessRecord(int studentID, int staffID) throws SQLException {
        String sql = "INSERT INTO studentcounselloraccess (studentID, staffID, accessStatus, approvedByStudent, createdDate) " +
                     "VALUES (?, ?, 'Approved', 0, NOW()) " +
                     "ON DUPLICATE KEY UPDATE accessStatus = 'Approved', createdDate = NOW()";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, staffID);
            return stmt.executeUpdate() > 0;
        }
    }

    // Fixed: table name 'StudentCounsellorAccess' to 'studentcounselloraccess'
    public static void autoEnrollStudentWithCounsellors(int studentID) throws SQLException {
        try (Connection conn = DatabaseConnection.getConnection()) {
            List<Integer> counsellorIDs = new ArrayList<>();
            try (Statement st = conn.createStatement(); ResultSet rs = st.executeQuery("SELECT staffID FROM student_counsellor")) {
                while (rs.next()) counsellorIDs.add(rs.getInt("staffID"));
            }
            for (Integer staffID : counsellorIDs) {
                try (PreparedStatement ps = conn.prepareStatement("INSERT INTO studentcounselloraccess (studentID, staffID, approvedByStudent) VALUES (?, ?, 0)")) {
                    ps.setInt(1, studentID);
                    ps.setInt(2, staffID);
                    ps.executeUpdate();
                }
            }
        }
    }

    public static Integer getStaffIDByUserID(int userID) throws SQLException {
        String sql = "SELECT staffID FROM student_counsellor WHERE userID = ?";
        try (Connection conn = DatabaseConnection.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userID);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() ? rs.getInt("staffID") : null;
            }
        }
    }
}