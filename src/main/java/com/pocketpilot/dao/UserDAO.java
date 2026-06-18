package com.pocketpilot.dao;

import java.sql.*;
import com.pocketpilot.model.User;
import com.pocketpilot.util.DatabaseConnection;

/**
 * UserDAO - Data Access Object for User entity
 * Updated with try-with-resources and getStudentIDByUserID
 */
public class UserDAO {

    public static User authenticateUser(String email, String password) throws SQLException {
        String sql = "SELECT userID, username, email, role, password FROM registration WHERE (email = ? OR username = ?) LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next() && password.equals(rs.getString("password"))) {
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }

    public static boolean emailExists(String email) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public static boolean usernameExists(String username) throws SQLException {
        String sql = "SELECT COUNT(*) FROM registration WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, username);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public static int registerUser(String username, String email, String phoneNumber, String role, String password) throws SQLException {
        String sql = "INSERT INTO registration (username, email, phone_number, role, password) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, username);
            stmt.setString(2, email);
            stmt.setString(3, phoneNumber);
            stmt.setString(4, role);
            stmt.setString(5, password);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) return rs.getInt(1);
                }
            }
        }
        return -1;
    }

    public static void deleteUser(int userID) throws SQLException {
        String sql = "DELETE FROM registration WHERE userID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userID);
            stmt.executeUpdate();
        }
    }

    public static User getUserByID(int userID) throws SQLException {
        String sql = "SELECT userID, username, email, role FROM registration WHERE userID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userID);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
        }
        return null;
    }

    /**
     * Look up StudentID using the UserID.
     * Note: Non-static method to match standard DAO practices.
     */
    public int getStudentIDByUserID(int userID) {
        String sql = "SELECT studentID FROM student WHERE userID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userID);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt("studentID");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Ensure that a user profile (Student, Parent, or Student_Counsellor) exists in the database.
     * If missing, create one.
     */
    public static void ensureProfileExists(int userID, String role, String username) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            if ("Student".equals(role)) {
                boolean exists = false;
                try (PreparedStatement pstmt = conn.prepareStatement("SELECT 1 FROM student WHERE userID = ?")) {
                    pstmt.setInt(1, userID);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) exists = true;
                    }
                }
                if (!exists) {
                    try (PreparedStatement pstmt = conn.prepareStatement("INSERT INTO student (userID, studentName) VALUES (?, ?)")) {
                        pstmt.setInt(1, userID);
                        pstmt.setString(2, username);
                        pstmt.executeUpdate();
                        System.out.println("[UserDAO] Auto-created missing Student profile for userID: " + userID);
                    }
                    // Auto-enroll with all counsellors
                    try {
                        int studentID = -1;
                        try (PreparedStatement pstmt = conn.prepareStatement("SELECT studentID FROM student WHERE userID = ?")) {
                            pstmt.setInt(1, userID);
                            try (ResultSet rs = pstmt.executeQuery()) {
                                if (rs.next()) studentID = rs.getInt("studentID");
                            }
                        }
                        if (studentID > 0) {
                            StudentCounsellorDAO.autoEnrollStudentWithCounsellors(studentID);
                            System.out.println("[UserDAO] Auto-enrolled new Student " + studentID + " with all counsellors");
                        }
                    } catch (Exception e) {
                        System.err.println("[UserDAO] Failed to auto-enroll student: " + e.getMessage());
                    }
                }
            } else if ("Parent".equals(role)) {
                boolean exists = false;
                try (PreparedStatement pstmt = conn.prepareStatement("SELECT 1 FROM parent WHERE userID = ?")) {
                    pstmt.setInt(1, userID);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) exists = true;
                    }
                }
                if (!exists) {
                    try (PreparedStatement pstmt = conn.prepareStatement("INSERT INTO parent (userID, parentName) VALUES (?, ?)")) {
                        pstmt.setInt(1, userID);
                        pstmt.setString(2, username);
                        pstmt.executeUpdate();
                        System.out.println("[UserDAO] Auto-created missing Parent profile for userID: " + userID);
                    }
                }
            } else if ("Student_Counsellor".equals(role)) {
                boolean exists = false;
                try (PreparedStatement pstmt = conn.prepareStatement("SELECT 1 FROM student_counsellor WHERE userID = ?")) {
                    pstmt.setInt(1, userID);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) exists = true;
                    }
                }
                if (!exists) {
                    try (PreparedStatement pstmt = conn.prepareStatement("INSERT INTO student_counsellor (userID, staffName) VALUES (?, ?)")) {
                        pstmt.setInt(1, userID);
                        pstmt.setString(2, username);
                        pstmt.executeUpdate();
                        System.out.println("[UserDAO] Auto-created missing Student Counsellor profile for userID: " + userID);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[UserDAO] Error ensuring profile exists: " + e.getMessage());
            e.printStackTrace();
        }
    }
}