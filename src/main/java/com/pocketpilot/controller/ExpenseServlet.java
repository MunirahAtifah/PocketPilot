package com.pocketpilot.controller;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
import java.io.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.pocketpilot.dao.ExpenseDAO;
import com.pocketpilot.dao.StudentDAO;

@WebServlet(name = "ExpenseServlet", urlPatterns = "/ExpenseServlet")
public class ExpenseServlet extends HttpServlet {
    private ExpenseDAO expenseDAO = new ExpenseDAO();
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
            if (servletPath.contains("UpdateExpenseServlet")) {
                action = "update";
            } else if (servletPath.contains("DeleteExpenseServlet")) {
                action = "delete";
            } else {
                // Check form parameters to distinguish update from add
                if (request.getParameter("expenseID") != null && !request.getParameter("expenseID").isEmpty()) {
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
                response.sendRedirect("expense.jsp?error=Invalid+action");
            }
        } catch (Exception e) {
            System.err.println("Error in ExpenseServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("expense.jsp?error=Operation+failed");
        }
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            
            String categoryIDStr = request.getParameter("categoryID");
            String expenseAmountStr = request.getParameter("expenseAmount");
            String description = request.getParameter("expenseDesc");
            String dateStr = request.getParameter("expenseDate");
            
            if (categoryIDStr == null || categoryIDStr.isEmpty() || 
                expenseAmountStr == null || expenseAmountStr.isEmpty() ||
                dateStr == null || dateStr.isEmpty()) {
                response.sendRedirect("expense.jsp?error=Please+fill+all+required+fields");
                return;
            }
            
            int categoryID = Integer.parseInt(categoryIDStr);
            double expenseAmount = Double.parseDouble(expenseAmountStr);
            
            if (expenseAmount <= 0) {
                response.sendRedirect("expense.jsp?error=Expense+amount+must+be+greater+than+0");
                return;
            }
            
            LocalDate expenseDate = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
            
            if (description == null || description.trim().isEmpty()) {
                description = "Expense on " + dateStr;
            }
            
            boolean success = expenseDAO.createExpense(studentID, categoryID, expenseAmount, 
                                                       description, expenseDate);
            
            if (success) {
                response.sendRedirect("expense.jsp?success=Expense+created+successfully");
            } else {
                response.sendRedirect("expense.jsp?error=Failed+to+create+expense");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("expense.jsp?error=Invalid+input+format");
        }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            
            String expenseIDStr = request.getParameter("expenseID");
            String categoryIDStr = request.getParameter("categoryID");
            String expenseAmountStr = request.getParameter("expenseAmount");
            String description = request.getParameter("expenseDesc");
            String dateStr = request.getParameter("expenseDate");
            
            if (expenseIDStr == null || expenseIDStr.isEmpty() ||
                categoryIDStr == null || categoryIDStr.isEmpty() ||
                expenseAmountStr == null || expenseAmountStr.isEmpty() ||
                dateStr == null || dateStr.isEmpty()) {
                response.sendRedirect("expense.jsp?error=Please+fill+all+required+fields");
                return;
            }
            
            int expenseID = Integer.parseInt(expenseIDStr);
            int categoryID = Integer.parseInt(categoryIDStr);
            double expenseAmount = Double.parseDouble(expenseAmountStr);
            
            if (expenseAmount <= 0) {
                response.sendRedirect("expense.jsp?error=Expense+amount+must+be+greater+than+0");
                return;
            }
            
            LocalDate expenseDate = LocalDate.parse(dateStr, DateTimeFormatter.ISO_LOCAL_DATE);
            
            if (description == null || description.trim().isEmpty()) {
                description = "Expense on " + dateStr;
            }
            
            boolean success = expenseDAO.updateExpense(expenseID, studentID, categoryID, 
                                                       expenseAmount, description, expenseDate);
            
            if (success) {
                response.sendRedirect("expense.jsp?success=Expense+updated+successfully");
            } else {
                response.sendRedirect("expense.jsp?error=Failed+to+update+expense");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("expense.jsp?error=Invalid+input+format");
        }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, Integer userID) 
            throws ServletException, IOException {
        
        try {
            int studentID = studentDAO.getStudentIDByUserID(userID);
            String expenseIDStr = request.getParameter("expenseID");
            
            if (expenseIDStr == null || expenseIDStr.isEmpty()) {
                response.sendRedirect("expense.jsp?error=Expense+ID+is+required");
                return;
            }
            
            int expenseID = Integer.parseInt(expenseIDStr);
            
            boolean success = expenseDAO.deleteExpense(expenseID, studentID);
            
            if (success) {
                response.sendRedirect("expense.jsp?success=Expense+deleted+successfully");
            } else {
                response.sendRedirect("expense.jsp?error=Failed+to+delete+expense");
            }
            
        } catch (NumberFormatException e) {
            response.sendRedirect("expense.jsp?error=Invalid+expense+ID");
        }
    }
}
