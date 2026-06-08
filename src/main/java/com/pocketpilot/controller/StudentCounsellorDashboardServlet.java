package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.annotation.WebServlet;

import com.pocketpilot.dao.StudentCounsellorDAO;
import com.pocketpilot.model.StudentCounsellorAccess;

/**
 * StudentCounsellorDashboardServlet - Handle Student Counsellor Dashboard
 * 
 * Purpose: Load and manage student approval requests for counsellors
 * 
 * Features:
 *   - Get list of pending/approved/disapproved students
 *   - Approve/disapprove student requests
 *   - Provide JSON responses for AJAX requests
 * 
 * URL Mapping: /StudentCounsellorDashboard
 */
@WebServlet("/StudentCounsellorDashboard")
public class StudentCounsellorDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    /**
     * Handle GET requests - Load dashboard data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Student_Counsellor".equals(role)) {
            response.sendRedirect("login.jsp?error=Unauthorized+access");
            return;
        }

        try {
            Integer userID = (Integer) session.getAttribute("userID");
            Integer staffID = StudentCounsellorDAO.getStaffIDByUserID(userID);

            if (staffID != null) {
                List<StudentCounsellorAccess> approvalRequests = 
                    StudentCounsellorDAO.getPendingApprovalsForCounsellor(staffID);
                request.setAttribute("approvalRequests", approvalRequests);
            }

            request.getRequestDispatcher("studentCounsellorDashboard.jsp").forward(request, response);

        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("studentCounsellorDashboard.jsp?error=Database+error");
        }
    }

    /**
     * Handle POST requests - Approve/disapprove students
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            sendJSONError(response, "Unauthorized");
            return;
        }

        String role = (String) session.getAttribute("role");
        if (!"Student_Counsellor".equals(role)) {
            sendJSONError(response, "Unauthorized");
            return;
        }

        String action = request.getParameter("action");
        String studentIDParam = request.getParameter("studentID");

        if (action == null || studentIDParam == null) {
            sendJSONError(response, "Missing parameters");
            return;
        }

        try {
            int studentID = Integer.parseInt(studentIDParam);
            Integer userID = (Integer) session.getAttribute("userID");
            Integer staffID = StudentCounsellorDAO.getStaffIDByUserID(userID);

            if (staffID == null) {
                sendJSONError(response, "Counsellor not found");
                return;
            }

            // Get the access record for this student-counsellor pair
            List<StudentCounsellorAccess> accesses = 
                StudentCounsellorDAO.getPendingApprovalsForCounsellor(staffID);
            
            int accessID = -1;
            for (StudentCounsellorAccess access : accesses) {
                if (access.getStudentID() == studentID) {
                    accessID = access.getAccessID();
                    break;
                }
            }

            if (accessID <= 0) {
                sendJSONError(response, "Access record not found");
                return;
            }

            boolean success = false;
            String message = "";

            if ("approveStudent".equals(action)) {
                success = StudentCounsellorDAO.approveStudent(accessID);
                message = success ? "Student approved" : "Failed to approve student";
            } else if ("disapproveStudent".equals(action)) {
                success = StudentCounsellorDAO.disapproveStudent(accessID);
                message = success ? "Student disapproved" : "Failed to disapprove student";
            } else {
                sendJSONError(response, "Invalid action");
                return;
            }

            sendJSONResponse(response, success, message);

        } catch (NumberFormatException e) {
            sendJSONError(response, "Invalid student ID");
        } catch (SQLException e) {
            System.err.println("Database error: " + e.getMessage());
            e.printStackTrace();
            sendJSONError(response, "Database error");
        }
    }

    /**
     * Send JSON success response
     */
    private void sendJSONResponse(HttpServletResponse response, boolean success, String message) 
            throws IOException {
        String json = "{\"success\":" + success + ",\"message\":\"" + message + "\"}";
        response.getWriter().write(json);
    }

    /**
     * Send JSON error response
     */
    private void sendJSONError(HttpServletResponse response, String message) throws IOException {
        String json = "{\"success\":false,\"message\":\"" + message + "\"}";
        response.getWriter().write(json);
    }
}
