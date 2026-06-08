package com.pocketpilot.model;

/**
 * User - Model class representing a user entity
 * 
 * Purpose: Encapsulates user data and provides getters/setters
 * 
 * Attributes:
 *   - userID: Unique identifier for user
 *   - username: User's unique username
 *   - email: User's email address
 *   - role: User's role ('Student', 'Parent', 'IT_Support')
 *   - phoneNumber: User's phone number (optional)
 *   - password: User's password (optional, should not be exposed)
 * 
 * @author PP Development Team
 * @version 1.0
 */
public class User {
    private int userID;
    private String username;
    private String email;
    private String role;
    private String phoneNumber;
    private String password;

    /**
     * Default constructor
     */
    public User() {
    }

    /**
     * Constructor with basic fields
     */
    public User(int userID, String username, String email, String role) {
        this.userID = userID;
        this.username = username;
        this.email = email;
        this.role = role;
    }

    /**
     * Constructor with all fields
     */
    public User(int userID, String username, String email, String role, String phoneNumber, String password) {
        this.userID = userID;
        this.username = username;
        this.email = email;
        this.role = role;
        this.phoneNumber = phoneNumber;
        this.password = password;
    }

    // Getters and Setters

    public int getUserID() {
        return userID;
    }

    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    /**
     * toString method for debugging
     */
    @Override
    public String toString() {
        return "User{" +
                "userID=" + userID +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", role='" + role + '\'' +
                ", phoneNumber='" + phoneNumber + '\'' +
                '}';
    }
}
