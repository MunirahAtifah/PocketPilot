<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    String message = request.getParameter("message");
    if (message == null || message.trim().isEmpty()) {
        message = "An unexpected error occurred. Please try again.";
    }
    String userRole = (String) session.getAttribute("role");
    String homeUrl = "index.jsp";
    if ("Student".equals(userRole)) {
        homeUrl = "studentDashboard.jsp";
    } else if ("Parent".equals(userRole)) {
        homeUrl = "parentDashboard.jsp";
    } else if ("Student_Counsellor".equals(userRole)) {
        homeUrl = "StudentCounsellorDashboard";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error - PocketPilot</title>
    <!-- Google Fonts: Outfit -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        :root {
            --primary: #6B46C1;
            --primary-light: #8B5CF6;
            --dark: #1A0B2E;
            --bg-gradient: radial-gradient(circle at 0% 0%, #F8F5FF 0%, #FFFDF9 70%, #F5F1E8 100%);
            --card-border: 1px solid rgba(224, 213, 199, 0.45);
        }
        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-gradient);
            background-attachment: fixed;
            color: var(--dark);
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }
        .error-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(20px);
            border: var(--card-border);
            border-radius: 24px;
            padding: 40px 30px;
            width: 100%;
            max-width: 480px;
            box-shadow: 0 20px 50px rgba(107, 70, 193, 0.12);
            text-align: center;
            animation: float 6s ease-in-out infinite;
        }
        .error-icon {
            font-size: 64px;
            margin-bottom: 20px;
            display: inline-block;
        }
        h1 {
            font-size: 28px;
            font-weight: 800;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 15px;
        }
        p {
            font-size: 16px;
            color: #5D5470;
            margin-bottom: 30px;
            line-height: 1.6;
        }
        .btn {
            display: inline-block;
            text-decoration: none;
            background: linear-gradient(135deg, var(--primary) 0%, var(--primary-light) 100%);
            color: white;
            padding: 12px 30px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 15px;
            box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
            transition: all 0.3s ease;
        }
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(107, 70, 193, 0.4);
        }
        .btn-secondary {
            background: white;
            color: var(--primary);
            border: 2px solid rgba(107, 70, 193, 0.15);
            margin-left: 10px;
            box-shadow: none;
        }
        .btn-secondary:hover {
            border-color: var(--primary);
            background: rgba(107, 70, 193, 0.02);
            box-shadow: none;
        }
    </style>
</head>
<body>
    <div class="error-card">
        <h1>Something went wrong</h1>
        <p><%= message %></p>
        <div style="display: flex; justify-content: center; gap: 10px;">
            <a href="<%= homeUrl %>" class="btn">Go Home</a>
            <a href="javascript:history.back()" class="btn btn-secondary">Go Back</a>
        </div>
    </div>
</body>
</html>
