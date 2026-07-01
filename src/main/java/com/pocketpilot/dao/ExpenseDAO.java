package com.pocketpilot.dao;

import com.pocketpilot.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
public class ExpenseDAO {

    /**
     * Create a new expense record
     * 
     * @param studentID Student who recorded the expense
     * @param categoryID Category of the expense
     * @param expenseAmount Amount spent
     * @param expenseDesc Description of the expense
     * @param expenseDate Date of the expense
     * @return true if successful, false otherwise
     */
    public static boolean createExpense(int studentID, int categoryID, double expenseAmount,
                                       String expenseDesc, LocalDate expenseDate) {
        String sql = "INSERT INTO expense (studentID, categoryID, expenseAmount, expenseDesc, expenseDate) " +
                    "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameters for INSERT query
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, categoryID);
            pstmt.setDouble(3, expenseAmount);
            pstmt.setString(4, expenseDesc);
            pstmt.setDate(5, Date.valueOf(expenseDate));

            // Step 2: Execute INSERT and get result
            int rowsAffected = pstmt.executeUpdate();
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error creating expense: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get expense by ID
     * 
     * @param expenseID ID of expense to retrieve
     * @return Map with expense data if found, null otherwise
     */
    public static Map<String, Object> getExpenseByID(int expenseID) {
        String sql = "SELECT e.expenseID, e.studentID, e.categoryID, e.expenseAmount, " +
                    "e.expenseDesc, e.expenseDate, c.categoryName FROM expense e " +
                    "JOIN category c ON e.categoryID = c.categoryID WHERE e.expenseID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameter
            pstmt.setInt(1, expenseID);

            // Step 2: Execute SELECT query
            ResultSet rs = pstmt.executeQuery();

            // Step 3: Check if result exists and create map
            if (rs.next()) {
                Map<String, Object> expense = new HashMap<>();
                expense.put("expenseID", rs.getInt("expenseID"));
                expense.put("studentID", rs.getInt("studentID"));
                expense.put("categoryID", rs.getInt("categoryID"));
                expense.put("expenseAmount", rs.getDouble("expenseAmount"));
                expense.put("expenseDesc", rs.getString("expenseDesc"));
                expense.put("expenseDate", rs.getDate("expenseDate").toLocalDate());
                expense.put("categoryName", rs.getString("categoryName"));
                
                return expense;
            }
            
            return null;
            
        } catch (SQLException e) {
            System.err.println("Error retrieving expense: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }

    /**
     * Update an existing expense
     * With ownership verification (only student can update their own expense)
     * 
     * @param expenseID Expense to update
     * @param studentID Student ID (for ownership check)
     * @param categoryID New category ID
     * @param expenseAmount New amount
     * @param expenseDesc New description
     * @param expenseDate New date
     * @return true if successful, false otherwise
     */
    public static boolean updateExpense(int expenseID, int studentID, int categoryID,
                                       double expenseAmount, String expenseDesc, LocalDate expenseDate) {
        String sql = "UPDATE expense SET categoryID = ?, expenseAmount = ?, expenseDesc = ?, expenseDate = ? " +
                    "WHERE expenseID = ? AND studentID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameters (with ownership check in WHERE clause)
            pstmt.setInt(1, categoryID);
            pstmt.setDouble(2, expenseAmount);
            pstmt.setString(3, expenseDesc);
            pstmt.setDate(4, Date.valueOf(expenseDate));
            pstmt.setInt(5, expenseID);
            pstmt.setInt(6, studentID);

            // Step 2: Execute UPDATE
            int rowsAffected = pstmt.executeUpdate();
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error updating expense: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete an expense with ownership verification
     * Only the student who created the expense can delete it
     * 
     * @param expenseID Expense to delete
     * @param studentID Student ID (for ownership check)
     * @return true if successful, false otherwise
     */
    public static boolean deleteExpense(int expenseID, int studentID) {
        String sql = "DELETE FROM expense WHERE expenseID = ? AND studentID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameters
            pstmt.setInt(1, expenseID);
            pstmt.setInt(2, studentID);

            // Step 2: Execute DELETE (with ownership check)
            int rowsAffected = pstmt.executeUpdate();
            
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            System.err.println("Error deleting expense: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all expenses for a student in a specific month
     * 
     * @param studentID Student to retrieve expenses for
     * @param month Month value (1-12)
     * @param year Year value
     * @return ArrayList of expense maps
     */
    public static List<Map<String, Object>> getExpensesByStudentAndMonth(int studentID, int month, int year) {
        String sql = "SELECT e.expenseID, e.studentID, e.categoryID, e.expenseAmount, " +
                    "e.expenseDesc, e.expenseDate, c.categoryName FROM expense e " +
                    "JOIN category c ON e.categoryID = c.categoryID " +
                    "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ? " +
                    "ORDER BY e.expenseDate DESC";

        List<Map<String, Object>> expenses = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameters
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month);
            pstmt.setInt(3, year);

            // Step 2: Execute SELECT query with date filtering
            ResultSet rs = pstmt.executeQuery();

            // Step 3: Iterate through results and create expense maps
            while (rs.next()) {
                Map<String, Object> expense = new HashMap<>();
                expense.put("expenseID", rs.getInt("expenseID"));
                expense.put("studentID", rs.getInt("studentID"));
                expense.put("categoryID", rs.getInt("categoryID"));
                expense.put("expenseAmount", rs.getDouble("expenseAmount"));
                expense.put("expenseDesc", rs.getString("expenseDesc"));
                expense.put("expenseDate", rs.getDate("expenseDate").toLocalDate());
                expense.put("categoryName", rs.getString("categoryName"));
                
                expenses.add(expense);
            }
            
            return expenses;
            
        } catch (SQLException e) {
            System.err.println("Error retrieving expenses: " + e.getMessage());
            e.printStackTrace();
            return expenses;
        }
    }

    /**
     * Get all expenses for a student
     * 
     * @param studentID Student to retrieve expenses for
     * @return ArrayList of all expense maps
     */
    public static List<Map<String, Object>> getAllExpensesByStudent(int studentID) {
        String sql = "SELECT e.expenseID, e.studentID, e.categoryID, e.expenseAmount, " +
                    "e.expenseDesc, e.expenseDate, c.categoryName FROM expense e " +
                    "JOIN category c ON e.categoryID = c.categoryID " +
                    "WHERE e.studentID = ? ORDER BY e.expenseDate DESC";

        List<Map<String, Object>> expenses = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameter
            pstmt.setInt(1, studentID);

            // Step 2: Execute SELECT query
            ResultSet rs = pstmt.executeQuery();

            // Step 3: Iterate through results
            while (rs.next()) {
                Map<String, Object> expense = new HashMap<>();
                expense.put("expenseID", rs.getInt("expenseID"));
                expense.put("studentID", rs.getInt("studentID"));
                expense.put("categoryID", rs.getInt("categoryID"));
                expense.put("expenseAmount", rs.getDouble("expenseAmount"));
                expense.put("expenseDesc", rs.getString("expenseDesc"));
                expense.put("expenseDate", rs.getDate("expenseDate").toLocalDate());
                expense.put("categoryName", rs.getString("categoryName"));
                
                expenses.add(expense);
            }
            
            return expenses;
            
        } catch (SQLException e) {
            System.err.println("Error retrieving all expenses: " + e.getMessage());
            e.printStackTrace();
            return expenses;
        }
    }

    /**
     * Calculate total expenses for a student in a month
     * 
     * @param studentID Student to calculate for
     * @param month Month value
     * @param year Year value
     * @return Total expense amount
     */
    public static double getTotalExpenseForMonth(int studentID, int month, int year) {
        String sql = "SELECT SUM(expenseAmount) as total FROM expense " +
                    "WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            // Step 1: Set parameters
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month);
            pstmt.setInt(3, year);

            // Step 2: Execute aggregation query
            ResultSet rs = pstmt.executeQuery();

            // Step 3: Get result
            if (rs.next()) {
                return rs.getDouble("total");
            }
            
            return 0.0;
            
        } catch (SQLException e) {
            System.err.println("Error calculating total expense: " + e.getMessage());
            e.printStackTrace();
            return 0.0;
        }
    }

    /**
     * Check if expense belongs to student (ownership verification)
     * Used for security checks before modifying expense
     * 
     * @param expenseID Expense ID to verify
     * @param studentID Student ID to check
     * @return true if expense belongs to student, false otherwise
     */
    public static boolean belongsToStudent(int expenseID, int studentID) {
        String sql = "SELECT studentID FROM expense WHERE expenseID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, expenseID);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("studentID") == studentID;
            }
            
            return false;
            
        } catch (SQLException e) {
            System.err.println("Error verifying expense ownership: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}
