package com.pocketpilot.model;

import java.time.LocalDate;
public class Budget {
    // Instance variables representing database columns
    private int budgetID;           // Primary key in Budget table
    private int studentID;          // Foreign key reference to Student
    private int categoryID;         // Foreign key reference to Category
    private double budgetAmount;    // Amount allocated for this budget
    private String budgetDesc;      // Text description of the budget
    private LocalDate budgetDate;   // Date when budget was created
    private String categoryName;    // Category name (loaded from Category table)

    // Default constructor - creates empty Budget object
    public Budget() {
    }

    /**
     * Constructor with essential budget fields
     * Used when creating new budget (without ID, which is auto-generated)
     */
    public Budget(int studentID, int categoryID, double budgetAmount, String budgetDesc, LocalDate budgetDate) {
        this.studentID = studentID;
        this.categoryID = categoryID;
        this.budgetAmount = budgetAmount;
        this.budgetDesc = budgetDesc;
        this.budgetDate = budgetDate;
    }

    /**
     * Constructor with all fields including budgetID
     * Used when loading existing budget from database
     */
    public Budget(int budgetID, int studentID, int categoryID, double budgetAmount, String budgetDesc, LocalDate budgetDate) {
        this.budgetID = budgetID;
        this.studentID = studentID;
        this.categoryID = categoryID;
        this.budgetAmount = budgetAmount;
        this.budgetDesc = budgetDesc;
        this.budgetDate = budgetDate;
    }

    // ===== GETTERS AND SETTERS =====

    /**
     * Get budget ID
     * @return Budget ID
     */
    public int getBudgetID() {
        return budgetID;
    }

    /**
     * Set budget ID
     * @param budgetID Budget ID to set
     */
    public void setBudgetID(int budgetID) {
        this.budgetID = budgetID;
    }

    /**
     * Get student ID (who owns this budget)
     * @return Student ID
     */
    public int getStudentID() {
        return studentID;
    }

    /**
     * Set student ID
     * @param studentID Student ID to set
     */
    public void setStudentID(int studentID) {
        this.studentID = studentID;
    }

    /**
     * Get category ID (budget category)
     * @return Category ID
     */
    public int getCategoryID() {
        return categoryID;
    }

    /**
     * Set category ID
     * @param categoryID Category ID to set
     */
    public void setCategoryID(int categoryID) {
        this.categoryID = categoryID;
    }

    /**
     * Get budget amount
     * @return Budget amount
     */
    public double getBudgetAmount() {
        return budgetAmount;
    }

    /**
     * Set budget amount
     * @param budgetAmount Budget amount to set
     */
    public void setBudgetAmount(double budgetAmount) {
        this.budgetAmount = budgetAmount;
    }

    /**
     * Get budget description
     * @return Budget description
     */
    public String getBudgetDesc() {
        return budgetDesc;
    }

    /**
     * Set budget description
     * @param budgetDesc Budget description to set
     */
    public void setBudgetDesc(String budgetDesc) {
        this.budgetDesc = budgetDesc;
    }

    /**
     * Get budget date (when budget was created)
     * @return Budget date
     */
    public LocalDate getBudgetDate() {
        return budgetDate;
    }

    /**
     * Set budget date
     * @param budgetDate Budget date to set
     */
    public void setBudgetDate(LocalDate budgetDate) {
        this.budgetDate = budgetDate;
    }

    /**
     * Get category name (loaded from Category table)
     * @return Category name (e.g., "School", "Transport")
     */
    public String getCategoryName() {
        return categoryName;
    }

    /**
     * Set category name
     * @param categoryName Category name to set
     */
    public void setCategoryName(String categoryName) {
        this.categoryName = categoryName;
    }

    @Override
    public String toString() {
        return "Budget{" +
                "budgetID=" + budgetID +
                ", studentID=" + studentID +
                ", categoryID=" + categoryID +
                ", budgetAmount=" + budgetAmount +
                ", budgetDesc='" + budgetDesc + '\'' +
                ", budgetDate=" + budgetDate +
                ", categoryName='" + categoryName + '\'' +
                '}';
    }
}
