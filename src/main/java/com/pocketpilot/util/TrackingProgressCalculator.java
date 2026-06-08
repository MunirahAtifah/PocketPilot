package com.pocketpilot.util;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

/**
 * TrackingProgressCalculator - Financial analysis and progress tracking engine
 * 
 * Purpose: Perform financial calculations and generate AI guidance for budget tracking
 * 
 * Features:
 *   - Calculate total monthly spending vs budget
 *   - Calculate average daily/category expenses
 *   - Detect surplus and deficit situations
 *   - Generate actionable AI guidance
 *   - Identify spending trends
 * 
 * Calculations:
 *   1. Total Budget: Sum of all budgets for the month
 *   2. Total Expense: Sum of all expenses for the month
 *   3. Average Expense: Total Expense / Number of days with expenses
 *   4. Variance: Total Budget - Total Expense (surplus if positive, deficit if negative)
 *   5. Budget Utilization: (Total Expense / Total Budget) * 100%
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class TrackingProgressCalculator {

    /**
     * Calculate total budget amount for a specific month and student
     * 
     * @param studentID Student to calculate for
     * @param month YearMonth object representing the month
     * @param budgets List of budget objects for the student
     * @return Total budget amount for the month
     */
    public static double calculateTotalBudget(int studentID, YearMonth month, List<Map<String, Object>> budgets) {
        double total = 0.0;

        // Step 1: Iterate through budget list
        for (Map<String, Object> budget : budgets) {
            // Step 2: Check if budget date matches the requested month
            LocalDate budgetDate = (LocalDate) budget.get("budgetDate");
            
            if (budgetDate.getYear() == month.getYear() && 
                budgetDate.getMonthValue() == month.getMonthValue()) {
                
                // Step 3: Add budget amount to total
                double amount = (double) budget.get("budgetAmount");
                total += amount;
            }
        }

        return total;
    }

    /**
     * Calculate total expense amount for a specific month and student
     * 
     * @param studentID Student to calculate for
     * @param month YearMonth object representing the month
     * @param expenses List of expense objects for the student
     * @return Total expense amount for the month
     */
    public static double calculateTotalExpense(int studentID, YearMonth month, List<Map<String, Object>> expenses) {
        double total = 0.0;

        // Step 1: Iterate through expense list
        for (Map<String, Object> expense : expenses) {
            // Step 2: Check if expense date matches the requested month
            LocalDate expenseDate = (LocalDate) expense.get("expenseDate");
            
            if (expenseDate.getYear() == month.getYear() && 
                expenseDate.getMonthValue() == month.getMonthValue()) {
                
                // Step 3: Add expense amount to total
                double amount = (double) expense.get("expenseAmount");
                total += amount;
            }
        }

        return total;
    }

    /**
     * Calculate average daily expense for the month
     * 
     * @param totalExpense Total expense for the month
     * @param daysWithExpenses Number of days with at least one expense
     * @return Average expense per day
     */
    public static double calculateAverageDailyExpense(double totalExpense, int daysWithExpenses) {
        // Step 1: Validate input to avoid division by zero
        if (daysWithExpenses == 0) {
            return 0.0;
        }

        // Step 2: Calculate and return average
        return totalExpense / daysWithExpenses;
    }

    /**
     * Calculate surplus or deficit for the month
     * Positive = Surplus (under budget)
     * Negative = Deficit (over budget)
     * 
     * @param totalBudget Total budget for the month
     * @param totalExpense Total expense for the month
     * @return Surplus/Deficit amount
     */
    public static double calculateSurplusDeficit(double totalBudget, double totalExpense) {
        // Step 1: Calculate variance
        double variance = totalBudget - totalExpense;

        return variance;
    }

    /**
     * Determine surplus status (surplus, deficit, or balanced)
     * 
     * @param surplusDeficit Surplus/deficit amount
     * @return "surplus", "deficit", or "balanced"
     */
    public static String determineSurplusStatus(double surplusDeficit) {
        // Step 1: Check for surplus (over budget remaining)
        if (surplusDeficit > 10.0) {
            return "surplus";
        }
        
        // Step 2: Check for deficit (exceeded budget)
        if (surplusDeficit < -10.0) {
            return "deficit";
        }
        
        // Step 3: Default to balanced
        return "balanced";
    }

    /**
     * Calculate budget utilization percentage
     * Shows how much of the budget has been used
     * 
     * @param totalExpense Total expense for the month
     * @param totalBudget Total budget for the month
     * @return Percentage of budget used (0-100+)
     */
    public static double calculateBudgetUtilization(double totalExpense, double totalBudget) {
        // Step 1: Validate input to avoid division by zero
        if (totalBudget == 0) {
            return 0.0;
        }

        // Step 2: Calculate percentage
        return (totalExpense / totalBudget) * 100.0;
    }

    /**
     * Generate AI guidance based on financial status
     * Delegates to AIService for unified AI logic
     * 
     * @param surplusStatus Status string ("surplus", "deficit", "balanced")
     * @param budgetUtilization Budget utilization percentage
     * @param averageDailyExpense Average daily expense amount
     * @param totalBudget Total budget for month
     * @param surplusDeficitAmount Surplus or deficit amount
     * @return AI guidance message for student
     * @deprecated Use AIService.generateAIGuidance() instead
     */
    public static String generateAIGuidance(String surplusStatus, double budgetUtilization, 
                                          double averageDailyExpense, double totalBudget, 
                                          double surplusDeficitAmount) {
        // Delegate to AIService for unified AI logic
        return AIService.generateRuleBasedGuidance(surplusStatus, budgetUtilization, 
                                                 averageDailyExpense, totalBudget, 
                                                 surplusDeficitAmount);
    }

    /**
     * Identify top spending categories for the month
     * Helps identify where most money is being spent
     * 
     * @param expenses List of expense objects
     * @param month YearMonth for filtering
     * @return Map of category names to total spending amounts
     */
    public static Map<String, Double> getTopSpendingCategories(List<Map<String, Object>> expenses, YearMonth month) {
        Map<String, Double> categoryTotals = new LinkedHashMap<>();

        // Step 1: Iterate through expenses and sum by category
        for (Map<String, Object> expense : expenses) {
            LocalDate expenseDate = (LocalDate) expense.get("expenseDate");
            
            // Step 2: Filter by month
            if (expenseDate.getYear() == month.getYear() && 
                expenseDate.getMonthValue() == month.getMonthValue()) {
                
                // Step 3: Get category name and add to map
                String categoryName = (String) expense.get("categoryName");
                double amount = (double) expense.get("expenseAmount");
                
                categoryTotals.put(categoryName, 
                    categoryTotals.getOrDefault(categoryName, 0.0) + amount);
            }
        }

        // Step 4: Sort by amount (highest first)
        return categoryTotals.entrySet()
            .stream()
            .sorted((a, b) -> Double.compare(b.getValue(), a.getValue()))
            .limit(5)  // Top 5 categories
            .collect(LinkedHashMap::new, 
                    (m, e) -> m.put(e.getKey(), e.getValue()), 
                    Map::putAll);
    }

    /**
     * Calculate spending trend (increasing or decreasing)
     * Compares current month to previous month
     * 
     * @param currentMonthTotal Current month's total expense
     * @param previousMonthTotal Previous month's total expense
     * @return Trend description and percentage change
     */
    public static Map<String, String> calculateSpendingTrend(double currentMonthTotal, double previousMonthTotal) {
        Map<String, String> trend = new HashMap<>();

        // Step 1: Avoid division by zero
        if (previousMonthTotal == 0) {
            trend.put("trend", "No previous data");
            trend.put("percentage", "N/A");
            return trend;
        }

        // Step 2: Calculate percentage change
        double percentChange = ((currentMonthTotal - previousMonthTotal) / previousMonthTotal) * 100;

        // Step 3: Determine trend direction
        if (percentChange > 10) {
            trend.put("trend", "📈 Spending INCREASED");
        } else if (percentChange < -10) {
            trend.put("trend", "📉 Spending DECREASED");
        } else {
            trend.put("trend", "➡ Spending STABLE");
        }

        // Step 4: Format and add percentage
        trend.put("percentage", String.format("%.1f%%", Math.abs(percentChange)));

        return trend;
    }

    /**
     * Validate month range (ensure month is not in future)
     * 
     * @param month YearMonth to validate
     * @return true if month is valid (not in future)
     */
    public static boolean isValidMonth(YearMonth month) {
        YearMonth currentMonth = YearMonth.now();
        return !month.isAfter(currentMonth);
    }
}
