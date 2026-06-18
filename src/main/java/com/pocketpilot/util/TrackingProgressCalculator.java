package com.pocketpilot.util;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

public class TrackingProgressCalculator {

    public static boolean isValidMonth(YearMonth month) {
        if (month == null) return false;
        // Example logic: valid if it is not in the future
        return !month.isAfter(YearMonth.now());
    }

    public static double calculateTotalBudget(int studentID, YearMonth month, List<Map<String, Object>> budgets) {
        return budgets.stream()
            .filter(b -> isSameMonth((LocalDate) b.get("budgetDate"), month))
            .mapToDouble(b -> (double) b.get("budgetAmount")).sum();
    }

    public static double calculateTotalExpense(int studentID, YearMonth month, List<Map<String, Object>> expenses) {
        return expenses.stream()
            .filter(e -> isSameMonth((LocalDate) e.get("expenseDate"), month))
            .mapToDouble(e -> (double) e.get("expenseAmount")).sum();
    }

    public static double calculateAverageDailyExpense(double total, int days) {
        return (days == 0) ? 0.0 : total / days;
    }

    public static double calculateSurplusDeficit(double budget, double expense) {
        return budget - expense;
    }

    public static String determineSurplusStatus(double sd) {
        return (sd > 10.0) ? "surplus" : (sd < -10.0) ? "deficit" : "balanced";
    }

    public static double calculateBudgetUtilization(double expense, double budget) {
        return (budget == 0) ? 0.0 : (expense / budget) * 100.0;
    }

    public static Map<String, Double> getTopSpendingCategories(List<Map<String, Object>> expenses, YearMonth month) {
        Map<String, Double> totals = new LinkedHashMap<>();
        expenses.stream().filter(e -> isSameMonth((LocalDate) e.get("expenseDate"), month)).forEach(e -> {
            String cat = (String) e.get("categoryName");
            totals.put(cat, totals.getOrDefault(cat, 0.0) + (double) e.get("expenseAmount"));
        });
        return totals;
    }

    public static Map<String, String> calculateSpendingTrend(double current, double previous) {
        Map<String, String> trend = new HashMap<>();
        if (previous == 0) {
            trend.put("trend", "No data"); trend.put("percentage", "N/A");
            return trend;
        }
        double change = ((current - previous) / previous) * 100;
        trend.put("trend", change > 10 ? "📈 Increase" : change < -10 ? "📉 Decrease" : "➡ Stable");
        trend.put("percentage", String.format("%.1f%%", Math.abs(change)));
        return trend;
    }

    private static boolean isSameMonth(LocalDate date, YearMonth month) {
        return date.getYear() == month.getYear() && date.getMonthValue() == month.getMonthValue();
    }
}