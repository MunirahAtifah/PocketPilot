package com.pocketpilot.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.pocketpilot.dao.BudgetDAO;
import com.pocketpilot.dao.StudentDAO;

@WebServlet(name = "BudgetServlet", urlPatterns = "/BudgetServlet")
public class BudgetServlet extends HttpServlet {
    private BudgetDAO budgetDAO = new BudgetDAO();
    private StudentDAO studentDAO = new StudentDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        Integer userID = (Integer) session.getAttribute("userID");
        String role = (String) session.getAttribute("role");
        
        if (userID == null || !"Student".equals(role)) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        String action = request.getParameter("action");
        
        // If action not provided, infer from servlet path or form parameters
        if (action == null || action.isEmpty()) {
            String servletPath = request.getServletPath();
            if (servletPath.contains("UpdateBudgetServlet")) {
                action = "update";
            } else if (servletPath.contains("DeleteBudgetServlet")) {
                action = "delete";
            } else {
                // Check form parameters to distinguish update from add
                if (request.getParameter("budgetID") != null && !request.getParameter("budgetID").isEmpty()) {
                    action = "update";
                } else {
                    action = "add"; // default to add
                }
            }
        }
        
        try {
            if ("add".equalsIgnoreCase(action)) {
                handleAdd(request, response, userID);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdate(request, response, userID);
            } else if ("delete".equalsIgnoreCase(action)) {
                handleDelete(request, response, userID);
            } else {
                response.sendRedirect("budget.jsp?error=Invalid+action");
            }
        } catch (Exception e) {
            System.err.println("Error in BudgetServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("budget.jsp?error=Operation+failed");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            
            String categoryIDStr = request.getParameter("categoryID");
            String budgetAmountStr = request.getParameter("budgetAmount");
            String description = request.getParameter("budgetDesc");
            String month = request.getParameter("month");
            String year = request.getParameter("year");
            
            if (categoryIDStr == null || categoryIDStr.isEmpty() || 
                budgetAmountStr == null || budgetAmountStr.isEmpty() ||
                month == null || month.isEmpty() || year == null || year.isEmpty()) {
                response.sendRedirect("budget.jsp?error=Please+fill+all+fields");
                return;
            }
            
            int categoryID = Integer.parseInt(categoryIDStr);
            double budgetAmount = Double.parseDouble(budgetAmountStr);
            
            if (budgetAmount <= 0) {
                response.sendRedirect("budget.jsp?error=Budget+amount+must+be+greater+than+0");
                return;
            }
            
            String dateStr = year + "-" + month + "-01";
            LocalDate createdDate = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
            
            if (description == null || description.trim().isEmpty()) {
                description = "Budget for " + dateStr;
            }
            
            boolean success = budgetDAO.createBudget(studentID, categoryID, budgetAmount, 
                                                      description, createdDate);
            
            if (success) {
                response.sendRedirect("budget.jsp?success=Budget+created+successfully");
            } else {
                response.sendRedirect("budget.jsp?error=Failed+to+create+budget");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("budget.jsp?error=Invalid+input+format");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            
            String budgetIDStr = request.getParameter("budgetID");
            String categoryIDStr = request.getParameter("categoryID");
            String budgetAmountStr = request.getParameter("budgetAmount");
            String description = request.getParameter("budgetDesc");
            String month = request.getParameter("month");
            String year = request.getParameter("year");
            
            if (budgetIDStr == null || budgetIDStr.isEmpty() ||
                categoryIDStr == null || categoryIDStr.isEmpty() ||
                budgetAmountStr == null || budgetAmountStr.isEmpty() ||
                month == null || month.isEmpty() || year == null || year.isEmpty()) {
                response.sendRedirect("budget.jsp?error=Please+fill+all+fields");
                return;
            }
            
            int budgetID = Integer.parseInt(budgetIDStr);
            int categoryID = Integer.parseInt(categoryIDStr);
            double budgetAmount = Double.parseDouble(budgetAmountStr);
            
            if (budgetAmount <= 0) {
                response.sendRedirect("budget.jsp?error=Budget+amount+must+be+greater+than+0");
                return;
            }
            
            String dateStr = year + "-" + month + "-01";
            LocalDate createdDate = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
            
            if (description == null || description.trim().isEmpty()) {
                description = "Budget for " + dateStr;
            }
            
            boolean success = budgetDAO.updateBudget(budgetID, studentID, categoryID, 
                                                      budgetAmount, description, createdDate);
            
            if (success) {
                response.sendRedirect("budget.jsp?success=Budget+updated+successfully");
            } else {
                response.sendRedirect("budget.jsp?error=Failed+to+update+budget");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("budget.jsp?error=Invalid+input+format");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            String budgetIDStr = request.getParameter("budgetID");
            
            if (budgetIDStr == null || budgetIDStr.isEmpty()) {
                response.sendRedirect("budget.jsp?error=Budget+ID+is+required");
                return;
            }
            
            int budgetID = Integer.parseInt(budgetIDStr);
            
            boolean success = budgetDAO.deleteBudget(budgetID, studentID);
            
            if (success) {
                response.sendRedirect("budget.jsp?success=Budget+deleted+successfully");
            } else {
                response.sendRedirect("budget.jsp?error=Failed+to+delete+budget");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("budget.jsp?error=Invalid+budget+ID");
        }
    }
}
