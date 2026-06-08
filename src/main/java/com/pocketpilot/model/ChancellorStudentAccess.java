package com.pocketpilot.model;

import java.time.LocalDateTime;

/**
 * ChancellorStudentAccess - Model class representing Chancellor-Student access relationship
 * 
 * Purpose: Manages permission and access control between Chancellor and Student
 * 
 * Features:
 *   - Tracks which students a Chancellor has access to
 *   - Maintains approval status (pending/approved)
 *   - ON/OFF toggle for enabling/disabling access
 *   - Tracks when access was created
 * 
 * Access Status Values:
 *   - "pending": Student hasn't approved Chancellor access yet
 *   - "approved": Chancellor has been granted access to student's financial data
 * 
 * Attributes:
 *   - accessID: Unique identifier for this access relationship
 *   - chancellorID: Chancellor who requested access
 *   - studentID: Student being supervised/monitored
 *   - accessStatus: "approved" or "pending"
 *   - isEnabled: Boolean ON/OFF toggle for access
 *   - createdDate: When this access relationship was created
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class ChancellorStudentAccess {
    // Instance variables representing database columns
    private int accessID;              // Primary key in ChancellorStudentAccess table
    private int chancellorID;          // Foreign key reference to Chancellor
    private int studentID;             // Foreign key reference to Student
    private String accessStatus;       // "approved" or "pending"
    private boolean isEnabled;         // ON/OFF toggle for access
    private LocalDateTime createdDate; // Date/time when access was created

    /**
     * Default constructor - creates empty ChancellorStudentAccess object
     */
    public ChancellorStudentAccess() {
    }

    /**
     * Constructor with essential access fields
     * Used when creating new access relationship
     */
    public ChancellorStudentAccess(int chancellorID, int studentID) {
        this.chancellorID = chancellorID;
        this.studentID = studentID;
        this.accessStatus = "pending";  // Default to pending
        this.isEnabled = true;           // Enabled by default
        this.createdDate = LocalDateTime.now();
    }

    /**
     * Constructor with complete fields
     * Used when loading from database
     */
    public ChancellorStudentAccess(int accessID, int chancellorID, int studentID, 
                                  String accessStatus, boolean isEnabled, LocalDateTime createdDate) {
        this.accessID = accessID;
        this.chancellorID = chancellorID;
        this.studentID = studentID;
        this.accessStatus = accessStatus;
        this.isEnabled = isEnabled;
        this.createdDate = createdDate;
    }

    // ===== GETTERS AND SETTERS =====

    /**
     * Get access ID (primary key)
     * @return Access ID
     */
    public int getAccessID() {
        return accessID;
    }

    /**
     * Set access ID
     * @param accessID Access ID to set
     */
    public void setAccessID(int accessID) {
        this.accessID = accessID;
    }

    /**
     * Get Chancellor ID
     * @return Chancellor ID
     */
    public int getChancellorID() {
        return chancellorID;
    }

    /**
     * Set Chancellor ID
     * @param chancellorID Chancellor ID to set
     */
    public void setChancellorID(int chancellorID) {
        this.chancellorID = chancellorID;
    }

    /**
     * Get Student ID
     * @return Student ID
     */
    public int getStudentID() {
        return studentID;
    }

    /**
     * Set Student ID
     * @param studentID Student ID to set
     */
    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }

    /**
     * Get access status ("approved" or "pending")
     * @return Access status
     */
    public String getAccessStatus() {
        return accessStatus;
    }

    /**
     * Set access status
     * @param accessStatus Status to set ("approved" or "pending")
     */
    public void setAccessStatus(String accessStatus) {
        this.accessStatus = accessStatus;
    }

    /**
     * Check if access is enabled (ON)
     * @return true if enabled, false if disabled (OFF)
     */
    public boolean isEnabled() {
        return isEnabled;
    }

    /**
     * Set access enabled/disabled status
     * @param enabled true to enable, false to disable
     */
    public void setEnabled(boolean enabled) {
        isEnabled = enabled;
    }

    /**
     * Get creation date/time
     * @return Date/time when access was created
     */
    public LocalDateTime getCreatedDate() {
        return createdDate;
    }

    /**
     * Set creation date/time
     * @param createdDate Date/time to set
     */
    public void setCreatedDate(LocalDateTime createdDate) {
        this.createdDate = createdDate;
    }

    /**
     * toString method for debugging
     */
    @Override
    public String toString() {
        return "ChancellorStudentAccess{" +
                "accessID=" + accessID +
                ", chancellorID=" + chancellorID +
                ", studentID=" + studentID +
                ", accessStatus='" + accessStatus + '\'' +
                ", isEnabled=" + isEnabled +
                ", createdDate=" + createdDate +
                '}';
    }
}
