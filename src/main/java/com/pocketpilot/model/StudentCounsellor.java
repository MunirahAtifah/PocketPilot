package com.pocketpilot.model;

import java.sql.Timestamp;

/**
 * StudentCounsellor - Model for Student_Counsellor staff
 * 
 * Represents a staff member who supervises and approves students
 */
public class StudentCounsellor extends User {
    private int staffID;
    private String staffName;
    private Timestamp createdDate;

    // Constructors
    public StudentCounsellor() {
        super();
    }

    // Getters and Setters
    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public String getStaffName() {
        return staffName;
    }

    public void setStaffName(String staffName) {
        this.staffName = staffName;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    @Override
    public String toString() {
        return "StudentCounsellor{" +
                "staffID=" + staffID +
                ", staffName='" + staffName + '\'' +
                ", createdDate=" + createdDate +
                ", " + super.toString() +
                '}';
    }
}
