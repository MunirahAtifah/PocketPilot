<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Counsellor Dashboard - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #FDFBF7 0%, #F5F1E8 100%);
            min-height: 100vh;
        }

        .header {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
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
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(10px);
            padding: 15px 20px;
            display: flex;
            gap: 20px;
            border-bottom: 1px solid #E0D5C7;
            position: sticky;
            top: 0;
            z-index: 1000;
            justify-content: center;
            align-items: center;
        }

        .navbar a {
            color: #6B46C1;
            text-decoration: none;
            font-weight: 600;
            font-size: 15px;
            transition: all 0.3s;
            padding: 6px 12px;
            border-radius: 6px;
        }

        .navbar a:hover {
            color: #8B5CF6;
            background: rgba(139, 92, 246, 0.1);
        }

        .navbar a.active {
            color: #8B5CF6;
            background: rgba(139, 92, 246, 0.15);
            border-bottom: none;
        }

        .logout-btn {
            margin-left: auto;
            background: #8B5CF6 !important;
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
            background: #6B46C1 !important;
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

        .stat-card .count {
            color: #6B46C1;
            font-size: 32px;
            font-weight: bold;
        }

        /* Students Table */
        .students-section {
            background: white;
            border-radius: 10px;
            padding: 25px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }

        .students-section h2 {
            color: #6B46C1;
            margin-bottom: 20px;
            font-size: 20px;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }

        table thead {
            background: #F5F1E8;
        }

        table th {
            padding: 12px;
            text-align: left;
            color: #6B46C1;
            border-bottom: 2px solid #6B46C1;
            font-weight: 600;
        }

        table td {
            padding: 12px;
            border-bottom: 1px solid #E0D5C7;
        }

        table tbody tr:hover {
            background: #FFFBF0;
        }

        .student-name {
            color: #6B46C1;
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
            background-color: white;
            transition: 0.4s;
            border-radius: 50%;
        }

        input:checked + .slider {
            background-color: #6B46C1;
        }

        input:checked + .slider:before {
            transform: translateX(26px);
        }

        .student-name {
            font-weight: 600;
            color: #333;
        }

        .student-username {
            color: #888;
            font-size: 0.9em;
        }

        .view-details-btn {
            background: #6B46C1;
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
            background: #8B5CF6;
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
        Integer pendingCount = (Integer) request.getAttribute("pendingCount");
        Integer approvedCount = (Integer) request.getAttribute("approvedCount");
        Integer staffID = (Integer) request.getAttribute("staffID");
    %>
    
    <div class="header">
        <h1>Student Counsellor Dashboard</h1>
        <p>Manage student approvals and view financial tracking</p>
    </div>
    
    <div class="navbar">
        <a href="StudentCounsellorDashboard" class="active">Dashboard</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        <!-- Statistics Cards -->
        <div class="main-content">
            <div class="stat-card">
                <h3>Pending Approvals</h3>
                <div class="count"><%= pendingCount %></div>
            </div>
            <div class="stat-card">
                <h3>Approved Students</h3>
                <div class="count"><%= approvedCount %></div>
            </div>
            <div class="stat-card">
                <h3>Total Students</h3>
                <div class="count"><%= allStudents.size() %></div>
            </div>
        </div>

        <!-- Students Table -->
        <div class="students-section">
            <h2>All Registered Students</h2>
            
            <% if (allStudents.isEmpty()) { %>
                <div class="no-data">
                    No students registered yet.
                </div>
            <% } else { %>
            <table>
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>Email</th>
                        <th>Student Approval</th>
                        <th>Counsellor Status</th>
                        <th>Requested Date</th>
                        <th style="width: 250px;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                <% for (Map<String, Object> student : allStudents) { 
                    Integer studentID = (Integer) student.get("studentID");
                    String name = (String) student.get("name");
                    String email = (String) student.get("email");
                    Boolean isApprovedByStudent = (Boolean) student.get("approvedByStudent");
                    String accessStatus = (String) student.get("accessStatus");
                    Integer accessID = (Integer) student.get("accessID");
                    java.util.Date requestedDate = (java.util.Date) student.get("requestedDate");
                    
                    boolean fullyConnected = isApprovedByStudent && "Approved".equalsIgnoreCase(accessStatus);
                    String studentApprovalBadge = isApprovedByStudent ? "badge-approved" : "badge-pending";
                    String studentApprovalText = isApprovedByStudent ? "Approved" : "Awaiting Student Approval";
                    
                    String counsellorStatusBadge = "badge-pending";
                    if ("Approved".equalsIgnoreCase(accessStatus)) counsellorStatusBadge = "badge-approved";
                    else if ("Disapproved".equalsIgnoreCase(accessStatus)) counsellorStatusBadge = "badge-pending"; // fallback styles
                    String counsellorStatusText = accessStatus != null ? accessStatus.toUpperCase() : "PENDING";
                %>
                    <tr>
                        <td>
                            <% if (fullyConnected) { %>
                                <a href="javascript:void(0)" onclick="viewStudentProfile(<%= studentID %>)" class="student-name" style="color:#6B46C1; text-decoration:underline;">
                                    <%= name %>
                                </a>
                            <% } else { %>
                                <span class="student-name disabled" title="Mutual approval required to view profiles"><%= name %></span>
                            <% } %>
                        </td>
                        <td><%= email %></td>
                        <td><span class="badge <%= studentApprovalBadge %>"><%= studentApprovalText %></span></td>
                        <td>
                            <span class="badge <%= counsellorStatusBadge %>" 
                                  style="<%= "Disapproved".equalsIgnoreCase(accessStatus) ? "background:#F8D7DA; color:#721C24;" : "" %>">
                                <%= counsellorStatusText %>
                            </span>
                        </td>
                        <td><%= requestedDate != null ? new java.text.SimpleDateFormat("MMM dd, yyyy").format(requestedDate) : "N/A" %></td>
                        <td>
                            <div class="action-buttons">
                            <% if (accessID == 0) { %>
                                <button class="btn-approve" onclick="connectStudent(<%= studentID %>, <%= staffID %>)">Connect</button>
                            <% } else if (!"Approved".equalsIgnoreCase(accessStatus)) { %>
                                <button class="btn-approve" onclick="approveStudent(<%= accessID %>)">APPROVE</button>
                                <button class="btn-disapprove" onclick="disapproveStudent(<%= accessID %>)">DISAPPROVE</button>
                            <% } else { %>
                                <button class="btn-disapprove" onclick="disapproveStudent(<%= accessID %>)">REVOKE</button>
                            <% } %>
                            </div>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
            <% } %>
        </div>
    </div>

    <script>
        function connectStudent(studentID, staffID) {
            if (confirm('Do you want to request connection with this student?')) {
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
                alert('An error occurred');
            });
        }

        function approveStudent(accessID) {
            if (confirm('Are you sure you want to approve this student?')) {
                sendAction('approveStudent', accessID);
            }
        }

        function disapproveStudent(accessID) {
            if (confirm('Are you sure you want to disapprove/revoke this student?')) {
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
</body>
</html>
