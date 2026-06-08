<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.pocketpilot.util.DatabaseConnection" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tracking Progress - PocketPilot</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: #F5F1E8;
            min-height: 100vh;
        }
        
        .header {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
            padding: 20px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            font-size: 28px;
            margin-bottom: 5px;
        }
        
        .header p {
            font-size: 14px;
            opacity: 0.9;
        }
        
        /* Top Horizontal Navbar */
        .navbar {
            background: white;
            padding: 0 40px;
            display: flex;
            gap: 25px;
            border-bottom: 1px solid #E0D5C7;
            align-items: center;
            height: 60px;
            position: sticky;
            top: 0;
            z-index: 1000;
        }
        
        .navbar a {
            color: #6B46C1;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            height: 100%;
            display: flex;
            align-items: center;
            transition: all 0.3s;
            border-bottom: 3px solid transparent;
        }
        
        .navbar a:hover {
            color: #8B5CF6;
        }

        .navbar a.active {
            color: #8B5CF6;
            border-bottom: 3px solid #8B5CF6;
        }

        .logout-btn {
            margin-left: auto;
            background: #8B5CF6 !important;
            color: white !important;
            padding: 8px 15px;
            border-radius: 5px;
            height: auto !important;
            border-bottom: none !important;
        }
        
        .logout-btn:hover {
            background: #6B46C1 !important;
            color: white !important;
        }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .controls {
            display: flex;
            gap: 15px;
            align-items: center;
            margin-bottom: 30px;
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0,0,0,0.05);
        }
        
        .controls input {
            padding: 10px 15px;
            border: 2px solid #E0D5C7;
            border-radius: 8px;
            font-size: 14px;
        }
        
        .btn {
            padding: 10px 20px;
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
            text-decoration: none;
        }
        
        .btn-download {
            background: #2e7d32;
        }

        /* Stats and Charts */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #6B46C1;
            text-align: center;
        }
        
        .stat-card h3 {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }
        
        .stat-card .amount {
            color: #6B46C1;
            font-size: 24px;
            font-weight: bold;
        }

        .stat-card.surplus { border-left-color: #2e7d32; }
        .stat-card.surplus .amount { color: #2e7d32; }

        .stat-card.deficit { border-left-color: #c62828; }
        .stat-card.deficit .amount { color: #c62828; }
        
        .ai-box {
            background: linear-gradient(135deg, #E9D5FF 0%, #F3E8FF 100%);
            border-left: 4px solid #6B46C1;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .ai-box h3 {
            margin-bottom: 10px;
        }
        
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }

        .chart-container h2 {
            font-size: 16px;
            margin-bottom: 15px;
            color: #6B46C1;
        }

        .chart-wrapper { height: 300px; position: relative; }

        .table-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
            margin-bottom: 20px;
        }

        .table-container h3 {
            color: #6B46C1;
            margin-bottom: 15px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        table th {
            background: #F5F1E8;
            padding: 12px;
            text-align: left;
            color: #6B46C1;
            border-bottom: 2px solid #6B46C1;
        }

        table td {
            padding: 12px;
            border-bottom: 1px solid #E0D5C7;
        }

        .no-data {
            text-align: center;
            padding: 20px;
            color: #999;
        }

        .no-data a {
            color: #6B46C1;
            text-decoration: none;
            font-weight: 600;
        }

        @media (max-width: 768px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        Integer userID = (Integer) session.getAttribute("userID");
        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Get student ID
        Integer studentID = null;
        Connection conn = null;
        PreparedStatement stmt = null;
        ResultSet rs = null;

        try {
            conn = DatabaseConnection.getConnection();
            String sql = "SELECT studentID FROM Student WHERE userID = ?";
            stmt = conn.prepareStatement(sql);
            stmt.setInt(1, userID);
            rs = stmt.executeQuery();

            if (rs.next()) {
                studentID = rs.getInt("studentID");
            }
        } catch (Exception e) {
            System.err.println("Error getting student ID: " + e.getMessage());
        } finally {
            try {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            } catch (Exception e) {}
        }

        // Get date parameters
        String startDateParam = request.getParameter("startDate");
        String endDateParam = request.getParameter("endDate");
        String startDate = startDateParam != null && !startDateParam.isEmpty() ? startDateParam : "2025-01-01";
        String endDate = endDateParam != null && !endDateParam.isEmpty() ? endDateParam : "2025-12-31";

        // Initialize totals
        double totalBudget = 0;
        double totalExpense = 0;
        List<Map<String, Object>> budgetList = new ArrayList<>();
        List<Map<String, Object>> expenseList = new ArrayList<>();
        Map<String, Double> categorySpending = new LinkedHashMap<>();

        // Fetch budget and expense data
        if (studentID != null) {
            try {
                conn = DatabaseConnection.getConnection();

                // Get budgets
                String budgetSQL = "SELECT b.budgetID, b.budgetAmount, b.budgetDesc, b.createdDate, c.categoryName " +
                                  "FROM Budget b " +
                                  "JOIN Category c ON b.categoryID = c.categoryID " +
                                  "WHERE b.studentID = ? AND DATE(b.createdDate) BETWEEN ? AND ? " +
                                  "ORDER BY b.createdDate DESC";
                stmt = conn.prepareStatement(budgetSQL);
                stmt.setInt(1, studentID);
                stmt.setString(2, startDate);
                stmt.setString(3, endDate);
                rs = stmt.executeQuery();

                while (rs.next()) {
                    Map<String, Object> budget = new HashMap<>();
                    budget.put("category", rs.getString("categoryName"));
                    budget.put("amount", rs.getDouble("budgetAmount"));
                    budget.put("date", rs.getDate("createdDate"));
                    budget.put("description", rs.getString("budgetDesc"));
                    budgetList.add(budget);
                    totalBudget += rs.getDouble("budgetAmount");
                }

                rs.close();
                stmt.close();

                // Get expenses
                String expenseSQL = "SELECT e.expenseID, e.expenseAmount, e.expenseDesc, e.expenseDate, c.categoryName " +
                                   "FROM Expense e " +
                                   "JOIN Category c ON e.categoryID = c.categoryID " +
                                   "WHERE e.studentID = ? AND DATE(e.expenseDate) BETWEEN ? AND ? " +
                                   "ORDER BY e.expenseDate DESC";
                stmt = conn.prepareStatement(expenseSQL);
                stmt.setInt(1, studentID);
                stmt.setString(2, startDate);
                stmt.setString(3, endDate);
                rs = stmt.executeQuery();

                while (rs.next()) {
                    Map<String, Object> expense = new HashMap<>();
                    expense.put("date", rs.getDate("expenseDate"));
                    expense.put("category", rs.getString("categoryName"));
                    expense.put("amount", rs.getDouble("expenseAmount"));
                    expense.put("description", rs.getString("expenseDesc"));
                    expenseList.add(expense);
                    totalExpense += rs.getDouble("expenseAmount");

                    // Track spending by category
                    String category = rs.getString("categoryName");
                    categorySpending.put(category, categorySpending.getOrDefault(category, 0.0) + rs.getDouble("expenseAmount"));
                }

            } catch (Exception e) {
                System.err.println("Error fetching data: " + e.getMessage());
                e.printStackTrace();
            } finally {
                try {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                } catch (Exception e) {}
            }
        }

        // Calculate metrics
        double surplus = totalBudget - totalExpense;
        double budgetUsage = totalBudget > 0 ? (totalExpense / totalBudget) * 100 : 0;
        
        // Calculate days between dates
        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
        java.util.Date start = sdf.parse(startDate);
        java.util.Date end = sdf.parse(endDate);
        long daysDifference = (end.getTime() - start.getTime()) / (1000 * 60 * 60 * 24) + 1;
        double dailyAverage = daysDifference > 0 ? totalExpense / daysDifference : 0;

        // Prepare data for charts (top 5 categories)
        List<String> topCategories = new ArrayList<>();
        List<Double> topCategoryAmounts = new ArrayList<>();
        int count = 0;
        for (Map.Entry<String, Double> entry : categorySpending.entrySet()) {
            if (count >= 5) break;
            topCategories.add(entry.getKey());
            topCategoryAmounts.add(entry.getValue());
            count++;
        }

        // Build JSON arrays for JavaScript
        StringBuilder categoryJsonArray = new StringBuilder("[");
        for (int i = 0; i < topCategories.size(); i++) {
            categoryJsonArray.append("\"").append(topCategories.get(i)).append("\"");
            if (i < topCategories.size() - 1) categoryJsonArray.append(",");
        }
        categoryJsonArray.append("]");

        StringBuilder amountJsonArray = new StringBuilder("[");
        for (int i = 0; i < topCategoryAmounts.size(); i++) {
            amountJsonArray.append(String.format("%.2f", topCategoryAmounts.get(i)));
            if (i < topCategoryAmounts.size() - 1) amountJsonArray.append(",");
        }
        amountJsonArray.append("]");
    %>
    
    <div class="header">
        <h1>📈 Financial Tracking Progress</h1>
        <p>Monitor your financial progress and performance</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="budget.jsp">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="trackingProgress.jsp" style="color: #8B5CF6; border-bottom: 3px solid #8B5CF6; padding-bottom: 12px;">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <!-- Main Content -->
    <div class="container">
            
        <div class="controls">
            <select id="startMonth" onchange="generateReport()">
                <option value="01" selected>January</option>
                <option value="02">February</option>
                <option value="03">March</option>
                <option value="04">April</option>
                <option value="05">May</option>
                <option value="06">June</option>
                <option value="07">July</option>
                <option value="08">August</option>
                <option value="09">September</option>
                <option value="10">October</option>
                <option value="11">November</option>
                <option value="12">December</option>
            </select>
            <input type="number" id="startYear" min="2020" max="2030" value="2025" onchange="generateReport()" style="width: 100px;">
            <span style="margin: 0 10px; color: #999;">to</span>
            <select id="endMonth" onchange="generateReport()">
                <option value="01">January</option>
                <option value="02">February</option>
                <option value="03">March</option>
                <option value="04">April</option>
                <option value="05">May</option>
                <option value="06">June</option>
                <option value="07">July</option>
                <option value="08">August</option>
                <option value="09">September</option>
                <option value="10">October</option>
                <option value="11">November</option>
                <option value="12" selected>December</option>
            </select>
            <input type="number" id="endYear" min="2020" max="2030" value="2025" onchange="generateReport()" style="width: 100px;">
            <button class="btn" onclick="generateReport()">GENERATE</button>
            <a href="#" class="btn btn-download">DOWNLOAD PDF</a>
        </div>
        
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>💰 Total Budget</h3>
                <div class="amount">RM<%= String.format("%.2f", totalBudget) %></div>
            </div>
            <div class="stat-card">
                <h3>💸 Total Expenses</h3>
                <div class="amount">RM<%= String.format("%.2f", totalExpense) %></div>
            </div>
            <div class="stat-card">
                <h3>💵 Daily Average</h3>
                <div class="amount">RM<%= String.format("%.2f", dailyAverage) %></div>
            </div>
            <div class="stat-card <%= surplus >= 0 ? "surplus" : "deficit" %>">
                <h3><%= surplus >= 0 ? "✓ Surplus" : "⚠ Deficit" %></h3>
                <div class="amount">RM<%= String.format("%.2f", Math.abs(surplus)) %></div>
            </div>
            <div class="stat-card">
                <h3>📊 Budget Usage</h3>
                <div class="amount"><%= String.format("%.1f", budgetUsage) %>%</div>
            </div>
        </div>
        
        <!-- AI Guidance -->
        <div class="ai-box">
            <h3>🤖 AI Guidance & Recommendations</h3>
            <p>
            <%
                if (totalBudget == 0 && totalExpense == 0) {
                    out.print("📌 Start by adding your budgets and expenses to see financial insights and recommendations.");
                } else if (budgetUsage > 100) {
                    out.print("⚠️ You have exceeded your budget by " + String.format("%.1f", budgetUsage - 100) + "%. Review your spending and adjust categories as needed.");
                } else if (budgetUsage > 80) {
                    out.print("📌 Your spending is at " + String.format("%.1f", budgetUsage) + "% of your budget. You're approaching the limit. Consider reducing discretionary spending.");
                } else if (budgetUsage > 50) {
                    out.print("✓ Your spending is at " + String.format("%.1f", budgetUsage) + "% of your budget. You're on track. Continue monitoring your expenses.");
                } else {
                    out.print("✓ Great job! Your spending is only " + String.format("%.1f", budgetUsage) + "% of your budget. Keep up the good financial habits!");
                }
            %>
            </p>
        </div>
        
        <!-- Charts -->
        <div class="charts-row">
            <div class="chart-container">
                <h2>Budget vs Expenses Comparison</h2>
                <div class="chart-wrapper">
                    <canvas id="budgetChart"></canvas>
                </div>
            </div>
            
            <div class="chart-container">
                <h2>Top Spending Categories</h2>
                <div class="chart-wrapper">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>
        
        <!-- Budgets Table -->
        <div class="table-container">
            <h3>📋 Budget Breakdown</h3>
            <% if (budgetList.isEmpty()) { %>
                <div class="no-data">No budgets recorded yet. <a href="budget.jsp">Add a budget</a></div>
            <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Budget Amount</th>
                        <th>Date</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                <% 
                java.text.SimpleDateFormat dateFormatter = new java.text.SimpleDateFormat("dd MMMM yyyy");
                for (Map<String, Object> budget : budgetList) { 
                %>
                    <tr>
                        <td><%= budget.get("category") %></td>
                        <td>RM<%= String.format("%.2f", (Double)budget.get("amount")) %></td>
                        <td><%= dateFormatter.format((java.util.Date)budget.get("date")) %></td>
                        <td><%= budget.get("description") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
        
        <!-- Expenses Table -->
        <div class="table-container">
            <h3>📊 Expense Breakdown</h3>
            <% if (expenseList.isEmpty()) { %>
                <div class="no-data">No expenses recorded yet. <a href="expense.jsp">Add an expense</a></div>
            <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Amount</th>
                        <th>Description</th>
                    </tr>
                </thead>
                <tbody>
                <% 
                for (Map<String, Object> expense : expenseList) { 
                %>
                    <tr>
                        <td><%= dateFormatter.format((java.util.Date)expense.get("date")) %></td>
                        <td><%= expense.get("category") %></td>
                        <td>RM<%= String.format("%.2f", (Double)expense.get("amount")) %></td>
                        <td><%= expense.get("description") %></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>
    
    <script>
        const chartDataBudget = <%= totalBudget %>;
        const chartDataExpense = <%= totalExpense %>;
        const chartCategories = <%= categoryJsonArray.toString() %>;
        const chartCategoryAmounts = <%= amountJsonArray.toString() %>;

        function generateReport() {
            const startMonth = document.getElementById('startMonth').value;
            const startYear = document.getElementById('startYear').value;
            const endMonth = document.getElementById('endMonth').value;
            const endYear = document.getElementById('endYear').value;
            
            if (startMonth && startYear && endMonth && endYear) {
                const startDate = startYear + '-' + startMonth + '-01';
                // Get last day of month
                const endDateObj = new Date(endYear, endMonth, 0);
                const endDate = endYear + '-' + endMonth + '-' + endDateObj.getDate();
                window.location.href = 'trackingProgress.jsp?startDate=' + startDate + '&endDate=' + endDate;
            }
        }
        
        function updateCharts() {
            // Budget vs Expense Chart
            const budgetCtx = document.getElementById('budgetChart').getContext('2d');
            new Chart(budgetCtx, {
                type: 'bar',
                data: {
                    labels: ['Budget', 'Expense'],
                    datasets: [{
                        label: 'Amount (RM)',
                        data: [chartDataBudget, chartDataExpense],
                        backgroundColor: ['#6B46C1', '#8B5CF6'],
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                }
            });
            
            // Category Chart
            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: chartCategories.length > 0 ? chartCategories : ['No data'],
                    datasets: [{
                        data: chartCategoryAmounts.length > 0 ? chartCategoryAmounts : [100],
                        backgroundColor: ['#6B46C1', '#8B5CF6', '#C084FC', '#D8B4FE', '#E9D5FF']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { position: 'bottom' } }
                }
            });
        }
        
        // Initialize charts on page load
        window.onload = function() {
            updateCharts();
        };
    </script>
</body>
</html>
