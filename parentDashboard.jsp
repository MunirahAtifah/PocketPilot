<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Parent Dashboard - PocketPilot</title>
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
        
        .logout-btn:hover {
            background: #6B46C1 !important;
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
            color: white;
            border-radius: 8px;
            cursor: pointer;
            text-align: left;
            font-weight: 600;
            font-size: 14px;
            transition: all 0.3s;
            text-decoration: none;
            display: block;
        }
        
        .sidebar-btn:hover {
            background: rgba(255, 255, 255, 0.3);
            transform: translateX(5px);
        }
        
        .sidebar-btn.active {
            background: white;
            color: #6B46C1;
        }
        
        .sidebar-settings {
            margin-top: auto;
            padding-top: 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .main-content {
            margin-left: 250px;
            padding: 30px;
        }
        
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }
        
        .header h1 {
            color: #6B46C1;
            font-size: 32px;
        }
        
        .logout-btn {
            background: #8B5CF6 !important;
            color: white !important;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            text-decoration: none;
        }
        
        .logout-btn:hover {
            background: #6B46C1 !important;
            color: white !important;
        }
        
        .selector-row {
            display: flex;
            gap: 15px;
            margin-bottom: 30px;
        }
        
        .selector-row select {
            padding: 10px 15px;
            border: 2px solid #E0D5C7;
            border-radius: 8px;
            color: #6B46C1;
            font-weight: 600;
            cursor: pointer;
            background: white;
        }
        
        .selector-row select:focus {
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
        
        .students-table {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            overflow-x: auto;
        }
        
        .students-table h3 {
            color: #6B46C1;
            margin-bottom: 20px;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
        }
        
        table thead {
            background: #F5F1E8;
            border-bottom: 2px solid #6B46C1;
        }
        
        table th {
            color: #6B46C1;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
        }
        
        table td {
            padding: 12px;
            border-bottom: 1px solid #E0D5C7;
            font-size: 13px;
        }
        
        table tbody tr:hover {
            background: #FFFBF0;
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
        <h1>👨‍👩‍👧‍👦 Parent Dashboard</h1>
        <p>Monitor your children's financial activities</p>
    </div>
    
    <div class="navbar">
        <a href="parentDashboard.jsp" style="color: #8B5CF6; border-bottom: 3px solid #8B5CF6; padding-bottom: 12px;">👨‍👩‍👧‍👦 Dashboard</a>
        <a href="trackingProgress.jsp">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">🚪 Logout</a>
    </div>
    
    <div class="container">
        
        <!-- Selectors -->
        <div class="selector-row">
            <select id="studentSelect" onchange="loadStudentData()">
                <option value="">Select Child...</option>
                <option value="1">Student One</option>
                <option value="2">Student Two</option>
            </select>
            
            <select id="monthSelect" onchange="loadStudentData()">
                <option value="">Select Month...</option>
                <option value="2025-01">Jan 2025</option>
                <option value="2025-02">Feb 2025</option>
                <option value="2025-03">Mar 2025</option>
                <option value="2025-04">Apr 2025</option>
                <option value="2025-05">May 2025</option>
                <option value="2025-06">Jun 2025</option>
                <option value="2025-07">Jul 2025</option>
                <option value="2025-08">Aug 2025</option>
                <option value="2025-09">Sep 2025</option>
                <option value="2025-10">Oct 2025</option>
                <option value="2025-11">Nov 2025</option>
                <option value="2025-12">Dec 2025</option>
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
                <h3>📊 Status</h3>
                <div class="amount" id="status">-</div>
            </div>
            <div class="stat-card">
                <h3>💵 Daily Average</h3>
                <div class="amount" id="dailyAverage">RM0.00</div>
            </div>
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
                <h2>Spending Trend</h2>
                <div class="chart-wrapper">
                    <canvas id="trendChart"></canvas>
                </div>
            </div>
        </div>
        
        <!-- Children Overview -->
        <div class="students-table">
            <h3>👨‍👩‍👧‍👦 Your Children's Overview</h3>
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
                    <tr>
                        <td>Student One</td>
                        <td>RM3,500.00</td>
                        <td>RM5,000.00</td>
                        <td>70%</td>
                        <td><span style="color: #ff9800;">⚠️ Caution</span></td>
                    </tr>
                    <tr>
                        <td>Student Two</td>
                        <td>RM2,100.00</td>
                        <td>RM4,000.00</td>
                        <td>52.5%</td>
                        <td><span style="color: #2e7d32;">✓ Good</span></td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
    
    <script>
        function loadStudentData() {
            const student = document.getElementById('studentSelect').value;
            const month = document.getElementById('monthSelect').value;
            
            if (!student || !month) {
                document.getElementById('totalBudget').textContent = 'RM0.00';
                document.getElementById('totalExpense').textContent = 'RM0.00';
                return;
            }
            
            // Update stats
            document.getElementById('totalBudget').textContent = '₱5,000.00';
            document.getElementById('totalExpense').textContent = '₱3,500.00';
            document.getElementById('status').textContent = '70% Used';
            document.getElementById('dailyAverage').textContent = '₱116.67';
            
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
                    plugins: { legend: { display: false } },
                    scales: { y: { beginAtZero: true } }
                }
            });
            
            // Trend Chart
            const trendCtx = document.getElementById('trendChart').getContext('2d');
            new Chart(trendCtx, {
                type: 'line',
                data: {
                    labels: ['Week 1', 'Week 2', 'Week 3', 'Week 4'],
                    datasets: [{
                        label: 'Weekly Spending',
                        data: [1200, 1100, 800, 400],
                        borderColor: '#6B46C1',
                        backgroundColor: 'rgba(107, 70, 193, 0.1)',
                        tension: 0.4,
                        fill: true,
                        pointBackgroundColor: '#6B46C1'
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: { legend: { display: true } },
                    scales: { y: { beginAtZero: true } }
                }
            });
        }
    </script>
</body>
</html>
