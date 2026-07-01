package com.pocketpilot.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.util.DatabaseConnection;
import com.pocketpilot.dao.StudentCounsellorDAO;
@WebServlet("/StudentCounsellorDashboard")
public class StudentCounsellorDashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        Integer userID = (Integer) session.getAttribute("userID");
        String role = (String) session.getAttribute("role");

        // Only counsellors can access this page
        if (!"Student_Counsellor".equals(role)) {
            response.sendRedirect("login.jsp");
            return;
        }

        try {
            // Get counsellor staff ID
            Integer staffID = StudentCounsellorDAO.getStaffIDByUserID(userID);
            
            if (staffID == null) {
                response.sendRedirect("login.jsp");
                return;
            }

            // Get all students with their approval status
            List<Map<String, Object>> allStudents = getAllStudentsWithStatus(staffID);
            
            // Count statistics
            int pendingCount = 0;
            int approvedCount = 0;
            
            for (Map<String, Object> student : allStudents) {
                boolean isApprovedByStudent = (Boolean) student.get("approvedByStudent");
                String accessStatus = (String) student.get("accessStatus");
                if (isApprovedByStudent && "Approved".equalsIgnoreCase(accessStatus)) {
                    approvedCount++;
                }
                if ("pending".equalsIgnoreCase(accessStatus)) {
                    pendingCount++;
                }
            }

            // Set attributes for JSP
            request.setAttribute("allStudents", allStudents);
            request.setAttribute("pendingCount", pendingCount);
            request.setAttribute("approvedCount", approvedCount);
            request.setAttribute("staffID", staffID);

            // Forward to JSP
            request.getRequestDispatcher("studentCounsellorDashboard.jsp").forward(request, response);

        } catch (Exception e) {
            System.err.println("Error in StudentCounsellorDashboardServlet: " + e.getMessage());
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.getWriter().print("{\"success\":false,\"message\":\"Not authenticated\"}");
            return;
        }

        String action = request.getParameter("action");

        try {
            if ("approveStudent".equals(action)) {
                handleApproveStudent(request, response);
            } else if ("disapproveStudent".equals(action)) {
                handleDisapproveStudent(request, response);
            } else if ("connectStudent".equals(action)) {
                handleConnectStudent(request, response);
            } else {
                response.getWriter().print("{\"success\":false,\"message\":\"Invalid action\"}");
            }
        } catch (Exception e) {
            System.err.println("Error handling action: " + e.getMessage());
            response.getWriter().print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }

    private void handleConnectStudent(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String studentIDStr = request.getParameter("studentID");
        String staffIDStr = request.getParameter("staffID");
        if (studentIDStr == null || studentIDStr.isEmpty() || staffIDStr == null || staffIDStr.isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid IDs\"}");
            return;
        }
        int studentID = Integer.parseInt(studentIDStr);
        int staffID = Integer.parseInt(staffIDStr);
        boolean success = StudentCounsellorDAO.createAccessRecord(studentID, staffID);
        if (success) {
            response.getWriter().print("{\"success\":true,\"message\":\"Connection request sent successfully\"}");
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"Failed to request connection\"}");
        }
    }

    private void handleApproveStudent(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        
        String accessIDStr = request.getParameter("accessID");
        
        if (accessIDStr == null || accessIDStr.isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid access ID\"}");
            return;
        }

        int accessID = Integer.parseInt(accessIDStr);
        boolean success = StudentCounsellorDAO.approveCounsellor(accessID);

        if (success) {
            response.getWriter().print("{\"success\":true,\"message\":\"Student approved successfully\"}");
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"Failed to approve student\"}");
        }
    }

    private void handleDisapproveStudent(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        
        String accessIDStr = request.getParameter("accessID");
        
        if (accessIDStr == null || accessIDStr.isEmpty()) {
            response.getWriter().print("{\"success\":false,\"message\":\"Invalid access ID\"}");
            return;
        }

        int accessID = Integer.parseInt(accessIDStr);
        boolean success = StudentCounsellorDAO.disapproveCounsellor(accessID);

        if (success) {
            response.getWriter().print("{\"success\":true,\"message\":\"Student disapproved\"}");
        } else {
            response.getWriter().print("{\"success\":false,\"message\":\"Failed to disapprove student\"}");
        }
    }

    // Get ALL students registered in the system with their approval status for this counsellor
    private List<Map<String, Object>> getAllStudentsWithStatus(Integer staffID) throws Exception {
        List<Map<String, Object>> students = new ArrayList<>();
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Query all students with their access status for this counsellor
            String sql = "SELECT s.studentID, u.username, u.email, u.userID, " +
                        "COALESCE(sca.accessID, 0) as accessID, " +
                        "COALESCE(sca.approvedByStudent, 0) as approvedByStudent, " +
                        "COALESCE(sca.accessStatus, 'pending') as accessStatus, " +
                        "COALESCE(sca.createdDate, NOW()) as createdDate " +
                        "FROM student s " +
                        "JOIN registration u ON s.userID = u.userID " +
                        "LEFT JOIN studentcounselloraccess sca ON s.studentID = sca.studentID " +
                        "AND sca.staffID = ? " +
                        "ORDER BY s.studentID DESC";

            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, staffID);
            rs = stmt.executeQuery();

            while (rs.next()) {
                Map<String, Object> student = new HashMap<>();
                student.put("studentID", rs.getInt("studentID"));
                student.put("name", rs.getString("username"));
                student.put("email", rs.getString("email"));
                student.put("accessID", rs.getInt("accessID"));
                student.put("approvedByStudent", rs.getBoolean("approvedByStudent"));
                student.put("accessStatus", rs.getString("accessStatus"));
                student.put("requestedDate", rs.getTimestamp("createdDate"));
                
                students.add(student);
            }

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }

        return students;
    }
}
