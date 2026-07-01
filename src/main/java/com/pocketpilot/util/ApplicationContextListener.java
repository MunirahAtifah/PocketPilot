package com.pocketpilot.util;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;
@WebListener
public class ApplicationContextListener implements ServletContextListener {
    
    private static final String TAG = "[ApplicationContextListener]";
    
    // Called when the web application is deployed and ready to process requests
    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println(TAG + " Application started");
        System.out.println(TAG + " Initializing NotificationScheduler...");
        
        try {
            // Initialize the notification scheduler
            NotificationScheduler.initialize();
            System.out.println(TAG + " NotificationScheduler initialized successfully");
        } catch (Exception e) {
            System.err.println(TAG + " Error initializing NotificationScheduler: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    // Called when the web application is about to be shut down
    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println(TAG + " Application shutting down");
        System.out.println(TAG + " Stopping NotificationScheduler...");
        
        try {
            // Shutdown the notification scheduler
            NotificationScheduler.shutdown();
            System.out.println(TAG + " NotificationScheduler stopped");
        } catch (Exception e) {
            System.err.println(TAG + " Error stopping NotificationScheduler: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
