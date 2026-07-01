<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, com.pocketpilot.util.DatabaseConnection, java.time.YearMonth" %>
<%
    // Check if user is logged in
    Integer uID = (Integer) session.getAttribute("userID");
    if (uID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    com.pocketpilot.dao.UserDAO userDAO = new com.pocketpilot.dao.UserDAO();
    int studentID = userDAO.getStudentIDByUserID(uID);
    if (studentID == -1) {
        response.sendRedirect("login.jsp");
        return;
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

    double totalExpenses = 0.0;
    double dailyAverage = 0.0;
    String highestCat = "-";

    try (Connection conn = DatabaseConnection.getConnection()) {
        // 1. Total expenses (This Month / Selected Month)
        String totalSql = "SELECT SUM(expenseAmount) FROM expense WHERE studentID = ? AND MONTH(expenseDate) = ? AND YEAR(expenseDate) = ?";
        try (PreparedStatement stmt = conn.prepareStatement(totalSql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, monthVal);
            stmt.setInt(3, yearVal);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    totalExpenses = rs.getDouble(1);
                }
            }
        }

        // 2. Average daily spending
        int days;
        YearMonth currentYearMonth = YearMonth.now();
        if (selectedMonth.equals(currentYearMonth)) {
            days = java.time.LocalDate.now().getDayOfMonth();
        } else {
            days = selectedMonth.lengthOfMonth();
        }
        dailyAverage = totalExpenses / (days > 0 ? days : 1);

        // 3. Highest category
        String highestSql = "SELECT c.categoryName FROM expense e " +
                            "JOIN category c ON e.categoryID = c.categoryID " +
                            "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ? " +
                            "GROUP BY c.categoryName ORDER BY SUM(e.expenseAmount) DESC LIMIT 1";
        try (PreparedStatement stmt = conn.prepareStatement(highestSql)) {
            stmt.setInt(1, studentID);
            stmt.setInt(2, monthVal);
            stmt.setInt(3, yearVal);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    highestCat = rs.getString(1);
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Load categories dynamically
    List<Map<String, Object>> categoriesList = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement("SELECT categoryID, categoryName FROM category ORDER BY categoryID")) {
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> cat = new HashMap<>();
                cat.put("id", rs.getInt("categoryID"));
                cat.put("name", rs.getString("categoryName"));
                categoriesList.add(cat);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Load expenses list dynamically
    List<Map<String, Object>> expenseList = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "SELECT e.expenseID, e.expenseDate, e.expenseDesc, e.expenseAmount, e.categoryID, c.categoryName, e.parentComment, e.counsellorComment " +
             "FROM expense e " +
             "JOIN category c ON e.categoryID = c.categoryID " +
             "WHERE e.studentID = ? AND MONTH(e.expenseDate) = ? AND YEAR(e.expenseDate) = ? " +
             "ORDER BY e.expenseDate DESC")) {
        stmt.setInt(1, studentID);
        stmt.setInt(2, monthVal);
        stmt.setInt(3, yearVal);
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("id", rs.getInt("expenseID"));
                row.put("date", rs.getDate("expenseDate").toLocalDate());
                row.put("desc", rs.getString("expenseDesc"));
                row.put("amount", rs.getDouble("expenseAmount"));
                row.put("categoryID", rs.getInt("categoryID"));
                row.put("category", rs.getString("categoryName"));
                row.put("parentComment", rs.getString("parentComment"));
                row.put("counsellorComment", rs.getString("counsellorComment"));
                expenseList.add(row);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Expense Management - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css?v=1.0.3">
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
            color: white !important;
            box-shadow: 0 4px 12px rgba(107, 70, 193, 0.4);
            transform: translateY(-1px);
        }
        
        .container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        .btn-primary {
            background: var(--header-bg-gradient);
            color: white;
            box-shadow: 0 2px 8px rgba(107, 70, 193, 0.3);
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(107, 70, 193, 0.4);
        }
        
        .btn-secondary {
            background: var(--border-color);
            color: var(--primary-color);
        }
        
        .btn-secondary:hover {
            background: #D4C4B0;
        }
        
        .btn-danger {
            background: #c62828;
            color: white;
        }
        
        .btn-danger:hover {
            background: #b71c1c;
        }
        
        .card {
            background: var(--card-bg);
            border-radius: 15px;
            padding: 25px;
            margin-bottom: 25px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            border: 1px solid var(--border-color);
            transition: all 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
        }
        
        .card h3 {
            color: var(--primary-color);
            margin-bottom: 20px;
            font-size: 20px;
            font-weight: 700;
            border-bottom: 2px solid var(--border-color);
            padding-bottom: 10px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 13px;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid var(--border-color);
            border-radius: 6px;
            font-size: 13px;
            font-family: inherit;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--nav-link-hover-bg);
        }
        
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 15px;
        }
        
        @media (max-width: 600px) {
            .form-row {
                grid-template-columns: 1fr;
            }
        }
        
        .table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .table thead {
            background: var(--body-bg);
            border-bottom: 2px solid var(--primary-color);
        }
        
        .table th {
            color: var(--primary-color);
            padding: 14px;
            text-align: left;
            font-weight: 700;
            font-size: 14px;
        }
        
        .table td {
            padding: 14px;
            border-bottom: 1px solid var(--border-color);
            font-size: 14px;
            color: var(--title-color);
        }
        
        .table tbody tr:hover {
            background: var(--nav-link-hover-bg);
        }
        
        .action-buttons {
            display: flex;
            gap: 8px;
        }
        
        .action-buttons a,
        .action-buttons button {
            padding: 6px 12px;
            font-size: 12px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
        }
        
        .edit-btn {
            background: var(--primary-hover);
            color: white;
        }
        
        .delete-btn {
            background: #c62828;
            color: white;
        }
        
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
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
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
        }
        
        .stat-card h4 {
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
    </style>
</head>
<body>
    <div class="header">
        <h1>Expense Management</h1>
        <p>Track and manage your expenses</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="budget.jsp">Budget</a>
        <a href="expense.jsp" class="active">Expense</a>
        <a href="TrackingProgressServlet">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        <!-- Month/Year Selector Form -->
        <div class="month-selector" style="margin-bottom: 25px; background: var(--card-bg); padding: 15px 25px; border-radius: 10px; box-shadow: 0 3px 10px rgba(0,0,0,0.05); border: 1px solid var(--border-color); max-width: fit-content;">
            <form method="GET" action="expense.jsp">
                <label for="monthInput" style="color: var(--primary-color); font-weight: 700; font-size: 14px; margin-right: 10px;">Select Month/Year: </label>
                <input type="month" id="monthInput" name="month" value="<%= selectedMonth %>" onchange="this.form.submit()" style="padding: 8px 12px; border: 2px solid var(--border-color); border-radius: 6px; color: var(--primary-color); font-weight: 600; font-size: 13px; cursor: pointer; outline: none; transition: border-color 0.3s; background-color: var(--card-bg);">
            </form>
        </div>

        <!-- Alerts for Success/Error feedback -->
        <% String successMsg = request.getParameter("success");
           if (successMsg != null && !successMsg.isEmpty()) { %>
            <div style="padding: 15px; background-color: #E8F5E9; color: #2E7D32; border-left: 5px solid #2E7D32; border-radius: 8px; margin-bottom: 20px; font-size: 14px; font-weight: 600;">
                <%= successMsg %>
            </div>
        <% } %>
        <% String errorMsg = request.getParameter("error");
           if (errorMsg != null && !errorMsg.isEmpty()) { %>
            <div style="padding: 15px; background-color: #FFEBEE; color: #C62828; border-left: 5px solid #C62828; border-radius: 8px; margin-bottom: 20px; font-size: 14px; font-weight: 600;">
                <%= errorMsg %>
            </div>
        <% } %>

        <!-- Statistics -->
        <div class="stats">
            <div class="stat-card">
                <h4>Total Expenses</h4>
                <div class="amount">RM <%= String.format("%.2f", totalExpenses) %></div>
            </div>
            <div class="stat-card">
                <h4>Average Daily Spending</h4>
                <div class="amount">RM <%= String.format("%.2f", dailyAverage) %></div>
            </div>
            <div class="stat-card">
                <h4>Highest Category</h4>
                <div class="amount"><%= highestCat %></div>
            </div>
        </div>
        
        <!-- Add Expense Form -->
        <div class="card">
            <h3 id="formCardTitle">Record New Expense</h3>
            
            <form method="POST" action="AddExpenseServlet" id="expenseForm">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="expenseID" id="editExpenseID" value="">
                <input type="hidden" name="month" value="<%= selectedMonth %>">
                <div class="form-row">
                    <div class="form-group">
                        <label for="category">Category</label>
                        <select name="categoryID" id="category" required>
                            <option value="">Select a category</option>
                            <% for (Map<String, Object> cat : categoriesList) { %>
                                <option value="<%= cat.get("id") %>"><%= cat.get("name") %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="amount">Amount (RM)</label>
                        <input 
                            type="number" 
                            step="0.01" 
                            name="expenseAmount" 
                            id="amount" 
                            placeholder="0.00"
                            required
                        >
                    </div>
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="date">Date</label>
                        <input 
                            type="date" 
                            name="expenseDate" 
                            id="date"
                            required
                        >
                    </div>
                    
                    <div class="form-group">
                        <label for="description">Description</label>
                        <input 
                            type="text" 
                            name="expenseDesc" 
                            id="description"
                            placeholder="What did you spend on?"
                            oninput="suggestCategory()"
                        >
                        <div id="aiSuggestion" style="margin-top: 10px; padding: 10px; background: #E9D5FF; border-radius: 5px; display: none;">
                            <span style="color: var(--primary-color); font-weight: 600;">AI Suggestion:</span>
                            <span id="suggestionText" style="color: var(--primary-color);"></span>
                        </div>
                    </div>
                </div>
                
                <button type="submit" id="submitBtn" class="btn btn-primary">Record Expense</button>
                <button type="button" id="cancelEditBtn" class="btn btn-secondary" style="display: none;" onclick="cancelEdit()">Cancel</button>
            </form>
        </div>

        <!-- Add Custom Category Card -->
        <div class="card">
            <h3>Add Custom Category</h3>
            <form method="POST" action="AddCategoryServlet">
                <input type="hidden" name="redirectPage" value="expense.jsp?month=<%= selectedMonth %>">
                <div class="form-row" style="align-items: flex-end;">
                    <div class="form-group" style="margin-bottom: 0;">
                        <label for="newCategoryName">New Category Name</label>
                        <input type="text" name="categoryName" id="newCategoryName" placeholder="e.g. Books, Coffee, Rent" required>
                    </div>
                    <div class="form-group" style="margin-bottom: 0;">
                        <button type="submit" class="btn btn-secondary" style="width: 100%;">Add Category</button>
                    </div>
                </div>
            </form>
        </div>
        
        <!-- Expenses List -->
        <div class="card">
            <h3>Your Expenses</h3>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>Date</th>
                        <th>Category</th>
                        <th>Amount (RM)</th>
                        <th>Description</th>
                        <th>Comment</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (expenseList.isEmpty()) { %>
                        <tr>
                            <td colspan="6" style="text-align: center; color: #999;">
                                No expenses yet. Record one above!
                            </td>
                        </tr>
                    <% } else { %>
                        <% for (Map<String, Object> e : expenseList) { %>
                            <tr>
                                <td><%= e.get("date") %></td>
                                <td><%= e.get("category") %></td>
                                <td style="font-weight: 600;">RM <%= String.format("%.2f", (Double) e.get("amount")) %></td>
                                <td><%= e.get("desc") != null ? e.get("desc") : "-" %></td>
                                 <td>
                                     <%
                                         String parentComment = (String) e.get("parentComment");
                                         String counsellorComment = (String) e.get("counsellorComment");
                                         StringBuilder commentStr = new StringBuilder();
                                         if (parentComment != null && !parentComment.trim().isEmpty()) {
                                             commentStr.append("<strong style='color: var(--primary-color);'>Parent:</strong> ").append(parentComment);
                                         }
                                         if (counsellorComment != null && !counsellorComment.trim().isEmpty()) {
                                             if (commentStr.length() > 0) commentStr.append("<br>");
                                             commentStr.append("<strong style='color: var(--primary-hover);'>Counsellor:</strong> ").append(counsellorComment);
                                         }
                                         if (commentStr.length() == 0) {
                                             commentStr.append("-");
                                         }
                                     %>
                                     <span style="font-size: 13px;"><%= commentStr.toString() %></span>
                                 </td>
                                <td>
                                    <div class="action-buttons">
                                        <button type="button" class="edit-btn btn btn-secondary" style="padding: 4px 8px; font-size: 12px; height: auto; border-radius: 4px;" onclick="enableEdit('<%= e.get("id") %>', '<%= e.get("categoryID") %>', '<%= e.get("amount") %>', '<%= e.get("date") %>', '<%= e.get("desc") != null ? e.get("desc").toString().replace("'", "\\'") : "" %>')">Edit</button>
                                        <form method="POST" action="AddExpenseServlet" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this expense?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="expenseID" value="<%= e.get("id") %>">
                                            <input type="hidden" name="month" value="<%= selectedMonth %>">
                                            <button type="submit" class="delete-btn btn btn-danger" style="padding: 4px 8px; font-size: 12px; height: auto; border-radius: 4px;">Delete</button>
                                        </form>
                                    </div>
                                </td>
                            </tr>
                        <% } %>
                    <% } %>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        let debounceTimer;
        let lastSuggestedCategoryId = null;
        function suggestCategory() {
            clearTimeout(debounceTimer);
            debounceTimer = setTimeout(() => {
                const description = document.getElementById('description').value;
                const categorySelect = document.getElementById('category');
                const suggestionDiv = document.getElementById('aiSuggestion');
                const suggestionText = document.getElementById('suggestionText');
                
                if (description.length < 2) {
                    suggestionDiv.style.display = 'none';
                    return;
                }
                
                fetch('AISuggestServlet?description=' + encodeURIComponent(description))
                    .then(response => response.json())
                    .then(data => {
                        // Only suggest if it is a specific category (not 'Other' fallback ID 8) 
                        // and is different from current selection
                        if (data && data.categoryID && data.categoryID !== 8 && String(categorySelect.value) !== String(data.categoryID)) {
                            lastSuggestedCategoryId = data.categoryID;
                            suggestionText.innerHTML = ' Select "<strong>' + data.categoryName + '</strong>" for this expense? <span style="text-decoration: underline; font-weight: bold; margin-left: 5px;">[Click to Apply]</span>';
                            suggestionDiv.style.display = 'block';
                            suggestionDiv.style.cursor = 'pointer';
                        } else {
                            suggestionDiv.style.display = 'none';
                        }
                    })
                    .catch(err => {
                        console.error('AI Suggestion failed:', err);
                    });
            }, 300);
        }

        document.getElementById('aiSuggestion').addEventListener('click', function() {
            if (lastSuggestedCategoryId) {
                document.getElementById('category').value = lastSuggestedCategoryId;
                document.getElementById('aiSuggestion').style.display = 'none';
            }
        });

        // Edit expense helpers
        function enableEdit(id, categoryID, amount, date, desc) {
            document.getElementById('formCardTitle').textContent = 'Edit Expense';
            document.getElementById('formAction').value = 'update';
            document.getElementById('editExpenseID').value = id;
            document.getElementById('category').value = categoryID;
            document.getElementById('amount').value = amount;
            document.getElementById('date').value = date;
            document.getElementById('description').value = desc;
            
            // Change submit button text
            document.getElementById('submitBtn').textContent = 'Update Expense';
            
            // Show cancel button
            document.getElementById('cancelEditBtn').style.display = 'inline-block';
            
            // Scroll to form
            document.getElementById('formCardTitle').scrollIntoView({ behavior: 'smooth' });
        }

        function cancelEdit() {
            document.getElementById('formCardTitle').textContent = 'Record New Expense';
            document.getElementById('formAction').value = 'add';
            document.getElementById('editExpenseID').value = '';
            document.getElementById('category').value = '';
            document.getElementById('amount').value = '';
            document.getElementById('date').value = '';
            document.getElementById('description').value = '';
            document.getElementById('submitBtn').textContent = 'Record Expense';
            document.getElementById('cancelEditBtn').style.display = 'none';
        }
    </script>

<script src="js/theme.js?v=1.0.3"></script>
</body>
</html>

