<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - PocketPilot</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 2rem;
        }
        
        .back-link {
            position: absolute;
            top: 20px;
            left: 20px;
            color: white;
            text-decoration: none;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
        }
        
        .back-link:hover {
            transform: translateX(-5px);
        }
        
        .login-container {
            background: #F5F1E8;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 450px;
            padding: 40px;
        }
        
        .logo-section {
            text-align: center;
            margin-bottom: 40px;
        }
        
        .logo-section h1 {
            color: #6B46C1;
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .logo-section p {
            color: #8B5CF6;
            font-size: 14px;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: #6B46C1;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #E0D5C7;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #6B46C1;
            background-color: #FFFBF0;
        }
        
        .login-button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
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
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            font-size: 13px;
        }
        
        .links a {
            color: #8B5CF6;
            text-decoration: none;
            transition: color 0.3s;
        }
        
        .links a:hover {
            color: #6B46C1;
            text-decoration: underline;
        }
        
        .error-message {
            background-color: #ffebee;
            color: #c62828;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #c62828;
        }
        
        .success-message {
            background-color: #e8f5e9;
            color: #2e7d32;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
            border-left: 4px solid #2e7d32;
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
            color: #6B46C1;
            font-size: 12px;
            font-weight: 600;
            user-select: none;
            z-index: 10;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            color: #6B46C1;
            font-weight: 600;
            margin-bottom: 8px;
            font-size: 14px;
        }
        
        .form-group input {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #E0D5C7;
            border-radius: 8px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: #6B46C1;
            background-color: #FFFBF0;
        }
        
        .login-button {
            width: 100%;
            padding: 12px;
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
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
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .links {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
            font-size: 13px;
        }
        
        .links a {
            color: #8B5CF6;
            text-decoration: none;
            transition: color 0.3s;
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

<script src="js/theme.js"></script>
</body>
</html>