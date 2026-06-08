package com.pocketpilot.util;

import com.pocketpilot.dao.NotificationDAO;
import com.pocketpilot.dao.UserDAO;
import com.pocketpilot.model.Notification;

import java.sql.*;
import java.time.*;
import java.util.*;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * NotificationScheduler - Scheduled notification generator
 * 
 * Purpose: Automatically create and manage notifications for students
 * 
 * Features:
 * - Generate daily reminders for students to add expenses/budgets
 * - Generate monthly reminders on the 1st for budget and expense review
 * - Respect student notification preferences
 * - Run scheduled tasks automatically
 * 
 * Scheduling:
 * - Daily reminders: 9:00 AM every day
 * - Monthly reminders: 1st of every month at 9:00 AM
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class NotificationScheduler {
    
    private static ScheduledExecutorService scheduler;
    private static final String TAG = "[NotificationScheduler]";
    
    // ============================================================
    // INITIALIZATION
    // ============================================================
    
    /**
     * Initialize and start the notification scheduler
     * Should be called when application starts
     */
    public static void initialize() {
        try {
            if (scheduler == null || scheduler.isShutdown()) {
                scheduler = Executors.newScheduledThreadPool(2);
                System.out.println(TAG + " Initializing notification scheduler...");
                
                // Schedule daily notifications task
                scheduleDailyNotificationsTask();
                
                // Schedule monthly notifications task
                scheduleMonthlyNotificationsTask();
                
                System.out.println(TAG + " Notification scheduler started successfully");
            }
        } catch (Exception e) {
            System.err.println(TAG + " Error initializing scheduler: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Shutdown the notification scheduler
     * Should be called when application stops
     */
    public static void shutdown() {
        if (scheduler != null && !scheduler.isShutdown()) {
            scheduler.shutdown();
            System.out.println(TAG + " Notification scheduler stopped");
        }
    }
    
    // ============================================================
    // SCHEDULED TASKS
    // ============================================================
    
    /**
     * Schedule daily notifications task
     * Runs every day at 9:00 AM
     */
    private static void scheduleDailyNotificationsTask() {
        // Calculate initial delay until 9:00 AM
        long initialDelay = calculateDelayUntilTime(9, 0);
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println(TAG + " Running daily notification task...");
                generateDailyNotifications();
                System.out.println(TAG + " Daily notification task completed");
            } catch (Exception e) {
                System.err.println(TAG + " Error in daily notification task: " + e.getMessage());
                e.printStackTrace();
            }
        }, initialDelay, 24, TimeUnit.HOURS);
    }
    
    /**
     * Schedule monthly notifications task
     * Runs on the 1st of every month at 9:00 AM
     */
    private static void scheduleMonthlyNotificationsTask() {
        // Calculate initial delay until 1st of next month at 9:00 AM
        long initialDelay = calculateDelayUntilMonthStart();
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println(TAG + " Running monthly notification task...");
                generateMonthlyNotifications();
                System.out.println(TAG + " Monthly notification task completed");
            } catch (Exception e) {
                System.err.println(TAG + " Error in monthly notification task: " + e.getMessage());
                e.printStackTrace();
            }
        }, initialDelay, 30, TimeUnit.DAYS); // Approximate 30 days for simplicity
    }
    
    // ============================================================
    // NOTIFICATION GENERATION
    // ============================================================
    
    /**
     * Generate daily reminders for all students
     */
    private static void generateDailyNotifications() {
        try {
            List<Integer> allStudents = getAllStudentIds();
            
            for (int studentID : allStudents) {
                // Check if student has daily reminders enabled
                Map<String, Object> preferences = NotificationDAO.getPreferences(studentID);
                
                if (preferences != null && (boolean) preferences.getOrDefault("enableDailyReminder", true)) {
                    Notification notification = new Notification();
                    notification.setStudentID(studentID);
                    notification.setNotificationType(Notification.NotificationType.DAILY_REMINDER);
                    notification.setMessage(getDailyReminderMessage());
                    notification.setScheduledDate(LocalDateTime.now());
                    
                    NotificationDAO.createNotification(notification);
                    System.out.println(TAG + " Created daily reminder for student " + studentID);
                }
            }
        } catch (Exception e) {
            System.err.println(TAG + " Error generating daily notifications: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Generate monthly reminders for all students on the 1st of the month
     */
    private static void generateMonthlyNotifications() {
        try {
            List<Integer> allStudents = getAllStudentIds();
            
            for (int studentID : allStudents) {
                // Check if student has monthly reminders enabled
                Map<String, Object> preferences = NotificationDAO.getPreferences(studentID);
                
                if (preferences != null && (boolean) preferences.getOrDefault("enableMonthlyReminder", true)) {
                    // Create monthly budget reminder
                    Notification budgetNotification = new Notification();
                    budgetNotification.setStudentID(studentID);
                    budgetNotification.setNotificationType(Notification.NotificationType.MONTHLY_BUDGET);
                    budgetNotification.setMessage(getMonthlyBudgetReminderMessage());
                    budgetNotification.setScheduledDate(LocalDateTime.now());
                    
                    NotificationDAO.createNotification(budgetNotification);
                    System.out.println(TAG + " Created monthly budget reminder for student " + studentID);
                    
                    // Create monthly expense reminder
                    Notification expenseNotification = new Notification();
                    expenseNotification.setStudentID(studentID);
                    expenseNotification.setNotificationType(Notification.NotificationType.MONTHLY_EXPENSE);
                    expenseNotification.setMessage(getMonthlyExpenseReminderMessage());
                    expenseNotification.setScheduledDate(LocalDateTime.now());
                    
                    NotificationDAO.createNotification(expenseNotification);
                    System.out.println(TAG + " Created monthly expense reminder for student " + studentID);
                }
            }
        } catch (Exception e) {
            System.err.println(TAG + " Error generating monthly notifications: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Manually trigger daily notifications (for testing)
     */
    public static void triggerDailyNotifications() {
        generateDailyNotifications();
    }
    
    /**
     * Manually trigger monthly notifications (for testing)
     */
    public static void triggerMonthlyNotifications() {
        generateMonthlyNotifications();
    }
    
    // ============================================================
    // HELPER METHODS
    // ============================================================
    
    /**
     * Get all student IDs from the database
     */
    private static List<Integer> getAllStudentIds() {
        List<Integer> studentIds = new ArrayList<>();
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            String sql = "SELECT studentID FROM Student";
            
            try (Statement stmt = conn.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {
                
                while (rs.next()) {
                    studentIds.add(rs.getInt("studentID"));
                }
            }
        } catch (SQLException e) {
            System.err.println(TAG + " Error getting student IDs: " + e.getMessage());
            e.printStackTrace();
        }
        
        return studentIds;
    }
    
    /**
     * Calculate delay in milliseconds until a specific time today or tomorrow
     */
    private static long calculateDelayUntilTime(int hour, int minute) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime targetTime = now.withHour(hour).withMinute(minute).withSecond(0).withNano(0);
        
        // If target time has already passed today, schedule for tomorrow
        if (targetTime.isBefore(now)) {
            targetTime = targetTime.plusDays(1);
        }
        
        Duration duration = Duration.between(now, targetTime);
        return duration.toMillis();
    }
    
    /**
     * Calculate delay in milliseconds until the 1st of next month at 9:00 AM
     */
    private static long calculateDelayUntilMonthStart() {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime nextMonthStart = now.withDayOfMonth(1).withHour(9).withMinute(0).withSecond(0).withNano(0);
        
        // If we're before 9 AM on the 1st, target today
        if (now.getDayOfMonth() == 1 && now.isBefore(nextMonthStart)) {
            // Do nothing, targetTime is correct
        } else if (now.isBefore(nextMonthStart)) {
            // We're before the 1st, so nextMonthStart is still in current month
            // This shouldn't happen based on the logic, so move to next month
            nextMonthStart = nextMonthStart.plusMonths(1);
        } else {
            // We're past 9 AM on the 1st or in the middle of the month, go to next month
            nextMonthStart = nextMonthStart.plusMonths(1);
        }
        
        Duration duration = Duration.between(now, nextMonthStart);
        return Math.max(duration.toMillis(), 1000); // At least 1 second delay
    }
    
    /**
     * Get daily reminder message
     */
    private static String getDailyReminderMessage() {
        return "📝 Daily Reminder: Don't forget to log your expenses today! Keep your budget records up to date.";
    }
    
    /**
     * Get monthly budget reminder message
     */
    private static String getMonthlyBudgetReminderMessage() {
        return "💰 Monthly Budget Reminder: It's the 1st of the month! Time to review and plan your budget for the month ahead.";
    }
    
    /**
     * Get monthly expense reminder message
     */
    private static String getMonthlyExpenseReminderMessage() {
        return "📊 Monthly Expense Review: Review your expenses from the past month and see how well you managed your budget!";
    }
    
    /**
     * Get scheduler status
     */
    public static String getStatus() {
        if (scheduler == null || scheduler.isShutdown()) {
            return "Notification scheduler is not running";
        } else if (scheduler.isTerminated()) {
            return "Notification scheduler is terminated";
        } else {
            return "Notification scheduler is running";
        }
    }
}
