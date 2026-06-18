package com.pocketpilot.controller;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.WebServlet;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.pocketpilot.util.DatabaseConnection;

@WebServlet("/AddCategoryServlet")
public class AddCategoryServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        String categoryName = request.getParameter("categoryName");
        String redirectPage = request.getParameter("redirectPage");
        if (redirectPage == null || redirectPage.isEmpty()) {
            redirectPage = "budget.jsp";
        }

        if (categoryName == null || categoryName.trim().isEmpty()) {
            response.sendRedirect(redirectPage + "?error=Category+name+cannot+be+empty");
            return;
        }

        categoryName = categoryName.trim();

        try (Connection conn = DatabaseConnection.getConnection()) {
            // Check if exists
            String checkSql = "SELECT COUNT(*) FROM category WHERE LOWER(categoryName) = LOWER(?)";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, categoryName);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        response.sendRedirect(redirectPage + "?error=Category+already+exists");
                        return;
                    }
                }
            }

            // Insert new category
            String insertSql = "INSERT INTO category (categoryName) VALUES (?)";
            try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                insertStmt.setString(1, categoryName);
                int rows = insertStmt.executeUpdate();
                if (rows > 0) {
                    response.sendRedirect(redirectPage + "?success=Category+added+successfully");
                } else {
                    response.sendRedirect(redirectPage + "?error=Failed+to+add+category");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(redirectPage + "?error=Database+error:+" + e.getMessage());
        }
    }
}
