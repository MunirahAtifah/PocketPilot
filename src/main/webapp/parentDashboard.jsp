<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.pocketpilot.util.DatabaseConnection" %>
<%
    Integer userID = (Integer) session.getAttribute("userID");
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    if (userID == null || !"Parent".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    int parentID = -1;
    List<Map<String, Object>> linkedChildren = new ArrayList<>();
    
    // Connect to database to load parent profile and children list
    try (Connection conn = DatabaseConnection.getConnection()) {
        // 1. Get parentID from userID
        String getParentSql = "SELECT parentID FROM parent WHERE userID = ?";
        try (PreparedStatement stmt = conn.prepareStatement(getParentSql)) {
            stmt.setInt(1, userID);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    parentID = rs.getInt("parentID");
                }
            }
        }

        if (parentID > 0) {
            // 2. Get all approved linked children
            String getChildrenSql = "SELECT s.studentID, s.studentName FROM supervisionaccess sa " +
                                    "JOIN student s ON sa.studentID = s.studentID " +
                                    "WHERE sa.parentID = ? AND sa.approvalStatus = 'Approved'";
            try (PreparedStatement stmt = conn.prepareStatement(getChildrenSql)) {
                stmt.setInt(1, parentID);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> child = new HashMap<>();
                        child.put("studentID", rs.getInt("studentID"));
                        child.put("studentName", rs.getString("studentName"));
                        linkedChildren.add(child);
                    }
                }
            }
        }
    } catch (SQLException e) {
        System.err.println("Database error loading parent properties: " + e.getMessage());
        e.printStackTrace();
    }

    // Determine selected student ID
    String studentParam = request.getParameter("studentID");
    int activeStudentID = -1;
    if (studentParam != null && !studentParam.isEmpty()) {
        try {
            activeStudentID = Integer.parseInt(studentParam);
        } catch (NumberFormatException e) {
            // ignore
        }
    }
    // If no parameter but children exist, default to the first child
    if (activeStudentID == -1 && !linkedChildren.isEmpty()) {
        activeStudentID = (Integer) linkedChildren.get(0).get("studentID");
    }

    // Determine selected month, default to current month
    String monthParam = request.getParameter("month");
    YearMonth selectedMonth;
    if (monthParam != null && monthParam.matches("\\d{4}-\\d{2}")) {
        selectedMonth = YearMonth.parse(monthParam);
    } else {
        selectedMonth = YearMonth.now();
    }
    int monthVal = selectedMonth.getMonthValue();
    int yearVal = selectedMonth.getYear();

    double totalBudget = 0.0;
    double totalExpense = 0.0;
    double dailyAverage = 0.0;
    double budgetUsagePercent = 0.0;
    String statusStr = "-";
    String statusColor = "#7F8C8D";

    double[] weeklyExpenses = new double[5]; // Week 1, 2, 3, 4, 5
    List<Map<String, Object>> childOverviewList = new ArrayList<>();

    // If we have an active child, load financial metrics
    if (activeStudentID > 0) {
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Load budget
            String budgetSql = "SELECT SUM(budgetAmount) FROM budget WHERE studentID = ? AND MONTH(budgetDate) = ? AND YEAR(budgetDate) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(budgetSql)) {
                stmt.setInt(1, activeStudentID);
                stmt.setInt(2, monthVal);
                stmt.setInt(3, yearVal);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        totalBudget = rs.getDouble(1);
                    }
                }
            }

            // Load expenses
            String expenseSql = "SELECT SUM(expenseAmount) FROM expense WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ?";
            try (PreparedStatement stmt = conn.prepareStatement(expenseSql)) {
                stmt.setInt(1, activeStudentID);
                stmt.setInt(2, monthVal);
                stmt.setInt(3, yearVal);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        totalExpense = rs.getDouble(1);
                    }
                }
            }

            // Calculate daily average
            int daysInMonth = selectedMonth.lengthOfMonth();
            if (selectedMonth.equals(YearMonth.now())) {
                daysInMonth = LocalDate.now().getDayOfMonth();
            }
            dailyAverage = totalExpense / (daysInMonth > 0 ? daysInMonth : 1);

            // Calculate utilization & status
            if (totalBudget > 0) {
                budgetUsagePercent = (totalExpense / totalBudget) * 100;
            }

            if (totalBudget == 0 && totalExpense == 0) {
                statusStr = "Inactive";
                statusColor = "#7F8C8D";
            } else if (budgetUsagePercent > 100) {
                statusStr = "Over Budget (" + String.format("%.1f", budgetUsagePercent) + "%)";
                statusColor = "#dc3545"; // Red
            } else if (budgetUsagePercent > 85) {
                statusStr = "Warning (" + String.format("%.1f", budgetUsagePercent) + "%)";
                statusColor = "#ff9800"; // Orange
            } else {
                statusStr = "Good (" + String.format("%.1f", budgetUsagePercent) + "%)";
                statusColor = "#28a745"; // Green
            }

            // Load weekly expenses (split month days 1-7, 8-14, 15-21, 22-28, 29+)
            String weeklySql = "SELECT DAY(expenseDate) as day_num, SUM(expenseAmount) as daily_total FROM expense " +
                               "WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ? " +
                               "GROUP BY DAY(expenseDate)";
            try (PreparedStatement stmt = conn.prepareStatement(weeklySql)) {
                stmt.setInt(1, activeStudentID);
                stmt.setInt(2, monthVal);
                stmt.setInt(3, yearVal);
                try (ResultSet rs = stmt.executeQuery()) {
                    while (rs.next()) {
                        int day = rs.getInt("day_num");
                        double dailyTotal = rs.getDouble("daily_total");
                        int weekIdx = (day - 1) / 7;
                        if (weekIdx >= 0 && weekIdx < 5) {
                            weeklyExpenses[weekIdx] += dailyTotal;
                        }
                    }
                }
            }

            // Load general list of overview for all children in this current month
            for (Map<String, Object> child : linkedChildren) {
                int cid = (Integer) child.get("studentID");
                String cname = (String) child.get("studentName");
                double cBudget = 0.0;
                double cExpense = 0.0;
                
                // Get budget
                String cbSql = "SELECT SUM(budgetAmount) FROM budget WHERE studentID = ? AND MONTH(budgetDate) = ? AND YEAR(budgetDate) = ?";
                try (PreparedStatement stmt = conn.prepareStatement(cbSql)) {
                    stmt.setInt(1, cid);
                    stmt.setInt(2, monthVal);
                    stmt.setInt(3, yearVal);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) cBudget = rs.getDouble(1);
                    }
                }
                
                // Get expense
                String ceSql = "SELECT SUM(expenseAmount) FROM expense WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ?";
                try (PreparedStatement stmt = conn.prepareStatement(ceSql)) {
                    stmt.setInt(1, cid);
                    stmt.setInt(2, monthVal);
                    stmt.setInt(3, yearVal);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) cExpense = rs.getDouble(1);
                    }
                }

                double cPercent = cBudget > 0 ? (cExpense / cBudget) * 100 : 0.0;
                String cStatus = "-";
                String cColor = "#7F8C8D";
                
                if (cBudget == 0 && cExpense == 0) {
                    cStatus = "Inactive";
                    cColor = "#7F8C8D";
                } else if (cPercent > 100) {
                    cStatus = "Over Budget";
                    cColor = "#dc3545";
                } else if (cPercent > 85) {
                    cStatus = "Caution";
                    cColor = "#ff9800";
                } else {
                    cStatus = "Good";
                    cColor = "#28a745";
                }

                Map<String, Object> ov = new HashMap<>();
                ov.put("studentName", cname);
                ov.put("studentID", cid);
                ov.put("budget", cBudget);
                ov.put("expense", cExpense);
                ov.put("percent", cPercent);
                ov.put("status", cStatus);
                ov.put("color", cColor);
                childOverviewList.add(ov);
            }
        } catch (SQLException e) {
            System.err.println("SQL Error loading parent dashboard financials: " + e.getMessage());
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent Dashboard - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css?v=1.0.1">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .header {
            background: var(--header-bg-gradient);
            color: white;
            padding: 30px 20px;
            text-align: center;
            border-bottom-left-radius: 20px;
            border-bottom-right-radius: 20px;
            box-shadow: 0 4px 15px rgba(107, 70, 193, 0.25);
        }
        .header h1 {
            color: white;
            font-size: 32px;
            margin-bottom: 5px;
            font-weight: 700;
        }
        .header p {
            color: #E9D5FF;
            font-size: 15px;
            font-weight: 500;
        }
        .navbar {
            background: var(--glass-bg);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            display: flex;
            gap: 20px;
            border-bottom: 1px solid var(--border-color);
            position: sticky;
            top: 0;
            z-index: 1000;
            justify-content: center;
        }
        .navbar a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.3s;
            padding: 5px 10px;
            border-radius: 6px;
        }
        .navbar a:hover {
            color: var(--primary-hover);
            background: rgba(139, 92, 246, 0.1);
        }
        .navbar a.active {
            color: var(--primary-hover);
            background: rgba(139, 92, 246, 0.15);
            border-bottom: none;
        }
        .logout-btn {
            margin-left: auto;
            background: var(--primary-hover) !important;
            color: white !important;
            padding: 8px 15px;
            border-radius: 6px;
            text-decoration: none;
            font-size: 14px;
            font-weight: 600;
            box-shadow: 0 2px 8px rgba(139, 92, 246, 0.3);
        }
        .logout-btn:hover {
            background: var(--primary-color) !important;
            box-shadow: 0 4px 12px rgba(107, 70, 193, 0.4);
            transform: translateY(-1px);
        }
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        .selector-row {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 30px;
            background: var(--card-bg);
            padding: 15px 25px;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
            border: 1px solid var(--border-color);
            max-width: fit-content;
        }
        .selector-row label {
            margin-bottom: 0;
            color: var(--primary-color);
            font-weight: 700;
            font-size: 15px;
        }
        .selector-row select {
            padding: 8px 16px;
            border: 2px solid var(--border-color);
            border-radius: 8px;
            color: var(--primary-color);
            font-weight: 600;
            font-size: 14px;
            cursor: pointer;
            outline: none;
            transition: all 0.3s;
        }
        .selector-row select:focus {
            border-color: var(--primary-hover);
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: var(--card-bg);
            padding: 25px 20px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border-left: 5px solid var(--primary-color);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
        }
        .stat-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0,0,0,0.08);
        }
        .stat-card h3 {
            color: var(--text-secondary);
            font-size: 13px;
            text-transform: uppercase;
            margin-bottom: 8px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        .stat-card .amount {
            color: var(--primary-color);
            font-size: 32px;
            font-weight: 800;
        }
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 35px;
        }
        .chart-container {
            background: var(--card-bg);
            padding: 25px;
            border-radius: 15px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--border-color);
        }
        .chart-container h2 {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 20px;
            font-weight: 700;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 10px;
        }
        .chart-wrapper {
            position: relative;
            height: 320px;
        }
        .students-table {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--border-color);
            margin-bottom: 30px;
        }
        .students-table h3 {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 20px;
            font-weight: 700;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 10px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table thead {
            background: var(--body-bg);
            border-bottom: 2px solid var(--primary-color);
        }
        table th {
            color: var(--primary-color);
            padding: 14px;
            text-align: left;
            font-weight: 700;
            font-size: 14px;
        }
        table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
            color: var(--title-color);
        }
        table tbody tr:hover {
            background: var(--nav-link-hover-bg);
        }
        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .no-data-alert {
            background: #FFF9E6;
            border-left: 5px solid #FFC107;
            color: #7A5800;
            padding: 20px;
            border-radius: 12px;
            font-size: 15px;
            font-weight: 600;
            text-align: center;
            margin-bottom: 30px;
        }
        @media (max-width: 992px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
            .navbar {
                flex-wrap: wrap;
            }
            .logout-btn {
                margin-left: 0;
                width: 100%;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Welcome, Parent <%= username %></h1>
        <p>Monitor your children's financial activities</p>
    </div>
    
    <div class="navbar">
        <a href="parentDashboard.jsp" class="active">Dashboard</a>
        <a href="TrackingProgressServlet?studentID=<%= activeStudentID %>">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        
        <% if (linkedChildren.isEmpty()) { %>
            <div class="no-data-alert">
                You haven't linked any children to your account yet. Please visit the 
                <a href="supervisionAccess.jsp" style="color: var(--primary-color); text-decoration: underline;">Supervision Access</a> 
                page and use your child's supervision code to link their account.
            </div>
        <% } else { %>
        
            <!-- Selectors Form -->
            <div class="selector-row">
                <label for="studentSelect">Select Child:</label>
                <select id="studentSelect" onchange="loadStudentData()">
                    <% for (Map<String, Object> child : linkedChildren) {
                        int cid = (Integer) child.get("studentID");
                        String cname = (String) child.get("studentName");
                        String selected = (cid == activeStudentID) ? "selected" : "";
                    %>
                        <option value="<%= cid %>" <%= selected %>><%= cname %></option>
                    <% } %>
                </select>
                
                <label for="monthSelect">Month:</label>
                <select id="monthSelect" onchange="loadStudentData()">
                    <%
                        YearMonth curr = YearMonth.now();
                        for (int i = -6; i <= 6; i++) {
                            YearMonth m = curr.plusMonths(i);
                            String val = m.toString();
                            String label = m.getMonth().getDisplayName(java.time.format.TextStyle.SHORT, Locale.ENGLISH) + " " + m.getYear();
                            String selected = val.equals(selectedMonth.toString()) ? "selected" : "";
                    %>
                        <option value="<%= val %>" <%= selected %>><%= label %></option>
                    <% } %>
                </select>
            </div>
            
            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Total Budget</h3>
                    <div class="amount">RM <%= String.format("%.2f", totalBudget) %></div>
                </div>
                <div class="stat-card">
                    <h3>Total Expenses</h3>
                    <div class="amount">RM <%= String.format("%.2f", totalExpense) %></div>
                </div>
                <div class="stat-card">
                    <h3>Status</h3>
                    <div class="amount" style="color: <%= statusColor %>;"><%= statusStr %></div>
                </div>
                <div class="stat-card">
                    <h3>Daily Average</h3>
                    <div class="amount">RM <%= String.format("%.2f", dailyAverage) %></div>
                </div>
            </div>
            
            <!-- Charts Grid -->
            <div class="charts-row">
                <div class="chart-container">
                    <h2>Budget vs Expenses</h2>
                    <div class="chart-wrapper">
                        <canvas id="budgetChart"></canvas>
                    </div>
                </div>
                
                <div class="chart-container">
                    <h2>Weekly Spending Trend</h2>
                    <div class="chart-wrapper">
                        <canvas id="trendChart"></canvas>
                    </div>
                </div>
            </div>
            
            <!-- Children Overview Table -->
            <div class="students-table">
                <h3>Your Children's Overview (This Month)</h3>
                <table>
                    <thead>
                        <tr>
                            <th>Child Name</th>
                            <th>Current Month Expense</th>
                            <th>Monthly Budget</th>
                            <th>Usage %</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> ov : childOverviewList) { %>
                            <tr>
                                <td>
                                    <a href="parentDashboard.jsp?studentID=<%= ov.get("studentID") %>&month=<%= selectedMonth.toString() %>" style="color: var(--primary-color); font-weight: bold; text-decoration: underline;">
                                        <%= ov.get("studentName") %>
                                    </a>
                                </td>
                                <td>RM <%= String.format("%.2f", (Double) ov.get("expense")) %></td>
                                <td>RM <%= String.format("%.2f", (Double) ov.get("budget")) %></td>
                                <td><%= String.format("%.1f", (Double) ov.get("percent")) %>%</td>
                                <td>
                                    <span class="status-badge" style="background: <%= ov.get("color") %>15; color: <%= ov.get("color") %>;">
                                        <%= ov.get("status") %>
                                    </span>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        
        <% } %>
    </div>
    
    <script>
        function loadStudentData() {
            const studentSelect = document.getElementById('studentSelect');
            const monthSelect = document.getElementById('monthSelect');
            if (studentSelect && monthSelect) {
                const childId = studentSelect.value;
                const month = monthSelect.value;
                window.location.href = 'parentDashboard.jsp?studentID=' + childId + '&month=' + month;
            }
        }
        
        // Render Charts using dynamically loaded DB values
        window.addEventListener('DOMContentLoaded', () => {
            <% if (activeStudentID > 0) { %>
                // 1. Budget vs Expense Bar Chart
                const budgetCtx = document.getElementById('budgetChart').getContext('2d');
                new Chart(budgetCtx, {
                    type: 'bar',
                    data: {
                        labels: ['Monthly Budget', 'Monthly Expenses'],
                        datasets: [{
                            label: 'Amount (RM)',
                            data: [<%= totalBudget %>,  <%= totalExpense %>],
                            backgroundColor: ['var(--primary-color)', 'var(--primary-hover)'],
                            borderRadius: 8,
                            barThickness: 50
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: '#F3E8FF' }
                            },
                            x: { grid: { display: false } }
                        }
                    }
                });
                
                // 2. Weekly Trend Line Chart
                const trendCtx = document.getElementById('trendChart').getContext('2d');
                new Chart(trendCtx, {
                    type: 'line',
                    data: {
                        labels: ['Week 1 (1-7)', 'Week 2 (8-14)', 'Week 3 (15-21)', 'Week 4 (22-28)', 'Week 5 (29+)'],
                        datasets: [{
                            label: 'Weekly Spending (RM)',
                            data: [
                                <%= weeklyExpenses[0] %>,
                                <%= weeklyExpenses[1] %>,
                                <%= weeklyExpenses[2] %>,
                                <%= weeklyExpenses[3] %>,
                                <%= weeklyExpenses[4] %>
                            ],
                            borderColor: 'var(--primary-color)',
                            backgroundColor: 'rgba(107, 70, 193, 0.1)',
                            tension: 0.4,
                            fill: true,
                            pointBackgroundColor: 'var(--primary-color)',
                            pointRadius: 5
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: { color: '#F3E8FF' }
                            },
                            x: { grid: { display: false } }
                        }
                    }
                });
            <% } %>
        });
    </script>

<script src="js/theme.js?v=1.0.1"></script>
</body>
</html>
