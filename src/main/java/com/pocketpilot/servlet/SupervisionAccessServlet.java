package com.pocketpilot.servlet;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.dao.StudentCounsellorDAO;
import com.pocketpilot.dao.ParentSupervisionDAO;

/**
 * SupervisionAccessServlet - Handle student supervision actions
 * 
 * Actions:
 * - approveCounsellor: Student approves a counsellor for access
 * - disapproveCounsellor: Student disapproves/revokes counsellor access
 * - generateCode: Generate new supervision code for parent
 */
@WebServlet("/SupervisionAccessServlet")
public class SupervisionAccessServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Set response type
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check session
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            out.print("{\"success\":false,\"message\":\"Not authenticated\"}");
            return;
        }

        Integer userID = (Integer) session.getAttribute("userID");
        String action = request.getParameter("action");

        try {
            // Get student ID
            Integer studentID = getStudentID(userID);
            if (studentID == null) {
                out.print("{\"success\":false,\"message\":\"Student not found\"}");
                return;
            }

            if ("approveCounsellor".equals(action)) {
                handleApproveCounsellor(request, response, out);
            } else if ("disapproveCounsellor".equals(action)) {
                handleDisapproveCounsellor(request, response, out);
            } else if ("generateCode".equals(action)) {
                handleGenerateCode(request, response, out, studentID);
            } else {
                out.print("{\"success\":false,\"message\":\"Invalid action\"}");
            }

        } catch (SQLException e) {
            System.err.println("SQL Error in SupervisionAccessServlet: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Database error: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            System.err.println("Error in SupervisionAccessServlet: " + e.getMessage());
            e.printStackTrace();
            out.print("{\"success\":false,\"message\":\"Error: " + e.getMessage() + "\"}");
        }
    }

    private void handleApproveCounsellor(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws SQLException {
        String accessIDStr = request.getParameter("accessID");
        
        if (accessIDStr == null || accessIDStr.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Invalid access ID\"}");
            return;
        }

        int accessID = Integer.parseInt(accessIDStr);
        boolean success = StudentCounsellorDAO.approveStudent(accessID);

        if (success) {
            out.print("{\"success\":true,\"message\":\"Counsellor approved successfully\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"Failed to approve counsellor\"}");
        }
    }

    private void handleDisapproveCounsellor(HttpServletRequest request, HttpServletResponse response, PrintWriter out)
            throws SQLException {
        String accessIDStr = request.getParameter("accessID");
        
        if (accessIDStr == null || accessIDStr.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Invalid access ID\"}");
            return;
        }

        int accessID = Integer.parseInt(accessIDStr);
        boolean success = StudentCounsellorDAO.disapproveStudent(accessID);

        if (success) {
            out.print("{\"success\":true,\"message\":\"Counsellor access removed\"}");
        } else {
            out.print("{\"success\":false,\"message\":\"Failed to remove counsellor access\"}");
        }
    }

    private void handleGenerateCode(HttpServletRequest request, HttpServletResponse response, PrintWriter out, Integer studentID)
            throws SQLException {
        try {
            String code = ParentSupervisionDAO.createSupervisionCode(studentID);
            out.print("{\"success\":true,\"code\":\"" + code + "\",\"message\":\"Code generated successfully\"}");
        } catch (SQLException e) {
            out.print("{\"success\":false,\"message\":\"Failed to generate code: " + e.getMessage() + "\"}");
        }
    }

    private Integer getStudentID(Integer userID) throws SQLException {
        // This should be implemented with actual database query
        // For now, returning a placeholder
        String sql = "SELECT studentID FROM student WHERE userID = ?";
        try (java.sql.Connection conn = com.pocketpilot.util.DatabaseConnection.getConnection();
             java.sql.PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, userID);
            try (java.sql.ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("studentID");
                }
            }
        }
        return null;
    }
}
