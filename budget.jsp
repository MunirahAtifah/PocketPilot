<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Budget Management - PocketPilot</title>
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
            color: white !important;
        }
        
        .container {
            max-width: 1000px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .action-bar {
            display: flex;
            gap: 10px;
            margin-bottom: 30px;
            flex-wrap: wrap;
        }
        
        .btn {
            padding: 10px 20px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .btn-secondary {
            background: #E0D5C7;
            color: #6B46C1;
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
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.1);
        }
        
        .card h3 {
            color: #6B46C1;
            margin-bottom: 15px;
            font-size: 18px;
        }
        
        .form-group {
            margin-bottom: 15px;
        }
        
        .form-group label {
            display: block;
            color: #6B46C1;
            font-weight: 600;
            margin-bottom: 5px;
            font-size: 13px;
        }
        
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 2px solid #E0D5C7;
            border-radius: 6px;
            font-size: 13px;
            font-family: inherit;
        }
        
        .form-group input:focus,
        .form-group select:focus,
        .form-group textarea:focus {
            outline: none;
            border-color: #6B46C1;
            background-color: #FFFBF0;
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
            background: #F5F1E8;
            border-bottom: 2px solid #6B46C1;
        }
        
        .table th {
            color: #6B46C1;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            font-size: 13px;
        }
        
        .table td {
            padding: 12px;
            border-bottom: 1px solid #E0D5C7;
            font-size: 13px;
        }
        
        .table tbody tr:hover {
            background: #FFFBF0;
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
            background: #8B5CF6;
            color: white;
        }
        
        .delete-btn {
            background: #c62828;
            color: white;
        }
        
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #999;
        }
        
        .empty-state p {
            margin-bottom: 15px;
        }
        
        .message {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
        }
        
        .message.success {
            background: #e8f5e9;
            color: #2e7d32;
            border-left: 4px solid #2e7d32;
        }
        
        .message.error {
            background: #ffebee;
            color: #c62828;
            border-left: 4px solid #c62828;
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
        <h1>Budget Management</h1>
        <p>Manage your monthly budgets</p>
    </div>
    
    <div class="navbar">
        <a href="studentDashboard.jsp">Dashboard</a>
        <a href="budget.jsp" style="color: #8B5CF6; border-bottom: 3px solid #8B5CF6; padding-bottom: 12px;">Budget</a>
        <a href="expense.jsp">Expense</a>
        <a href="trackingProgress.jsp">Tracking Progress</a>
        <a href="supervisionAccess.jsp">Supervision</a>
        <a href="LogoutServlet" class="logout-btn">Logout</a>
    </div>
    
    <div class="container">
        <!-- Add Budget Form -->
        <div class="card">
            <h3>Add New Budget</h3>
            
            <form method="POST" action="AddBudgetServlet">
                <div class="form-row">
                    <div class="form-group">
                        <label for="category">Category</label>
                        <select name="categoryID" id="category" required>
                            <option value="">Select a category</option>
                            <option value="1">School Supplies</option>
                            <option value="2">Transportation</option>
                            <option value="3">Food & Dining</option>
                            <option value="4">Entertainment</option>
                            <option value="5">Utilities</option>
                            <option value="6">Clothing</option>
                            <option value="7">Books & Materials</option>
                            <option value="8">Health & Fitness</option>
                            <option value="9">Personal Care</option>
                            <option value="10">Emergency Fund</option>
                            <option value="11">Savings</option>
                            <option value="12">Miscellaneous</option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="amount">Budget Amount (RM)</label>
                        <input 
                            type="number" 
                            step="0.01" 
                            name="budgetAmount" 
                            id="amount" 
                            placeholder="0.00"
                            required
                        >
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-group">
                        <label for="month">Month</label>
                        <select name="month" id="month" required>
                            <option value="">Select a month</option>
                            <option value="01">January</option>
                            <option value="02">February</option>
                            <option value="03">March</option>
                            <option value="04">April</option>
                            <option value="05">May</option>
                            <option value="06">June</option>
                            <option value="07">July</option>
                            <option value="08">August</option>
                            <option value="09">September</option>
                            <option value="10">October</option>
                            <option value="11">November</option>
                            <option value="12">December </option>
                        </select>
                    </div>
                    
                    <div class="form-group">
                        <label for="year">Year</label>
                        <input 
                            type="number" 
                            name="year" 
                            id="year" 
                            min="2020" 
                            max="2030"
                            value="2025"
                            required
                        >
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="description">Description</label>
                    <textarea 
                        name="budgetDesc" 
                        id="description" 
                        rows="3"
                        placeholder="Add notes about this budget..."
                        oninput="suggestCategory()"
                    ></textarea>
                    <div id="aiSuggestion" style="margin-top: 10px; padding: 10px; background: #E9D5FF; border-radius: 5px; display: none;">
                        <span style="color: #6B46C1; font-weight: 600;">🤖 AI Suggestion:</span>
                        <span id="suggestionText" style="color: #6B46C1;"></span>
                    </div>
                </div>
                
                <button type="submit" class="btn btn-primary">Save Budget</button>
            </form>
        </div>
        
        <!-- Budgets List -->
        <div class="card">
            <h3>📊 Your Budgets</h3>
            
            <% 
                // Placeholder for budgets - would come from database
                List<Budget> budgets = BudgetDAO.getBudgetsByStudentID(userID);
            %>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Amount (RM)</th>
                        <th>Date</th>
                        <th>Description</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="5" style="text-align: center; color: #999;">
                            No budgets yet. Create one above!
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>

    <script>
        function suggestCategory() {
            const description = document.getElementById('description').value.toLowerCase();
            const categorySelect = document.getElementById('category');
            const suggestionDiv = document.getElementById('aiSuggestion');
            const suggestionText = document.getElementById('suggestionText');
            
            if (description.length < 2) {
                suggestionDiv.style.display = 'none';
                return;
            }
            
            // Keywords for each category
            const categoryKeywords = {
                '1': ['book', 'pen', 'notebook', 'stationery', 'school', 'paper', 'pencil', 'supplies'],
                '2': ['taxi', 'bus', 'transport', 'fuel', 'car', 'bike', 'train', 'travel', 'commute'],
                '3': ['food', 'eat', 'lunch', 'dinner', 'breakfast', 'restaurant', 'cafe', 'meal', 'snack', 'drink', 'coffee'],
                '4': ['movie', 'game', 'entertainment', 'play', 'cinema', 'fun', 'hobby', 'recreation', 'ticket', 'concert'],
                '5': ['electricity', 'water', 'gas', 'internet', 'utility', 'bill', 'phone', 'mobile'],
                '6': ['cloth', 'shirt', 'pant', 'shoe', 'dress', 'clothing', 'wear', 'apparel', 'fashion'],
                '7': ['book', 'read', 'material', 'textbook', 'reference', 'novel', 'magazine'],
                '8': ['gym', 'fitness', 'health', 'exercise', 'sport', 'medicine', 'doctor', 'medical'],
                '9': ['shampoo', 'soap', 'hygiene', 'personal', 'care', 'beauty', 'cosmetic', 'grooming'],
                '10': ['emergency', 'save', 'reserve', 'backup', 'fund', 'contingency'],
                '11': ['save', 'savings', 'deposit', 'invest', 'accumulate'],
                '12': ['other', 'misc', 'miscellaneous', 'general', 'various', 'other']
            };
            
            let suggestedCategoryID = null;
            let highestMatch = 0;
            
            // Find the best matching category
            for (const [categoryID, keywords] of Object.entries(categoryKeywords)) {
                let matches = 0;
                keywords.forEach(keyword => {
                    if (description.includes(keyword)) {
                        matches++;
                    }
                });
                
                if (matches > highestMatch) {
                    highestMatch = matches;
                    suggestedCategoryID = categoryID;
                }
            }
            
            if (suggestedCategoryID && highestMatch > 0) {
                categorySelect.value = suggestedCategoryID;
                const selectedText = categorySelect.options[categorySelect.selectedIndex].text;
                suggestionText.textContent = ' Select "' + selectedText + '" for this budget?';
                suggestionDiv.style.display = 'block';
            } else {
                suggestionDiv.style.display = 'none';
            }
        }
    </script>
</body>
</html>
