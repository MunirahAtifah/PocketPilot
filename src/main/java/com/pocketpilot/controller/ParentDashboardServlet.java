package com.pocketpilot.controller;

import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 * ParentDashboardServlet - Handles Parent Dashboard
 * 
 * This servlet manages the parent dashboard which displays:
 * - Overview of all children's accounts
 * - Combined financial statistics
 * - Children's spending patterns
 * - Supervision management
 * - Alerts and notifications
 */
@WebServlet("/ParentDashboardServlet")
public class ParentDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * GET request handler - Load parent dashboard
     * 
     * Retrieves parent's user session and loads all children data
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

        // Validate user role (only Parent can access)
        if (role == null || !role.equals("Parent")) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get parameters
        String selectedStudentID = request.getParameter("studentID");
        String selectedMonth = request.getParameter("month");

        // TODO: Load parent dashboard data from database
        // 1. Fetch list of supervised children
        // 2. If student selected, fetch their budget/expense data
        // 3. Calculate combined statistics
        // 4. Identify alerts (overspending, etc)
        // 5. Set request attributes for JSP

        // For now, forward to parent dashboard JSP
        request.getRequestDispatcher("parentDashboard.jsp").forward(request, response);
    }

    /**
     * POST request handler - Handle parent dashboard updates
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
