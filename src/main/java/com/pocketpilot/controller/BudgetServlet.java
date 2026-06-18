package com.pocketpilot.controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.*;
import java.time.LocalDate;
import com.pocketpilot.dao.BudgetDAO;
import com.pocketpilot.dao.UserDAO;
import com.pocketpilot.model.Budget;

@WebServlet(name = "BudgetServlet", urlPatterns = {"/BudgetServlet"})
public class BudgetServlet extends HttpServlet {
    private final BudgetDAO budgetDAO = new BudgetDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer userID = (session != null) ? (Integer) session.getAttribute("userID") : null;
        
        if (userID == null || !"Student".equals(session.getAttribute("role"))) {
            response.sendRedirect("login.jsp?error=Access+denied");
            return;
        }

        String action = request.getParameter("action");
        try {
            int studentID = userDAO.getStudentIDByUserID(userID);
            if (studentID == -1) {
                response.sendRedirect("budget.jsp?error=Student+not+found");
                return;
            }

            if ("add".equals(action)) handleAdd(request, response, studentID);
            else if ("update".equals(action)) handleUpdate(request, response, studentID);
            else if ("delete".equals(action)) handleDelete(request, response, studentID);
        } catch (Exception e) {
            response.sendRedirect("budget.jsp?error=Operation+failed");
        }
    }

    private void sendRedirect(HttpServletRequest request, HttpServletResponse response, String statusParam) throws IOException {
        String month = request.getParameter("month");
        String redirectUrl = "budget.jsp";
        if (month != null && !month.trim().isEmpty()) {
            redirectUrl += "?month=" + month + "&" + statusParam;
        } else {
            redirectUrl += "?" + statusParam;
        }
        response.sendRedirect(redirectUrl);
    }

    private void handleAdd(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        try {
            Budget b = new Budget();
            b.setStudentID(studentID);
            b.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
            b.setBudgetAmount(Double.parseDouble(request.getParameter("budgetAmount")));
            b.setBudgetDesc(request.getParameter("budgetDesc"));
            
            // Logic for YYYY-MM input
            String period = request.getParameter("budgetPeriod"); // "2026-06"
            String[] parts = period.split("-");
            b.setBudgetDate(LocalDate.of(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]), 1));
            
            if (budgetDAO.createBudget(b)) sendRedirect(request, response, "success=Created");
            else sendRedirect(request, response, "error=Failed");
        } catch (Exception e) { sendRedirect(request, response, "error=Invalid+input"); }
    }

    private void handleUpdate(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        try {
            Budget b = new Budget();
            b.setBudgetID(Integer.parseInt(request.getParameter("budgetID")));
            b.setStudentID(studentID);
            b.setCategoryID(Integer.parseInt(request.getParameter("categoryID")));
            b.setBudgetAmount(Double.parseDouble(request.getParameter("budgetAmount")));
            b.setBudgetDesc(request.getParameter("budgetDesc"));
            
            // Logic for YYYY-MM input
            String period = request.getParameter("budgetPeriod");
            String[] parts = period.split("-");
            b.setBudgetDate(LocalDate.of(Integer.parseInt(parts[0]), Integer.parseInt(parts[1]), 1));
            
            if (budgetDAO.updateBudget(b)) sendRedirect(request, response, "success=Updated");
            else sendRedirect(request, response, "error=Update+failed");
        } catch (Exception e) { sendRedirect(request, response, "error=Invalid+input"); }
    }

    private void handleDelete(HttpServletRequest request, HttpServletResponse response, int studentID) throws IOException {
        try {
            int budgetID = Integer.parseInt(request.getParameter("budgetID"));
            if (budgetDAO.deleteBudget(budgetID, studentID)) sendRedirect(request, response, "success=Deleted");
            else sendRedirect(request, response, "error=Delete+failed");
        } catch (Exception e) { sendRedirect(request, response, "error=Invalid+ID"); }
    }
}