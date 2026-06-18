package com.pocketpilot.dao;

import com.pocketpilot.model.Notification;
import com.pocketpilot.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

/**
 * NotificationDAO - Data access object for Notification operations
 * 
 * Purpose: Manage database operations for notifications
 * 
 * Operations:
 * - Create new notifications
 * - Retrieve notifications for students
 * - Mark notifications as read
 * - Delete old notifications
 * - Get notification preferences
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class NotificationDAO {
    
    // ============================================================
    // CREATE NOTIFICATIONS
    // ============================================================
    
    /**
     * Create a new notification in the database
     * 
     * @param notification Notification object to create
     * @return true if successful, false otherwise
     */
    public static boolean createNotification(Notification notification) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "INSERT INTO notification (studentID, notificationType, message, scheduledDate) " +
                        "VALUES (?, ?, ?, ?)";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, notification.getStudentID());
                stmt.setString(2, notification.getNotificationType());
                stmt.setString(3, notification.getMessage());
                stmt.setTimestamp(4, Timestamp.valueOf(notification.getScheduledDate()));
                
                int rowsAffected = stmt.executeUpdate();
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error creating notification: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Create multiple notifications at once
     * 
     * @param notifications List of notifications to create
     * @return Number of notifications created
     */
    public static int createMultipleNotifications(List<Notification> notifications) {
        int count = 0;
        for (Notification notification : notifications) {
            if (createNotification(notification)) {
                count++;
            }
        }
        return count;
    }
    
    // ============================================================
    // RETRIEVE NOTIFICATIONS
    // ============================================================
    
    /**
     * Get all unread notifications for a student
     * 
     * @param studentID Student identifier
     * @return List of unread notifications
     */
    public static List<Notification> getUnreadNotifications(int studentID) {
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM notification WHERE studentID = ? AND isRead = FALSE " +
                        "ORDER BY scheduledDate DESC";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, studentID);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Notification notification = mapResultSetToNotification(rs);
                        notifications.add(notification);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error retrieving unread notifications: " + e.getMessage());
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Get all notifications for a student (read and unread)
     * 
     * @param studentID Student identifier
     * @return List of all notifications for the student
     */
    public static List<Notification> getAllNotifications(int studentID) {
        List<Notification> notifications = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM notification WHERE studentID = ? " +
                        "ORDER BY scheduledDate DESC LIMIT 100";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, studentID);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Notification notification = mapResultSetToNotification(rs);
                        notifications.add(notification);
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error retrieving all notifications: " + e.getMessage());
            e.printStackTrace();
        }
        
        return notifications;
    }
    
    /**
     * Get unread notifications count for a student
     * 
     * @param studentID Student identifier
     * @return Count of unread notifications
     */
    public static int getUnreadCount(int studentID) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT COUNT(*) as count FROM notification WHERE studentID = ? AND isRead = FALSE";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, studentID);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt("count");
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error getting unread count: " + e.getMessage());
            e.printStackTrace();
        }
        
        return 0;
    }
    
    // ============================================================
    // UPDATE NOTIFICATIONS
    // ============================================================
    
    /**
     * Mark a notification as read
     * 
     * @param notificationID Notification identifier
     * @return true if successful, false otherwise
     */
    public static boolean markAsRead(int notificationID) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE notification SET isRead = TRUE WHERE notificationID = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, notificationID);
                
                int rowsAffected = stmt.executeUpdate();
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error marking notification as read: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Mark all unread notifications as read for a student
     * 
     * @param studentID Student identifier
     * @return Number of notifications marked as read
     */
    public static int markAllAsRead(int studentID) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE notification SET isRead = TRUE WHERE studentID = ? AND isRead = FALSE";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, studentID);
                
                return stmt.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error marking all notifications as read: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    // ============================================================
    // DELETE NOTIFICATIONS
    // ============================================================
    
    /**
     * Delete a notification
     * 
     * @param notificationID Notification identifier
     * @return true if successful, false otherwise
     */
    public static boolean deleteNotification(int notificationID) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "DELETE FROM notification WHERE notificationID = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, notificationID);
                
                int rowsAffected = stmt.executeUpdate();
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error deleting notification: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Delete old notifications (older than specified days)
     * 
     * @param daysOld Number of days old to delete
     * @return Number of notifications deleted
     */
    public static int deleteOldNotifications(int daysOld) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "DELETE FROM notification WHERE createdDate < DATE_SUB(NOW(), INTERVAL ? DAY) AND isRead = TRUE";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, daysOld);
                
                return stmt.executeUpdate();
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error deleting old notifications: " + e.getMessage());
            e.printStackTrace();
            return 0;
        }
    }
    
    // ============================================================
    // NOTIFICATION PREFERENCES
    // ============================================================
    
    /**
     * Get notification preferences for a student
     * 
     * @param studentID Student identifier
     * @return Map with preferences or null if not found
     */
    public static Map<String, Object> getPreferences(int studentID) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT * FROM notificationpreference WHERE studentID = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setInt(1, studentID);
                
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        Map<String, Object> preferences = new HashMap<>();
                        preferences.put("enableDailyReminder", rs.getBoolean("enableDailyReminder"));
                        preferences.put("enableMonthlyReminder", rs.getBoolean("enableMonthlyReminder"));
                        preferences.put("reminderTime", rs.getTime("reminderTime"));
                        preferences.put("reminderDayOfMonth", rs.getInt("reminderDayOfMonth"));
                        return preferences;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error getting preferences: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }
    
    /**
     * Update notification preferences for a student
     * 
     * @param studentID Student identifier
     * @param preferences Map with updated preferences
     * @return true if successful, false otherwise
     */
    public static boolean updatePreferences(int studentID, Map<String, Object> preferences) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "UPDATE notificationpreference SET enableDailyReminder = ?, " +
                        "enableMonthlyReminder = ?, reminderTime = ?, reminderDayOfMonth = ? " +
                        "WHERE studentID = ?";
            
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setBoolean(1, (boolean) preferences.getOrDefault("enableDailyReminder", true));
                stmt.setBoolean(2, (boolean) preferences.getOrDefault("enableMonthlyReminder", true));
                stmt.setTime(3, (Time) preferences.getOrDefault("reminderTime", Time.valueOf("09:00:00")));
                stmt.setInt(4, (int) preferences.getOrDefault("reminderDayOfMonth", 1));
                stmt.setInt(5, studentID);
                
                int rowsAffected = stmt.executeUpdate();
                return rowsAffected > 0;
            }
        } catch (SQLException e) {
            System.err.println("[NotificationDAO] Error updating preferences: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    // ============================================================
    // HELPER METHODS
    // ============================================================
    
    /**
     * Map ResultSet row to Notification object
     */
    private static Notification mapResultSetToNotification(ResultSet rs) throws SQLException {
        Notification notification = new Notification();
        notification.setNotificationID(rs.getInt("notificationID"));
        notification.setStudentID(rs.getInt("studentID"));
        notification.setNotificationType(rs.getString("notificationType"));
        notification.setMessage(rs.getString("message"));
        notification.setRead(rs.getBoolean("isRead"));
        notification.setCreatedDate(rs.getTimestamp("createdDate").toLocalDateTime());
        notification.setScheduledDate(rs.getTimestamp("scheduledDate").toLocalDateTime());
        return notification;
    }
}
