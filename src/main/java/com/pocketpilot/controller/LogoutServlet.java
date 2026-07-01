package com.pocketpilot.controller;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
@WebServlet("/LogoutServlet")
public class LogoutServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    // Handle GET requests - Process logout
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    // Handle POST requests - Process logout
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        logout(request, response);
    }

    /**
     * Perform logout operation
     * 
     * @param request HttpServletRequest
     * @param response HttpServletResponse
     * @throws IOException if error
     */
    private void logout(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        // Get session
        HttpSession session = request.getSession(false);

        if (session != null) {
            // Get username before invalidating
            String username = (String) session.getAttribute("username");
            System.out.println("User logged out: " + username);

            // Invalidate session (clears all attributes)
            session.invalidate();
        }

        // Redirect to login page
        response.sendRedirect("login.jsp?message=You+have+been+logged+out");
    }
}
