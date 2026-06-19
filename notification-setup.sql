-- ============================================================
-- PocketPilot Notification System Database Setup
-- ============================================================
-- This script adds notification functionality to track and manage
-- reminders for students to complete their budget and expense records
-- ============================================================

USE pp;

-- ============================================================
-- NOTIFICATION TABLE
-- ============================================================
-- Attribute           Data Type           Key Type    Description
-- notificationID      Integer (10)        PK          Notification identifier
-- studentID           Integer (10)        FK          Student to notify
-- notificationType    Varchar (255)       -           Type: "DAILY_REMINDER", "MONTHLY_BUDGET", "MONTHLY_EXPENSE"
-- message             Text                -           Notification message content
-- isRead              Boolean             -           Whether student has read notification
-- createdDate         DateTime            -           When notification was created
-- scheduledDate       DateTime            -           When notification should be shown/sent
-- ============================================================

CREATE TABLE IF NOT EXISTS Notification (
    notificationID INT(10) AUTO_INCREMENT PRIMARY KEY,
    studentID INT(10) NOT NULL,
    notificationType VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    isRead BOOLEAN DEFAULT FALSE,
    createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    scheduledDate DATETIME NOT NULL,
    
    FOREIGN KEY (studentID) REFERENCES Student(studentID) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    INDEX idx_studentID (studentID),
    INDEX idx_notificationType (notificationType),
    INDEX idx_scheduledDate (scheduledDate),
    INDEX idx_isRead (isRead)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- NOTIFICATION PREFERENCE TABLE
-- ============================================================
-- Allows students to customize notification preferences
-- ============================================================

CREATE TABLE IF NOT EXISTS NotificationPreference (
    preferenceID INT(10) AUTO_INCREMENT PRIMARY KEY,
    studentID INT(10) NOT NULL UNIQUE,
    enableDailyReminder BOOLEAN DEFAULT TRUE,
    enableMonthlyReminder BOOLEAN DEFAULT TRUE,
    reminderTime TIME DEFAULT '09:00:00',
    reminderDayOfMonth INT(2) DEFAULT 1,
    
    FOREIGN KEY (studentID) REFERENCES Student(studentID) 
        ON DELETE CASCADE ON UPDATE CASCADE,
    
    INDEX idx_studentID (studentID)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- INSERT DEFAULT PREFERENCES FOR EXISTING STUDENTS
-- ============================================================
-- This assumes your Student table already has students
-- You may need to run this after inserting students

INSERT IGNORE INTO NotificationPreference (studentID, enableDailyReminder, enableMonthlyReminder, reminderTime, reminderDayOfMonth)
SELECT studentID, TRUE, TRUE, '09:00:00', 1 FROM Student
WHERE studentID NOT IN (SELECT studentID FROM NotificationPreference);
