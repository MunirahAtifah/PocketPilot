package com.pocketpilot.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.Scanner;

/**
 * AIService - Unified AI-powered financial guidance engine
 * 
 * Purpose: Provide intelligent financial recommendations using Gemini API
 * 
 * Features:
 *   - Generate AI-powered financial guidance using Google Gemini API
 *   - Fallback to rule-based guidance if API is unavailable
 *   - Analyze budget status and provide personalized recommendations
 *   - Adapt guidance based on spending patterns and trends
 * 
 * Configuration:
 *   - Gemini API Key: Set via environment variable GEMINI_API_KEY
 *   - API Endpoint: https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent
 * 
 * @author PocketPilot Development Team
 * @version 2.0
 */
public class AIService {

    private static final String GEMINI_API_KEY = System.getenv("GEMINI_API_KEY");
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent";
    private static final int API_TIMEOUT = 10000; // 10 seconds

    /**
     * Generate AI-powered financial guidance using Gemini API
     * Falls back to rule-based guidance if API fails
     * 
     * @param surplusStatus Status of budget (surplus, deficit, or balanced)
     * @param budgetUtilization Percentage of budget used
     * @param averageDailyExpense Average daily spending amount
     * @param totalBudget Total budget for the month
     * @param surplusDeficitAmount Amount of surplus or deficit
     * @param spendingTrend Spending trend (increasing, decreasing, or stable)
     * @param topCategories Top spending categories and amounts
     * @return AI-powered financial guidance string
     */
    public static String generateAIGuidance(String surplusStatus, double budgetUtilization,
                                          double averageDailyExpense, double totalBudget,
                                          double surplusDeficitAmount, String spendingTrend,
                                          Map<String, Double> topCategories) {
        
        // Try to get guidance from Gemini API
        String aiGuidance = getGeminiGuidance(surplusStatus, budgetUtilization, 
                                             averageDailyExpense, totalBudget, 
                                             surplusDeficitAmount, spendingTrend, 
                                             topCategories);
        
        // If Gemini API fails or returns null, use rule-based guidance
        if (aiGuidance == null || aiGuidance.isEmpty()) {
            aiGuidance = generateRuleBasedGuidance(surplusStatus, budgetUtilization,
                                                  averageDailyExpense, totalBudget,
                                                  surplusDeficitAmount);
        }
        
        return aiGuidance;
    }

    /**
     * Call Gemini API for intelligent financial guidance
     * 
     * @param surplusStatus Status of budget (surplus, deficit, or balanced)
     * @param budgetUtilization Percentage of budget used
     * @param averageDailyExpense Average daily spending amount
     * @param totalBudget Total budget for the month
     * @param surplusDeficitAmount Amount of surplus or deficit
     * @param spendingTrend Spending trend (increasing, decreasing, or stable)
     * @param topCategories Top spending categories
     * @return AI-generated guidance from Gemini API or null if failed
     */
    private static String getGeminiGuidance(String surplusStatus, double budgetUtilization,
                                           double averageDailyExpense, double totalBudget,
                                           double surplusDeficitAmount, String spendingTrend,
                                           Map<String, Double> topCategories) {
        try {
            // Check if API key is available
            if (GEMINI_API_KEY == null || GEMINI_API_KEY.trim().isEmpty()) {
                System.out.println("[AIService] Gemini API key not configured. Using rule-based guidance.");
                return null;
            }

            // Build the prompt for Gemini
            String prompt = buildFinancialPrompt(surplusStatus, budgetUtilization,
                                               averageDailyExpense, totalBudget,
                                               surplusDeficitAmount, spendingTrend,
                                               topCategories);

            // Call Gemini API
            String jsonResponse = callGeminiAPI(prompt);
            
            // Parse and extract the guidance from response
            String guidance = parseGeminiResponse(jsonResponse);
            
            if (guidance != null && !guidance.isEmpty()) {
                System.out.println("[AIService] Successfully generated guidance using Gemini API");
                return guidance;
            }
            
        } catch (Exception e) {
            System.err.println("[AIService] Error calling Gemini API: " + e.getMessage());
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Build a comprehensive financial analysis prompt for Gemini
     */
    private static String buildFinancialPrompt(String surplusStatus, double budgetUtilization,
                                              double averageDailyExpense, double totalBudget,
                                              double surplusDeficitAmount, String spendingTrend,
                                              Map<String, Double> topCategories) {
        StringBuilder prompt = new StringBuilder();
        
        prompt.append("You are a financial advisor for a student. Analyze the following budget data and provide concise, actionable financial guidance in 3-4 sentences:\n\n");
        
        prompt.append("Budget Status: ").append(surplusStatus).append("\n");
        prompt.append("Budget Utilization: ").append(String.format("%.1f", budgetUtilization)).append("%\n");
        prompt.append("Total Budget: RM").append(String.format("%.2f", totalBudget)).append("\n");
        prompt.append("Average Daily Expense: RM").append(String.format("%.2f", averageDailyExpense)).append("\n");
        
        if (surplusDeficitAmount > 0) {
            prompt.append("Surplus Amount: RM").append(String.format("%.2f", surplusDeficitAmount)).append("\n");
        } else if (surplusDeficitAmount < 0) {
            prompt.append("Deficit Amount: RM").append(String.format("%.2f", Math.abs(surplusDeficitAmount))).append("\n");
        }
        
        prompt.append("Spending Trend: ").append(spendingTrend).append("\n");
        
        if (topCategories != null && !topCategories.isEmpty()) {
            prompt.append("Top Spending Categories: ");
            topCategories.forEach((category, amount) -> 
                prompt.append(category).append(" (RM").append(String.format("%.2f", amount)).append("), ")
            );
            prompt.append("\n");
        }
        
        prompt.append("\nProvide specific, practical recommendations for this student's financial situation. ");
        prompt.append("Start with an emoji relevant to the situation. Be encouraging but realistic.");
        
        return prompt.toString();
    }

    /**
     * Call the Gemini API with the given prompt
     */
    private static String callGeminiAPI(String prompt) throws Exception {
        URL url = new URL(GEMINI_API_URL + "?key=" + GEMINI_API_KEY);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        
        connection.setRequestMethod("POST");
        connection.setRequestProperty("Content-Type", "application/json");
        connection.setConnectTimeout(API_TIMEOUT);
        connection.setReadTimeout(API_TIMEOUT);
        
        // Build JSON request
        String jsonRequest = buildGeminiRequest(prompt);
        
        // Send request
        connection.setDoOutput(true);
        try (OutputStream os = connection.getOutputStream()) {
            byte[] input = jsonRequest.getBytes("utf-8");
            os.write(input, 0, input.length);
        }
        
        // Read response
        int responseCode = connection.getResponseCode();
        if (responseCode != 200) {
            System.err.println("[AIService] Gemini API returned status code: " + responseCode);
            return null;
        }
        
        StringBuilder response = new StringBuilder();
        try (Scanner scanner = new Scanner(connection.getInputStream(), "utf-8")) {
            while (scanner.hasNextLine()) {
                response.append(scanner.nextLine());
            }
        }
        
        return response.toString();
    }

    /**
     * Build JSON request for Gemini API
     */
    private static String buildGeminiRequest(String prompt) {
        // Escape quotes and newlines in prompt
        String escapedPrompt = prompt.replace("\"", "\\\"").replace("\n", "\\n");
        
        return "{\n" +
               "  \"contents\": [{\n" +
               "    \"parts\": [{\n" +
               "      \"text\": \"" + escapedPrompt + "\"\n" +
               "    }]\n" +
               "  }],\n" +
               "  \"generationConfig\": {\n" +
               "    \"temperature\": 0.7,\n" +
               "    \"topP\": 0.95,\n" +
               "    \"topK\": 40,\n" +
               "    \"maxOutputTokens\": 500\n" +
               "  }\n" +
               "}";
    }

    /**
     * Parse Gemini API response to extract guidance text
     */
    private static String parseGeminiResponse(String jsonResponse) {
        try {
            // Simple JSON parsing to extract text content
            // Looking for: "candidates": [{"content": {"parts": [{"text": "..."}]}}]
            
            int textStart = jsonResponse.indexOf("\"text\": \"");
            if (textStart == -1) {
                return null;
            }
            
            textStart += "\"text\": \"".length();
            int textEnd = jsonResponse.indexOf("\"", textStart);
            
            if (textEnd == -1) {
                return null;
            }
            
            String guidance = jsonResponse.substring(textStart, textEnd);
            
            // Unescape the text
            guidance = guidance.replace("\\n", "\n")
                              .replace("\\\"", "\"")
                              .replace("\\\\", "\\");
            
            return guidance.trim();
            
        } catch (Exception e) {
            System.err.println("[AIService] Error parsing Gemini response: " + e.getMessage());
            return null;
        }
    }

    /**
     * Generate rule-based financial guidance (fallback when API is unavailable)
     * This preserves the original logic from TrackingProgressCalculator
     * 
     * @param surplusStatus Status of budget (surplus, deficit, or balanced)
     * @param budgetUtilization Percentage of budget used
     * @param averageDailyExpense Average daily spending amount
     * @param totalBudget Total budget for the month
     * @param surplusDeficitAmount Amount of surplus or deficit
     * @return Rule-based financial guidance string
     */
    public static String generateRuleBasedGuidance(String surplusStatus, double budgetUtilization,
                                                   double averageDailyExpense, double totalBudget,
                                                   double surplusDeficitAmount) {
        StringBuilder guidance = new StringBuilder();

        // Analyze surplus status and provide specific guidance
        if ("surplus".equals(surplusStatus)) {
            // Surplus detected - recommend savings
            guidance.append("✓ Great job! You have surplus remaining.\n");
            guidance.append("💡 Recommendation: Allocate ").append(String.format("%.2f", surplusDeficitAmount))
                    .append(" to emergency savings fund.\n");
            guidance.append("📊 You are using ").append(String.format("%.1f", budgetUtilization))
                    .append("% of your monthly budget.\n");
        }
        // Deficit detected - provide corrective actions
        else if ("deficit".equals(surplusStatus)) {
            guidance.append("⚠ Alert: You have exceeded your budget!\n");
            guidance.append("💡 Recommendation: Reduce daily spending to ").append(String.format("%.2f", averageDailyExpense * 0.8))
                    .append(" per day to stay on track.\n");
            guidance.append("📊 You are using ").append(String.format("%.1f", budgetUtilization))
                    .append("% of your monthly budget.\n");
            guidance.append("💭 Review high-spending categories and adjust habits.\n");
        }
        // Balanced status - encourage maintenance
        else {
            guidance.append("✓ You are on track with your budget!\n");
            guidance.append("💡 Recommendation: Maintain current spending patterns.\n");
            guidance.append("📊 You are using ").append(String.format("%.1f", budgetUtilization))
                    .append("% of your monthly budget.\n");
            guidance.append("📈 Current daily average: ").append(String.format("%.2f", averageDailyExpense)).append("\n");
        }

        return guidance.toString();
    }

    /**
     * Generate simple rule-based guidance with spending trend analysis
     * 
     * @param surplusStatus Budget status
     * @param spendingTrend Direction of spending trend
     * @return Guidance string
     */
    public static String generateQuickGuidance(String surplusStatus, String spendingTrend) {
        StringBuilder guidance = new StringBuilder();
        
        if ("increasing".equals(spendingTrend)) {
            guidance.append("⚠️ Your spending is increasing! ");
        } else if ("decreasing".equals(spendingTrend)) {
            guidance.append("✅ Great! Your spending is decreasing. ");
        } else {
            guidance.append("📊 Your spending is stable. ");
        }
        
        if ("surplus".equals(surplusStatus)) {
            guidance.append("Continue managing your budget wisely!");
        } else if ("deficit".equals(surplusStatus)) {
            guidance.append("You need to reduce spending immediately.");
        } else {
            guidance.append("You're on track!");
        }
        
        return guidance.toString();
    }
}
