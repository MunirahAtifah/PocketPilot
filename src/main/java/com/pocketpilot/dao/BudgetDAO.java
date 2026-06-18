package com.pocketpilot.dao;

import java.sql.*;
import com.pocketpilot.model.Budget;
import com.pocketpilot.util.DatabaseConnection;

public class BudgetDAO {

    public boolean createBudget(Budget b) {
        String sql = "INSERT INTO budget (studentID, categoryID, budgetAmount, budgetDesc, budgetDate) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, b.getStudentID());
            stmt.setInt(2, b.getCategoryID());
            stmt.setDouble(3, b.getBudgetAmount());
            stmt.setString(4, b.getBudgetDesc());
            stmt.setDate(5, Date.valueOf(b.getBudgetDate()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean updateBudget(Budget b) {
        String sql = "UPDATE budget SET categoryID = ?, budgetAmount = ?, budgetDesc = ?, budgetDate = ? WHERE budgetID = ? AND studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, b.getCategoryID());
            stmt.setDouble(2, b.getBudgetAmount());
            stmt.setString(3, b.getBudgetDesc());
            stmt.setDate(4, Date.valueOf(b.getBudgetDate()));
            stmt.setInt(5, b.getBudgetID());
            stmt.setInt(6, b.getStudentID());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    public boolean deleteBudget(int budgetID, int studentID) {
        String sql = "DELETE FROM budget WHERE budgetID = ? AND studentID = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, budgetID);
            stmt.setInt(2, studentID);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { e.printStackTrace(); return false; }
    }

    // Method to get total budget for the month
    public double getTotalBudgetForMonth(int studentID, int month, int year) {
        String sql = "SELECT SUM(budgetAmount) FROM budget WHERE studentID = ? AND MONTH(budgetDate) = ? AND YEAR(budgetDate) = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, month);
            stmt.setInt(3, year);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    // Method to get total expenses for the month (Required for "Remaining" calculation)
    public double getTotalExpensesForMonth(int studentID, int month, int year) {
        String sql = "SELECT SUM(expenseAmount) FROM expense WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, month);
            stmt.setInt(3, year);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getDouble(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return 0.0;
    }

    // Method to get highest spending category for the month
    public String getHighestCategory(int studentID, int month, int year) {
        String sql = "SELECT c.categoryName FROM expense e JOIN category c ON e.categoryID = c.categoryID " +
                     "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ? " +
                     "GROUP BY c.categoryName ORDER BY SUM(e.expenseAmount) DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, month);
            stmt.setInt(3, year);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) { e.printStackTrace(); }
        return "-";
    }
}