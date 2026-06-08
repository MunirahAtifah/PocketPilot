<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - PocketPilot</title>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #F5F1E8 0%, #FFFBF0 100%);
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
        
        .navbar {
            background: white;
            padding: 15px 20px;
            display: flex;
            gap: 20px;
            border-bottom: 1px solid #E0D5C7;
        }
        
        .navbar a {
            color: #6B46C1;
            text-decoration: none;
            font-weight: 600;
            font-size: 14px;
            transition: color 0.3s;
        }
        
        .navbar a:hover {
            color: #8B5CF6;
        }
        
        .logout-btn {
            margin-left: auto;
            background: #8B5CF6 !important;
            color: white !important;
            padding: 8px 15px;
            border-radius: 5px;
            text-decoration: none;
            font-size: 13px;
        }

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .sidebar {
            display: none;
        }
        
        .sidebar-logo {
            display: none;
        }
        
        .sidebar-nav {
            display: none;
        }
        
        .sidebar-btn {
            display: none;
        }
        
        .sidebar-settings {
            display: none;
        }
        
        .main-content {
            margin-left: 0;
            padding: 0;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
        }
        
        .logout-btn:hover {
            background: #6B46C1 !important;
            color: white !important;
        }
        
        .month-selector {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
        }
        
        .month-selector select {
            padding: 10px 15px;
            border: 2px solid #E0D5C7;
            border-radius: 8px;
            color: #6B46C1;
            font-weight: 600;
            cursor: pointer;
            background: white;
        }
        
        .month-selector select:focus {
            outline: none;
            border-color: #6B46C1;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #6B46C1;
        }
        
        .stat-card h3 {
            color: #999;
            font-size: 12px;
            text-transform: uppercase;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .stat-card .amount {
            color: #6B46C1;
            font-size: 28px;
            font-weight: bold;
        }
        
        .chart-container {
            background: white;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            margin-bottom: 20px;
        }
        
        .chart-container h2 {
            color: #6B46C1;
            margin-bottom: 20px;
            font-size: 18px;
        }
        
        .chart-wrapper {
            position: relative;
            height: 300px;
        }
        
        .charts-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        
        @media (max-width: 1200px) {
            .charts-row {
                grid-template-columns: 1fr;
            }
        }
        
        .ai-guidance {
            background: linear-gradient(135deg, #E9D5FF 0%, #F3E8FF 100%);
            border-left: 4px solid #6B46C1;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
        }
        
        .ai-guidance h3 {
            color: #6B46C1;
            margin-bottom: 10px;
        }
        
        .ai-guidance p {
            color: #666;
            line-height: 1.6;
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        if (session.getAttribute("userID") == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    
    <div class="header">
        <h1>Student Dashboard</h1>
        <p>Track your budget and expenses</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp" style="color: #8B5CF6; border-bottom: 3px solid #8B5CF6; padding-bottom: 12px;">Dashboard</a>
        <a href="budget.jsp">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="trackingProgress.jsp">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        
        <!-- Month Selector -->
        <div class="month-selector">
            <select id="monthSelect" onchange="loadMonthData()">
                <option value="">Select Month...</option>
                <option value="2025-01">Jan </option>
                <option value="2025-02">Feb </option>
                <option value="2025-03">Mar </option>
                <option value="2025-04">Apr </option>
                <option value="2025-05">May </option>
                <option value="2025-06">Jun </option>
                <option value="2025-07">Jul </option>
                <option value="2025-08">Aug </option>
                <option value="2025-09">Sep </option>
                <option value="2025-10">Oct </option>
                <option value="2025-11">Nov </option>
                <option value="2025-12">Dec </option>
            </select>
        </div>
        
        <!-- Statistics Cards -->
        <div class="stats-grid">
            <div class="stat-card">
                <h3>💰 Total Budget</h3>
                <div class="amount" id="totalBudget">RM0.00</div>
            </div>
            <div class="stat-card">
                <h3>💸 Total Expenses</h3>
                <div class="amount" id="totalExpense">RM0.00</div>
            </div>
            <div class="stat-card">
                <h3>📊 Budget Usage</h3>
                <div class="amount" id="budgetUsage">0%</div>
            </div>
            <div class="stat-card">
                <h3>💵 Daily Average</h3>
                <div class="amount" id="dailyAverage">RM0.00</div>
            </div>
        </div>
        
        <!-- AI Guidance -->
        <div class="ai-guidance">
            <h3>🤖 AI Guidance</h3>
            <p id="aiGuidance">Select a month to get personalized spending recommendations.</p>
        </div>
        
        <!-- Charts -->
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
        // Sample data - Replace with actual data from servlet
        function loadMonthData() {
            const month = document.getElementById('monthSelect').value;
            if (!month) {
                document.getElementById('totalBudget').textContent = 'RM0.00';
                document.getElementById('totalExpense').textContent = 'RM0.00';
                document.getElementById('budgetUsage').textContent = '0%';
                document.getElementById('dailyAverage').textContent = '₱0.00';
                return;
            }
            
            // Update stats (would come from server)
            document.getElementById('totalBudget').textContent = '₱5,000.00';
            document.getElementById('totalExpense').textContent = '₱3,500.00';
            document.getElementById('budgetUsage').textContent = '70%';
            document.getElementById('dailyAverage').textContent = '₱116.67';
            
            // Update guidance
            document.getElementById('aiGuidance').textContent = 
                'Your spending is at 70% of your budget. Continue monitoring your expenses. Consider allocating more to savings.';
            
            // Update charts
            updateCharts();
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
                        data: [5000, 3500],
                        backgroundColor: ['#6B46C1', '#8B5CF6'],
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            display: false
                        }
                    },
                    scales: {
                        y: {
                            beginAtZero: true
                        }
                    }
                }
            });
            
            // Category Chart
            const categoryCtx = document.getElementById('categoryChart').getContext('2d');
            new Chart(categoryCtx, {
                type: 'doughnut',
                data: {
                    labels: ['Food', 'Transportation', 'Entertainment', 'School', 'Others'],
                    datasets: [{
                        data: [800, 600, 500, 400, 200],
                        backgroundColor: ['#6B46C1', '#8B5CF6', '#C084FC', '#D8B4FE', '#E9D5FF']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        legend: {
                            position: 'bottom'
                        }
                    }
                }
            });
        }
    </script>
</body>
</html>
