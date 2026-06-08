package com.pocketpilot.model;

import java.time.LocalDateTime;

/**
 * Notification - Represents a notification sent to students
 * 
 * Purpose: Track reminders for students to complete budget and expense records
 * 
 * Types:
 * - DAILY_REMINDER: Daily reminder to add expenses/update budget
 * - MONTHLY_BUDGET: Monthly reminder on 1st to set up budget
 * - MONTHLY_EXPENSE: Monthly reminder on 1st to review expenses
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class Notification {
    
    private int notificationID;
    private int studentID;
    private String notificationType;
    private String message;
    private boolean isRead;
    private LocalDateTime createdDate;
    private LocalDateTime scheduledDate;
    
    // ============================================================
    // CONSTRUCTORS
    // ============================================================
    
    /**
     * Default constructor
     */
    public Notification() {
    }
    
    /**
     * Constructor with parameters
     */
    public Notification(int studentID, String notificationType, String message, 
                       LocalDateTime scheduledDate) {
        this.studentID = studentID;
        this.notificationType = notificationType;
        this.message = message;
        this.scheduledDate = scheduledDate;
        this.isRead = false;
        this.createdDate = LocalDateTime.now();
    }
    
    // ============================================================
    // GETTERS AND SETTERS
    // ============================================================
    
    public int getNotificationID() {
        return notificationID;
    }
    
    public void setNotificationID(int notificationID) {
        this.notificationID = notificationID;
    }
    
    public int getStudentID() {
        return studentID;
    }
    
    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }
    
    public String getNotificationType() {
        return notificationType;
    }
    
    public void setNotificationType(String notificationType) {
        this.notificationType = notificationType;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean read) {
        isRead = read;
    }
    
    public LocalDateTime getCreatedDate() {
        return createdDate;
    }
    
    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }
    
    public LocalDateTime getScheduledDate() {
        return scheduledDate;
    }
    
    public void setScheduledDate(LocalDateTime scheduledDate) {
        this.scheduledDate = scheduledDate;
    }
    
    // ============================================================
    // HELPER METHODS
    // ============================================================
    
    /**
     * Notification types enumeration
     */
    public static class NotificationType {
        public static final String DAILY_REMINDER = "DAILY_REMINDER";
        public static final String MONTHLY_BUDGET = "MONTHLY_BUDGET";
        public static final String MONTHLY_EXPENSE = "MONTHLY_EXPENSE";
    }
    
    @Override
    public String toString() {
        return "Notification{" +
                "notificationID=" + notificationID +
                ", studentID=" + studentID +
                ", notificationType='" + notificationType + '\'' +
                ", isRead=" + isRead +
                ", createdDate=" + createdDate +
                ", scheduledDate=" + scheduledDate +
                '}';
    }
}
