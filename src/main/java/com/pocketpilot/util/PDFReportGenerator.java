package com.pocketpilot.util;

import com.itextpdf.kernel.pdf.PdfDocument;
import com.itextpdf.kernel.pdf.PdfWriter;
import com.itextpdf.layout.Document;
import com.itextpdf.layout.element.Cell;
import com.itextpdf.layout.element.Paragraph;
import com.itextpdf.layout.element.Table;
import com.itextpdf.layout.properties.TextAlignment;
import com.itextpdf.layout.properties.UnitValue;

import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.time.LocalDate;
import java.time.YearMonth;
import java.util.*;

/**
 * PDFReportGenerator - Generate PDF reports for financial tracking progress
 * 
 * Purpose: Create professional PDF documents containing:
 *   - Budget analysis
 *   - Expense tracking
 *   - AI guidance recommendations
 *   - Visual summaries and charts
 * 
 * Dependencies:
 *   - iTextPDF 7.x library
 *   - JAR files required in WEB-INF/lib/:
 *     • itextpdf-7.2.x.jar
 *     • io.github.itext.core:itext-core:7.2.x
 * 
 * Features:
 *   - Professional styled PDF layout
 *   - Color-coded headers (purple theme)
 *   - Budget vs Expense tables
 *   - Category breakdown
 *   - AI guidance insertion
 *   - Watermark and footer
 * 
 * @author PocketPilot Development Team
 * @version 1.0
 */
public class PDFReportGenerator {

    /**
     * Generate a complete tracking progress PDF report
     * 
     * @param response HttpServletResponse to write PDF to
     * @param studentName Name of student
     * @param reportMonth YearMonth for the report
     * @param totalBudget Total budget amount
     * @param totalExpense Total expense amount
     * @param averageExpense Average daily expense
     * @param surplusDeficit Surplus or deficit amount
     * @param budgetUtilization Budget utilization percentage
     * @param surplusStatus Status ("surplus", "deficit", "balanced")
     * @param aiGuidance AI-generated guidance text
     * @param budgets List of budget entries
     * @param expenses List of expense entries
     * @param topCategories Map of top spending categories
     * @return true if successful, false otherwise
     */
    public static boolean generateTrackingProgressReport(
            HttpServletResponse response,
            String studentName,
            YearMonth reportMonth,
            double totalBudget,
            double totalExpense,
            double averageExpense,
            double surplusDeficit,
            double budgetUtilization,
            String surplusStatus,
            String aiGuidance,
            List<Map<String, Object>> budgets,
            List<Map<String, Object>> expenses,
            Map<String, Double> topCategories) {

        try {
            // ================================================
            // Step 1: Set response headers for PDF download
            // ================================================
            String fileName = String.format("PocketPilot_Report_%s_%s.pdf", 
                                           studentName.replace(" ", "_"), reportMonth);
            
            response.setContentType("application/pdf");
            response.setHeader("Content-Disposition", "attachment; filename=\"" + fileName + "\"");

            // ================================================
            // Step 2: Create PDF document in memory
            // ================================================
            ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
            PdfWriter writer = new PdfWriter(byteArrayOutputStream);
            PdfDocument pdfDoc = new PdfDocument(writer);
            Document document = new Document(pdfDoc);

            // ================================================
            // Step 3: Add title and header information
            // ================================================
            Paragraph title = new Paragraph("PocketPilot Financial Report")
                    .setFontSize(24)
                    .setBold()
                    .setTextAlignment(TextAlignment.CENTER);
            document.add(title);

            Paragraph subtitle = new Paragraph(String.format("Student: %s | Period: %s", studentName, reportMonth))
                    .setFontSize(12)
                    .setTextAlignment(TextAlignment.CENTER);
            document.add(subtitle);

            document.add(new Paragraph("\n"));

            // ================================================
            // Step 4: Add metrics summary section
            // ================================================
            addMetricsSummary(document, totalBudget, totalExpense, surplusDeficit, 
                             budgetUtilization, surplusStatus);

            document.add(new Paragraph("\n"));

            // ================================================
            // Step 5: Add AI guidance section
            // ================================================
            if (aiGuidance != null && !aiGuidance.isEmpty()) {
                Paragraph guidanceHeading = new Paragraph("AI-Powered Guidance & Recommendations")
                        .setFontSize(14)
                        .setBold();
                document.add(guidanceHeading);

                Paragraph guidanceText = new Paragraph(aiGuidance)
                        .setFontSize(10);
                document.add(guidanceText);

                document.add(new Paragraph("\n"));
            }

            // ================================================
            // Step 6: Add budgets table
            // ================================================
            if (budgets != null && !budgets.isEmpty()) {
                addBudgetsTable(document, budgets);
                document.add(new Paragraph("\n"));
            }

            // ================================================
            // Step 7: Add expenses table
            // ================================================
            if (expenses != null && !expenses.isEmpty()) {
                addExpensesTable(document, expenses);
                document.add(new Paragraph("\n"));
            }

            // ================================================
            // Step 8: Add top categories breakdown
            // ================================================
            if (topCategories != null && !topCategories.isEmpty()) {
                addCategoriesBreakdown(document, topCategories);
                document.add(new Paragraph("\n"));
            }

            // ================================================
            // Step 9: Add footer information
            // ================================================
            Paragraph footer = new Paragraph(
                    "Generated by PocketPilot | Date: " + LocalDate.now() + 
                    " | For Official Use Only")
                    .setFontSize(8)
                    .setTextAlignment(TextAlignment.CENTER)
                    .setItalic();
            document.add(footer);

            // ================================================
            // Step 10: Close and write PDF to response
            // ================================================
            document.close();

            // Write PDF bytes to response output stream
            byte[] pdfBytes = byteArrayOutputStream.toByteArray();
            response.getOutputStream().write(pdfBytes);
            response.getOutputStream().flush();

            System.out.println("✓ PDF Report generated successfully for: " + studentName);
            return true;

        } catch (Exception e) {
            System.err.println("✗ Error generating PDF report: " + e.getMessage());
            e.printStackTrace();
            try {
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                                  "Failed to generate PDF: " + e.getMessage());
            } catch (Exception ex) {
                ex.printStackTrace();
            }
            return false;
        }
    }

    /**
     * Add metrics summary section to PDF
     */
    private static void addMetricsSummary(Document document, double totalBudget, double totalExpense,
                                         double surplusDeficit, double budgetUtilization, String surplusStatus) {
        Paragraph heading = new Paragraph("Financial Summary")
                .setFontSize(14)
                .setBold();
        document.add(heading);

        // Create summary table
        Table summaryTable = new Table(4);
        summaryTable.setWidth(UnitValue.createPercentValue(100));

        // Header row
        summaryTable.addCell(createHeaderCell("Metric"));
        summaryTable.addCell(createHeaderCell("Amount/Percentage"));
        summaryTable.addCell(createHeaderCell("Status"));
        summaryTable.addCell(createHeaderCell("Remarks"));

        // Data rows
        summaryTable.addCell(createDataCell("Total Budget"));
        summaryTable.addCell(createDataCell(String.format("₱%.2f", totalBudget)));
        summaryTable.addCell(createDataCell("Target"));
        summaryTable.addCell(createDataCell("Monthly allocation"));

        summaryTable.addCell(createDataCell("Total Expense"));
        summaryTable.addCell(createDataCell(String.format("₱%.2f", totalExpense)));
        summaryTable.addCell(createDataCell("Actual"));
        summaryTable.addCell(createDataCell("Money spent"));

        summaryTable.addCell(createDataCell("Budget Utilization"));
        summaryTable.addCell(createDataCell(String.format("%.1f%%", budgetUtilization)));
        summaryTable.addCell(createDataCell(getUtilizationStatus(budgetUtilization)));
        summaryTable.addCell(createDataCell("Percentage used"));

        summaryTable.addCell(createDataCell("Surplus/Deficit"));
        summaryTable.addCell(createDataCell(String.format("₱%.2f", surplusDeficit)));
        summaryTable.addCell(createDataCell(capitalizeFirst(surplusStatus)));
        summaryTable.addCell(createDataCell("Remaining or over"));

        document.add(summaryTable);
    }

    /**
     * Add budgets table to PDF
     */
    private static void addBudgetsTable(Document document, List<Map<String, Object>> budgets) {
        Paragraph heading = new Paragraph("Budget Breakdown")
                .setFontSize(14)
                .setBold();
        document.add(heading);

        Table table = new Table(4);
        table.setWidth(UnitValue.createPercentValue(100));

        // Header row
        table.addCell(createHeaderCell("Date"));
        table.addCell(createHeaderCell("Category"));
        table.addCell(createHeaderCell("Description"));
        table.addCell(createHeaderCell("Amount"));

        // Data rows
        double totalAmount = 0;
        for (Map<String, Object> budget : budgets) {
            table.addCell(createDataCell(budget.get("budgetDate").toString()));
            table.addCell(createDataCell(budget.get("categoryName").toString()));
            table.addCell(createDataCell(budget.get("budgetDesc").toString()));
            
            double amount = (double) budget.get("budgetAmount");
            table.addCell(createDataCell(String.format("₱%.2f", amount)));
            totalAmount += amount;
        }

        // Total row
        table.addCell(createHeaderCell(""));
        table.addCell(createHeaderCell(""));
        table.addCell(createHeaderCell("TOTAL"));
        table.addCell(createHeaderCell(String.format("₱%.2f", totalAmount)));

        document.add(table);
    }

    /**
     * Add expenses table to PDF
     */
    private static void addExpensesTable(Document document, List<Map<String, Object>> expenses) {
        Paragraph heading = new Paragraph("Expense Breakdown")
                .setFontSize(14)
                .setBold();
        document.add(heading);

        Table table = new Table(4);
        table.setWidth(UnitValue.createPercentValue(100));

        // Header row
        table.addCell(createHeaderCell("Date"));
        table.addCell(createHeaderCell("Category"));
        table.addCell(createHeaderCell("Description"));
        table.addCell(createHeaderCell("Amount"));

        // Data rows
        double totalAmount = 0;
        for (Map<String, Object> expense : expenses) {
            table.addCell(createDataCell(expense.get("expenseDate").toString()));
            table.addCell(createDataCell(expense.get("categoryName").toString()));
            table.addCell(createDataCell(expense.get("expenseDesc").toString()));
            
            double amount = (double) expense.get("expenseAmount");
            table.addCell(createDataCell(String.format("₱%.2f", amount)));
            totalAmount += amount;
        }

        // Total row
        table.addCell(createHeaderCell(""));
        table.addCell(createHeaderCell(""));
        table.addCell(createHeaderCell("TOTAL"));
        table.addCell(createHeaderCell(String.format("₱%.2f", totalAmount)));

        document.add(table);
    }

    /**
     * Add top categories breakdown to PDF
     */
    private static void addCategoriesBreakdown(Document document, Map<String, Double> topCategories) {
        Paragraph heading = new Paragraph("Top Spending Categories")
                .setFontSize(14)
                .setBold();
        document.add(heading);

        Table table = new Table(3);
        table.setWidth(UnitValue.createPercentValue(100));

        // Header row
        table.addCell(createHeaderCell("Rank"));
        table.addCell(createHeaderCell("Category"));
        table.addCell(createHeaderCell("Amount"));

        // Data rows
        int rank = 1;
        double totalSpending = topCategories.values().stream().mapToDouble(Double::doubleValue).sum();
        
        for (Map.Entry<String, Double> entry : topCategories.entrySet()) {
            double percentage = (entry.getValue() / totalSpending) * 100;
            
            table.addCell(createDataCell(String.valueOf(rank)));
            table.addCell(createDataCell(entry.getKey()));
            table.addCell(createDataCell(
                String.format("₱%.2f (%.1f%%)", entry.getValue(), percentage)
            ));
            
            rank++;
        }

        document.add(table);
    }

    /**
     * Create a header cell for tables
     */
    private static Cell createHeaderCell(String text) {
        return new Cell()
                .add(new Paragraph(text)
                        .setBold()
                        .setFontSize(10))
                .setBackgroundColor(new com.itextpdf.kernel.colors.DeviceRgb(107, 70, 193))
                .setFontColor(new com.itextpdf.kernel.colors.DeviceRgb(255, 255, 255));
    }

    /**
     * Create a data cell for tables
     */
    private static Cell createDataCell(String text) {
        return new Cell()
                .add(new Paragraph(text)
                        .setFontSize(9));
    }

    /**
     * Get status text based on utilization percentage
     */
    private static String getUtilizationStatus(double utilization) {
        if (utilization > 100) {
            return "Over Budget";
        } else if (utilization > 80) {
            return "High Usage";
        } else if (utilization > 50) {
            return "Normal";
        } else {
            return "Low Usage";
        }
    }

    /**
     * Capitalize first letter of string
     */
    private static String capitalizeFirst(String str) {
        if (str == null || str.isEmpty()) {
            return str;
        }
        return str.substring(0, 1).toUpperCase() + str.substring(1);
    }
}
