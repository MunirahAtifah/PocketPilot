<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PocketPilot - Smart Budget Management for Students</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
        }
        
        /* Navbar */
        nav {
            background: rgba(255, 255, 255, 0.95);
            padding: 1rem 2rem;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #6B46C1;
            text-decoration: none;
        }
        
        .nav-buttons {
            display: flex;
            gap: 1rem;
        }
        
        .nav-buttons a {
            padding: 10px 20px;
            border-radius: 6px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .login-btn {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
        }
        
        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 20px rgba(107, 70, 193, 0.4);
        }
        
        .signup-btn {
            background: white;
            color: #6B46C1;
            border: 2px solid #6B46C1;
        }
        
        .signup-btn:hover {
            background: #F0E6FF;
        }
        
        /* Hero Section */
        .hero {
            min-height: 80vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            text-align: center;
            padding: 2rem;
        }
        
        .hero-content {
            max-width: 800px;
            animation: fadeInUp 1s ease;
        }
        
        .hero h1 {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            font-weight: 700;
        }
        
        .hero p {
            font-size: 1.3rem;
            margin-bottom: 2rem;
            opacity: 0.95;
        }
        
        .cta-button {
            display: inline-block;
            padding: 15px 40px;
            background: white;
            color: #6B46C1;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            transition: all 0.3s ease;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
        }
        
        .cta-button:hover {
            transform: translateY(-3px);
            box-shadow: 0 15px 40px rgba(0, 0, 0, 0.3);
        }
        
        /* Features Section */
        .features {
            background: white;
            padding: 4rem 2rem;
            margin-top: 2rem;
        }
        
        .features h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 3rem;
            font-size: 2.5rem;
        }
        
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .feature-card {
            background: #F5F1E8;
            padding: 2rem;
            border-radius: 12px;
            text-align: center;
            transition: all 0.3s ease;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.08);
        }
        
        .feature-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(107, 70, 193, 0.2);
        }
        
        .feature-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
        }
        
        .feature-card h3 {
            color: #6B46C1;
            margin-bottom: 1rem;
        }
        
        .feature-card p {
            color: #555;
            line-height: 1.6;
        }
        
        /* Benefits Section */
        .benefits {
            background: #F0E6FF;
            padding: 4rem 2rem;
        }
        
        .benefits h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 3rem;
            font-size: 2.5rem;
        }
        
        .benefits-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 2rem;
            max-width: 1200px;
            margin: 0 auto;
        }
        
        .benefit-item {
            background: white;
            padding: 1.5rem;
            border-radius: 10px;
            border-left: 5px solid #6B46C1;
        }
        
        .benefit-item h4 {
            color: #6B46C1;
            margin-bottom: 0.5rem;
        }
        
        .benefit-item p {
            color: #555;
        }
        
        /* CTA Section */
        .cta-section {
            background: linear-gradient(135deg, #6B46C1 0%, #8B5CF6 100%);
            color: white;
            text-align: center;
            padding: 4rem 2rem;
        }
        
        .cta-section h2 {
            font-size: 2.5rem;
            margin-bottom: 1.5rem;
            color: white;
        }
        
        .cta-section p {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.95;
        }
        
        .cta-button-secondary {
            display: inline-block;
            padding: 15px 40px;
            background: white;
            color: #6B46C1;
            text-decoration: none;
            border-radius: 50px;
            font-weight: 700;
            font-size: 1.1rem;
            transition: all 0.3s ease;
        }
        
        .cta-button-secondary:hover {
            transform: translateY(-3px);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.3);
        }
        
        /* Footer */
        footer {
            background: #2c3e50;
            color: white;
            text-align: center;
            padding: 2rem;
            margin-top: 2rem;
        }
        
        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav>
        <a href="index.jsp" class="logo">🎯 PocketPilot</a>
        <div class="nav-buttons">
            <a href="login.jsp" class="login-btn">Login</a>
            <a href="signup.jsp" class="signup-btn">Sign Up</a>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1>Take Control of Your Budget</h1>
            <p>Smart expense tracking and budget management for students and parents</p>
            <a href="login.jsp" class="cta-button">Get Started</a>
        </div>
    </section>

    <!-- Features Section -->
    <section class="features">
        <h2>Why Choose PocketPilot?</h2>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon">💰</div>
                <h3>Track Expenses</h3>
                <p>Easily monitor all your spending with detailed categorization and real-time updates</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📊</div>
                <h3>Budget Planning</h3>
                <p>Create and manage budgets to stay within your spending limits</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">👨‍👩‍👧</div>
                <h3>Family Supervision</h3>
                <p>Parents can monitor their children's spending with secure access codes</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📈</div>
                <h3>Progress Reports</h3>
                <p>Generate detailed reports to analyze spending patterns and trends</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">🔒</div>
                <h3>Secure & Private</h3>
                <p>Your financial data is encrypted and protected with enterprise-level security</p>
            </div>
            <div class="feature-card">
                <div class="feature-icon">📱</div>
                <h3>Easy to Use</h3>
                <p>Intuitive interface designed for students and families</p>
            </div>
        </div>
    </section>

    <!-- Benefits Section -->
    <section class="benefits">
        <h2>Key Benefits</h2>
        <div class="benefits-list">
            <div class="benefit-item">
                <h4>✓ Real-time Tracking</h4>
                <p>Know exactly where your money goes with instant expense updates</p>
            </div>
            <div class="benefit-item">
                <h4>✓ Smart Categories</h4>
                <p>Pre-defined categories for common expenses to organize quickly</p>
            </div>
            <div class="benefit-item">
                <h4>✓ Parent Control</h4>
                <p>Parents can approve transactions and set spending limits</p>
            </div>
            <div class="benefit-item">
                <h4>✓ Financial Learning</h4>
                <p>Learn money management skills through practical tracking</p>
            </div>
            <div class="benefit-item">
                <h4>✓ PDF Reports</h4>
                <p>Generate and download professional expense reports</p>
            </div>
            <div class="benefit-item">
                <h4>✓ 24/7 Access</h4>
                <p>Access your budget anytime, anywhere from any device</p>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section">
        <h2>Ready to Take Control?</h2>
        <p>Start managing your finances smarter today</p>
        <a href="login.jsp" class="cta-button-secondary">Login Now</a>
    </section>

    <!-- Footer -->
    <footer>
        <p>&copy; 2026 PocketPilot - Smart Budget Management. All rights reserved.</p>
    </footer>
</body>
</html>
