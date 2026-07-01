<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up - PocketPilot</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=1.0.3">
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
            padding: 20px;
            color: var(--text-color);
        }
        
        .signup-container {
            background: var(--card-bg);
            border: 1px solid var(--border-color);
            border-radius: 15px;
            box-shadow: var(--card-shadow);
            max-width: 500px;
            width: 100%;
            padding: 40px;
        }
        
        .signup-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .signup-header h1 {
            color: var(--primary-color);
            font-size: 32px;
            margin-bottom: 10px;
        }
        
        .signup-header p {
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
        
        .form-group input,
        .form-group select {
            width: 100%;
            padding: 12px;
            border: 2px solid var(--input-border);
            border-radius: 8px;
            font-size: 14px;
            font-family: inherit;
            color: var(--input-text);
            background: var(--input-bg);
            transition: border-color 0.3s;
        }
        
        .form-group input:focus,
        .form-group select:focus {
            outline: none;
            border-color: var(--primary-color);
            background-color: var(--input-bg);
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
        
        .btn {
            width: 100%;
            padding: 12px;
            background: var(--header-bg-gradient);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
            margin-top: 10px;
            font-family: inherit;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px var(--accent-glow);
        }
        
        .login-link {
            text-align: center;
            margin-top: 20px;
            font-size: 14px;
            color: var(--text-muted);
        }
        
        .login-link a {
            color: var(--primary-color);
            text-decoration: none;
            font-weight: 600;
        }
        
        .login-link a:hover {
            text-decoration: underline;
            color: var(--primary-hover);
        }
        
        .error-message {
            color: #ef4444;
            font-size: 13px;
            margin-bottom: 15px;
            padding: 12px;
            background: rgba(220, 38, 38, 0.1);
            border-radius: 8px;
            border-left: 4px solid #ef4444;
            display: none;
        }
        
        .success-message {
            color: #10b981;
            font-size: 13px;
            margin-bottom: 15px;
            padding: 12px;
            background: rgba(16, 185, 129, 0.1);
            border-radius: 8px;
            border-left: 4px solid #10b981;
            display: none;
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

        .dynamic-fields {
            margin-top: 20px;
            padding-top: 20px;
            border-top: 1px solid var(--border-color);
        }

        .field-hidden {
            display: none;
        }

        .role-description {
            background: var(--bg-alt);
            padding: 10px;
            border-radius: 8px;
            font-size: 12px;
            color: var(--text-muted);
            border: 1px solid var(--border-color);
            margin-top: 5px;
        }
    </style>
</head>
<body>
    <%
        // Check if user is already logged in
        if (session.getAttribute("userID") != null) {
            response.sendRedirect("studentDashboard.jsp");
            return;
        }
    %>
    
    <div class="signup-container">
        <div class="signup-header">
            <h1>Create Account</h1>
            <p>Join PocketPilot to manage your finances</p>
        </div>
        
        <div id="errorMessage" class="error-message"></div>
        <div id="successMessage" class="success-message"></div>
        
        <form method="POST" action="SignupServlet" id="signupForm">
            <!-- Role Selection -->
            <div class="form-group">
                <label for="role">Select Your Role</label>
                <select name="role" id="role" required>
                    <option value="">-- Choose a role --</option>
                    <option value="Student">Student</option>
                    <option value="Parent">Parent</option>
                    <option value="Student_Counsellor">Student Counsellor</option>
                </select>
            </div>
            
            <!-- Full Name (All Roles) -->
            <div class="form-group">
                <label for="fullName">Full Name</label>
                <input 
                    type="text" 
                    id="fullName" 
                    name="fullName" 
                    placeholder="Your full name"
                    required
                >
            </div>
            
            <!-- Basic Information (All Roles) -->
            <div class="form-group">
                <label for="username">Username</label>
                <input 
                    type="text" 
                    id="username" 
                    name="username" 
                    placeholder="Choose a username"
                    required
                >
            </div>
            
            <div class="form-group">
                <label for="email">Email Address</label>
                <input 
                    type="email" 
                    id="email" 
                    name="email" 
                    placeholder="your@email.com"
                    required
                >
            </div>
            
            <div class="form-group">
                <label for="phoneNumber">Phone Number</label>
                <input 
                    type="tel" 
                    id="phoneNumber" 
                    name="phoneNumber" 
                    placeholder="01234567890"
                    required
                >
            </div>
            
            <!-- Password -->
            <div class="form-group">
                <label for="password">Password</label>
                <div class="password-container">
                    <input 
                        type="password" 
                        id="password" 
                        name="password" 
                        placeholder="Minimum 6 characters"
                        required
                    >
                    <span class="toggle-password" onclick="togglePasswordVisibility('password', this)">Show</span>
                </div>
                <div id="passwordWarning" style="display: none; color: #c62828; font-size: 13px; margin-top: 5px; font-weight: 500; align-items: center; gap: 4px; transition: all 0.3s ease;">
                    Password must be at least 6 characters
                </div>
            </div>
            
            <div class="form-group">
                <label for="confirmPassword">Confirm Password</label>
                <div class="password-container">
                    <input 
                        type="password" 
                        id="confirmPassword" 
                        name="confirmPassword" 
                        placeholder="Re-enter your password"
                        required
                    >
                    <span class="toggle-password" onclick="togglePasswordVisibility('confirmPassword', this)">Show</span>
                </div>
            </div>
            
            <button type="submit" class="btn">Create Account</button>
        </form>
        
        <div class="login-link">
            Already have an account? <a href="login.jsp">Login here</a>
        </div>
    </div>

    <script>
        // Real-time password validation
        const passwordInput = document.getElementById('password');
        const passwordWarning = document.getElementById('passwordWarning');

        passwordInput.addEventListener('blur', function() {
            validatePasswordLength();
        });

        passwordInput.addEventListener('input', function() {
            if (passwordInput.value.length >= 6) {
                passwordWarning.style.display = 'none';
                passwordInput.style.borderColor = 'var(--border-color)';
            }
        });

        function validatePasswordLength() {
            if (passwordInput.value.length > 0 && passwordInput.value.length < 6) {
                passwordWarning.style.display = 'flex';
                passwordInput.style.borderColor = '#c62828';
            } else {
                passwordWarning.style.display = 'none';
                passwordInput.style.borderColor = 'var(--border-color)';
            }
        }

        const urlParams = new URLSearchParams(window.location.search);
        const errorMessage = urlParams.get('error');
        const successMessage = urlParams.get('success');

        if (errorMessage) {
            document.getElementById('errorMessage').textContent = decodeURIComponent(errorMessage);
            document.getElementById('errorMessage').style.display = 'block';
        }
        
        if (successMessage) {
            document.getElementById('successMessage').textContent = decodeURIComponent(successMessage);
            document.getElementById('successMessage').style.display = 'block';
            setTimeout(() => {
                window.location.href = 'login.jsp?success=' + encodeURIComponent(successMessage);
            }, 2000);
        }

        // Form validation
        document.getElementById('signupForm').addEventListener('submit', function(e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            const role = document.getElementById('role').value;
            const fullName = document.getElementById('fullName').value;
            const errorDiv = document.getElementById('errorMessage');
            
            errorDiv.style.display = 'none';
            
            if (!role) {
                errorDiv.textContent = 'Please select a role';
                errorDiv.style.display = 'block';
                e.preventDefault();
                return;
            }

            if (!fullName.trim()) {
                errorDiv.textContent = 'Full name is required';
                errorDiv.style.display = 'block';
                e.preventDefault();
                return;
            }
            
            if (password !== confirmPassword) {
                errorDiv.textContent = 'Passwords do not match';
                errorDiv.style.display = 'block';
                e.preventDefault();
                return;
            }
            
            if (password.length < 6) {
                errorDiv.textContent = 'Password must be at least 6 characters';
                errorDiv.style.display = 'block';
                e.preventDefault();
                return;
            }
        });

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

<script src="js/theme.js?v=1.0.3"></script>
</body>
</html>

