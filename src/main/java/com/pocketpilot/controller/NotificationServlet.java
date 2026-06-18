package com.pocketpilot.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.pocketpilot.dao.NotificationDAO;
import com.pocketpilot.dao.UserDAO;
import com.pocketpilot.model.Notification;

/**
 * NotificationServlet - Handle notification operations
 * 
 * Endpoints:
 * - GET /NotificationServlet?action=getUnread - Get unread notifications
 * - GET /NotificationServlet?action=getAll - Get all notifications
 * - POST /NotificationServlet?action=markAsRead - Mark notification as read
 * - POST /NotificationServlet?action=markAllAsRead - Mark all as read
 * - GET /NotificationServlet?action=getPreferences - Get notification preferences
 * - POST /NotificationServlet?action=updatePreferences - Update preferences
 */
@WebServlet("/NotificationServlet")
public class NotificationServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            // Check if user is logged in
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userID") == null) {
                sendError(response, 401, "Please log in first");
                return;
            }
            
            int userID = (int) session.getAttribute("userID");
            int studentID = new UserDAO().getStudentIDByUserID(userID);
            if (studentID == -1) {
                sendError(response, 404, "Student profile not found");
                return;
            }
            String action = request.getParameter("action");
            
            if ("getUnread".equals(action)) {
                getUnreadNotifications(response, studentID);
            } else if ("getAll".equals(action)) {
                getAllNotifications(response, studentID);
            } else if ("getCount".equals(action)) {
                getUnreadCount(response, studentID);
            } else if ("getPreferences".equals(action)) {
                getNotificationPreferences(response, studentID);
            } else {
                sendError(response, 400, "Invalid action");
            }
            
        } catch (Exception e) {
            sendError(response, 500, "Internal server error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        
        try {
            // Check if user is logged in
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("userID") == null) {
                sendError(response, 401, "Please log in first");
                return;
            }
            
            int userID = (int) session.getAttribute("userID");
            int studentID = new UserDAO().getStudentIDByUserID(userID);
            if (studentID == -1) {
                sendError(response, 404, "Student profile not found");
                return;
            }
            String action = request.getParameter("action");
            
            if ("markAsRead".equals(action)) {
                markNotificationAsRead(request, response, studentID);
            } else if ("markAllAsRead".equals(action)) {
                markAllAsRead(response, studentID);
            } else if ("updatePreferences".equals(action)) {
                updateNotificationPreferences(request, response, studentID);
            } else {
                sendError(response, 400, "Invalid action");
            }
            
        } catch (Exception e) {
            sendError(response, 500, "Internal server error: " + e.getMessage());
            e.printStackTrace();
        }
    }

    /**
     * Get unread notifications for student
     */
    private void getUnreadNotifications(HttpServletResponse response, int studentID)
            throws IOException {
        try {
            List<Notification> notifications = NotificationDAO.getUnreadNotifications(studentID);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"notifications\": ");
            out.print(new Gson().toJson(notifications));
            out.print("}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error fetching notifications");
        }
    }

    /**
     * Get all notifications for student
     */
    private void getAllNotifications(HttpServletResponse response, int studentID)
            throws IOException {
        try {
            List<Notification> notifications = NotificationDAO.getAllNotifications(studentID);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"notifications\": ");
            out.print(new Gson().toJson(notifications));
            out.print("}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error fetching notifications");
        }
    }

    /**
     * Get unread notification count
     */
    private void getUnreadCount(HttpServletResponse response, int studentID)
            throws IOException {
        try {
            int count = NotificationDAO.getUnreadCount(studentID);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"count\": " + count + "}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error fetching notification count");
        }
    }

    /**
     * Get notification preferences
     */
    private void getNotificationPreferences(HttpServletResponse response, int studentID)
            throws IOException {
        try {
            Map<String, Object> preferences = NotificationDAO.getPreferences(studentID);
            
            PrintWriter out = response.getWriter();
            if (preferences != null) {
                out.print("{\"success\": true, \"preferences\": ");
                out.print(new Gson().toJson(preferences));
                out.print("}");
            } else {
                out.print("{\"success\": false, \"message\": \"Preferences not found\"}");
            }
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error fetching preferences");
        }
    }

    /**
     * Mark notification as read
     */
    private void markNotificationAsRead(HttpServletRequest request, HttpServletResponse response, 
                                       int studentID) throws IOException {
        try {
            int notificationID = Integer.parseInt(request.getParameter("notificationID"));
            
            boolean success = NotificationDAO.markAsRead(notificationID);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 400, "Invalid notification ID");
        }
    }

    /**
     * Mark all notifications as read for student
     */
    private void markAllAsRead(HttpServletResponse response, int studentID)
            throws IOException {
        try {
            int count = NotificationDAO.markAllAsRead(studentID);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": true, \"markedCount\": " + count + "}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error marking notifications as read");
        }
    }

    /**
     * Update notification preferences
     */
    private void updateNotificationPreferences(HttpServletRequest request, HttpServletResponse response,
                                             int studentID) throws IOException {
        try {
            Map<String, Object> preferences = new java.util.HashMap<>();
            
            String enableDaily = request.getParameter("enableDailyReminder");
            String enableMonthly = request.getParameter("enableMonthlyReminder");
            
            if (enableDaily != null) {
                preferences.put("enableDailyReminder", "true".equalsIgnoreCase(enableDaily));
            }
            if (enableMonthly != null) {
                preferences.put("enableMonthlyReminder", "true".equalsIgnoreCase(enableMonthly));
            }
            
            boolean success = NotificationDAO.updatePreferences(studentID, preferences);
            
            PrintWriter out = response.getWriter();
            out.print("{\"success\": " + success + "}");
            out.flush();
        } catch (Exception e) {
            sendError(response, 500, "Error updating preferences");
        }
    }

    /**
     * Send error response
     */
    private void sendError(HttpServletResponse response, int statusCode, String message)
            throws IOException {
        response.setStatus(statusCode);
        PrintWriter out = response.getWriter();
        out.print("{\"success\": false, \"message\": \"" + escapeJson(message) + "\"}");
        out.flush();
    }

    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String text) {
        return text.replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r");
    }
}
