<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.pocketpilot.util.DatabaseConnection" %>
<%@ page import="com.pocketpilot.model.StudentCounsellorAccess" %>
<%@ page import="com.pocketpilot.dao.StudentCounsellorDAO" %>
<%@ page import="com.pocketpilot.dao.ParentSupervisionDAO" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supervision Access - PocketPilot</title>
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
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }

        .tabs {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
            border-bottom: 2px solid #E0D5C7;
            background: white;
            border-radius: 8px 8px 0 0;
        }

        .tab-button {
            padding: 15px 25px;
            background: none;
            border: none;
            cursor: pointer;
            color: #666;
            font-size: 14px;
            font-weight: 600;
            border-bottom: 3px solid transparent;
            transition: all 0.3s;
        }

        .tab-button.active {
            color: #6B46C1;
            border-bottom-color: #6B46C1;
        }

        .tab-content {
            display: none;
            background: white;
            padding: 25px;
            border-radius: 0 8px 8px 8px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
        }

        .tab-content.active {
            display: block;
        }

        .section {
            margin-bottom: 30px;
        }

        .section h3 {
            color: #6B46C1;
            margin-bottom: 15px;
            font-size: 18px;
        }

        .code-generator {
            background: #F5F1E8;
            padding: 20px;
            border-radius: 8px;
            margin-bottom: 20px;
        }

        .code-generator button {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 600;
            transition: all 0.3s;
        }

        .code-generator button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(107, 70, 193, 0.3);
        }

        .generated-codes {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
        }

        .code-card {
            background: linear-gradient(135deg, #E9D5FF 0%, #F3E8FF 100%);
            border: 2px solid #6B46C1;
            padding: 15px;
            border-radius: 8px;
            text-align: center;
        }

        .code-card .label {
            font-size: 12px;
            color: #666;
            margin-bottom: 8px;
        }

        .code-card .code {
            font-size: 24px;
            font-weight: bold;
            color: #6B46C1;
            font-family: 'Courier New', monospace;
            letter-spacing: 2px;
        }

        .code-card .status {
            font-size: 11px;
            color: #999;
            margin-top: 8px;
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
        }

        .btn-approve:hover {
            background: #1b5e20;
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
            margin-left: 5px;
            transition: all 0.3s;
        }

        .btn-disapprove:hover {
            background: #b71c1c;
        }

        .badge {
            display: inline-block;
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
        }

        .badge-pending {
            background: #FFF3CD;
            color: #856404;
        }

        .badge-approved {
            background: #D4EDDA;
            color: #155724;
        }

        .badge-active {
            background: #D4EDDA;
            color: #155724;
        }

        .no-data {
            text-align: center;
            padding: 30px;
            color: #999;
        }
    </style>
<body>
    <%
        // Check if user is logged in
        Integer userID = (Integer) session.getAttribute("userID");
        String userRole = (String) session.getAttribute("role");
        
        if (userID == null) {
            response.sendRedirect("login.jsp");
            return;
        }

        // Only students can access this page
        if (!"Student".equals(userRole)) {
            response.sendRedirect("loginDashboard.jsp");
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

        // Get data for all tabs
        List<StudentCounsellorAccess> counsellorRequests = new ArrayList<>();
        List<String> generatedCodes = new ArrayList<>();

        if (studentID != null) {
            try {
                // Get pending counsellor approval requests
                counsellorRequests = StudentCounsellorDAO.getPendingCounsellorRequestsForStudent(studentID);
                
                // Get generated codes
                generatedCodes = ParentSupervisionDAO.getPendingCodesForStudent(studentID);
            } catch (Exception e) {
                System.err.println("Error fetching supervision data: " + e.getMessage());
            }
        }
    %>
    
    <div class="header">
        <h1>👥 Supervision Access Management</h1>
        <p>Manage your supervision relationships with counsellors and parents</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="budget.jsp">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="trackingProgress.jsp">Tracking</a>
        <a href="supervisionAccess.jsp" class="active">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        <!-- Tab Navigation -->
        <div class="tabs">
            <button class="tab-button active" onclick="switchTab('counsellors')">Counsellor Access Requests</button>
            <button class="tab-button" onclick="switchTab('parents')">Parent Supervision Codes</button>
        </div>

        <!-- Tab 1: Counsellor Access Requests -->
        <div id="counsellors" class="tab-content active">
            <div class="section">
                <h3>Pending Counsellor Approval Requests</h3>
                <p style="color: #666; margin-bottom: 15px; font-size: 14px;">
                    Student counsellors are requesting access to view your budget and expenses. 
                    Review and approve or disapprove each request.
                </p>

                <% if (counsellorRequests.isEmpty()) { %>
                    <div class="no-data">
                        ✓ No pending requests. All counsellor access has been approved or disapproved.
                    </div>
                <% } else { %>
                <table>
                    <thead>
                        <tr>
                            <th>Counsellor Name</th>
                            <th>Request Status</th>
                            <th>Requested Date</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% 
                    java.text.SimpleDateFormat dateFormatter = new java.text.SimpleDateFormat("dd MMMM yyyy");
                    for (StudentCounsellorAccess req : counsellorRequests) { 
                        String statusDisplay = req.isApprovedByStudent() ? "APPROVED" : "PENDING";
                        String statusClass = req.isApprovedByStudent() ? "badge-approved" : "badge-pending";
                    %>
                        <tr>
                            <td><strong>Counsellor ID: <%= req.getStaffID() %></strong></td>
                            <td><span class="badge <%= statusClass %>"><%= statusDisplay %></span></td>
                            <td><%= req.getCreatedDate() != null ? dateFormatter.format(new java.util.Date(req.getCreatedDate().getTime())) : "N/A" %></td>
                            <td>
                                <% if (!req.isApprovedByStudent()) { %>
                                    <button class="btn-approve" onclick="approveCounsellor(<%= req.getAccessID() %>)">✓ APPROVE</button>
                                    <button class="btn-disapprove" onclick="disapproveCounsellor(<%= req.getAccessID() %>)">✗ DISAPPROVE</button>
                                <% } else { %>
                                    <button class="btn-disapprove" onclick="disapproveCounsellor(<%= req.getAccessID() %>)">✗ REVOKE ACCESS</button>
                                <% } %>
                            </td>
                        </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } %>
            </div>
        </div>

        <!-- Tab 2: Parent Supervision Codes -->
        <div id="parents" class="tab-content">
            <div class="section">
                <h3>Generate Supervision Code for Parent</h3>
                <p style="color: #666; margin-bottom: 15px; font-size: 14px;">
                    Create a unique code to share with a parent. They can enter this code to connect to your account 
                    and view your budget and expenses.
                </p>

                <div class="code-generator">
                    <button onclick="generateNewCode()"> GENERATE NEW CODE</button>
                </div>

                <h3 style="margin-top: 30px;">Your Active Supervision Codes</h3>
                <% if (generatedCodes.isEmpty()) { %>
                    <div class="no-data">
                        No active codes. <a href="javascript:void(0)" onclick="generateNewCode()" style="color: #6B46C1; font-weight: 600;">Generate one now</a>
                    </div>
                <% } else { %>
                <div class="generated-codes">
                <% for (String code : generatedCodes) { %>
                    <div class="code-card">
                        <div class="label">Parent Supervision Code</div>
                        <div class="code"><%= code %></div>
                        <div class="status">⏳ Waiting for parent entry</div>
                    </div>
                <% } %>
                </div>
                <% } %>
            </div>
        </div>
    </div>

    <script>
        function switchTab(tabName) {
            // Hide all tabs
            const tabs = document.querySelectorAll('.tab-content');
            tabs.forEach(tab => tab.classList.remove('active'));

            // Remove active class from all buttons
            const buttons = document.querySelectorAll('.tab-button');
            buttons.forEach(btn => btn.classList.remove('active'));

            // Show selected tab
            document.getElementById(tabName).classList.add('active');

            // Add active class to clicked button
            event.target.classList.add('active');
        }

        function approveCounsellor(accessID) {
            if (confirm('Are you sure you want to approve this counsellor?\nThey will be able to view your budget and expenses.')) {
                fetch('SupervisionAccessServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=approveCounsellor&accessID=' + accessID
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('✓ Counsellor approved! They now have access to your budget and expenses.');
                        location.reload();
                    } else {
                        alert('✗ Error: ' + data.message);
                    }
                })
                .catch(error => console.error('Error:', error));
            }
        }

        function disapproveCounsellor(accessID) {
            if (confirm('Are you sure you want to disapprove this counsellor?\nThey will lose access to your budget and expenses.')) {
                fetch('SupervisionAccessServlet', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded'
                    },
                    body: 'action=disapproveCounsellor&accessID=' + accessID
                })
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        alert('✓ Counsellor access removed.');
                        location.reload();
                    } else {
                        alert('✗ Error: ' + data.message);
                    }
                })
                .catch(error => console.error('Error:', error));
            }
        }

        function generateNewCode() {
            fetch('SupervisionAccessServlet', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded'
                },
                body: 'action=generateCode'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    alert('✓ New supervision code generated:\n\n' + data.code + '\n\nShare this with the parent.');
                    location.reload();
                } else {
                    alert('✗ Error: ' + data.message);
                }
            })
            .catch(error => console.error('Error:', error));
        }
    </script>
</body>
</html>
