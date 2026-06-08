package com.pocketpilot.model;

import java.sql.Timestamp;

/**
 * StudentCounsellorAccess - Model for Student_Counsellor and Student relationship
 * 
 * Represents the approval/access records between Student_Counsellor staff and Students
 * New Workflow: Student approves/disapproves counsellors (not vice versa)
 */
public class StudentCounsellorAccess {
    private int accessID;
    private int studentID;
    private int staffID;
    private String accessStatus; // pending, approved, disapproved
    private Timestamp createdDate;
    private boolean approvedByStudent; // true = student approved this counsellor
    private Timestamp studentApprovalDate;

    // Constructors
    public StudentCounsellorAccess() {}

    public StudentCounsellorAccess(int studentID, int staffID) {
        this.studentID = studentID;
        this.staffID = staffID;
        this.accessStatus = "pending";
        this.approvedByStudent = false;
    }

    // Getters and Setters
    public int getAccessID() {
        return accessID;
    }

    public void setAccessID(int accessID) {
        this.accessID = accessID;
    }

    public int getStudentID() {
        return studentID;
    }

    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }

    public int getStaffID() {
        return staffID;
    }

    public void setStaffID(int staffID) {
        this.staffID = staffID;
    }

    public String getAccessStatus() {
        return accessStatus;
    }

    public void setAccessStatus(String accessStatus) {
        this.accessStatus = accessStatus;
    }

    public Timestamp getCreatedDate() {
        return createdDate;
    }

    public void setCreatedDate(Timestamp createdDate) {
        this.createdDate = createdDate;
    }

    public boolean isApprovedByStudent() {
        return approvedByStudent;
    }

    public void setApprovedByStudent(boolean approvedByStudent) {
        this.approvedByStudent = approvedByStudent;
    }

    public Timestamp getStudentApprovalDate() {
        return studentApprovalDate;
    }

    public void setStudentApprovalDate(Timestamp studentApprovalDate) {
        this.studentApprovalDate = studentApprovalDate;
    }

    @Override
    public String toString() {
        return "StudentCounsellorAccess{" +
                "accessID=" + accessID +
                ", studentID=" + studentID +
                ", staffID=" + staffID +
                ", accessStatus='" + accessStatus + '\'' +
                ", createdDate=" + createdDate +
                ", approvedByStudent=" + approvedByStudent +
                ", studentApprovalDate=" + studentApprovalDate +
                '}';
    }
}
