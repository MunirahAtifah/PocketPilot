package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pocketpilot.util.DatabaseConnection;

/**
 * ForgotPasswordServlet handles user password reset requests.
 * It verifies the mock OTP "123456" and updates the registration table.
 */
@WebServlet("/ForgotPasswordServlet")
public class ForgotPasswordServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("forgotPassword.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (email != null) {
            email = email.trim();
        }
        if (newPassword == null) {
            newPassword = "";
        }
        if (confirmPassword == null) {
            confirmPassword = "";
        }

        // 1. Verify passwords match
        if (newPassword.isEmpty() || !newPassword.equals(confirmPassword)) {
            response.sendRedirect("forgotPassword.jsp?reset_status=mismatch");
            return;
        }

        // 2. Update password in the database
        try {
            boolean success = updatePassword(email, newPassword);
            if (success) {
                response.sendRedirect("forgotPassword.jsp?reset_status=success");
            } else {
                response.sendRedirect("forgotPassword.jsp?reset_status=invalid_email");
            }
        } catch (SQLException e) {
            System.err.println("Error updating password in database: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect("forgotPassword.jsp?reset_status=error");
        }
    }

    private boolean updatePassword(String email, String newPassword) throws SQLException {
        String sql = "UPDATE registration SET password = ? WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newPassword);
            stmt.setString(2, email);
            int rowsUpdated = stmt.executeUpdate();
            return rowsUpdated > 0;
        }
    }
}
