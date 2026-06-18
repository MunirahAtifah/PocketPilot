package com.pocketpilot.controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import com.pocketpilot.dao.ExpenseDAO;
import com.pocketpilot.dao.UserDAO;

@WebServlet(name = "ExpenseServlet", urlPatterns = {"/ExpenseServlet", "/AddExpenseServlet", "/UpdateExpenseServlet", "/DeleteExpenseServlet"})
public class ExpenseServlet extends HttpServlet {
    private ExpenseDAO expenseDAO = new ExpenseDAO();
    private UserDAO userDAO = new UserDAO();

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
        if (action == null || action.isEmpty()) {
            String path = request.getServletPath();
            if (path.contains("UpdateExpenseServlet")) action = "update";
            else if (path.contains("DeleteExpenseServlet")) action = "delete";
            else action = (request.getParameter("expenseID") != null) ? "update" : "add";
        }
        
        try {
            int studentID = userDAO.getStudentIDByUserID(userID);
            
            if ("add".equalsIgnoreCase(action)) {
                handleAdd(request, response, studentID);
            } else if ("update".equalsIgnoreCase(action)) {
                handleUpdate(request, response, studentID);
            } else if ("delete".equalsIgnoreCase(action)) {
                handleDelete(request, response, studentID);
            } else {
                response.sendRedirect("expense.jsp?error=Invalid+action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("expense.jsp?error=Operation+failed");
        }
    }

    private void sendRedirect(HttpServletRequest request, HttpServletResponse response, String statusParam) throws IOException {
        String month = request.getParameter("month");
        String redirectUrl = "expense.jsp";
        if (month != null && !month.trim().isEmpty()) {
            redirectUrl += "?month=" + month + "&" + statusParam;
        } else {
            redirectUrl += "?" + statusParam;
        }
        response.sendRedirect(redirectUrl);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        int catID = Integer.parseInt(request.getParameter("categoryID"));
        double amt = Double.parseDouble(request.getParameter("expenseAmount"));
        String desc = request.getParameter("expenseDesc");
        LocalDate date = LocalDate.parse(request.getParameter("expenseDate"), DateTimeFormatter.ISO_LOCAL_DATE);
        
        boolean success = expenseDAO.createExpense(studentID, catID, amt, desc, date);
        sendRedirect(request, response, success ? "success=Added" : "error=Failed");
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        int id = Integer.parseInt(request.getParameter("expenseID"));
        int cat = Integer.parseInt(request.getParameter("categoryID"));
        double amt = Double.parseDouble(request.getParameter("expenseAmount"));
        String desc = request.getParameter("expenseDesc");
        LocalDate date = LocalDate.parse(request.getParameter("expenseDate"), DateTimeFormatter.ISO_LOCAL_DATE);
        
        boolean success = expenseDAO.updateExpense(id, studentID, cat, amt, desc, date);
        sendRedirect(request, response, success ? "success=Updated" : "error=Failed");
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        int id = Integer.parseInt(request.getParameter("expenseID"));
        boolean success = expenseDAO.deleteExpense(id, studentID);
        sendRedirect(request, response, success ? "success=Deleted" : "error=Failed");
    }
}