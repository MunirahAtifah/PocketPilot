package com.pocketpilot.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.pocketpilot.model.User;
import com.pocketpilot.util.DatabaseConnection;

/**
 * UserDAO - Data Access Object for User entity
 * 
 * Purpose: Handle all database operations related to User
 * 
 * Features:
 *   - Create/Read/Update/Delete user records
 *   - Authenticate users
 *   - Check for duplicate email/username
 *   - Query users by various criteria
 * 
 * Database Table: Registration
 * 
 * @author PP Development Team
 * @version 1.0
 */
public class UserDAO {

    /**
     * Authenticate user by email/username and password
     * 
     * @param email Email or username
     * @param password Password to verify
     * @return User object if authenticated, null if not
     * @throws SQLException if database error
     */
    public static User authenticateUser(String email, String password) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // SQL query to check both email and username
            String sql = "SELECT userID, username, email, role, password FROM Registration " +
                        "WHERE (email = ? OR username = ?) LIMIT 1";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
            stmt.setString(2, email);

            rs = stmt.executeQuery();

            if (rs.next()) {
                // User found - verify password
                String storedPassword = rs.getString("password");

                // TODO: In production, use BCrypt.checkpw(password, storedPassword)
                // For now, we're doing plain text comparison (not secure!)
                if (password.equals(storedPassword)) {
                    // Password matches - return User object
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));

                    return user;
                }
            }

            // User not found or password doesn't match
            return null;

        } finally {
            // Close resources
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Check if email already exists in database
     * 
     * @param email Email to check
     * @return true if email exists, false otherwise
     * @throws SQLException if database error
     */
    public static boolean emailExists(String email) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM Registration WHERE email = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);
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
     * Check if username already exists in database
     * 
     * @param username Username to check
     * @return true if username exists, false otherwise
     * @throws SQLException if database error
     */
    public static boolean usernameExists(String username) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT COUNT(*) FROM Registration WHERE username = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setString(1, username);
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
     * Register a new user in the database
     * 
     * @param username Username
     * @param email Email address
     * @param phoneNumber Phone number
     * @param role User role ('Student', 'Parent', 'IT_Support')
     * @param password Password (should be hashed before calling)
     * @return Generated userID if successful, -1 if failed
     * @throws SQLException if database error
     */
    public static int registerUser(String username, String email, String phoneNumber, String role, String password)
            throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "INSERT INTO Registration (username, email, phone_number, role, password) " +
                        "VALUES (?, ?, ?, ?, ?)";

            stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stmt.setString(1, username);
            stmt.setString(2, email);
            stmt.setString(3, phoneNumber);
            stmt.setString(4, role);
            stmt.setString(5, password);

            int affectedRows = stmt.executeUpdate();

            if (affectedRows > 0) {
                rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }

            return -1;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Delete user from database
     * 
     * @param userID User ID to delete
     * @throws SQLException if database error
     */
    public static void deleteUser(int userID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;

        try {
            conn = DatabaseConnection.getConnection();

            String sql = "DELETE FROM Registration WHERE userID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);

            stmt.executeUpdate();
            System.out.println("User " + userID + " deleted");

        } finally {
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    /**
     * Get user by userID
     * 
     * @param userID User ID
     * @return User object if found, null otherwise
     * @throws SQLException if database error
     */
    public static User getUserByID(int userID) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT userID, username, email, role FROM Registration WHERE userID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            rs = stmt.executeQuery();

            if (rs.next()) {
                User user = new User();
                user.setUserID(rs.getInt("userID"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setRole(rs.getString("role"));
                return user;
            }

            return null;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }
}
