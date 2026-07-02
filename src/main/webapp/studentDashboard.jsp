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

        // 5. Generate AI Guidance using the central Groq AI Service
        if (totalBudget == 0 && totalExpense == 0) {
            aiGuidance = "No budget or expense records found for " + selectedMonth + ". Get started by recording a budget or logging your expenses!";
        } else if (totalBudget == 0) {
            aiGuidance = "You have recorded RM" + String.format("%.2f", totalExpense) + " in expenses, but have not set a budget for " + selectedMonth + ". Go to the Budget tab to set limits!";
        } else {
            String surplusStatus = "balanced";
            double surplusDeficitAmount = totalBudget - totalExpense;
            if (surplusDeficitAmount > 10.0) {
                surplusStatus = "surplus";
            } else if (surplusDeficitAmount < -10.0) {
                surplusStatus = "deficit";
            }

            Map<String, String> dummyTrend = new HashMap<>();
            dummyTrend.put("trend", "Stable");
            dummyTrend.put("percentage", "0%");

            aiGuidance = com.pocketpilot.util.AIService.generateAIGuidance(
                surplusStatus,
                budgetUsagePercent,
                dailyAverage,
                totalBudget,
                surplusDeficitAmount,
                dummyTrend,
                categoryExpenses
            );
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
    <link rel="stylesheet" href="css/style.css?v=1.0.4">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/4.4.0/chart.umd.min.js"></script>
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
        .month-selector {
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
        .month-selector label {
            margin-bottom: 0;
            color: var(--primary-color);
            font-weight: 700;
            font-size: 15px;
        }
        .month-selector select {
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
        .month-selector select:focus {
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
        .ai-guidance {
            background: var(--bg-alt);
            border-left: 5px solid var(--primary-hover);
            padding: 20px 25px;
            border-radius: 15px;
            margin-bottom: 35px;
            box-shadow: 0 4px 12px rgba(139,92,246,0.08);
            animation: fadeIn 0.5s ease-in-out;
        }
        .ai-guidance h3 {
            color: var(--primary-color);
            margin-bottom: 8px;
            font-size: 18px;
            font-weight: 700;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .ai-guidance p {
            color: var(--text-primary);
            font-size: 15px;
            line-height: 1.6;
            margin-bottom: 0;
            font-weight: 500;
        }
        .charts-row {
            display: grid;
            grid-template-columns: 1.2fr 0.8fr;
            gap: 25px;
            margin-bottom: 30px;
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
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
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
        <h1>Welcome, Student <%= username %></h1>
        <p>Track your budget and expenses dynamically</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp" class="active">Dashboard</a>
        <a href="budget.jsp">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="TrackingProgressServlet">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        
        <!-- Notification Center Card -->
        <% if (!unreadNotifications.isEmpty()) { %>
        <div class="notification-center" id="notificationCenter" style="margin-bottom: 30px; background: var(--card-bg); padding: 25px; border-radius: 15px; box-shadow: 0 4px 15px rgba(0,0,0,0.05); border: 1px solid var(--border-color); border-left: 5px solid #FF9F43; transition: all 0.3s ease;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; border-bottom: 2px solid #FFF3E0; padding-bottom: 10px;">
                <h3 style="color: #D35400; margin: 0; font-size: 18px; font-weight: 700; display: flex; align-items: center; gap: 8px;">
                    Notification Center (<span id="notifCount"><%= unreadNotifications.size() %></span>)
                </h3>
                <button onclick="markAllNotificationsAsRead()" style="background: none; border: none; color: #E67E22; font-weight: 600; font-size: 14px; cursor: pointer; transition: color 0.3s;" onmouseover="this.style.color='#D35400'" onmouseout="this.style.color='#E67E22'">
                    Mark All as Read
                </button>
            </div>
            <div style="display: flex; flex-direction: column; gap: 12px;" id="notificationsList">
                <% for (Notification notif : unreadNotifications) { %>
                    <div class="notif-item" id="notif-<%= notif.getNotificationID() %>" style="display: flex; justify-content: space-between; align-items: center; padding: 12px 15px; background: var(--nav-link-hover-bg); border-radius: 8px; border: 1px solid #FFE8CC; transition: all 0.3s;">
                        <span style="font-size: 14px; color: #5D4037; font-weight: 500;"><%= notif.getMessage() %></span>
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
        
        <!-- AI Guidance Card -->
        <% if (aiGuidance != null && !aiGuidance.isEmpty()) { %>
        <div class="ai-guidance">
            <h3>🤖 PocketPilot AI Guidance</h3>
            <p style="white-space: pre-line;"><%= aiGuidance %></p>
        </div>
        <% } %>
        
        <!-- AI Chatbot Replacement -->
        <div class="ai-chat-container">
            <div class="ai-chat-header">
                <h3>
                    <span class="chat-icon">💬</span>
                    <span>PocketPilot AI Assistant</span>
                </h3>
                <span class="chat-status"><span class="status-dot"></span>Online</span>
            </div>
            
            <div class="ai-chat-messages" id="aiChatMessages">
                <div class="ai-chat-message assistant">
                    <div class="message-content">
                        <strong>PocketPilot AI:</strong><br>
                        Hello! I am your interactive assistant. Ask me anything about your budgets, expenses, parent/counsellor access, or how the system works!
                    </div>
                    <div class="message-time">Just now</div>
                </div>
            </div>
            
            <form class="ai-chat-input-area" id="aiChatForm" onsubmit="sendChatMessage(event)">
                <input type="text" id="aiChatInput" placeholder="Ask about your budget, expenses, or how the system works..." required autocomplete="off">
                <button type="submit" class="btn-chat-send">
                    <span class="send-icon">➔</span>
                </button>
            </form>
        </div>

        <script>
            // Budget Context details for AI
            const budgetContext = "Month: <%= selectedMonth %>; Total Budget: RM <%= String.format("%.2f", totalBudget) %>; Total Expense: RM <%= String.format("%.2f", totalExpense) %>; Daily Average Spending: RM <%= String.format("%.2f", dailyAverage) %>; Budget Utilization: <%= String.format("%.1f", budgetUsagePercent) %>%.";

            function sendChatMessage(event) {
                event.preventDefault();
                
                const inputElement = document.getElementById("aiChatInput");
                const messageText = inputElement.value.trim();
                if (!messageText) return;

                // Clear input
                inputElement.value = "";

                // Append user message
                appendMessage("user", messageText);

                // Show typing indicator
                showTypingIndicator();

                // Scroll to bottom
                scrollToBottom();

                // Send request
                fetch("AIChatServlet", {
                    method: "POST",
                    headers: {
                        "Content-Type": "application/x-www-form-urlencoded"
                    },
                    body: "message=" + encodeURIComponent(messageText) + "&budgetContext=" + encodeURIComponent(budgetContext)
                })
                .then(response => response.json())
                .then(data => {
                    removeTypingIndicator();
                    if (data.success) {
                        appendMessage("assistant", data.response);
                    } else {
                        appendMessage("assistant", "⚠️ Error: " + data.message);
                    }
                    scrollToBottom();
                })
                .catch(error => {
                    removeTypingIndicator();
                    console.error("Error during chat request:", error);
                    appendMessage("assistant", "⚠️ Connection error. Please try again later.");
                    scrollToBottom();
                });
            }

            function appendMessage(sender, text) {
                const messagesContainer = document.getElementById("aiChatMessages");
                const messageDiv = document.createElement("div");
                messageDiv.className = "ai-chat-message " + sender;
                
                const contentDiv = document.createElement("div");
                contentDiv.className = "message-content";
                contentDiv.innerHTML = "<strong>" + (sender === "user" ? "You" : "PocketPilot AI") + ":</strong><br>" + text.replace(/\n/g, "<br>");
                
                const timeDiv = document.createElement("div");
                timeDiv.className = "message-time";
                timeDiv.textContent = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                
                messageDiv.appendChild(contentDiv);
                messageDiv.appendChild(timeDiv);
                messagesContainer.appendChild(messageDiv);
            }

            function showTypingIndicator() {
                const messagesContainer = document.getElementById("aiChatMessages");
                const indicatorDiv = document.createElement("div");
                indicatorDiv.className = "ai-chat-message assistant";
                indicatorDiv.id = "typingIndicator";
                
                const contentDiv = document.createElement("div");
                contentDiv.className = "message-content typing-indicator";
                contentDiv.innerHTML = '<span class="typing-dot"></span><span class="typing-dot"></span><span class="typing-dot"></span>';
                
                indicatorDiv.appendChild(contentDiv);
                messagesContainer.appendChild(indicatorDiv);
            }

            function removeTypingIndicator() {
                const indicator = document.getElementById("typingIndicator");
                if (indicator) {
                    indicator.remove();
                }
            }

            function scrollToBottom() {
                const messagesContainer = document.getElementById("aiChatMessages");
                messagesContainer.scrollTop = messagesContainer.scrollHeight;
            }
        </script>
        
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
            const primaryColor = getComputedStyle(document.documentElement).getPropertyValue('--accent').trim() || '#9d4edd';
            const primaryHover = getComputedStyle(document.documentElement).getPropertyValue('--accent-light').trim() || '#c77dff';
            const borderColor = getComputedStyle(document.documentElement).getPropertyValue('--border-color').trim() || 'rgba(157, 78, 221, 0.15)';
            // 1. Budget vs Expense Bar Chart
            const budgetCtx = document.getElementById('budgetChart').getContext('2d');
            new Chart(budgetCtx, {
                type: 'bar',
                data: {
                    labels: ['Monthly Budget', 'Monthly Expenses'],
                    datasets: [{
                        label: 'Amount (RM)',
                        data: [<%= totalBudget %>, <%= totalExpense %>],
                        backgroundColor: [primaryColor, primaryHover],
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
                                out.print("'" + catName.replace("'", "\\'") + "'");
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
                        backgroundColor: [primaryColor, primaryHover, '#C084FC', '#D8B4FE', '#E9D5FF', '#F3E8FF', '#C084FC', borderColor],
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

<script src="js/theme.js?v=1.0.4"></script>
</body>
</html>


