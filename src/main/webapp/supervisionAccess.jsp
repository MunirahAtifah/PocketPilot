<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.pocketpilot.util.DatabaseConnection, com.pocketpilot.model.StudentCounsellorAccess, com.pocketpilot.dao.StudentCounsellorDAO" %>
<%
    Integer userID = (Integer) session.getAttribute("userID");
    String role = (String) session.getAttribute("role");
    
    if (userID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    Integer studentID = null;
    Integer parentID = null;
    List<StudentCounsellorAccess> counsellorRequests = new ArrayList<>();
    List<Map<String, Object>> supervisionLinks = new ArrayList<>();
    Map<Integer, String> counsellorNames = new HashMap<>();

    try (Connection conn = DatabaseConnection.getConnection()) {
        if ("Student".equals(role)) {
            // Get studentID
            String studentSql = "SELECT studentID FROM student WHERE userID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(studentSql)) {
                stmt.setInt(1, userID);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        studentID = rs.getInt("studentID");
                    }
                }
            }
            
            if (studentID != null) {
                // Get pending counsellor requests
                counsellorRequests = StudentCounsellorDAO.getPendingCounsellorRequestsForStudent(studentID);
                
                // Get counsellor names mapping
                try (PreparedStatement stmt = conn.prepareStatement("SELECT staffID, staffName FROM student_counsellor")) {
                    try (ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            counsellorNames.put(rs.getInt("staffID"), rs.getString("staffName"));
                        }
                    }
                }
                
                // Get all generated supervision codes and parent links for this student
                String linksSql = "SELECT sa.code, sa.approvalStatus, sa.relationship, p.parentName " +
                                  "FROM supervisionaccess sa " +
                                  "LEFT JOIN parent p ON sa.parentID = p.parentID " +
                                  "WHERE sa.studentID = ? ORDER BY sa.createdDate DESC";
                try (PreparedStatement stmt = conn.prepareStatement(linksSql)) {
                    stmt.setInt(1, studentID);
                    try (ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> link = new HashMap<>();
                            link.put("code", rs.getString("code"));
                            link.put("approvalStatus", rs.getString("approvalStatus"));
                            link.put("relationship", rs.getString("relationship"));
                            link.put("parentName", rs.getString("parentName"));
                            supervisionLinks.add(link);
                        }
                    }
                }
            }
        } else if ("Parent".equals(role)) {
            // Get parentID
            String parentSql = "SELECT parentID FROM parent WHERE userID = ?";
            try (PreparedStatement stmt = conn.prepareStatement(parentSql)) {
                stmt.setInt(1, userID);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        parentID = rs.getInt("parentID");
                    }
                }
            }

            if (parentID != null) {
                // Get all student links for this parent
                String linksSql = "SELECT sa.code, sa.approvalStatus, sa.relationship, s.studentName, s.studentID " +
                                  "FROM supervisionaccess sa " +
                                  "JOIN student s ON sa.studentID = s.studentID " +
                                  "WHERE sa.parentID = ? ORDER BY sa.createdDate DESC";
                try (PreparedStatement stmt = conn.prepareStatement(linksSql)) {
                    stmt.setInt(1, parentID);
                    try (ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            Map<String, Object> link = new HashMap<>();
                            link.put("code", rs.getString("code"));
                            link.put("approvalStatus", rs.getString("approvalStatus"));
                            link.put("relationship", rs.getString("relationship"));
                            link.put("studentName", rs.getString("studentName"));
                            link.put("studentID", rs.getInt("studentID"));
                            supervisionLinks.add(link);
                        }
                    }
                }
            }
        }
    } catch (SQLException e) {
        System.err.println("Error loading supervision access data: " + e.getMessage());
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supervision Management - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css">
    <script src="js/theme.js"></script>
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
        .status-badge {
            padding: 4px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: 700;
            text-transform: uppercase;
        }
        .code-box {
            font-family: 'Courier New', monospace;
            background: var(--input-bg);
            padding: 15px;
            border-radius: 8px;
            border: 2px dashed var(--primary-color);
            font-size: 24px;
            text-align: center;
            font-weight: 700;
            color: var(--primary-color);
            margin: 20px 0;
            max-width: 250px;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>Supervision Access Management</h1>
        <p>Manage family and academic tracking options</p>
    </div>
 
    <div class="navbar">
        <a href="#" class="navbar-brand">PocketPilot</a>
        <button class="menu-toggle" onclick="toggleMobileMenu()">☰</button>
        <div class="navbar-links" id="navbarLinks">
            <% if ("Student".equals(role)) { %>
                <a href="studentDashboard.jsp">Dashboard</a>
                <a href="budget.jsp">Budget</a>
                <a href="expense.jsp">Expense</a>
                <a href="TrackingProgressServlet">Tracking Progress</a>
                <a href="supervisionAccess.jsp" class="active">Supervision</a>
            <% } else if ("Parent".equals(role)) { 
                int firstChildID = -1;
                for (Map<String, Object> link : supervisionLinks) {
                    Object sIdObj = link.get("studentID");
                    if (sIdObj != null) {
                        firstChildID = (Integer) sIdObj;
                        break;
                    }
                }
                String trackingUrl = firstChildID > 0 ? "TrackingProgressServlet?studentID=" + firstChildID : "TrackingProgressServlet";
            %>
                <a href="parentDashboard.jsp">Dashboard</a>
                <a href="<%= trackingUrl %>">Tracking Progress</a>
                <a href="supervisionAccess.jsp" class="active">Supervision</a>
            <% } %>
            <button class="theme-toggle" onclick="toggleTheme()">🌓 Theme</button>
            <a href="LogoutServlet" class="logout-btn">Logout</a>
        </div>
    </div>

    <div class="container">
        
        <!-- Alerts for Success/Error feedback -->
        <% String successMsg = request.getParameter("success");
           if (successMsg != null && !successMsg.isEmpty()) { %>
            <div class="alert alert-success">
                <%= successMsg %>
            </div>
        <% } %>
        <% String errorMsg = request.getParameter("error");
           if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div class="alert alert-danger">
                <%= errorMsg %>
            </div>
        <% } %>

        <% if ("Student".equals(role)) { %>
            <!-- ================= STUDENT ACCESS VIEW ================= -->
            
            <!-- Counsellor Supervision Setup -->
            <%
                List<StudentCounsellorAccess> pendingCounsellors = new ArrayList<>();
                List<StudentCounsellorAccess> approvedCounsellors = new ArrayList<>();
                if (counsellorRequests != null) {
                    for (StudentCounsellorAccess req : counsellorRequests) {
                        if (req.isApprovedByStudent()) {
                            approvedCounsellors.add(req);
                        } else {
                            pendingCounsellors.add(req);
                        }
                    }
                }
            %>

            <!-- Counsellor Approval Requests -->
            <div class="card">
                <h3>Pending Counsellor Requests</h3>
                <% if (pendingCounsellors.isEmpty()) { %>
                    <p style="color: #7F8C8D; font-style: italic;">No pending counsellor supervision requests.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Counsellor Name</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (StudentCounsellorAccess req : pendingCounsellors) { %>
                                <tr>
                                    <td><%= counsellorNames.getOrDefault(req.getStaffID(), "Counsellor (ID: " + req.getStaffID() + ")") %></td>
                                    <td>
                                        <span class="status-badge" style="background: #FFF3CD; color: #856404;">
                                            Pending Approval
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn-primary" style="padding: 6px 12px; background: #28a745;" onclick="updateAccess(<%= req.getAccessID() %>, 'approveCounsellor')">Approve</button>
                                        <button class="btn-primary" style="padding: 6px 12px; background: #dc3545;" onclick="updateAccess(<%= req.getAccessID() %>, 'disapproveCounsellor')">Decline</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

            <!-- Linked Counsellors -->
            <div class="card">
                <h3>Linked Counsellors</h3>
                <% if (approvedCounsellors.isEmpty()) { %>
                    <p style="color: #7F8C8D; font-style: italic;">No counsellors linked to your account yet.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Counsellor Name</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (StudentCounsellorAccess req : approvedCounsellors) { %>
                                <tr>
                                    <td><%= counsellorNames.getOrDefault(req.getStaffID(), "Counsellor (ID: " + req.getStaffID() + ")") %></td>
                                    <td>
                                        <span class="status-badge" style="background: #E8F5E9; color: #2E7D32;">
                                            Approved
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn-primary" style="padding: 6px 12px; background: #dc3545;" onclick="updateAccess(<%= req.getAccessID() %>, 'disapproveCounsellor')">Revoke Link</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

            <!-- Parent Supervision Section -->
            <div class="card">
                <h3>Parent Supervision Setup</h3>
                <p style="color: #555; font-size: 15px; margin-bottom: 15px;">
                    Generate a supervision code and share it with your parent. They will use this code to link their account and view your monthly budgets.
                </p>
                
                <%
                    boolean hasPendingCode = false;
                    String activeCode = "";
                    for (Map<String, Object> link : supervisionLinks) {
                        if (link.get("parentName") == null) {
                            hasPendingCode = true;
                            activeCode = (String) link.get("code");
                            break;
                        }
                    }
                %>
                
                <% if (hasPendingCode) { %>
                    <p style="font-weight: bold; color: #6B46C1;">Your active pending code is:</p>
                    <div class="code-box"><%= activeCode %></div>
                    <p style="color: #7F8C8D; font-size: 13px;">Provide this 6-character code to your parent to link accounts.</p>
                <% } else { %>
                    <form method="POST" action="GenerateSupervisionCodeServlet">
                        <button type="submit" class="btn-primary">Generate Supervision Code</button>
                    </form>
                <% } %>
            </div>

            <!-- Active Supervision Links -->
            <div class="card">
                <h3>Linked Parents</h3>
                <%
                    List<Map<String, Object>> linkedParents = new ArrayList<>();
                    for (Map<String, Object> link : supervisionLinks) {
                        if (link.get("parentName") != null) {
                            linkedParents.add(link);
                        }
                    }
                %>
                <% if (linkedParents.isEmpty()) { %>
                    <p style="color: #7F8C8D; font-style: italic;">No parents have linked to your account yet.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Parent Name</th>
                                <th>Relationship</th>
                                <th>Supervision Code</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> parent : linkedParents) { %>
                                <tr>
                                    <td style="font-weight: 600;"><%= parent.get("parentName") %></td>
                                    <td><%= parent.get("relationship") %></td>
                                    <td style="font-family: monospace; font-weight: 700; color: #6B46C1;"><%= parent.get("code") %></td>
                                    <td>
                                        <span class="status-badge" style="background: #E8F5E9; color: #2E7D32;">
                                            Approved
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn-primary" style="padding: 6px 12px; background: #dc3545;" onclick="revokeAccess('<%= parent.get("code") %>')">Revoke Link</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

        <% } else if ("Parent".equals(role)) { %>
            <!-- ================= PARENT ACCESS VIEW ================= -->

            <!-- Link Child Form -->
            <div class="card">
                <h3>Link Child's Account</h3>
                <p style="color: #555; font-size: 15px; margin-bottom: 20px;">
                    Enter the 6-character supervision code generated by your child to link their account to your dashboard.
                </p>
                <form method="POST" action="LinkSupervisionCodeServlet">
                    <div class="form-group">
                        <label for="supervisionCode">Supervision Code</label>
                        <input type="text" id="supervisionCode" name="supervisionCode" placeholder="e.g. QC0A6R" required maxlength="8">
                    </div>
                    <div class="form-group">
                        <label for="relationship">Relationship</label>
                        <select id="relationship" name="relationship" required>
                            <option value="">Select Relationship...</option>
                            <option value="Father">Father</option>
                            <option value="Mother">Mother</option>
                            <option value="Guardian">Guardian</option>
                            <option value="Other">Other</option>
                        </select>
                    </div>
                    <button type="submit" class="btn-primary">Link Child Account</button>
                </form>
            </div>

            <!-- Active supervision child connections -->
            <div class="card">
                <h3>Linked Children</h3>
                <% if (supervisionLinks.isEmpty()) { %>
                    <p style="color: #7F8C8D; font-style: italic;">No children linked to your account yet. Use the form above to link.</p>
                <% } else { %>
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Child Name</th>
                                <th>Relationship</th>
                                <th>Status</th>
                                <th>Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% for (Map<String, Object> child : supervisionLinks) { %>
                                <tr>
                                    <td style="font-weight: 600;"><%= child.get("studentName") %></td>
                                    <td><%= child.get("relationship") %></td>
                                    <td>
                                        <span class="status-badge" style="background: #E8F5E9; color: #2E7D32;">
                                            Connected
                                        </span>
                                    </td>
                                    <td>
                                        <button class="btn-primary" style="padding: 6px 12px; background: #dc3545;" onclick="removeAccess('<%= child.get("code") %>')">Remove Link</button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>

        <% } %>

    </div>

    <script>
        // Counsellor approval action handler
        function updateAccess(id, action) {
            fetch('SupervisionAccessServlet?action=' + action + '&accessID=' + id, {method: 'POST'})
            .then(() => location.reload());
        }
        
        // Student revokes parent access
        function revokeAccess(code) {
            if (confirm("Are you sure you want to revoke this parent's supervision access?")) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'RevokeSupervisionAccessServlet';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'accessId';
                input.value = code;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }

        // Parent unlinks from child
        function removeAccess(code) {
            if (confirm("Are you sure you want to remove this child supervision link?")) {
                const form = document.createElement('form');
                form.method = 'POST';
                form.action = 'RemoveSupervisionServlet';
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'accessId';
                input.value = code;
                form.appendChild(input);
                document.body.appendChild(form);
                form.submit();
            }
        }
    </script>
</body>
</html>