<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.time.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.pocketpilot.util.DatabaseConnection" %>
<%@ page import="com.pocketpilot.dao.UserDAO" %>
<%@ page import="com.pocketpilot.dao.NotificationDAO" %>
<%@ page import="com.pocketpilot.model.Notification" %>
<%
    Integer userID = (Integer) session.getAttribute("userID");
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");
    if (userID == null || !"Student".equals(role)) {
        response.sendRedirect("login.jsp");
        return;
    }

    UserDAO userDAO = new UserDAO();
    int studentID = userDAO.getStudentIDByUserID(userID);

    // Check and generate any missing notifications for today on page load
    if (studentID != -1) {
        com.pocketpilot.util.NotificationScheduler.checkAndGenerateNotificationsForStudent(studentID);
    }
    List<Notification> unreadNotifications = new ArrayList<>();
    if (studentID != -1) {
        unreadNotifications = NotificationDAO.getUnreadNotifications(studentID);
    }

    // Get selected month from query parameter, default to current month
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
    String aiGuidance = "Select a month to get personalized spending recommendations.";

    // Track category expenses for chart representation
    Map<String, Double> categoryExpenses = new LinkedHashMap<>();
    
    // Connect to local database and retrieve values
    try (Connection conn = DatabaseConnection.getConnection()) {
        // 1. Get total budget for this student in selected month
        String budgetSql = "SELECT SUM(budgetAmount) FROM budget WHERE studentID = ? AND MONTH(budgetDate) = ? AND YEAR(budgetDate) = ?";
        try (PreparedStatement stmt = conn.prepareStatement(budgetSql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, monthVal);
            stmt.setInt(3, yearVal);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    totalBudget = rs.getDouble(1);
                }
            }
        }

        // 2. Get expenses and category breakdown for this student in selected month
        String expenseSql = "SELECT e.expenseAmount, c.categoryName FROM expense e " +
                            "JOIN category c ON e.categoryID = c.categoryID " +
                            "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ?";
        try (PreparedStatement stmt = conn.prepareStatement(expenseSql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, monthVal);
            stmt.setInt(3, yearVal);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    double amt = rs.getDouble("expenseAmount");
                    String catName = rs.getString("categoryName");
                    totalExpense += amt;
                    categoryExpenses.put(catName, categoryExpenses.getOrDefault(catName, 0.0) + amt);
                }
            }
        }

        // 3. Calculate average daily spending
        int daysInMonth = selectedMonth.lengthOfMonth();
        if (selectedMonth.equals(YearMonth.now())) {
            daysInMonth = LocalDate.now().getDayOfMonth();
        }
        dailyAverage = totalExpense / (daysInMonth > 0 ? daysInMonth : 1);

        // 4. Calculate usage percentage
        if (totalBudget > 0) {
            budgetUsagePercent = (totalExpense / totalBudget) * 100;
        }

        // 5. Generate AI Guidance based on actual budget & expense ratios
        if (totalBudget == 0 && totalExpense == 0) {
            aiGuidance = "No budget or expense records found for " + selectedMonth + ". Get started by recording a budget or logging your expenses!";
        } else if (totalBudget == 0) {
            aiGuidance = "You have recorded RM" + String.format("%.2f", totalExpense) + " in expenses, but have not set a budget for " + selectedMonth + ". Go to the Budget tab to set limits!";
        } else if (budgetUsagePercent > 100) {
            aiGuidance = "Over-budget Warning: You have exceeded your monthly limit by RM" + String.format("%.2f", totalExpense - totalBudget) + " (" + String.format("%.1f", budgetUsagePercent) + "% utilization). Please review your category chart to locate major leaks.";
        } else if (budgetUsagePercent > 85) {
            aiGuidance = "Tight Budget Alert: You have utilized " + String.format("%.1f", budgetUsagePercent) + "% of your budget. With only RM" + String.format("%.2f", totalBudget - totalExpense) + " left, freeze non-essential spending.";
        } else {
            aiGuidance = "Healthy Balance: Your spending is under control at " + String.format("%.1f", budgetUsagePercent) + "% of your budget. You have RM" + String.format("%.2f", totalBudget - totalExpense) + " remaining. Excellent job keeping to your goals!";
        }
    } catch (SQLException e) {
        System.err.println("SQL Error loading student dashboard metrics: " + e.getMessage());
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/theme.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        .header {
            background: var(--primary-gradient);
            color: white;
            padding: 30px 20px;
            text-align: center;
            border-bottom-left-radius: 20px;
            border-bottom-right-radius: 20px;
            box-shadow: var(--card-shadow);
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
        .month-selector {
            max-width: fit-content;
        }
        .charts-row {
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 25px;
            margin-bottom: 30px;
        }
        .chart-wrapper {
            position: relative;
            height: 320px;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @media (max-width: 992px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Welcome, Student <%= username %></h1>
        <p>Track your budget and expenses dynamically</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp" class="navbar-brand">PocketPilot</a>
        <button class="menu-toggle" onclick="toggleMobileMenu()">☰</button>
        <div class="navbar-links" id="navbarLinks">
            <a href="studentDashboard.jsp" class="active">Dashboard</a>
            <a href="budget.jsp">Budget</a>
            <a href="expense.jsp">Expense</a>
            <a href="TrackingProgressServlet">Tracking Progress</a>
            <a href="supervisionAccess.jsp">Supervision</a>
            <button class="theme-toggle" onclick="toggleTheme()">🌓 Theme</button>
            <a href="LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>
    
    <div class="container">
        
        <!-- Notification Center Card -->
        <% if (!unreadNotifications.isEmpty()) { %>
        <div class="notification-center" id="notificationCenter" style="margin-bottom: 30px; background: var(--card-bg); padding: 25px; border-radius: 15px; box-shadow: var(--card-shadow); border: 1px solid var(--border-color); border-left: 5px solid #FF9F43; transition: all 0.3s ease;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid var(--border-color); padding-bottom: 10px;">
                <h3 style="color: #D35400; margin: 0; font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                    Notification Center (<span id="notifCount"><%= unreadNotifications.size() %></span>)
                </h3>
                <button onclick="markAllNotificationsAsRead()" style="background: none; border: none; color: #E67E22; font-weight: 600; font-size: 14px; cursor: pointer; transition: color 0.3s;" onmouseover="this.style.color='#D35400'" onmouseout="this.style.color='#E67E22'">
                    Mark All as Read
                </button>
            </div>
            <div style="display: flex; flex-direction: column; gap: 12px;" id="notificationsList">
                <% for (Notification notif : unreadNotifications) { %>
                    <div class="notif-item" id="notif-<%= notif.getNotificationID() %>" style="display: flex; justify-content: space-between; align-items: center; padding: 12px 15px; background: var(--input-bg); border-radius: 8px; border: 1px solid var(--border-color); transition: all 0.3s;">
                        <span style="font-size: 14px; color: var(--text-color); font-weight: 500;"><%= notif.getMessage() %></span>
                        <button onclick="markAsRead(<%= notif.getNotificationID() %>)" style="background: rgba(230, 126, 34, 0.1); border: none; color: #E67E22; padding: 6px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; transition: all 0.3s;" onmouseover="this.style.background='rgba(230,126,34,0.2)'" onmouseout="this.style.background='rgba(230,126,34,0.1)'">
                            Dismiss
                        </button>
                    </div>
                <% } %>
            </div>
        </div>
        <% } %>
        
        <!-- Month Selector Form -->
        <div class="month-selector">
            <label for="monthSelect">Report Month:</label>
            <select id="monthSelect" onchange="loadMonthData()">
                <%
                    YearMonth curr = YearMonth.now();
                    // Generate a range of months from 6 months ago to 6 months in the future
                    for (int i = -6; i <= 6; i++) {
                        YearMonth m = curr.plusMonths(i);
                        String val = m.toString();
                        String label = m.getMonth().getDisplayName(java.time.format.TextStyle.SHORT, Locale.ENGLISH) + " " + m.getYear();
                        String selected = val.equals(selectedMonth.toString()) ? "selected" : "";
                %>
                    <option value="<%= val %>" <%= selected %>><%= label %></option>
                <%
                    }
                %>
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
                <h3>Budget Usage</h3>
                <div class="amount"><%= String.format("%.1f", budgetUsagePercent) %>%</div>
            </div>
            <div class="stat-card">
                <h3>Daily Average</h3>
                <div class="amount">RM <%= String.format("%.2f", dailyAverage) %></div>
            </div>
        </div>
        
        <!-- AI Guidance Alert -->
        <div class="ai-guidance">
            <h3>PocketPilot AI Guidance</h3>
            <p><%= aiGuidance %></p>
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
                <h2>Top Spending Categories</h2>
                <div class="chart-wrapper">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>
    </div>
    
    <script>
        function loadMonthData() {
            const month = document.getElementById('monthSelect').value;
            if (month) {
                window.location.href = 'studentDashboard.jsp?month=' + month;
            }
        }
        
        // Render Charts using dynamically loaded DB values
        window.addEventListener('DOMContentLoaded', () => {
            // 1. Budget vs Expense Bar Chart
            const budgetCtx = document.getElementById('budgetChart').getContext('2d');
            new Chart(budgetCtx, {
                type: 'bar',
                data: {
                    labels: ['Monthly Budget', 'Monthly Expenses'],
                    datasets: [{
                        label: 'Amount (RM)',
                        data: [<%= totalBudget %>, <%= totalExpense %>],
                        backgroundColor: ['#6B46C1', '#8B5CF6'],
                        borderRadius: 8,
                        borderWidth: 0,
                        barThickness: 50
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { display: false }
                    },
                    scales: {
                        y: {
                            beginAtZero: true,
                            grid: { color: '#F3E8FF' }
                        },
                        x: {
                            grid: { display: false }
                        }
                    }
                }
            });
            
            // 2. Category Doughnut Chart
            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: [
                        <%
                            int cIndex = 0;
                            for (String catName : categoryExpenses.keySet()) {
                                if (cIndex > 0) out.print(", ");
                                out.print("'" + catName + "'");
                                cIndex++;
                            }
                            if (categoryExpenses.isEmpty()) {
                                out.print("'No Expenses'");
                            }
                        %>
                    ],
                    datasets: [{
                        data: [
                            <%
                                cIndex = 0;
                                for (double amt : categoryExpenses.values()) {
                                    if (cIndex > 0) out.print(", ");
                                    out.print(amt);
                                    cIndex++;
                                }
                                if (categoryExpenses.isEmpty()) {
                                    out.print("0");
                                }
                            %>
                        ],
                        backgroundColor: ['#6B46C1', '#8B5CF6', '#C084FC', '#D8B4FE', '#E9D5FF', '#F3E8FF', '#C084FC', '#E0D5C7'],
                        borderWidth: 1,
                        borderColor: '#ffffff'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: { position: 'bottom' }
                    }
                }
            });
        });
        // Notification helpers
        function markAsRead(notifID) {
            fetch('NotificationServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=markAsRead&notificationID=' + notifID
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const item = document.getElementById('notif-' + notifID);
                    if (item) {
                        item.style.opacity = '0';
                        item.style.transform = 'scale(0.95)';
                        setTimeout(() => {
                            item.remove();
                            // Update count
                            const list = document.getElementById('notificationsList');
                            const countSpan = document.getElementById('notifCount');
                            const newCount = list.children.length;
                            if (newCount === 0) {
                                document.getElementById('notificationCenter').remove();
                            } else {
                                countSpan.textContent = newCount;
                            }
                        }, 300);
                    }
                }
            })
            .catch(error => console.error('Error dismiss notification:', error));
        }

        function markAllNotificationsAsRead() {
            fetch('NotificationServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=markAllAsRead'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    const center = document.getElementById('notificationCenter');
                    if (center) {
                        center.style.opacity = '0';
                        center.style.transform = 'scale(0.95)';
                        setTimeout(() => {
                            center.remove();
                        }, 300);
                    }
                }
            })
            .catch(error => console.error('Error mark all read:', error));
        }
    </script>
</body>
</html>
