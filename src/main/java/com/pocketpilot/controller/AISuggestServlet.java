package com.pocketpilot.controller;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.pocketpilot.util.AIService;

@WebServlet("/AISuggestServlet")
public class AISuggestServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String description = request.getParameter("description");
        int suggestedID = AIService.suggestCategoryID(description);

        String categoryName = "Other";
        switch (suggestedID) {
            case 1: categoryName = "Education"; break;
            case 2: categoryName = "Food"; break;
            case 3: categoryName = "Transport"; break;
            case 4: categoryName = "Entertainment"; break;
            case 5: categoryName = "Utilities"; break;
            case 6: categoryName = "Healthcare"; break;
            case 7: categoryName = "Shopping"; break;
            case 8: categoryName = "Other"; break;
        }

        String json = "{\"categoryID\": " + suggestedID + ", \"categoryName\": \"" + categoryName + "\"}";
        response.getWriter().write(json);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
