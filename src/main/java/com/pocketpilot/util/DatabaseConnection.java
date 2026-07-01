package com.pocketpilot.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
public class DatabaseConnection {

    /** MySQL JDBC Driver Class */
    private static final String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    // Resolved database configuration cached after first successful initialization
    private static String resolvedUrl = null;
    private static String resolvedUser = "root";
    private static String resolvedPassword = "";
    private static final Object lock = new Object();
    // Static Initializer - Load JDBC Driver
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

    /**
     * Resolve database configuration dynamically, checking environment variables
     * and auto-detecting active database configurations.
     */
    private static void resolveConnection() {
        synchronized (lock) {
            if (resolvedUrl != null) {
                return;
            }

            // Check if environment variables are set
            String envHost = System.getenv("DB_HOST");
            String envPort = System.getenv("DB_PORT");
            String envName = System.getenv("DB_NAME");
            String envUser = System.getenv("DB_USER");
            String envPass = System.getenv("DB_PASSWORD");

            if (envHost != null) {
                String port = envPort != null ? envPort : "3306";
                String name = envName != null ? envName : "pp";
                resolvedUrl = "jdbc:mysql://" + envHost + ":" + port + "/" + name + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
                resolvedUser = envUser != null ? envUser : "root";
                resolvedPassword = envPass != null ? envPass : "";
                System.out.println("✓ Using database configuration from environment: " + resolvedUrl);
                return;
            }

            // Define config candidates to test
            class DbConfigCandidate {
                String url;
                String user;
                String password;
                DbConfigCandidate(String url, String user, String password) {
                    this.url = url;
                    this.user = user;
                    this.password = password;
                }
            }

            java.util.List<DbConfigCandidate> candidates = new java.util.ArrayList<>();
            // 1. Docker environment default configuration
            candidates.add(new DbConfigCandidate("jdbc:mysql://pocketpilot-db:3306/pp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&connectTimeout=2000", "root", "rootpassword"));
            // 2. Local XAMPP/WAMP default (lowercase pp)
            candidates.add(new DbConfigCandidate("jdbc:mysql://localhost:3306/pp?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&connectTimeout=2000", "root", ""));
            // 3. Local XAMPP/WAMP default (uppercase PP)
            candidates.add(new DbConfigCandidate("jdbc:mysql://localhost:3306/PP?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC&connectTimeout=2000", "root", ""));

            for (DbConfigCandidate candidate : candidates) {
                try (Connection conn = DriverManager.getConnection(candidate.url, candidate.user, candidate.password)) {
                    resolvedUrl = candidate.url;
                    resolvedUser = candidate.user;
                    resolvedPassword = candidate.password;
                    System.out.println("✓ Successfully connected to auto-detected database: " + resolvedUrl);
                    return;
                } catch (SQLException e) {
                    System.out.println("Info: Database connection candidate failed: " + candidate.url + " (" + e.getMessage() + ")");
                }
            }

            // Default fallback if all connection attempts fail
            resolvedUrl = "jdbc:mysql://localhost:3306/PP?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
            resolvedUser = "root";
            resolvedPassword = "";
            System.err.println("⚠ All database connection attempts failed. Falling back to default: " + resolvedUrl);
        }
    }
    // Public Methods
    /**
     * Get a database connection
     * 
     * @return Connection object
     * @throws SQLException if connection fails
     */
    public static Connection getConnection() throws SQLException {
        if (resolvedUrl == null) {
            resolveConnection();
        }
        try {
            Connection conn = DriverManager.getConnection(resolvedUrl, resolvedUser, resolvedPassword);
            System.out.println("✓ Database connection established: " + resolvedUrl);
            return conn;
        } catch (SQLException e) {
            System.err.println("✗ Failed to establish database connection");
            System.err.println("URL: " + resolvedUrl);
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
        if (resolvedUrl == null) {
            resolveConnection();
        }
        return "URL: " + resolvedUrl + "\n" +
               "User: " + resolvedUser + "\n" +
               "Driver: " + JDBC_DRIVER;
    }
}
