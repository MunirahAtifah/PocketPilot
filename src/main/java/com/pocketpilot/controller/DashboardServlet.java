package com.pocketpilot.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * DashboardServlet - Handles Student Dashboard
 * 
 * This servlet manages the student dashboard page which displays:
 * - Monthly budget overview
 * - Expense tracking
 * - Financial statistics
 * - Chart data for visualizations
 * - AI-powered guidance
 */
@WebServlet("/DashboardServlet")
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * GET request handler - Load student dashboard
     * 
     * Retrieves user session information and loads dashboard data
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Validate session
        HttpSession session = request.getSession();
        Integer userID = (Integer) session.getAttribute("userID");
        String username = (String) session.getAttribute("username");
        String role = (String) session.getAttribute("role");

        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Validate user role (only Student can access)
        if (role == null || !role.equals("Student")) {
            response.sendRedirect("login.jsp");
            return;
        }

        // TODO: Load student dashboard data from database
        // - Fetch budgets for selected month
        // - Fetch expenses for selected month
        // - Calculate statistics
        // - Generate AI guidance
        // - Set request attributes for JSP

        // For now, forward to dashboard JSP
        request.getRequestDispatcher("dashboard.jsp").forward(request, response);
    }

    /**
     * POST request handler - Handle dashboard updates
     * 
     * May be used for month changes or other dashboard interactions
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
