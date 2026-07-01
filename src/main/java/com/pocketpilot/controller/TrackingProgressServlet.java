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
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.dao.BudgetDAO;
import com.pocketpilot.util.DatabaseConnection;
import com.pocketpilot.util.ReportGenerator;
import com.pocketpilot.util.ReportGenerator.ReportData;
import com.pocketpilot.util.TrackingProgressCalculator;
@WebServlet("/TrackingProgressServlet")
public class TrackingProgressServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Handle GET requests - Load tracking progress report
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");
        // Step 1: Get session and verify user
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
        // Step 2: Get parameters from request
        String studentIDStr = request.getParameter("studentID");
        String monthStr = request.getParameter("month");
        String action = request.getParameter("action");
        // Step 3: Determine which student to track
        int trackingStudentID = -1;

        if ("Student".equals(role)) {
            // Retrieve studentID from userID
            try (Connection conn = DatabaseConnection.getConnection();
                 PreparedStatement pstmt = conn.prepareStatement("SELECT studentID FROM student WHERE userID = ?")) {
                pstmt.setInt(1, userID);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        trackingStudentID = rs.getInt("studentID");
                    }
                }
            } catch (SQLException e) {
                System.err.println("Error mapping userID to studentID: " + e.getMessage());
            }
            if (trackingStudentID == -1) {
                response.sendRedirect("error.jsp?message=Student+profile+not+found");
                return;
            }
        } else if ("Parent".equals(role)) {
            if (studentIDStr != null && !studentIDStr.isEmpty()) {
                try {
                    trackingStudentID = Integer.parseInt(studentIDStr);
                } catch (NumberFormatException e) {
                    response.sendRedirect("error.jsp?message=Invalid+student+ID");
                    return;
                }
            } else {
                // Find parent's first approved child
                try (Connection conn = DatabaseConnection.getConnection();
                     PreparedStatement pstmt = conn.prepareStatement(
                         "SELECT sa.studentID FROM supervisionaccess sa " +
                         "JOIN parent p ON sa.parentID = p.parentID " +
                         "WHERE p.userID = ? AND sa.approvalStatus = 'Approved' " +
                         "ORDER BY sa.id LIMIT 1")) {
                    pstmt.setInt(1, userID);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            trackingStudentID = rs.getInt("studentID");
                        }
                    }
                } catch (SQLException e) {
                    System.err.println("Error finding parent child: " + e.getMessage());
                }
                if (trackingStudentID == -1) {
                    response.sendRedirect("supervisionAccess.jsp?error=Please+link+a+child+account+first+to+track+progress");
                    return;
                }
            }
        } else if ("Student_Counsellor".equals(role)) {
            if (studentIDStr != null && !studentIDStr.isEmpty()) {
                try {
                    trackingStudentID = Integer.parseInt(studentIDStr);
                } catch (NumberFormatException e) {
                    response.sendRedirect("StudentCounsellorDashboard?error=Invalid+student+ID");
                    return;
                }

                // Verify mutual student-counsellor approval connection status
                boolean hasAccess = false;
                try {
                    Integer staffID = com.pocketpilot.dao.StudentCounsellorDAO.getStaffIDByUserID(userID);
                    if (staffID != null) {
                        try (Connection conn = DatabaseConnection.getConnection();
                             PreparedStatement pstmt = conn.prepareStatement(
                                 "SELECT COUNT(*) FROM studentcounselloraccess " +
                                 "WHERE studentID = ? AND staffID = ? AND approvedByStudent = 1 AND accessStatus = 'Approved'")) {
                            pstmt.setInt(1, trackingStudentID);
                            pstmt.setInt(2, staffID);
                            try (ResultSet rs = pstmt.executeQuery()) {
                                if (rs.next() && rs.getInt(1) > 0) {
                                    hasAccess = true;
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                if (!hasAccess) {
                    response.sendRedirect("StudentCounsellorDashboard?error=Access+denied.+Mutual+approval+required.");
                    return;
                }
            } else {
                response.sendRedirect("StudentCounsellorDashboard?error=Please+select+a+student+first");
                return;
            }
        } else {
            response.sendRedirect("error.jsp?message=Unauthorized+access");
            return;
        }
        // Step 4: Get month for report (default to current month)
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
            // Step 5: Load budget and expense data
            List<Map<String, Object>> budgets = getBudgetsForMonth(trackingStudentID, reportMonth);
            List<Map<String, Object>> expenses = getExpensesForMonth(trackingStudentID, reportMonth);
            List<Map<String, Object>> previousMonthExpenses = getExpensesForMonth(trackingStudentID, reportMonth.minusMonths(1));
            // Step 6: Generate complete report using unified ReportGenerator
            ReportData report = ReportGenerator.generateReport(trackingStudentID, reportMonth, 
                                                               budgets, expenses, previousMonthExpenses);
            // Step 7: Check if this is a PDF export request
            if ("export".equals(action)) {
                String studentName = getStudentName(trackingStudentID);
                boolean success = ReportGenerator.exportReportAsPDF(response, studentName, reportMonth, report, role);
                if (success) {
                    return; // PDF was written to response
                }
            }
            // Step 8: Pass report data to JSP for display
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
            
            String msg = request.getParameter("msg");
            if (msg != null) {
                request.setAttribute("msg", msg);
            }
            // Step 9: Forward to JSP for display
            request.getRequestDispatcher("trackingProgress.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error generating tracking progress: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("error.jsp?message=Failed+to+generate+report");
        }
    }

    // Handle POST requests - Save comments on budget or expense
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        String role = (String) roleObj;
        if (!"Parent".equals(role) && !"Student_Counsellor".equals(role)) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        String action = request.getParameter("action");
        if ("updateComment".equals(action)) {
            String type = request.getParameter("type");
            String idStr = request.getParameter("id");
            String comment = request.getParameter("comment");
            String studentIDStr = request.getParameter("studentID");
            String monthStr = request.getParameter("month");

            if (type != null && idStr != null) {
                try (Connection conn = DatabaseConnection.getConnection()) {
                    String sql;
                    if ("budget".equals(type)) {
                        if ("Parent".equals(role)) {
                            sql = "UPDATE budget SET parentComment = ? WHERE budgetID = ?";
                        } else {
                            sql = "UPDATE budget SET counsellorComment = ? WHERE budgetID = ?";
                        }
                    } else {
                        if ("Parent".equals(role)) {
                            sql = "UPDATE expense SET parentComment = ? WHERE expenseID = ?";
                        } else {
                            sql = "UPDATE expense SET counsellorComment = ? WHERE expenseID = ?";
                        }
                    }
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        pstmt.setString(1, comment);
                        pstmt.setInt(2, Integer.parseInt(idStr));
                        pstmt.executeUpdate();
                    }
                } catch (SQLException e) {
                    System.err.println("Error updating comment: " + e.getMessage());
                    e.printStackTrace();
                }
            }

            // Redirect back to GET request
            String redirectUrl = "TrackingProgressServlet?studentID=" + studentIDStr + "&month=" + monthStr + "&msg=success";
            response.sendRedirect(redirectUrl);
        }
    }

    // Get budgets for a specific month
    private List<Map<String, Object>> getBudgetsForMonth(int studentID, YearMonth month) throws SQLException {
        List<Map<String, Object>> budgets = new ArrayList<>();
        
        String sql = "SELECT b.budgetID, b.budgetDate, b.budgetDesc, b.budgetAmount, b.comment, b.parentComment, b.counsellorComment, " +
                    "c.categoryName FROM budget b " +
                    "JOIN category c ON b.categoryID = c.categoryID " +
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
                budget.put("comment", rs.getString("comment"));
                budget.put("parentComment", rs.getString("parentComment"));
                budget.put("counsellorComment", rs.getString("counsellorComment"));
                budget.put("categoryName", rs.getString("categoryName"));
                budgets.add(budget);
            }
        }

        return budgets;
    }

    // Get expenses for a specific month
    private List<Map<String, Object>> getExpensesForMonth(int studentID, YearMonth month) throws SQLException {
        List<Map<String, Object>> expenses = new ArrayList<>();
        
        String sql = "SELECT e.expenseID, e.expenseDate, e.expenseDesc, e.expenseAmount, e.comment, e.parentComment, e.counsellorComment, " +
                    "c.categoryName FROM expense e " +
                    "JOIN category c ON e.categoryID = c.categoryID " +
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
                expense.put("comment", rs.getString("comment"));
                expense.put("parentComment", rs.getString("parentComment"));
                expense.put("counsellorComment", rs.getString("counsellorComment"));
                expense.put("categoryName", rs.getString("categoryName"));
                expenses.add(expense);
            }
        }

        return expenses;
    }

    // Handle PDF export (now delegated to ReportGenerator)
    private void handlePDFExport(HttpServletRequest request, HttpServletResponse response,
                                 int userID, String role, String studentIDStr, String monthStr) 
            throws IOException {
        // PDF export is now handled by ReportGenerator.exportReportAsPDF()
        response.sendRedirect("error.jsp?message=Use+the+Report+Generation+endpoint");
    }

    // Get student name by student ID
    private String getStudentName(int studentID) {
        String sql = "SELECT studentName FROM student WHERE studentID = ?";

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
