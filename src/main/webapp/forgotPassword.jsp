<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - PocketPilot</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css">
    <script src="js/theme.js"></script>
    <style>
        body {
            background: var(--bg-gradient);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            color: var(--text-color);
        }
        
        .container {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            width: 100%;
            max-width: 500px;
            padding: 40px;
        }
        
        .logo-section {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .logo-section h1 {
            color: var(--primary-color);
            font-size: 28px;
            margin-bottom: 10px;
        }
        
        .logo-section p {
            color: var(--primary-light);
            font-size: 14px;
        }
        
        .tabs {
            display: flex;
            margin-bottom: 30px;
            border-bottom: 2px solid var(--border-color);
        }
        
        .tab {
            flex: 1;
            padding: 12px;
            text-align: center;
            cursor: pointer;
            border-bottom: 3px solid transparent;
            color: var(--primary-light);
            font-weight: 600;
            transition: all 0.3s;
        }
        
        .tab.active {
            color: var(--primary-color);
            border-bottom-color: var(--primary-color);
        }
        
        .tab-content {
            display: none;
        }
        
        .tab-content.active {
            display: block;
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
            border: 2px solid var(--border-color);
            border-radius: 8px;
            font-size: 14px;
            color: var(--text-color);
            background: var(--input-bg);
            transition: border-color 0.3s;
        }
        
        .form-group input:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--input-bg);
        }
        
        .button {
            width: 100%;
            padding: 12px;
            background: var(--primary-gradient);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        .button:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .message {
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 20px;
            font-size: 13px;
        }
        
        .message.success {
            background-color: #e8f5e9;
            color: #2e7d32;
            border-left: 4px solid #2e7d32;
        }
        
        .message.error {
            background-color: #ffebee;
            color: #c62828;
            border-left: 4px solid #c62828;
        }
        
        .message.info {
            background-color: #e3f2fd;
            color: #1565c0;
            border-left: 4px solid #1565c0;
        }
        
        .info-text {
            color: var(--primary-light);
            font-size: 13px;
            margin-bottom: 20px;
            line-height: 1.5;
        }
        
        .back-link {
            text-align: center;
            margin-top: 20px;
        }
        
        .back-link a {
            color: var(--primary-light);
            text-decoration: none;
            font-size: 13px;
            transition: color 0.3s;
        }
        
        .back-link a:hover {
            color: var(--primary-color);
            text-decoration: underline;
        }
        
        .otp-group {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 10px;
            margin-bottom: 20px;
        }
        
        .otp-input {
            text-align: center;
            font-size: 24px;
            font-weight: bold;
            padding: 12px !important;
        }
 
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
            font-size: 14px;
            user-select: none;
            z-index: 10;
        }
    </style>
</head>
<body>
    <button class="theme-toggle" style="position: absolute; top: 20px; right: 20px; z-index: 1000;" onclick="toggleTheme()">🌓 Theme</button>
    <div class="container">
        <div class="logo-section">
            <h1>Reset Password</h1>
            <p>Regain access to your account</p>
        </div>
        
        <div class="tabs">
            <div class="tab active" onclick="switchTab(event, 'reset-tab')">
                Reset Password
            </div>
        </div>
        
        <!-- Reset Password Tab -->
        <div id="reset-tab" class="tab-content active">
            <p class="info-text">
                Enter your email address and new password to update your password.
            </p>
            
            <form method="POST" action="ForgotPasswordServlet">
                <input type="hidden" name="step" value="reset-password">
                
                <div class="form-group">
                    <label for="email-reset">Email Address</label>
                    <input 
                        type="email" 
                        id="email-reset" 
                        name="email" 
                        placeholder="your@email.com"
                        required
                    >
                </div>
                
                <div class="form-group">
                    <label for="new-password">New Password</label>
                    <div class="password-container">
                        <input 
                            type="password" 
                            id="new-password" 
                            name="newPassword" 
                            placeholder="Enter new password"
                            minlength="6"
                            required
                        >
                        <span class="toggle-password" onclick="togglePasswordVisibility('new-password', this)" style="font-size: 12px; font-weight: 600;">Show</span>
                    </div>
                </div>
                
                <div class="form-group">
                    <label for="confirm-password">Confirm Password</label>
                    <div class="password-container">
                        <input 
                            type="password" 
                            id="confirm-password" 
                            name="confirmPassword" 
                            placeholder="Confirm new password"
                            minlength="6"
                            required
                        >
                        <span class="toggle-password" onclick="togglePasswordVisibility('confirm-password', this)" style="font-size: 12px; font-weight: 600;">Show</span>
                    </div>
                </div>
                
                <button type="submit" class="button">Reset Password</button>
            </form>
            
            <% 
                String resetStatus = request.getParameter("reset_status");
                if ("success".equals(resetStatus)) {
            %>
                <div class="message success" style="margin-top: 20px;">
                    Password reset successful! You can now login with your new password.
                </div>
            <% 
                } else if ("invalid_email".equals(resetStatus)) {
            %>
                <div class="message error" style="margin-top: 20px;">
                    Email address not found. Please try again.
                </div>
            <% 
                } else if ("mismatch".equals(resetStatus)) {
            %>
                <div class="message error" style="margin-top: 20px;">
                    Passwords do not match. Please try again.
                </div>
            <% 
                } else if ("error".equals(resetStatus)) {
            %>
                <div class="message error" style="margin-top: 20px;">
                    An error occurred. Please try again.
                </div>
            <% } %>
        </div>
        
        <div class="back-link">
            <a href="login.jsp">← Back to Login</a>
        </div>
    </div>
    
    <script>
        function switchTab(event, tabName) {
            // Hide all tabs
            const tabs = document.querySelectorAll('.tab-content');
            tabs.forEach(tab => tab.classList.remove('active'));
            
            // Remove active class from all tab buttons
            const tabButtons = document.querySelectorAll('.tab');
            tabButtons.forEach(btn => btn.classList.remove('active'));
            
            // Show selected tab
            document.getElementById(tabName).classList.add('active');
            
            // Add active class to clicked button
            event.target.classList.add('active');
        }

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
</body>
</html>
