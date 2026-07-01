<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.time.LocalDate, java.time.format.DateTimeFormatter" %>
<%
    // Redirect direct accesses to the Servlet
    if (request.getAttribute("totalBudget") == null) {
        response.sendRedirect("TrackingProgressServlet");
        return;
    }

    String userRole = (String) session.getAttribute("role");
    String reportMonth = (String) request.getAttribute("reportMonth");
    Integer trackingStudentID = (Integer) request.getAttribute("trackingStudentID");
    
    String totalBudget = (String) request.getAttribute("totalBudget");
    String totalExpense = (String) request.getAttribute("totalExpense");
    String averageExpense = (String) request.getAttribute("averageExpense");
    String surplusDeficit = (String) request.getAttribute("surplusDeficit");
    String surplusStatus = (String) request.getAttribute("surplusStatus");
    String budgetUtilization = (String) request.getAttribute("budgetUtilization");
    String aiGuidance = (String) request.getAttribute("aiGuidance");
    
    Map<String, Double> topCategories = (Map<String, Double>) request.getAttribute("topCategories");
    Map<String, String> spendingTrend = (Map<String, String>) request.getAttribute("spendingTrend");
    List<Map<String, Object>> budgets = (List<Map<String, Object>>) request.getAttribute("budgets");
    List<Map<String, Object>> expenses = (List<Map<String, Object>>) request.getAttribute("expenses");

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMMM yyyy");

    // Build Chart JSON strings
    StringBuilder catNames = new StringBuilder("[");
    StringBuilder catAmounts = new StringBuilder("[");
    if (topCategories != null && !topCategories.isEmpty()) {
        for (Map.Entry<String, Double> entry : topCategories.entrySet()) {
            catNames.append("'").append(entry.getKey()).append("',");
            catAmounts.append(entry.getValue()).append(",");
        }
    }
    String categoryJson = catNames.length() > 1 ? catNames.substring(0, catNames.length()-1) + "]" : "[]";
    String amountJson = catAmounts.length() > 1 ? catAmounts.substring(0, catAmounts.length()-1) + "]" : "[]";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tracking Progress - PocketPilot</title>
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
        .trend-badge {
            display: inline-block;
            font-size: 13px;
            margin-top: 5px;
            padding: 2px 8px;
            border-radius: 12px;
            background: var(--nav-link-hover-bg);
            color: var(--primary-color);
            font-weight: 600;
        }
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 25px;
            margin-bottom: 35px;
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
        <h1>Financial Tracking Progress</h1>
        <p>Analyze budget metrics and visual breakdown reports</p>
    </div>
 
    <!-- Role-Based Navigation -->
    <div class="navbar">
        <a href="#" class="navbar-brand">PocketPilot</a>
        <button class="menu-toggle" onclick="toggleMobileMenu()">☰</button>
        <div class="navbar-links" id="navbarLinks">
            <% if ("Student".equals(userRole)) { %>
                <a href="studentDashboard.jsp">Dashboard</a>
                <a href="budget.jsp">Budget</a>
                <a href="expense.jsp">Expense</a>
                <a href="TrackingProgressServlet" class="active">Tracking Progress</a>
                <a href="supervisionAccess.jsp">Supervision</a>
            <% } else if ("Parent".equals(userRole)) { %>
                <a href="parentDashboard.jsp">Dashboard</a>
                <a href="TrackingProgressServlet?studentID=<%= trackingStudentID %>" class="active">Tracking Progress</a>
                <a href="supervisionAccess.jsp">Supervision</a>
            <% } else if ("Student_Counsellor".equals(userRole)) { %>
                <a href="StudentCounsellorDashboard">Dashboard</a>
                <a href="TrackingProgressServlet?studentID=<%= trackingStudentID %>" class="active">Tracking Progress</a>
            <% } %>
            <button class="theme-toggle" onclick="toggleTheme()">🌓 Theme</button>
            <a href="LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>

    <div class="container">
        <%
            String msg = (String) request.getAttribute("msg");
            if (msg == null) {
                msg = request.getParameter("msg");
            }
            if ("success".equals(msg)) {
        %>
            <div class="success-alert" style="background: #DEF7EC; color: #03543F; border: 1px solid #BCF0DA; padding: 15px 20px; border-radius: 12px; margin-bottom: 25px; font-weight: 600; display: flex; align-items: center; justify-content: center; gap: 8px; box-shadow: 0 4px 12px rgba(46, 204, 113, 0.1);">
                <span>✓ Saved Successfully !</span>
            </div>
        <% } %>

        <!-- Month Selector and PDF Export Button -->
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; flex-wrap: wrap; gap: 15px;">
            <div class="month-selector" style="margin-bottom: 0;">
                <form method="GET" action="TrackingProgressServlet">
                    <% if (!"Student".equals(userRole)) { %>
                        <input type="hidden" name="studentID" value="<%= trackingStudentID %>">
                    <% } %>
                    <label for="monthInput">Report Period: </label>
                    <input type="month" id="monthInput" name="month" value="<%= reportMonth %>" onchange="this.form.submit()">
                </form>
            </div>
            <div>
                <a href="TrackingProgressServlet?action=export&month=<%= reportMonth %><%= !"Student".equals(userRole) ? "&studentID=" + trackingStudentID : "" %>" download class="button btn-primary" style="text-decoration: none; display: inline-flex; align-items: center; gap: 8px;">
                    Download PDF
                </a>
            </div>
        </div>

        <!-- Metric Summary Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>Total Budget</h3>
                <div class="amount">RM <%= totalBudget %></div>
            </div>
            <div class="stat-card">
                <h3>Total Expenses</h3>
                <div class="amount">RM <%= totalExpense %></div>
            </div>
            <div class="stat-card">
                <h3>Daily Average</h3>
                <div class="amount">RM <%= averageExpense %></div>
            </div>
            <div class="stat-card <%= surplusStatus %>">
                <h3>
                    <% if ("surplus".equals(surplusStatus)) { %>
                        Surplus
                    <% } else if ("deficit".equals(surplusStatus)) { %>
                        Deficit
                    <% } else { %>
                        balanced
                    <% } %>
                </h3>
                <div class="amount">RM <%= surplusDeficit.replace("-", "") %></div>
            </div>
            <div class="stat-card">
                <h3>Budget Utilization</h3>
                <div class="amount"><%= budgetUtilization %>%</div>
            </div>
        </div>

        <!-- AI Guidance block -->
        <% if (aiGuidance != null && !aiGuidance.isEmpty()) { %>
            <div class="ai-guidance">
                <h3>PocketPilot AI Insights</h3>
                <p><%= aiGuidance %></p>
                <% if (spendingTrend != null && spendingTrend.get("trend") != null) { %>
                    <span class="trend-badge"><%= spendingTrend.get("trend") %> (<%= spendingTrend.get("percentage") %>)</span>
                <% } %>
            </div>
        <% } %>

        <!-- Charts Grid -->
        <div class="charts-row">
            <div class="chart-container">
                <h2>Budget vs Expenses</h2>
                <div class="chart-wrapper">
                    <canvas id="budgetChart"></canvas>
                </div>
            </div>
            <div class="chart-container">
                <h2>Top Categories</h2>
                <div class="chart-wrapper">
                    <canvas id="categoryChart"></canvas>
                </div>
            </div>
        </div>

        <!-- Expense Breakdown -->
        <div class="table-section">
            <h3>Breakdown of Expenses for <%= reportMonth %></h3>
            <% if (expenses == null || expenses.isEmpty()) { %>
                <p style="color: #7F8C8D; font-style: italic; text-align: center; padding: 20px;">No expenses recorded for this month.</p>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Category</th>
                            <th>Amount (RM)</th>
                            <th>Description</th>
                            <th>Comment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> expense : expenses) { 
                            LocalDate exDate = (LocalDate) expense.get("expenseDate");
                            String parentComment = (String) expense.get("parentComment");
                            String counsellorComment = (String) expense.get("counsellorComment");
                            String expComment = "Parent".equals(userRole) ? parentComment : counsellorComment;
                        %>
                            <tr>
                                <td><%= exDate != null ? exDate.format(dateFormatter) : "-" %></td>
                                <td><%= expense.get("categoryName") %></td>
                                <td style="font-weight: 700; color: #2C3E50;">RM <%= String.format("%.2f", (Double) expense.get("expenseAmount")) %></td>
                                <td><%= expense.get("expenseDesc") != null ? expense.get("expenseDesc") : "-" %></td>
                                <td>
                                    <% if ("Parent".equals(userRole) || "Student_Counsellor".equals(userRole)) { %>
                                        <form method="POST" action="TrackingProgressServlet" style="display: flex; gap: 8px; align-items: center;">
                                            <input type="hidden" name="action" value="updateComment">
                                            <input type="hidden" name="type" value="expense">
                                            <input type="hidden" name="id" value="<%= expense.get("expenseID") %>">
                                            <input type="hidden" name="studentID" value="<%= trackingStudentID %>">
                                            <input type="hidden" name="month" value="<%= reportMonth %>">
                                            <input type="text" name="comment" value="<%= expComment != null ? expComment : "" %>" placeholder="Comment..." style="padding: 6px 10px; border: 1px solid #E0D5C7; border-radius: 4px; font-size: 13px; font-family: inherit; width: 180px;">
                                            <button type="submit" class="btn btn-primary" style="padding: 6px 12px; font-size: 11px; text-transform: none; border-radius: 4px; height: auto;">Save</button>
                                        </form>
                                    <% } else { %>
                                        <%
                                            StringBuilder studentComment = new StringBuilder();
                                            if (parentComment != null && !parentComment.trim().isEmpty()) {
                                                studentComment.append("<strong style='color: #6B46C1;'>Parent:</strong> ").append(parentComment);
                                            }
                                            if (counsellorComment != null && !counsellorComment.trim().isEmpty()) {
                                                if (studentComment.length() > 0) studentComment.append("<br>");
                                                studentComment.append("<strong style='color: #8B5CF6;'>Counsellor:</strong> ").append(counsellorComment);
                                            }
                                            if (studentComment.length() == 0) {
                                                studentComment.append("-");
                                            }
                                        %>
                                        <span style="font-size: 13px;"><%= studentComment.toString() %></span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
        
        <!-- Budget Breakdown -->
        <div class="table-section">
            <h3>Breakdown of Budgets for <%= reportMonth %></h3>
            <% if (budgets == null || budgets.isEmpty()) { %>
                <p style="color: #7F8C8D; font-style: italic; text-align: center; padding: 20px;">No budgets set for this month.</p>
            <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Category</th>
                            <th>Amount (RM)</th>
                            <th>Description</th>
                            <th>Comment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% for (Map<String, Object> budget : budgets) { 
                            LocalDate bDate = (LocalDate) budget.get("budgetDate");
                            String parentComment = (String) budget.get("parentComment");
                            String counsellorComment = (String) budget.get("counsellorComment");
                            String budComment = "Parent".equals(userRole) ? parentComment : counsellorComment;
                        %>
                            <tr>
                                <td><%= bDate != null ? bDate.format(dateFormatter) : "-" %></td>
                                <td><%= budget.get("categoryName") %></td>
                                <td style="font-weight: 700; color: #2C3E50;">RM <%= String.format("%.2f", (Double) budget.get("budgetAmount")) %></td>
                                <td><%= budget.get("budgetDesc") != null ? budget.get("budgetDesc") : "-" %></td>
                                <td>
                                    <% if ("Parent".equals(userRole) || "Student_Counsellor".equals(userRole)) { %>
                                        <form method="POST" action="TrackingProgressServlet" style="display: flex; gap: 8px; align-items: center;">
                                            <input type="hidden" name="action" value="updateComment">
                                            <input type="hidden" name="type" value="budget">
                                            <input type="hidden" name="id" value="<%= budget.get("budgetID") %>">
                                            <input type="hidden" name="studentID" value="<%= trackingStudentID %>">
                                            <input type="hidden" name="month" value="<%= reportMonth %>">
                                            <input type="text" name="comment" value="<%= budComment != null ? budComment : "" %>" placeholder="Comment..." style="padding: 6px 10px; border: 1px solid #E0D5C7; border-radius: 4px; font-size: 13px; font-family: inherit; width: 180px;">
                                            <button type="submit" class="btn btn-primary" style="padding: 6px 12px; font-size: 11px; text-transform: none; border-radius: 4px; height: auto;">Save</button>
                                        </form>
                                    <% } else { %>
                                        <%
                                            StringBuilder studentComment = new StringBuilder();
                                            if (parentComment != null && !parentComment.trim().isEmpty()) {
                                                studentComment.append("<strong style='color: #6B46C1;'>Parent:</strong> ").append(parentComment);
                                            }
                                            if (counsellorComment != null && !counsellorComment.trim().isEmpty()) {
                                                if (studentComment.length() > 0) studentComment.append("<br>");
                                                studentComment.append("<strong style='color: #8B5CF6;'>Counsellor:</strong> ").append(counsellorComment);
                                            }
                                            if (studentComment.length() == 0) {
                                                studentComment.append("-");
                                            }
                                        %>
                                        <span style="font-size: 13px;"><%= studentComment.toString() %></span>
                                    <% } %>
                                </td>
                            </tr>
                        <% } %>
                    </tbody>
                </table>
            <% } %>
        </div>
    </div>

    <script>
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
                    labels: <%= categoryJson %>,
                    datasets: [{
                        data: <%= amountJson %>,
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
    </script>
    <!-- Toast Notification Container -->
    <div id="toastNotification" class="toast-notification">
        <span class="toast-icon">✓</span>
        <span class="toast-message">Saved Successfully!</span>
    </div>

    <style>
        .toast-notification {
            position: fixed;
            top: -100px;
            left: 50%;
            transform: translateX(-50%);
            background: #6B46C1;
            color: white;
            padding: 14px 28px;
            border-radius: 50px;
            box-shadow: 0 10px 25px rgba(107, 70, 193, 0.35);
            z-index: 9999;
            transition: all 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
            opacity: 0;
            display: flex;
            align-items: center;
            gap: 10px;
            font-weight: 600;
            font-size: 15px;
            border: 1px solid #8B5CF6;
        }
        .toast-notification.show {
            top: 30px;
            opacity: 1;
        }
        .toast-icon {
            background: rgba(255, 255, 255, 0.2);
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
    </style>

    <script>
        function showToast(message) {
            const toast = document.getElementById('toastNotification');
            if (toast) {
                if (message) {
                    toast.querySelector('.toast-message').innerText = message;
                }
                toast.classList.add('show');
                setTimeout(() => {
                    toast.classList.remove('show');
                }, 3000);
            }
        }
        
        <%
            String msgToast = (String) request.getAttribute("msg");
            if (msgToast == null) {
                msgToast = request.getParameter("msg");
            }
            if ("success".equals(msgToast)) {
        %>
            window.addEventListener('DOMContentLoaded', () => {
                showToast("Saved Successfully!");
                alert("Saved Successfully!");
            });
        <% } %>
    </script>
</body>
</html>