package com.pocketpilot.controller;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.pocketpilot.util.AIService;
import com.google.gson.JsonObject;

@WebServlet("/AIChatServlet")
public class AIChatServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("userID") == null) {
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Not authenticated. Please log in.");
            out.print(jsonResponse.toString());
            return;
        }

        String userMessage = request.getParameter("message");
        String budgetContext = request.getParameter("budgetContext");

        if (userMessage == null || userMessage.trim().isEmpty()) {
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Message cannot be empty.");
            out.print(jsonResponse.toString());
            return;
        }

        if (budgetContext == null) {
            budgetContext = "No budget context provided.";
        }

        try {
            String aiResponse = AIService.chatWithAI(userMessage.trim(), budgetContext.trim());
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("response", aiResponse);
            out.print(jsonResponse.toString());
        } catch (Exception e) {
            System.err.println("Error in AIChatServlet: " + e.getMessage());
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Error contacting AI service: " + e.getMessage());
            out.print(jsonResponse.toString());
        }
    }
}
