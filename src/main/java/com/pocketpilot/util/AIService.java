package com.pocketpilot.util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Map;
import java.util.Scanner;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonArray;

public class AIService {

    private static final String GEMINI_API_KEY = System.getenv("GEMINI_API_KEY");
    private static final String GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";
    private static final int API_TIMEOUT = 10000;

    public static String generateAIGuidance(String surplusStatus, double budgetUtilization,
                                            double averageDailyExpense, double totalBudget,
                                            double surplusDeficitAmount, Map<String, String> spendingTrend,
                                            Map<String, Double> topCategories) {
        
        String aiGuidance = getGeminiGuidance(surplusStatus, budgetUtilization, averageDailyExpense, 
                                              totalBudget, surplusDeficitAmount, spendingTrend, topCategories);
        
        if (aiGuidance == null || aiGuidance.isEmpty()) {
            aiGuidance = generateRuleBasedGuidance(surplusStatus, budgetUtilization, averageDailyExpense, totalBudget, surplusDeficitAmount);
        }
        return aiGuidance;
    }

    private static String getGeminiGuidance(String surplusStatus, double budgetUtilization,
                                            double averageDailyExpense, double totalBudget,
                                            double surplusDeficitAmount, Map<String, String> spendingTrend,
                                            Map<String, Double> topCategories) {
        try {
            if (GEMINI_API_KEY == null || GEMINI_API_KEY.trim().isEmpty()) return null;

            String prompt = buildFinancialPrompt(surplusStatus, budgetUtilization, averageDailyExpense, 
                                                 totalBudget, surplusDeficitAmount, spendingTrend, topCategories);
            String jsonResponse = callGeminiAPI(prompt);
            return parseGeminiResponse(jsonResponse);
        } catch (Exception e) {
            return null;
        }
    }

    private static String buildFinancialPrompt(String surplusStatus, double budgetUtilization,
                                              double averageDailyExpense, double totalBudget,
                                              double surplusDeficitAmount, Map<String, String> spendingTrend,
                                              Map<String, Double> topCategories) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Analyze this student budget: Status=").append(surplusStatus)
              .append(", Utilization=").append(String.format("%.1f%%", budgetUtilization))
              .append(", Budget=RM").append(String.format("%.2f", totalBudget))
              .append(", AvgDaily=RM").append(String.format("%.2f", averageDailyExpense))
              .append(", Trend=").append(spendingTrend.get("trend")).append(" (").append(spendingTrend.get("percentage")).append(").")
              .append(" Provide 3-4 sentences of actionable, encouraging financial advice.");
        return prompt.toString();
    }

    private static String callGeminiAPI(String prompt) throws Exception {
        URL url = new URL(GEMINI_API_URL + "?key=" + GEMINI_API_KEY);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setConnectTimeout(API_TIMEOUT);
        conn.setDoOutput(true);
        
        String json = "{\"contents\": [{\"parts\": [{\"text\": \"" + prompt.replace("\"", "\\\"") + "\"}]}]}";
        try (OutputStream os = conn.getOutputStream()) { os.write(json.getBytes("utf-8")); }
        
        try (Scanner scanner = new Scanner(conn.getInputStream(), "utf-8")) {
            return scanner.hasNextLine() ? scanner.nextLine() : "";
        }
    }

    private static String parseGeminiResponse(String json) {
        try {
            JsonObject responseObj = JsonParser.parseString(json).getAsJsonObject();
            JsonArray candidates = responseObj.getAsJsonArray("candidates");
            if (candidates != null && candidates.size() > 0) {
                JsonObject firstCandidate = candidates.get(0).getAsJsonObject();
                JsonObject content = firstCandidate.getAsJsonObject("content");
                if (content != null) {
                    JsonArray parts = content.getAsJsonArray("parts");
                    if (parts != null && parts.size() > 0) {
                        return parts.get(0).getAsJsonObject().get("text").getAsString().trim();
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[AIService] Gson parsing failed: " + e.getMessage());
        }
        return null;
    }

    public static String generateRuleBasedGuidance(String status, double util, double avg, double budget, double diff) {
        if ("surplus".equals(status)) return "✓ Great job! You have a surplus of RM" + String.format("%.2f", diff) + ". Keep it up!";
        if ("deficit".equals(status)) return "⚠ Alert: You exceeded your budget. Try reducing daily spend to RM" + String.format("%.2f", avg * 0.8) + ".";
        return "✓ You are on track with your budget. Maintain your current spending habits.";
    }

    public static int suggestCategoryID(String description) {
        if (description == null || description.trim().isEmpty()) {
            return 8; // Default to 'Other'
        }
        // First try Gemini API if key is available
        if (GEMINI_API_KEY != null && !GEMINI_API_KEY.trim().isEmpty()) {
            try {
                String prompt = "Given the following transaction description: \"" + description.replace("\"", "\\\"") + 
                                "\", classify it into one of these category IDs:\n" +
                                "1 - Education (tuition, books, supplies, school fees)\n" +
                                "2 - Food (meals, groceries, dining out, drinks, coffee)\n" +
                                "3 - Transport (bus, taxi, train, fuel, Grab, commute)\n" +
                                "4 - Entertainment (movies, games, concerts, fun, hobbies)\n" +
                                "5 - Utilities (electricity, water, gas, internet, mobile bills)\n" +
                                "6 - Healthcare (medicines, clinics, gym, fitness, health)\n" +
                                "7 - Shopping (clothes, shoes, gifts, gadgets, retail)\n" +
                                "8 - Other (general, miscellaneous, everything else)\n\n" +
                                "Respond with ONLY the single number of the category ID (1-8). No other words, punctuation, or formatting.";
                String jsonResponse = callGeminiAPI(prompt);
                String result = parseGeminiResponse(jsonResponse);
                if (result != null) {
                    result = result.trim();
                    if (result.matches("[1-8]")) {
                        return Integer.parseInt(result);
                    }
                }
            } catch (Exception e) {
                // Ignore and fall back to rule-based suggestion
            }
        }
        
        // Rule-based fallback
        return getRuleBasedCategorySuggestion(description);
    }

    public static int getRuleBasedCategorySuggestion(String description) {
        if (description == null || description.trim().isEmpty()) {
            return 8; // Default to 'Other'
        }
        String desc = description.toLowerCase();
        
        // Education
        if (desc.contains("book") || desc.contains("pen") || desc.contains("pencil") || desc.contains("notebook") || 
            desc.contains("stationery") || desc.contains("school") || desc.contains("tuition") || desc.contains("exam") || 
            desc.contains("fee") || desc.contains("course") || desc.contains("class") || desc.contains("material")) {
            return 1;
        }
        
        // Food
        if (desc.contains("food") || desc.contains("eat") || desc.contains("lunch") || desc.contains("dinner") || 
            desc.contains("breakfast") || desc.contains("restaurant") || desc.contains("cafe") || desc.contains("meal") || 
            desc.contains("snack") || desc.contains("drink") || desc.contains("coffee") || desc.contains("starbucks") || 
            desc.contains("mcd") || desc.contains("kfc") || desc.contains("grocery") || desc.contains("groceries") || 
            desc.contains("rice") || desc.contains("water") || desc.contains("dine") || desc.contains("dining")) {
            return 2;
        }
        
        // Transport
        if (desc.contains("taxi") || desc.contains("bus") || desc.contains("transport") || desc.contains("fuel") || 
            desc.contains("car") || desc.contains("bike") || desc.contains("train") || desc.contains("travel") || 
            desc.contains("commute") || desc.contains("grab") || desc.contains("petrol") || desc.contains("parking") || 
            desc.contains("toll") || desc.contains("lrt") || desc.contains("mrt")) {
            return 3;
        }
        
        // Entertainment
        if (desc.contains("movie") || desc.contains("game") || desc.contains("entertainment") || desc.contains("play") || 
            desc.contains("cinema") || desc.contains("fun") || desc.contains("hobby") || desc.contains("recreation") || 
            desc.contains("ticket") || desc.contains("concert") || desc.contains("netflix") || desc.contains("spotify") || 
            desc.contains("steam") || desc.contains("pubg")) {
            return 4;
        }
        
        // Utilities
        if (desc.contains("electricity") || desc.contains("water") || desc.contains("gas") || desc.contains("internet") || 
            desc.contains("utility") || desc.contains("bill") || desc.contains("phone") || desc.contains("mobile") || 
            desc.contains("wifi") || desc.contains("unifi") || desc.contains("digi") || desc.contains("maxis") || 
            desc.contains("celcom") || desc.contains("hotlink")) {
            return 5;
        }
        
        // Healthcare
        if (desc.contains("gym") || desc.contains("fitness") || desc.contains("health") || desc.contains("exercise") || 
            desc.contains("sport") || desc.contains("medicine") || desc.contains("doctor") || desc.contains("medical") || 
            desc.contains("clinic") || desc.contains("hospital") || desc.contains("pill") || desc.contains("dentist") || 
            desc.contains("supplement")) {
            return 6;
        }
        
        // Shopping
        if (desc.contains("cloth") || desc.contains("shirt") || desc.contains("pant") || desc.contains("shoe") || 
            desc.contains("dress") || desc.contains("clothing") || desc.contains("wear") || desc.contains("apparel") || 
            desc.contains("fashion") || desc.contains("gift") || desc.contains("gadget") || desc.contains("shopee") || 
            desc.contains("lazada") || desc.contains("amazon") || desc.contains("mall") || desc.contains("buy")) {
            return 7;
        }
        
        return 8; // Other
    }
}