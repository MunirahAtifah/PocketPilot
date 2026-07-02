<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Counsellor Dashboard - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css?v=1.0.4">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--card-bg);
            min-height: 100vh;
        }

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

        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }

        /* Nav Bar */
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
            align-items: center;
        }

        .navbar a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.3s;
            padding: 6px 12px;
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
            height: auto !important;
            display: inline-flex !important;
            align-items: center;
            font-family: inherit;
        }
        
        .logout-btn:hover {
            background: var(--primary-color) !important;
            box-shadow: 0 4px 12px rgba(107, 70, 193, 0.4);
            transform: translateY(-1px);
        }

        /* Main Content */
        .main-content {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }

        .stat-card {
            background: var(--card-bg);
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
            border-left: 4px solid var(--primary-color);
            text-align: center;
        }

        .stat-card h3 {
            font-size: 14px;
            color: #666;
            margin-bottom: 10px;
        }

        .stat-card .count {
            color: var(--primary-color);
            font-size: 32px;
            font-weight: bold;
        }

        /* Students Table */
        .students-section {
            background: var(--card-bg);
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }

        .students-section h2 {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table thead {
            background: var(--body-bg);
        }

        table th {
            padding: 12px;
            text-align: left;
            color: var(--primary-color);
            border-bottom: 2px solid var(--primary-color);
            font-weight: 600;
        }

        table td {
            padding: 12px;
            border-bottom: 1px solid var(--border-color);
        }

        table tbody tr:hover {
            background: var(--nav-link-hover-bg);
        }

        .student-name {
            color: var(--primary-color);
            font-weight: 600;
            text-decoration: none;
            cursor: pointer;
        }

        .student-name:hover {
            text-decoration: underline;
        }

        .student-name.disabled {
            color: #999;
            cursor: not-allowed;
            text-decoration: none;
        }

        .badge {
            display: inline-block;
            padding: 6px 12px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 600;
        }

        .badge-approved {
            background: #D4EDDA;
            color: #155724;
        }

        .badge-pending {
            background: #FFF3CD;
            color: #856404;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
        }

        .btn-approve {
            background: #2e7d32;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s;
            font-family: inherit;
        }

        .btn-approve:hover {
            background: #1b5e20;
            transform: translateY(-2px);
        }

        .btn-disapprove {
            background: #c62828;
            color: white;
            padding: 8px 12px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 12px;
            font-weight: 600;
            transition: all 0.3s;
            font-family: inherit;
        }

        .btn-disapprove:hover {
            background: #b71c1c;
            transform: translateY(-2px);
        }

        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
        }

        .toggle-switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }

        .toggle-switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }

        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: 0.4s;
            border-radius: 34px;
        }

        .slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: var(--card-bg);
            transition: 0.4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: var(--primary-color);
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .student-name {
            font-weight: 600;
            color: var(--text-primary);
        }

        .student-username {
            color: #888;
            font-size: 0.9em;
        }

        .view-details-btn {
            background: var(--primary-color);
            color: white;
            border: none;
            padding: 8px 16px;
            border-radius: 5px;
            cursor: pointer;
            text-decoration: none;
            font-size: 0.9em;
            transition: background 0.3s;
            font-family: inherit;
        }

        .view-details-btn:hover {
            background: var(--primary-hover);
        }

        .no-students {
            text-align: center;
            color: #999;
            padding: 40px;
            font-size: 1.1em;
        }

        /* Footer */
        footer {
            text-align: center;
            color: #999;
            padding: 30px;
            margin-top: 60px;
            border-top: 1px solid #E0D7F2;
        }

        footer p {
            margin: 5px 0;
        }

        .welcome-message {
            color: white;
            font-size: 1em;
            opacity: 0.9;
        }

        /* Responsive */
        @media (max-width: 768px) {
            header h1 {
                font-size: 1.8em;
            }

            .navbar {
                flex-direction: column;
                gap: 15px;
            }

            table {
                font-size: 0.9em;
            }

            table th, table td {
                padding: 10px;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in
        Integer userID = (Integer) session.getAttribute("userID");
        String userRole = (String) session.getAttribute("role");
        String username = (String) session.getAttribute("username");
        
        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Only counsellors can access this page
        if (!"Student_Counsellor".equals(userRole)) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Redirect direct accesses to the Servlet to populate data
        if (request.getAttribute("allStudents") == null) {
            response.sendRedirect("StudentCounsellorDashboard");
            return;
        }

        // Get data from servlet
        List<Map<String, Object>> allStudents = (List<Map<String, Object>>) request.getAttribute("allStudents");
        Integer staffID = (Integer) request.getAttribute("staffID");

        // Segment students dynamically for tabs
        List<Map<String, Object>> activeSupervised = new ArrayList<>();
        List<Map<String, Object>> pendingApprovalsList = new ArrayList<>();
        List<Map<String, Object>> studentDirectory = new ArrayList<>();

        if (allStudents != null) {
            for (Map<String, Object> student : allStudents) {
                Integer accessID = (Integer) student.get("accessID");
                Boolean isApprovedByStudent = (Boolean) student.get("approvedByStudent");
                String accessStatus = (String) student.get("accessStatus");

                if (accessID == 0 || "Disapproved".equalsIgnoreCase(accessStatus)) {
                    studentDirectory.add(student);
                } else if (isApprovedByStudent && "Approved".equalsIgnoreCase(accessStatus)) {
                    activeSupervised.add(student);
                } else {
                    pendingApprovalsList.add(student);
                }
            }
        }
    %>
    
    <div class="header">
        <h1>Welcome, Counsellor <%= username %></h1>
        <p>Manage student approvals and view financial tracking</p>
    </div>
    
    <div class="navbar">
        <a href="StudentCounsellorDashboard" class="active">Dashboard</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        <!-- Statistics Cards -->
        <div class="main-content">
            <div class="stat-card" style="border-left-color: #2ec4b6;">
                <h3>Supervised Students</h3>
                <div class="count" style="color: #2ec4b6;"><%= activeSupervised.size() %></div>
            </div>
            <div class="stat-card" style="border-left-color: #ff9f43;">
                <h3>Pending Approvals</h3>
                <div class="count" style="color: #ff9f43;"><%= pendingApprovalsList.size() %></div>
            </div>
            <div class="stat-card" style="border-left-color: var(--accent);">
                <h3>Total Registered</h3>
                <div class="count" style="color: var(--accent);"><%= allStudents != null ? allStudents.size() : 0 %></div>
            </div>
        </div>

        <!-- Sleek Card Wrapper for Tables and Tabs -->
        <div class="counsellor-dashboard-card">
            <!-- Tabs Menu -->
            <div class="dashboard-tabs">
                <button class="tab-btn active" onclick="switchTab('active-tab')">
                    👥 Supervised Students (<%= activeSupervised.size() %>)
                </button>
                <button class="tab-btn" onclick="switchTab('pending-tab')">
                    ⏳ Pending Approval (<%= pendingApprovalsList.size() %>)
                </button>
                <button class="tab-btn" onclick="switchTab('directory-tab')">
                    🔍 Student Directory (<%= studentDirectory.size() %>)
                </button>
            </div>

            <!-- Tab 1: Supervised Students -->
            <div id="active-tab" class="tab-content active">
                <% if (activeSupervised.isEmpty()) { %>
                    <div class="no-data">
                        No active supervised students yet. Request connection with students using the Student Directory.
                    </div>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th style="width: 180px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> student : activeSupervised) { 
                                Integer studentID = (Integer) student.get("studentID");
                                String name = (String) student.get("name");
                                String email = (String) student.get("email");
                                Integer accessID = (Integer) student.get("accessID");
                            %>
                                <tr>
                                    <td>
                                        <a href="javascript:void(0)" onclick="viewStudentProfile(<%= studentID %>)" class="student-name" style="text-decoration: underline; color: var(--accent-light); font-weight: 600;">
                                            <%= name %>
                                        </a>
                                    </td>
                                    <td><%= email %></td>
                                    <td><span class="pill-badge badge-success">Connected</span></td>
                                    <td>
                                        <button class="animated-btn danger" onclick="disapproveStudent(<%= accessID %>)">Disconnect</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

            <!-- Tab 2: Pending Student Approval -->
            <div id="pending-tab" class="tab-content">
                <% if (pendingApprovalsList.isEmpty()) { %>
                    <div class="no-data">
                        No pending connection requests.
                    </div>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Email</th>
                                <th>Requested Date</th>
                                <th>Status</th>
                                <th style="width: 180px;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> student : pendingApprovalsList) { 
                                Integer studentID = (Integer) student.get("studentID");
                                String name = (String) student.get("name");
                                String email = (String) student.get("email");
                                Integer accessID = (Integer) student.get("accessID");
                                java.util.Date requestedDate = (java.util.Date) student.get("requestedDate");
                            %>
                                <tr>
                                    <td><span class="student-name disabled" title="Awaiting student approval" style="color: var(--text-muted);"><%= name %></span></td>
                                    <td><%= email %></td>
                                    <td><%= requestedDate != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(requestedDate) : "N/A" %></td>
                                    <td><span class="pill-badge badge-warning">Awaiting Student</span></td>
                                    <td>
                                        <button class="animated-btn danger" onclick="disapproveStudent(<%= accessID %>)">Cancel Request</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

            <!-- Tab 3: Student Directory -->
            <div id="directory-tab" class="tab-content">
                <!-- Search & Filters -->
                <div class="directory-actions">
                    <div class="search-wrapper">
                        <input type="text" id="directorySearchInput" onkeyup="filterDirectory()" class="search-input" placeholder="Search by student name or email...">
                    </div>
                </div>

                <% if (studentDirectory.isEmpty()) { %>
                    <div class="no-data">
                        No new students available to connect. All registered students are linked or pending.
                    </div>
                <% } else { %>
                    <table class="table" id="directoryTable">
                        <thead>
                            <tr>
                                <th>Student Name</th>
                                <th>Email</th>
                                <th>Status</th>
                                <th style="width: 180px;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> student : studentDirectory) { 
                                Integer studentID = (Integer) student.get("studentID");
                                String name = (String) student.get("name");
                                String email = (String) student.get("email");
                            %>
                                <tr class="directory-row">
                                    <td class="search-name" style="font-weight:600;"><%= name %></td>
                                    <td class="search-email"><%= email %></td>
                                    <td><span class="pill-badge badge-info" style="opacity: 0.7;">Not Connected</span></td>
                                    <td>
                                        <button class="animated-btn primary" onclick="connectStudent(<%= studentID %>, <%= staffID %>)">Connect</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        // Tab switching logic
        function switchTab(tabId) {
            // Hide all tab contents
            document.querySelectorAll('.tab-content').forEach(function(content) {
                content.classList.remove('active');
            });
            // Deactivate all tab buttons
            document.querySelectorAll('.tab-btn').forEach(function(btn) {
                btn.classList.remove('active');
            });
            // Show current tab content
            document.getElementById(tabId).classList.add('active');
            // Activate current tab button
            event.currentTarget.classList.add('active');
        }

        // Live filter for student directory search
        function filterDirectory() {
            var input = document.getElementById("directorySearchInput");
            var filter = input.value.toLowerCase();
            var rows = document.querySelectorAll(".directory-row");
            
            rows.forEach(function(row) {
                var nameText = row.querySelector(".search-name").textContent.toLowerCase();
                var emailText = row.querySelector(".search-email").textContent.toLowerCase();
                if (nameText.includes(filter) || emailText.includes(filter)) {
                    row.style.display = "";
                } else {
                    row.style.display = "none";
                }
            });
        }
        
        // Connect Student Action
        function connectStudent(studentID, staffID) {
            if (confirm('Do you want to send a supervision access request to this student?')) {
                sendConnectAction(studentID, staffID);
            }
        }

        function sendConnectAction(studentID, staffID) {
            fetch('StudentCounsellorDashboard', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=connectStudent&studentID=' + studentID + '&staffID=' + staffID
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred while requesting connection');
            });
        }

        // Disapprove/Disconnect Action
        function disapproveStudent(accessID) {
            if (confirm('Are you sure you want to revoke/cancel supervision access?')) {
                sendAction('disapproveStudent', accessID);
            }
        }

        function sendAction(action, accessID) {
            fetch('StudentCounsellorDashboard', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=' + action + '&accessID=' + accessID
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert(data.message);
                    location.reload();
                } else {
                    alert(data.message);
                }
            })
            .catch(error => {
                console.error('Error:', error);
                alert('An error occurred');
            });
        }

        function viewStudentProfile(studentID) {
            window.location.href = 'TrackingProgressServlet?studentID=' + studentID;
        }
    </script>

<script src="js/theme.js?v=1.0.4"></script>
</body>
</html>
