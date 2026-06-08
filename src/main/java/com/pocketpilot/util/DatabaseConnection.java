package com.pocketpilot.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DatabaseConnection - Utility class for database connectivity
 * 
 * Purpose: Manage MySQL database connections for the PP application
 * 
 * IMPORTANT - DATABASE SCOPE:
 * ──────────────────────────
 * This class is exclusively for the PocketPilot (PP) application.
 * It connects ONLY to the 'PP' database.
 * 
 * All database operations for PP must use this connection class.
 * This ensures:
 *   ✓ Centralized database configuration
 *   ✓ Single database scope (no cross-database queries)
 *   ✓ Consistent connection management
 *   ✓ Security isolation from other applications
 * 
 * SECURITY & PASSWORD HANDLING:
 * ────────────────────────────
 * ✓ Passwords are stored securely in the 'PP' database
 * ✓ Passwords are NEVER exposed through this connection class
 * ✓ Staff interface displays MASKED passwords (e.g., a****b)
 * ✓ Actual passwords remain encrypted in the database
 * ✓ Password masking happens at the UI layer only
 * 
 * Features:
 *   - Loads MySQL JDBC driver
 *   - Creates and returns database connections
 *   - Centralizes database configuration
 *   - Handles connection errors
 *   - PocketPilot (PP) application only
 * 
 * Database Configuration:
 *   - Database Name: PP (PP exclusive)
 *   - Host: localhost
 *   - Port: 3306
 *   - Username: root
 *   - Password: (empty for XAMPP default)
 * 
 * Usage:
 *   Connection conn = DatabaseConnection.getConnection();
 *   // Use connection for PP database operations
 *   conn.close();
 * 
 * @author PP Development Team
 * @version 1.0
 */
public class DatabaseConnection {

    // ================================================
    // Database Configuration - UPDATED FOR DOCKER
    // ================================================
    
    /** Database URL - Uses Docker service name 'pocketpilot-db' and database 'pocketpilot_db' */
    private static final String DB_URL = "jdbc:mysql://pocketpilot-db:3306/pp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    
    /** Database Username */
    private static final String DB_USER = "root";
    
    /** Database Password - Matches MYSQL_ROOT_PASSWORD in compose file */
    private static final String DB_PASSWORD = "rootpassword";
    
    /** MySQL JDBC Driver Class */
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    // ================================================
    // Static Initializer - Load JDBC Driver
    // ================================================
    
    static {
        try {
            // Load MySQL JDBC Driver
            Class.forName(JDBC_DRIVER);
            System.out.println("✓ MySQL JDBC Driver loaded successfully");
        } catch (ClassNotFoundException e) {
            System.err.println("✗ Failed to load MySQL JDBC Driver");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    // ================================================
    // Public Methods
    // ================================================

    /**
     * Get a database connection
     * 
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            System.out.println("✓ Database connection established");
            return conn;
        } catch (SQLException e) {
            System.err.println("✗ Failed to establish database connection");
            System.err.println("URL: " + DB_URL);
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }

    /**
     * Test the database connection
     * Useful for debugging connection issues
     * 
     * @return true if connection successful, false otherwise
     */
    public static boolean testConnection() {
        Connection conn = null;
        try {
            conn = getConnection();
            System.out.println("✓ Database connection test passed");
            return true;
        } catch (SQLException e) {
            System.err.println("✗ Database connection test failed");
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    System.err.println("Error closing test connection: " + e.getMessage());
                }
            }
        }
    }

    /**
     * Get database information
     * 
     * @return String with database connection details
     */
    public static String getDatabaseInfo() {
        return "Database: PP\n" +
               "Host: localhost\n" +
               "Port: 3306\n" +
               "User: " + DB_USER + "\n" +
               "Driver: " + JDBC_DRIVER;
    }
}
