<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PocketPilot</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=1.0.1">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--body-bg-gradient);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
            color: var(--text-color);
        }
        
        .back-link {
            position: absolute;
            top: 20px;
            left: 20px;
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .back-link:hover {
            transform: translateX(-5px);
            color: var(--primary-hover);
        }
        
        .login-container {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            width: 100%;
            max-width: 450px;
            padding: 40px;
        }
        
        .logo-section {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .logo-section h1 {
            color: var(--primary-color);
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .logo-section p {
            color: var(--text-muted);
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: var(--primary-color);
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid var(--input-border);
            border-radius: 8px;
            font-size: 14px;
            color: var(--input-text);
            background: var(--input-bg);
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--input-bg);
        }
        
        .login-button {
            width: 100%;
            padding: 12px;
            background: var(--header-bg-gradient);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            margin-top: 10px;
            transition: transform 0.2s, box-shadow 0.2s;
            font-family: inherit;
        }
        
        .login-button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px var(--accent-glow);
        }
        
        .links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            font-size: 13px;
        }
        
        .links a {
            color: var(--primary-hover);
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .links a:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .error-message {
            background-color: rgba(220, 38, 38, 0.1);
            color: #ef4444;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #ef4444;
        }
        
        .success-message {
            background-color: rgba(16, 185, 129, 0.1);
            color: #10b981;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #10b981;
        }
        
        /* Password container with eye toggle */
        .password-container {
            position: relative;
            display: flex;
            align-items: center;
            width: 100%;
        }
        
        .password-container input {
            padding-right: 45px !important;
        }
        
        .toggle-password {
            position: absolute;
            right: 15px;
            cursor: pointer;
            color: var(--primary-color);
            font-size: 12px;
            font-weight: 600;
            user-select: none;
            z-index: 10;
        }
        </style>
</head>
<body>
    <a href="index.jsp" class="back-link">← Back to Home</a>
    
    <div class="login-container">
        <div class="logo-section">
            <h1>PocketPilot</h1>
            <p>Manage Your Student Finance</p>
        </div>
        
        <%-- Display error/success message --%>
        <% String message = request.getParameter("message");
           String success = request.getParameter("success");
           String error = request.getParameter("error");
           String displayMessage = null;
           boolean isSuccess = false;
           
           if (success != null) {
               displayMessage = success;
               isSuccess = true;
           } else if (message != null) {
               displayMessage = message;
               isSuccess = message.contains("logged out") || message.contains("success");
           } else if (error != null) {
               displayMessage = error;
               isSuccess = false;
           }
           
           if (displayMessage != null) {
               if (isSuccess) { %>
                   <div class="success-message"><%= displayMessage %></div>
               <% } else { %>
                   <div class="error-message"><%= displayMessage %></div>
               <% }
           }
        %>
        
        <%-- CHANGED: Added dynamic context path mapping to prevent 404 routing errors --%>
        <form action="${pageContext.request.contextPath}/LoginServlet" method="POST">
            <div class="form-group">
                <label for="email">Email</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    placeholder="Enter your email address"
                    required
                >
            </div>
            
            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-container">
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="Enter your password"
                        required
                    >
                    <span class="toggle-password" onclick="togglePasswordVisibility('password', this)">Show</span>
                </div>
            </div>
            
            <button type="submit" class="login-button">Login</button>
        </form>
        
        <div class="links">
            <a href="forgotPassword.jsp">Forgot Password?</a>
            <a href="signup.jsp">Create Account</a>
        </div>
    </div>
    <script>
        function togglePasswordVisibility(fieldId, toggleElement) {
            const passwordInput = document.getElementById(fieldId);
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleElement.textContent = "Hide";
            } else {
                passwordInput.type = "password";
                toggleElement.textContent = "Show";
            }
        }
    </script>

<script src="js/theme.js?v=1.0.1"></script>
</body>
</html>