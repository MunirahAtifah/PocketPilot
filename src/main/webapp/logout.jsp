<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Logout - PocketPilot</title>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        
        .logout-container {
            background: #F5F1E8;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0, 0, 0, 0.2);
            width: 100%;
            max-width: 450px;
            padding: 40px;
            text-align: center;
        }
        
        .logout-icon {
            font-size: 50px;
            margin-bottom: 20px;
        }
        
        .logout-container h2 {
            color: #6B46C1;
            margin-bottom: 15px;
        }
        
        .logout-container p {
            color: #666;
            margin-bottom: 30px;
            font-size: 14px;
        }
        
        .button-group {
            display: flex;
            gap: 10px;
            justify-content: center;
        }
        
        .btn {
            padding: 12px 30px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
            font-family: inherit;
        }
        
        .btn-login {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
        }
        
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .btn-home {
            background: #E0D5C7;
            color: #6B46C1;
        }
        
        .btn-home:hover {
            background: #D4C4B0;
        }
    </style>
</head>
<body>
    <div class="logout-container">
        <div class="logout-icon">👋</div>
        <h2>You've been logged out</h2>
        <p>Thank you for using PocketPilot. Your session has been safely closed.</p>
        
        <div class="button-group">
            <a href="login.jsp"><button class="btn btn-login">Login Again</button></a>
            <a href="index.jsp"><button class="btn btn-home">Home</button></a>
        </div>
    </div>
    
    <%
        // Invalidate session to ensure logout
        session.invalidate();
    %>
</body>
</html>
