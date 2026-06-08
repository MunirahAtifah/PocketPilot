package com.pocketpilot.dao;

import com.pocketpilot.model.Budget;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * BudgetDAO - Data Access Object for Budget Management
 * 
 * Purpose: Handle all database operations for Budget entity
 * 
 * Features:
 *   - Create, Read, Update, Delete budget records
 *   - Query budgets by student and month
 *   - Calculate monthly budget totals
 *   - Join with Category table for category names
 * 
 * Database Tables:
 *   - Budget: Stores budget entries
 *   - Category: Stores budget categories
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class BudgetDAO {
    // Database connection parameters
    private String dbUrl = "jdbc:mysql://localhost:3306/PP";
    private String dbUser = "root";
    private String dbPassword = "";

    // Static block to load MySQL JDBC driver
    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
    }

    /**
     * Create a new budget entry in the database
     * 
     * Inserts a new row into the Budget table with the provided budget information
     * 
     * @param budget Budget object with studentID, categoryID, budgetAmount, budgetDesc, and budgetDate set
     * @return true if insert was successful (rowsAffected > 0), false otherwise
     */
    public boolean createBudget(Budget budget) {
        // SQL INSERT statement to add new budget record
        String sql = "INSERT INTO Budget (studentID, categoryID, budgetAmount, budgetDesc, budgetDate) VALUES (?, ?, ?, ?, ?)";
        
        // Try-with-resources ensures connection and statement are automatically closed
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter values for the INSERT query
            pstmt.setInt(1, budget.getStudentID());          // Student ID
            pstmt.setInt(2, budget.getCategoryID());         // Category ID
            pstmt.setDouble(3, budget.getBudgetAmount());    // Budget amount
            pstmt.setString(4, budget.getBudgetDesc());      // Description
            pstmt.setDate(5, Date.valueOf(budget.getBudgetDate())); // Date
            
            // Execute update and get number of affected rows
            int rowsAffected = pstmt.executeUpdate();
            
            // Return true if at least one row was inserted
            return rowsAffected > 0;
        } catch (SQLException e) {
            // Log error and return false
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get a single budget by its ID
     * 
     * Retrieves budget information from Budget table and joins with Category table
     * to get the category name
     * 
     * @param budgetID The ID of the budget to retrieve
     * @return Budget object if found, null if not found
     */
    public Budget getBudgetByID(int budgetID) {
        // SQL SELECT query with JOIN to Category table
        String sql = "SELECT b.budgetID, b.studentID, b.categoryID, b.budgetAmount, b.budgetDesc, b.budgetDate, c.categoryName " +
                     "FROM Budget b JOIN Category c ON b.categoryID = c.categoryID WHERE b.budgetID = ?";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter value for WHERE clause
            pstmt.setInt(1, budgetID);
            
            // Execute query
            ResultSet rs = pstmt.executeQuery();
            
            // If budget found, extract and return data
            if (rs.next()) {
                Budget budget = new Budget();
                budget.setBudgetID(rs.getInt("budgetID"));
                budget.setStudentID(rs.getInt("studentID"));
                budget.setCategoryID(rs.getInt("categoryID"));
                budget.setBudgetAmount(rs.getDouble("budgetAmount"));
                budget.setBudgetDesc(rs.getString("budgetDesc"));
                budget.setBudgetDate(rs.getDate("budgetDate").toLocalDate());
                budget.setCategoryName(rs.getString("categoryName"));
                return budget;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Return null if budget not found
        return null;
    }

    /**
     * Get all budgets for a student in a specific month and year
     * 
     * Retrieves all budgets for a student filtered by month and year,
     * ordered by date in descending order (newest first)
     * 
     * @param studentID The student ID
     * @param month The month (1-12)
     * @param year The year (e.g., 2026)
     * @return List of Budget objects, empty list if none found
     */
    public List<Budget> getBudgetsByStudentAndMonth(int studentID, int month, int year) {
        List<Budget> budgets = new ArrayList<>();
        
        // SQL SELECT query with MONTH and YEAR filters
        String sql = "SELECT b.budgetID, b.studentID, b.categoryID, b.budgetAmount, b.budgetDesc, b.budgetDate, c.categoryName " +
                     "FROM Budget b JOIN Category c ON b.categoryID = c.categoryID " +
                     "WHERE b.studentID = ? AND MONTH(b.budgetDate) = ? AND YEAR(b.budgetDate) = ? " +
                     "ORDER BY b.budgetDate DESC";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter values for WHERE clause
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month);
            pstmt.setInt(3, year);
            
            // Execute query
            ResultSet rs = pstmt.executeQuery();
            
            // Process all rows in result set
            while (rs.next()) {
                Budget budget = new Budget();
                budget.setBudgetID(rs.getInt("budgetID"));
                budget.setStudentID(rs.getInt("studentID"));
                budget.setCategoryID(rs.getInt("categoryID"));
                budget.setBudgetAmount(rs.getDouble("budgetAmount"));
                budget.setBudgetDesc(rs.getString("budgetDesc"));
                budget.setBudgetDate(rs.getDate("budgetDate").toLocalDate());
                budget.setCategoryName(rs.getString("categoryName"));
                
                // Add to list
                budgets.add(budget);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Return list (empty if no results)
        return budgets;
    }

    /**
     * Get all budgets for a student (regardless of month/year)
     * 
     * Retrieves all budgets for a student, ordered by date descending
     * 
     * @param studentID The student ID
     * @return List of Budget objects, empty list if none found
     */
    public List<Budget> getAllBudgetsByStudent(int studentID) {
        List<Budget> budgets = new ArrayList<>();
        
        // SQL SELECT query for all budgets
        String sql = "SELECT b.budgetID, b.studentID, b.categoryID, b.budgetAmount, b.budgetDesc, b.budgetDate, c.categoryName " +
                     "FROM Budget b JOIN Category c ON b.categoryID = c.categoryID " +
                     "WHERE b.studentID = ? ORDER BY b.budgetDate DESC";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter value for WHERE clause
            pstmt.setInt(1, studentID);
            
            // Execute query
            ResultSet rs = pstmt.executeQuery();
            
            // Process all rows in result set
            while (rs.next()) {
                Budget budget = new Budget();
                budget.setBudgetID(rs.getInt("budgetID"));
                budget.setStudentID(rs.getInt("studentID"));
                budget.setCategoryID(rs.getInt("categoryID"));
                budget.setBudgetAmount(rs.getDouble("budgetAmount"));
                budget.setBudgetDesc(rs.getString("budgetDesc"));
                budget.setBudgetDate(rs.getDate("budgetDate").toLocalDate());
                budget.setCategoryName(rs.getString("categoryName"));
                
                // Add to list
                budgets.add(budget);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Return list (empty if no results)
        return budgets;
    }

    /**
     * Update an existing budget entry
     * 
     * Updates budget record where budgetID and studentID match (ensures security)
     * Prevents students from updating other students' budgets
     * 
     * @param budget Budget object with updated values and budgetID/studentID set
     * @return true if update was successful, false otherwise
     */
    public boolean updateBudget(Budget budget) {
        // SQL UPDATE statement with security check (studentID in WHERE)
        String sql = "UPDATE Budget SET categoryID = ?, budgetAmount = ?, budgetDesc = ?, budgetDate = ? WHERE budgetID = ? AND studentID = ?";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter values for SET clause
            pstmt.setInt(1, budget.getCategoryID());
            pstmt.setDouble(2, budget.getBudgetAmount());
            pstmt.setString(3, budget.getBudgetDesc());
            pstmt.setDate(4, Date.valueOf(budget.getBudgetDate()));
            
            // Set parameter values for WHERE clause (security check)
            pstmt.setInt(5, budget.getBudgetID());
            pstmt.setInt(6, budget.getStudentID());
            
            // Execute update and get number of affected rows
            int rowsAffected = pstmt.executeUpdate();
            
            // Return true if at least one row was updated
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a budget entry
     * 
     * Deletes budget record where budgetID and studentID match (ensures security)
     * Prevents students from deleting other students' budgets
     * 
     * @param budgetID The ID of the budget to delete
     * @param studentID The student ID (security check - must own the budget)
     * @return true if delete was successful, false otherwise
     */
    public boolean deleteBudget(int budgetID, int studentID) {
        // SQL DELETE statement with security check (studentID in WHERE)
        String sql = "DELETE FROM Budget WHERE budgetID = ? AND studentID = ?";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter values for WHERE clause
            pstmt.setInt(1, budgetID);
            pstmt.setInt(2, studentID);
            
            // Execute delete and get number of affected rows
            int rowsAffected = pstmt.executeUpdate();
            
            // Return true if at least one row was deleted
            return rowsAffected > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get the total budget amount for a student in a specific month
     * 
     * Sums all budget amounts for a student in the given month/year
     * Useful for calculating monthly budget totals
     * 
     * @param studentID The student ID
     * @param month The month (1-12)
     * @param year The year (e.g., 2026)
     * @return Total budget amount (0.0 if no budgets found)
     */
    public double getTotalBudgetForMonth(int studentID, int month, int year) {
        // SQL SELECT with SUM function to aggregate budget amounts
        String sql = "SELECT SUM(budgetAmount) as total FROM Budget " +
                     "WHERE studentID = ? AND MONTH(budgetDate) = ? AND YEAR(budgetDate) = ?";
        
        try (Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Set parameter values for WHERE clause
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month);
            pstmt.setInt(3, year);
            
            // Execute query
            ResultSet rs = pstmt.executeQuery();
            
            // If result found, return the sum
            if (rs.next()) {
                return rs.getDouble("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        // Return 0.0 if no results or error
        return 0.0;
    }
}
