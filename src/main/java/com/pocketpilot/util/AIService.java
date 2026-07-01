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

    private static final String GROQ_API_KEY = System.getenv("GROQ_API_KEY");
    private static final String GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";
    private static final int API_TIMEOUT = 10000;

    public static String generateAIGuidance(String surplusStatus, double budgetUtilization,
            double averageDailyExpense, double totalBudget,
            double surplusDeficitAmount, Map<String, String> spendingTrend,
            Map<String, Double> topCategories) {

        String aiGuidance = getGroqGuidance(surplusStatus, budgetUtilization, averageDailyExpense,
                totalBudget, surplusDeficitAmount, spendingTrend, topCategories);

        if (aiGuidance == null || aiGuidance.isEmpty()) {
            aiGuidance = generateRuleBasedGuidance(surplusStatus, budgetUtilization, averageDailyExpense, totalBudget,
                    surplusDeficitAmount);
        }
        return aiGuidance;
    }

    private static String getGroqGuidance(String surplusStatus, double budgetUtilization,
            double averageDailyExpense, double totalBudget,
            double surplusDeficitAmount, Map<String, String> spendingTrend,
            Map<String, Double> topCategories) {
        try {
            if (GROQ_API_KEY == null || GROQ_API_KEY.trim().isEmpty())
                return null;

            String prompt = buildFinancialPrompt(surplusStatus, budgetUtilization, averageDailyExpense,
                    totalBudget, surplusDeficitAmount, spendingTrend, topCategories);
            String jsonResponse = callGroqAPI(prompt);
            return parseGroqResponse(jsonResponse);
        } catch (Exception e) {
            System.err.println("[AIService] Guidance generation failed: " + e.getMessage());
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
                .append(", Trend=").append(spendingTrend.get("trend")).append(" (")
                .append(spendingTrend.get("percentage")).append(").");

        if (topCategories != null && !topCategories.isEmpty()) {
            prompt.append(" Top spending categories: ").append(topCategories.toString()).append(".");
        }

        if ("deficit".equals(surplusStatus)) {
            prompt.append(" The student has a deficit of RM")
                    .append(String.format("%.2f", Math.abs(surplusDeficitAmount)))
                    .append(". Based on the top spending categories, identify where they should cut back and spend less to get back on track.");
        } else if ("surplus".equals(surplusStatus)) {
            prompt.append(" The student has a surplus of RM")
                    .append(String.format("%.2f", Math.abs(surplusDeficitAmount)))
                    .append(". Provide advice on where to allocate this surplus, specifically suggesting putting it into an Emergency Fund or allocating it toward a goal they have set.");
        } else {
            prompt.append(
                    " The budget is balanced. Suggest setting aside a small amount of money into an Emergency Fund or student goals.");
        }

        prompt.append(" Provide 3-4 sentences of actionable, encouraging financial advice.");
        return prompt.toString();
    }

    private static String callGroqAPI(String prompt) throws Exception {
        URL url = new URL(GROQ_API_URL);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setRequestProperty("Authorization", "Bearer " + GROQ_API_KEY);
        conn.setConnectTimeout(API_TIMEOUT);
        conn.setDoOutput(true);

        JsonObject requestBody = new JsonObject();
        requestBody.addProperty("model", "llama-3.1-8b-instant");
        requestBody.addProperty("temperature", 0.2);
        JsonArray messages = new JsonArray();
        JsonObject message = new JsonObject();
        message.addProperty("role", "user");
        message.addProperty("content", prompt);
        messages.add(message);
        requestBody.add("messages", messages);
        String json = requestBody.toString();

        try (OutputStream os = conn.getOutputStream()) {
            os.write(json.getBytes("utf-8"));
        }

        int responseCode = conn.getResponseCode();
        if (responseCode >= 400) {
            java.io.InputStream errStream = conn.getErrorStream();
            if (errStream != null) {
                try (Scanner scanner = new Scanner(errStream, "utf-8")) {
                    String errResponse = scanner.hasNext() ? scanner.useDelimiter("\\A").next() : "";
                    System.err.println("[AIService] Groq API returned error " + responseCode + ": " + errResponse);
                }
            }
            throw new RuntimeException("HTTP error code: " + responseCode);
        }

        try (Scanner scanner = new Scanner(conn.getInputStream(), "utf-8")) {
            return scanner.hasNext() ? scanner.useDelimiter("\\A").next() : "";
        }
    }

    private static String parseGroqResponse(String json) {
        try {
            JsonObject responseObj = JsonParser.parseString(json).getAsJsonObject();
            JsonArray choices = responseObj.getAsJsonArray("choices");
            if (choices != null && choices.size() > 0) {
                JsonObject firstChoice = choices.get(0).getAsJsonObject();
                JsonObject message = firstChoice.getAsJsonObject("message");
                if (message != null) {
                    return message.get("content").getAsString().trim();
                }
            }
        } catch (Exception e) {
            System.err.println("[AIService] Groq Gson parsing failed: " + e.getMessage());
        }
        return null;
    }

    public static int suggestCategoryID(String description) {
        if (description == null || description.trim().isEmpty()) {
            return 8; // Default to 'Other'
        }
        if (GROQ_API_KEY != null && !GROQ_API_KEY.trim().isEmpty()) {
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
                String jsonResponse = callGroqAPI(prompt);
                String result = parseGroqResponse(jsonResponse);
                if (result != null) {
                    result = result.trim();
                    if (result.matches("[1-8]")) {
                        System.out.println("[AIService] Category successfully suggested by GROQ AI: " + result
                                + " for description: \"" + description + "\"");
                        return Integer.parseInt(result);
                    }
                }
            } catch (Exception e) {
                System.err.println("[AIService] Groq API request failed: " + e.getMessage());
            }
        }

        System.out.println("[AIService] Category suggested by Fallback Default: 8 (Other) for description: \""
                + description + "\"");
        return 8;
    }
}