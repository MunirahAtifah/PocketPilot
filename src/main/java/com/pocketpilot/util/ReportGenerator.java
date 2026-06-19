package com.pocketpilot.util;

import javax.servlet.http.HttpServletResponse;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

/**
 * ReportGenerator - Unified report generation engine
 * 
 * Purpose: Consolidate all financial tracking and report generation logic
 * Merges TrackingProgressCalculator + PDFReportGenerator for cleaner architecture
 * 
 * Features:
 *   - Calculate financial metrics
 *   - Generate AI guidance
 *   - Identify spending trends
 *   - Export to PDF
 *   - Create visual summaries
 * 
 * Responsibilities:
 *   1. Calculate budget vs expense analysis
 *   2. Detect surplus/deficit situations
 *   3. Generate actionable AI guidance
 *   4. Create PDF reports
 *   5. Identify top spending categories
 *   6. Compare month-over-month trends
 * 
 * Usage:
 *   ReportData report = ReportGenerator.generateReport(studentID, month, budgets, expenses);
 *   ReportGenerator.exportPDF(response, studentName, report);
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class ReportGenerator {

    /**
     * Container class for complete report data
     * Holds all calculated metrics and analysis for a financial period
     */
    public static class ReportData {
        public double totalBudget;
        public double totalExpense;
        public double averageExpense;
        public double surplusDeficit;
        public String surplusStatus;           // "surplus", "deficit", "balanced"
        public double budgetUtilization;
        public String aiGuidance;
        public Map<String, Double> topCategories;
        public Map<String, String> spendingTrend;
        public List<Map<String, Object>> budgets;
        public List<Map<String, Object>> expenses;

        @Override
        public String toString() {
            return "ReportData{" +
                    "totalBudget=" + totalBudget +
                    ", totalExpense=" + totalExpense +
                    ", surplusStatus='" + surplusStatus + '\'' +
                    ", budgetUtilization=" + budgetUtilization +
                    '}';
        }
    }

    /**
     * Generate complete financial report for a student and month
     * Consolidates all financial calculations into single ReportData object
     * 
     * @param studentID Student to generate report for
     * @param month YearMonth for the report
     * @param budgets List of budget entries
     * @param expenses List of expense entries
     * @param previousMonthExpenses List of previous month expenses (for trend analysis)
     * @return ReportData object with all calculations
     */
    public static ReportData generateReport(int studentID, YearMonth month,
                                           List<Map<String, Object>> budgets,
                                           List<Map<String, Object>> expenses,
                                           List<Map<String, Object>> previousMonthExpenses) {
        
        ReportData report = new ReportData();

        // ================================================
        // Step 1: Calculate total budget and expense
        // ================================================
        report.totalBudget = calculateTotalBudget(studentID, month, budgets);
        report.totalExpense = calculateTotalExpense(studentID, month, expenses);

        // ================================================
        // Step 2: Calculate average daily expense
        // ================================================
        Set<LocalDate> daysWithExpenses = new HashSet<>();
        for (Map<String, Object> expense : expenses) {
            LocalDate expenseDate = (LocalDate) expense.get("expenseDate");
            if (expenseDate.getYear() == month.getYear() && 
                expenseDate.getMonthValue() == month.getMonthValue()) {
                daysWithExpenses.add(expenseDate);
            }
        }
        
        report.averageExpense = calculateAverageDailyExpense(report.totalExpense, daysWithExpenses.size());

        // ================================================
        // Step 3: Calculate surplus/deficit
        // ================================================
        report.surplusDeficit = calculateSurplusDeficit(report.totalBudget, report.totalExpense);
        report.surplusStatus = determineSurplusStatus(report.surplusDeficit);
        report.budgetUtilization = calculateBudgetUtilization(report.totalExpense, report.totalBudget);

        // ================================================
        // Step 4: Generate AI guidance using AIService
        // ================================================
        report.aiGuidance = AIService.generateAIGuidance(
            report.surplusStatus, report.budgetUtilization, 
            report.averageExpense, report.totalBudget, report.surplusDeficit,
            calculateSpendingTrend(report.totalExpense, calculateTotalExpense(studentID, month.minusMonths(1), previousMonthExpenses)),
            getTopSpendingCategories(expenses, month)
        );

        // ================================================
        // Step 5: Get top spending categories
        // ================================================
        report.topCategories = getTopSpendingCategories(expenses, month);

        // ================================================
        // Step 6: Calculate spending trend
        // ================================================
        double previousMonthTotal = calculateTotalExpense(studentID, month.minusMonths(1), previousMonthExpenses);
        report.spendingTrend = calculateSpendingTrend(report.totalExpense, previousMonthTotal);

        // ================================================
        // Step 7: Store budget and expense lists
        // ================================================
        report.budgets = filterByMonth(budgets, month);
        report.expenses = filterByMonth(expenses, month);

        return report;
    }

    public static boolean exportReportAsPDF(HttpServletResponse response, String studentName,
                                            YearMonth reportMonth, ReportData report, String role) {
        return PDFReportGenerator.generateTrackingProgressReport(
            response,
            studentName,
            reportMonth,
            report.totalBudget,
            report.totalExpense,
            report.averageExpense,
            report.surplusDeficit,
            report.budgetUtilization,
            report.surplusStatus,
            report.aiGuidance,
            report.budgets,
            report.expenses,
            report.topCategories,
            role
        );
    }

    /**
     * Calculate total budget for the month
     */
    private static double calculateTotalBudget(int studentID, YearMonth month, 
                                               List<Map<String, Object>> budgets) {
        double total = 0.0;

        for (Map<String, Object> budget : budgets) {
            LocalDate budgetDate = (LocalDate) budget.get("budgetDate");
            
            if (budgetDate.getYear() == month.getYear() && 
                budgetDate.getMonthValue() == month.getMonthValue()) {
                total += (double) budget.get("budgetAmount");
            }
        }

        return total;
    }

    /**
     * Calculate total expense for the month
     */
    private static double calculateTotalExpense(int studentID, YearMonth month,
                                               List<Map<String, Object>> expenses) {
        double total = 0.0;

        for (Map<String, Object> expense : expenses) {
            LocalDate expenseDate = (LocalDate) expense.get("expenseDate");
            
            if (expenseDate.getYear() == month.getYear() && 
                expenseDate.getMonthValue() == month.getMonthValue()) {
                total += (double) expense.get("expenseAmount");
            }
        }

        return total;
    }

    /**
     * Calculate average daily expense
     */
    private static double calculateAverageDailyExpense(double totalExpense, int daysWithExpenses) {
        if (daysWithExpenses == 0) {
            return 0.0;
        }
        return totalExpense / daysWithExpenses;
    }

    /**
     * Calculate surplus or deficit
     */
    private static double calculateSurplusDeficit(double totalBudget, double totalExpense) {
        return totalBudget - totalExpense;
    }

    /**
     * Determine surplus status
     */
    private static String determineSurplusStatus(double surplusDeficit) {
        if (surplusDeficit > 10.0) {
            return "surplus";
        } else if (surplusDeficit < -10.0) {
            return "deficit";
        } else {
            return "balanced";
        }
    }

    /**
     * Calculate budget utilization percentage
     */
    private static double calculateBudgetUtilization(double totalExpense, double totalBudget) {
        if (totalBudget == 0) {
            return 0.0;
        }
        return (totalExpense / totalBudget) * 100.0;
    }


    /**
     * Get top spending categories
     */
    private static Map<String, Double> getTopSpendingCategories(List<Map<String, Object>> expenses, YearMonth month) {
        Map<String, Double> categoryTotals = new LinkedHashMap<>();

        for (Map<String, Object> expense : expenses) {
            LocalDate expenseDate = (LocalDate) expense.get("expenseDate");
            
            if (expenseDate.getYear() == month.getYear() && 
                expenseDate.getMonthValue() == month.getMonthValue()) {
                
                String categoryName = (String) expense.get("categoryName");
                double amount = (double) expense.get("expenseAmount");
                
                categoryTotals.put(categoryName, 
                    categoryTotals.getOrDefault(categoryName, 0.0) + amount);
            }
        }

        // Sort and limit to top 5
        return categoryTotals.entrySet()
            .stream()
            .sorted((a, b) -> Double.compare(b.getValue(), a.getValue()))
            .limit(5)
            .collect(LinkedHashMap::new,
                    (m, e) -> m.put(e.getKey(), e.getValue()),
                    Map::putAll);
    }

    /**
     * Calculate spending trend
     */
    private static Map<String, String> calculateSpendingTrend(double currentMonthTotal, double previousMonthTotal) {
        Map<String, String> trend = new HashMap<>();

        if (previousMonthTotal == 0) {
            trend.put("trend", "No previous data");
            trend.put("percentage", "N/A");
            return trend;
        }

        double percentChange = ((currentMonthTotal - previousMonthTotal) / previousMonthTotal) * 100;

        if (percentChange > 10) {
            trend.put("trend", "Spending INCREASED");
        } else if (percentChange < -10) {
            trend.put("trend", "Spending DECREASED");
        } else {
            trend.put("trend", "Spending STABLE");
        }

        trend.put("percentage", String.format("%.1f%%", Math.abs(percentChange)));

        return trend;
    }

    /**
     * Filter entries by month
     */
    private static List<Map<String, Object>> filterByMonth(List<Map<String, Object>> entries, YearMonth month) {
        List<Map<String, Object>> filtered = new ArrayList<>();

        for (Map<String, Object> entry : entries) {
            LocalDate date = (LocalDate) entry.get(
                entry.containsKey("budgetDate") ? "budgetDate" : "expenseDate"
            );
            
            if (date.getYear() == month.getYear() && 
                date.getMonthValue() == month.getMonthValue()) {
                filtered.add(entry);
            }
        }

        return filtered;
    }

    /**
     * Validate report data
     */
    public static boolean isValidReport(ReportData report) {
        return report != null &&
               report.totalBudget >= 0 &&
               report.totalExpense >= 0 &&
               report.surplusStatus != null &&
               !report.surplusStatus.isEmpty();
    }
}
