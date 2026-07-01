<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate, com.pocketpilot.dao.BudgetDAO, java.util.*, java.sql.*, com.pocketpilot.util.DatabaseConnection" %>
<%
    // 1. Force variable initialization so they are always available to the HTML
    double totalBudget = 0.0;
    double totalExpenses = 0.0;
    String highestCat = "-";

    // 2. Check login using "userID" to match expense.jsp
    Integer uID = (Integer) session.getAttribute("userID");
    if (uID == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    // 3. Logic only runs if logged in
    com.pocketpilot.dao.UserDAO userDAO = new com.pocketpilot.dao.UserDAO();
    int studentID = userDAO.getStudentIDByUserID(uID);
    if (studentID == -1) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Get selected month from query parameter, default to current month
    String monthParam = request.getParameter("month");
    java.time.YearMonth selectedMonth;
    if (monthParam != null && monthParam.matches("\\d{4}-\\d{2}")) {
        selectedMonth = java.time.YearMonth.parse(monthParam);
    } else {
        selectedMonth = java.time.YearMonth.now();
    }
    int monthVal = selectedMonth.getMonthValue();
    int yearVal = selectedMonth.getYear();

    BudgetDAO budgetDAO = new BudgetDAO();
    int sIDInt = studentID;
    
    totalBudget = budgetDAO.getTotalBudgetForMonth(sIDInt, monthVal, yearVal);
    totalExpenses = budgetDAO.getTotalExpensesForMonth(sIDInt, monthVal, yearVal);
    highestCat = budgetDAO.getHighestCategory(sIDInt, monthVal, yearVal);

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

    // Load budgets dynamically (filtered by selected month/year)
    List<Map<String, Object>> budgetList = new ArrayList<>();
    try (Connection conn = DatabaseConnection.getConnection();
         PreparedStatement stmt = conn.prepareStatement(
             "SELECT b.budgetID, b.budgetDate, b.budgetDesc, b.budgetAmount, b.categoryID, c.categoryName, b.parentComment, b.counsellorComment " +
             "FROM budget b " +
             "JOIN category c ON b.categoryID = c.categoryID " +
             "WHERE b.studentID = ? AND MONTH(b.budgetDate) = ? AND YEAR(b.budgetDate) = ? " +
             "ORDER BY b.budgetDate DESC")) {
        stmt.setInt(1, studentID);
        stmt.setInt(2, monthVal);
        stmt.setInt(3, yearVal);
        try (ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> budgetRow = new HashMap<>();
                budgetRow.put("id", rs.getInt("budgetID"));
                budgetRow.put("date", rs.getDate("budgetDate").toLocalDate());
                budgetRow.put("desc", rs.getString("budgetDesc"));
                budgetRow.put("amount", rs.getDouble("budgetAmount"));
                budgetRow.put("categoryID", rs.getInt("categoryID"));
                budgetRow.put("category", rs.getString("categoryName"));
                budgetRow.put("parentComment", rs.getString("parentComment"));
                budgetRow.put("counsellorComment", rs.getString("counsellorComment"));
                budgetList.add(budgetRow);
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Budget Management - PocketPilot</title>
    <link rel="stylesheet" href="css/style.css?v=1.0.1">
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
            background: rgba(255, 255, 255, 0.85);
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
            background: white;
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
            border-bottom: 2px solid #F3E8FF;
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
            background: white;
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
            color: #7F8C8D;
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
    <div class="header"><h1>Budget Management</h1><p>Set and manage your monthly budgets</p></div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="budget.jsp" class="active">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="TrackingProgressServlet">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>

    <div class="container">
        <!-- Month Selector Form -->
        <div class="month-selector" style="margin-bottom: 25px; background: white; padding: 15px 25px; border-radius: 10px; box-shadow: 0 3px 10px rgba(0,0,0,0.05); border: 1px solid var(--border-color); max-width: fit-content;">
            <form method="GET" action="budget.jsp">
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

        <div class="stats">
            <div class="stat-card"><h4>Total Budget</h4><div class="amount">RM <%= String.format("%.2f", totalBudget) %></div></div>
            <div class="stat-card"><h4>Remaining</h4><div class="amount">RM <%= String.format("%.2f", totalBudget - totalExpenses) %></div></div>
            <div class="stat-card"><h4>Top Category</h4><div class="amount"><%= highestCat %></div></div>
        </div>

        <!-- Add Budget Form -->
        <div class="card">
            <h3 id="formCardTitle">Record New Budget</h3>
            <form method="POST" action="BudgetServlet">
                <input type="hidden" name="action" id="formAction" value="add">
                <input type="hidden" name="budgetID" id="editBudgetID" value="">
                <input type="hidden" name="month" value="<%= selectedMonth %>">
                <div class="form-group">
                    <label>Budget Period (Month/Year)</label>
                    <input type="month" name="budgetPeriod" id="budgetPeriod" required>
                </div>
                <div class="form-group">
                    <label>Category</label>
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
                        name="budgetAmount" 
                        id="amount" 
                        placeholder="0.00"
                        required
                    >
                </div>
                
                <div class="form-row">
                    <div class="form-group">
                        <label for="date">Date</label>
                        <input 
                            type="date" 
                            name="budgetDate" 
                            id="date"
                            required
                        >
                    </div>
                    
                    <div class="form-group">
                        <label for="description">Description</label>
                        <input 
                            type="text" 
                            name="budgetDesc" 
                            id="description"
                            placeholder="What is the budget for?"
                            oninput="suggestCategory()"
                        >
                        <div id="aiSuggestion" style="margin-top: 10px; padding: 10px; background: #E9D5FF; border-radius: 5px; display: none;">
                            <span style="color: var(--primary-color); font-weight: 600;">AI Suggestion:</span>
                            <span id="suggestionText" style="color: var(--primary-color);"></span>
                        </div>
                    </div>
                </div>
                
                <button type="submit" id="submitBtn" class="btn btn-primary">Record Budget</button>
                <button type="button" id="cancelEditBtn" class="btn btn-secondary" style="display: none;" onclick="cancelEdit()">Cancel</button>
            </form>
        </div>

        <!-- Add Custom Category Card -->
        <div class="card">
            <h3>Add Custom Category</h3>
            <form method="POST" action="AddCategoryServlet">
                <input type="hidden" name="redirectPage" value="budget.jsp?month=<%= selectedMonth %>">
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
        
        <!-- Budget List -->
        <div class="card">
            <h3>Your Budgets</h3>
            
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
                    <% if (budgetList.isEmpty()) { %>
                        <tr>
                            <td colspan="6" style="text-align: center; color: #999;">
                                No budgets yet. Record one above!
                            </td>
                        </tr>
                    <% } else { %>
                        <% for (Map<String, Object> b : budgetList) { %>
                            <tr>
                                <td><%= b.get("date") %></td>
                                <td><%= b.get("category") %></td>
                                <td style="font-weight: 600;">RM <%= String.format("%.2f", (Double) b.get("amount")) %></td>
                                <td><%= b.get("desc") != null ? b.get("desc") : "-" %></td>
                                 <td>
                                     <%
                                         String parentComment = (String) b.get("parentComment");
                                         String counsellorComment = (String) b.get("counsellorComment");
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
                                        <button type="button" class="edit-btn btn btn-secondary" style="padding: 4px 8px; font-size: 12px; height: auto; border-radius: 4px;" onclick="enableEdit('<%= b.get("id") %>', '<%= b.get("categoryID") %>', '<%= b.get("amount") %>', '<%= b.get("date") %>', '<%= b.get("desc") != null ? b.get("desc").toString().replace("'", "\\'") : "" %>')">Edit</button>
                                        <form method="POST" action="BudgetServlet" style="display:inline;" onsubmit="return confirm('Are you sure you want to delete this budget?');">
                                            <input type="hidden" name="action" value="delete">
                                            <input type="hidden" name="budgetID" value="<%= b.get("id") %>">
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
                            suggestionText.innerHTML = ' Select "<strong>' + data.categoryName + '</strong>" for this budget? <span style="text-decoration: underline; font-weight: bold; margin-left: 5px;">[Click to Apply]</span>';
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
        // Edit budget helpers
        function enableEdit(id, categoryID, amount, date, desc) {
            document.getElementById('formCardTitle').textContent = 'Edit Budget';
            document.getElementById('formAction').value = 'update';
            document.getElementById('editBudgetID').value = id;
            document.getElementById('category').value = categoryID;
            document.getElementById('amount').value = amount;
            document.getElementById('date').value = date;
            document.getElementById('description').value = desc;
            
            // Convert YYYY-MM-DD date to YYYY-MM for month selector
            const monthVal = date.substring(0, 7);
            document.getElementById('budgetPeriod').value = monthVal;
            
            // Change submit button text
            document.getElementById('submitBtn').textContent = 'Update Budget';
            
            // Show cancel button
            document.getElementById('cancelEditBtn').style.display = 'inline-block';
            
            // Scroll to form
            document.getElementById('formCardTitle').scrollIntoView({ behavior: 'smooth' });
        }

        function cancelEdit() {
            document.getElementById('formCardTitle').textContent = 'Record New Budget';
            document.getElementById('formAction').value = 'add';
            document.getElementById('editBudgetID').value = '';
            document.getElementById('category').value = '';
            document.getElementById('amount').value = '';
            document.getElementById('date').value = '';
            document.getElementById('description').value = '';
            document.getElementById('budgetPeriod').value = '';
            document.getElementById('submitBtn').textContent = 'Record Budget';
            document.getElementById('cancelEditBtn').style.display = 'none';
        }
    </script>

<script src="js/theme.js?v=1.0.1"></script>
</body>
</html>