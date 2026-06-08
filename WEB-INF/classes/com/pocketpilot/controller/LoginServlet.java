package com.pocketpilot.controller;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.model.User;
import com.pocketpilot.util.DatabaseConnection;

public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("login.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("text/html;charset=UTF-8");

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email != null) {
            email = email.trim();
        }
        if (password == null) {
            password = "";
        }

        if (email == null || email.isEmpty()) {
            redirectWithError(response, "Email is required");
            return;
        }

        if (password.isEmpty()) {
            redirectWithError(response, "Password is required");
            return;
        }

        try {
            User user = authenticateUser(email, password);

            if (user != null) {
                HttpSession session = request.getSession(true);
                session.setAttribute("userID", user.getUserID());
                session.setAttribute("username", user.getUsername());
                session.setAttribute("role", user.getRole());
                session.setAttribute("email", user.getEmail());

                String role = user.getRole();
                String redirectUrl = "";

                if ("Student".equals(role)) {
                    redirectUrl = "studentDashboard.jsp";
                } else if ("Parent".equals(role)) {
                    redirectUrl = "parentDashboard.jsp";
                } else if ("Student_Counsellor".equals(role)) {
                    redirectUrl = "studentCounsellorDashboard.jsp";
                } else {
                    redirectUrl = "login.jsp?error=Unknown+user+role";
                }

                response.sendRedirect(redirectUrl);

            } else {
                redirectWithError(response, "Invalid credentials");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            redirectWithError(response, "An error occurred. Please try again later.");
        }
    }

    private User authenticateUser(String email, String password) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();

            // Case-sensitive fix for Linux Docker
            String sql = "SELECT userID, username, email, role, password FROM registration " +
                        "WHERE email = ? LIMIT 1";

            stmt = conn.prepareStatement(sql);
            stmt.setString(1, email);

            rs = stmt.executeQuery();

            if (rs.next()) {
                String storedPassword = rs.getString("password");

                if (password.equals(storedPassword)) {
                    User user = new User();
                    user.setUserID(rs.getInt("userID"));
                    user.setUsername(rs.getString("username"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    return user;
                }
            }
            return null;

        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    }

    private void redirectWithError(HttpServletResponse response, String errorMessage) 
            throws IOException {
        String encodedError = errorMessage.replace(" ", "+");
        response.sendRedirect("login.jsp?error=" + encodedError);
    }
}