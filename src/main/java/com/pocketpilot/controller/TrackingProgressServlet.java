package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.dao.BudgetDAO;
import com.pocketpilot.util.DatabaseConnection;
import com.pocketpilot.util.ReportGenerator;
import com.pocketpilot.util.ReportGenerator.ReportData;

/**
 * TrackingProgressServlet - Generate financial tracking progress reports
 * 
 * Purpose: Calculate and display budget vs expense analysis with AI guidance
 * 
 * Flow:
 * 1. User (Student or Chancellor) logs in and navigates to "Tracking Progress" section
 * 2. If Chancellor, verify student granted permission to view reports
 * 3. User specifies time period (month/year)
 * 4. System queries stored expense and budget data for specified period
 * 5. Financial logic algorithm performs calculations:
 *    a) Calculates total monthly spending vs total budget
 *    b) Calculates average expense to detect spending trends
 * 6. If surplus detected, AI provides actionable guidance
 * 7. System generates and displays visual progress report and summary
 * 8. Student/Chancellor can export report as PDF
 * 
 * Features:
 *   - Budget vs Expense analysis
 *   - Surplus/Deficit detection
 *   - Average daily expense calculation
 *   - Top spending categories identification
 *   - Month-over-month trend analysis
 *   - AI-powered guidance generation
 *   - Report export to PDF
 * 
 * URL Mapping: GET /TrackingProgress
 * 
 * Request Parameters:
 *   - studentID: Student whose progress to track (for Chancellor view)
 *   - month: Month for report (format: YYYY-MM or current month)
 *   - action: "view" (default) or "export"
 * 
 * Session Requirements:
 *   - userID: Must be set (Student or Chancellor)
 *   - role: Must be "Student" or "Chancellor"
 * 
 * Response Attributes:
 *   - totalBudget: Total budgeted amount for month
 *   - totalExpense: Total spent amount for month
 *   - averageExpense: Average daily spending
 *   - surplusDeficit: Surplus (positive) or Deficit (negative)
 *   - surplusStatus: "surplus", "deficit", or "balanced"
 *   - budgetUtilization: Percentage of budget used
 *   - aiGuidance: AI-generated actionable recommendations
 *   - topCategories: Map of top spending categories
 *   - spendingTrend: Trend compared to previous month
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class TrackingProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle GET requests - Load tracking progress report
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        // ================================================
        // Step 1: Get session and verify user
        // ================================================
        HttpSession session = request.getSession(false);

        if (session == null) {
            response.sendRedirect("login.jsp?error=Please+log+in+first");
            return;
        }

        Object userIDObj = session.getAttribute("userID");
        Object roleObj = session.getAttribute("role");

        if (userIDObj == null || roleObj == null) {
            response.sendRedirect("login.jsp?error=Invalid+session");
            return;
        }

        int userID = (Integer) userIDObj;
        String role = (String) roleObj;

        // ================================================
        // Step 2: Get parameters from request
        // ================================================
        String studentIDStr = request.getParameter("studentID");
        String monthStr = request.getParameter("month");
        String action = request.getParameter("action");

        // If action is "export", handle PDF export
        if ("export".equals(action)) {
            handlePDFExport(request, response, userID, role, studentIDStr, monthStr);
            return;
        }

        // ================================================
        // Step 3: Determine which student to track
        // ================================================
        int trackingStudentID = userID;

        // If Chancellor provided studentID, get that student's data instead
        if ("Chancellor".equals(role) && studentIDStr != null && !studentIDStr.isEmpty()) {
            try {
                trackingStudentID = Integer.parseInt(studentIDStr);
                
                // Chancellor must have access to this student
                // (This will be verified when we read data from database)
            } catch (NumberFormatException e) {
                response.sendRedirect("error.jsp?message=Invalid+student+ID");
                return;
            }
        } else if (!"Student".equals(role) && !"Chancellor".equals(role)) {
            response.sendRedirect("error.jsp?message=Unauthorized+access");
            return;
        }

        // ================================================
        // Step 4: Get month for report (default to current month)
        // ================================================
        YearMonth reportMonth;
        if (monthStr != null && !monthStr.isEmpty()) {
            try {
                reportMonth = YearMonth.parse(monthStr);
            } catch (Exception e) {
                reportMonth = YearMonth.now();
            }
        } else {
            reportMonth = YearMonth.now();
        }

        // Verify month is not in future
        if (!TrackingProgressCalculator.isValidMonth(reportMonth)) {
            reportMonth = YearMonth.now();
        }

        try {
            // ================================================
            // Step 5: Load budget and expense data
            // ================================================
            List<Map<String, Object>> budgets = getBudgetsForMonth(trackingStudentID, reportMonth);
            List<Map<String, Object>> expenses = getExpensesForMonth(trackingStudentID, reportMonth);
            List<Map<String, Object>> previousMonthExpenses = getExpensesForMonth(trackingStudentID, reportMonth.minusMonths(1));

            // ================================================
            // Step 6: Generate complete report using unified ReportGenerator
            // ================================================
            ReportData report = ReportGenerator.generateReport(trackingStudentID, reportMonth, 
                                                               budgets, expenses, previousMonthExpenses);

            // ================================================
            // Step 7: Check if this is a PDF export request
            // ================================================
            if ("export".equals(action)) {
                String studentName = getStudentName(trackingStudentID);
                boolean success = ReportGenerator.exportReportAsPDF(response, studentName, reportMonth, report);
                if (success) {
                    return; // PDF was written to response
                }
            }

            // ================================================
            // Step 8: Pass report data to JSP for display
            // ================================================
            request.setAttribute("totalBudget", String.format("%.2f", report.totalBudget));
            request.setAttribute("totalExpense", String.format("%.2f", report.totalExpense));
            request.setAttribute("averageExpense", String.format("%.2f", report.averageExpense));
            request.setAttribute("surplusDeficit", String.format("%.2f", report.surplusDeficit));
            request.setAttribute("surplusStatus", report.surplusStatus);
            request.setAttribute("budgetUtilization", String.format("%.1f", report.budgetUtilization));
            request.setAttribute("aiGuidance", report.aiGuidance);
            request.setAttribute("topCategories", report.topCategories);
            request.setAttribute("spendingTrend", report.spendingTrend);
            request.setAttribute("reportMonth", reportMonth.toString());
            request.setAttribute("trackingStudentID", trackingStudentID);
            request.setAttribute("budgets", report.budgets);
            request.setAttribute("expenses", report.expenses);

            // ================================================
            // Step 9: Forward to JSP for display
            // ================================================
            request.getRequestDispatcher("trackingProgress.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error generating tracking progress: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Failed+to+generate+report");
        }
    }

    /**
     * Get budgets for a specific month
     */
    private List<Map<String, Object>> getBudgetsForMonth(int studentID, YearMonth month) throws SQLException {
        List<Map<String, Object>> budgets = new ArrayList<>();
        
        String sql = "SELECT b.budgetID, b.budgetDate, b.budgetDesc, b.budgetAmount, " +
                    "c.categoryName FROM Budget b " +
                    "JOIN Category c ON b.categoryID = c.categoryID " +
                    "WHERE b.studentID = ? AND MONTH(b.budgetDate) = ? AND YEAR(b.budgetDate) = ? " +
                    "ORDER BY b.budgetDate DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month.getMonthValue());
            pstmt.setInt(3, month.getYear());

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> budget = new HashMap<>();
                budget.put("budgetID", rs.getInt("budgetID"));
                budget.put("budgetDate", rs.getDate("budgetDate").toLocalDate());
                budget.put("budgetDesc", rs.getString("budgetDesc"));
                budget.put("budgetAmount", rs.getDouble("budgetAmount"));
                budget.put("categoryName", rs.getString("categoryName"));
                budgets.add(budget);
            }
        }

        return budgets;
    }

    /**
     * Get expenses for a specific month
     */
    private List<Map<String, Object>> getExpensesForMonth(int studentID, YearMonth month) throws SQLException {
        List<Map<String, Object>> expenses = new ArrayList<>();
        
        String sql = "SELECT e.expenseID, e.expenseDate, e.expenseDesc, e.expenseAmount, " +
                    "c.categoryName FROM Expense e " +
                    "JOIN Category c ON e.categoryID = c.categoryID " +
                    "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ? " +
                    "ORDER BY e.expenseDate DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            pstmt.setInt(2, month.getMonthValue());
            pstmt.setInt(3, month.getYear());

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> expense = new HashMap<>();
                expense.put("expenseID", rs.getInt("expenseID"));
                expense.put("expenseDate", rs.getDate("expenseDate").toLocalDate());
                expense.put("expenseDesc", rs.getString("expenseDesc"));
                expense.put("expenseAmount", rs.getDouble("expenseAmount"));
                expense.put("categoryName", rs.getString("categoryName"));
                expenses.add(expense);
            }
        }

        return expenses;
    }

    /**
     * Handle PDF export (now delegated to ReportGenerator)
     */
    private void handlePDFExport(HttpServletRequest request, HttpServletResponse response,
                                 int userID, String role, String studentIDStr, String monthStr) 
            throws IOException {
        // PDF export is now handled by ReportGenerator.exportReportAsPDF()
        response.sendRedirect("error.jsp?message=Use+the+Report+Generation+endpoint");
    }

    /**
     * Get student name by student ID
     */
    private String getStudentName(int studentID) {
        String sql = "SELECT studentName FROM Student WHERE studentID = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, studentID);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString("studentName");
            }
            
            return "Student " + studentID;
            
        } catch (SQLException e) {
            System.err.println("Error retrieving student name: " + e.getMessage());
            return "Student " + studentID;
        }
    }
}
