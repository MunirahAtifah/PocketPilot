<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>PocketPilot - Smart Student Budgeting & AI Insights</title>
    
    <!-- Google Fonts: Outfit -->
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="css/style.css?v=1.0.3">
    
    <style>
        /* CSS Reset & Variables */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        :root {
            --primary: var(--primary-color);
            --primary-light: var(--primary-hover);
            --accent: var(--accent-light);
            --dark: var(--text-primary);
            --bg-gradient: var(--bg-primary);
            --card-border: 1px solid var(--border-color);
            --shadow: var(--shadow-sm);
            --transition: all 0.4s cubic-bezier(0.16, 1, 0.3, 1);
        }

        body {
            font-family: 'Outfit', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-gradient);
            color: var(--text-primary);
            line-height: 1.6;
            overflow-x: hidden;
        }

        /* Glassmorphic Navbar */
        nav {
            position: sticky;
            top: 0;
            z-index: 1000;
            background: var(--glass-bg);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border-bottom: var(--card-border);
            padding: 18px 8%;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 30px rgba(0, 0, 0, 0.02);
        }

        .logo-container {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
        }

        .logo-icon {
            font-size: 28px;
            animation: pulse 2s infinite;
        }

        .logo-text {
            font-size: 24px;
            font-weight: 800;
            background: var(--primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .nav-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .nav-link {
            text-decoration: none;
            color: var(--primary);
            font-weight: 600;
            font-size: 15px;
            padding: 8px 16px;
            transition: var(--transition);
        }

        .nav-link:hover {
            color: var(--primary-light);
        }

        .btn-nav-signup {
            text-decoration: none;
            background: var(--primary);
            color: white;
            padding: 10px 24px;
            border-radius: 30px;
            font-weight: 600;
            font-size: 15px;
            box-shadow: 0 4px 15px rgba(107, 70, 193, 0.2);
            transition: var(--transition);
        }

        .btn-nav-signup:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(107, 70, 193, 0.35);
        }

        /* Hero Section */
        .hero {
            display: grid;
            grid-template-columns: 1.1fr 0.9fr;
            align-items: center;
            padding: 80px 8%;
            gap: 60px;
            position: relative;
        }

        .hero::before {
            content: '';
            position: absolute;
            width: 300px;
            height: 300px;
            background: radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, transparent 70%);
            top: 10%;
            left: -100px;
            z-index: -1;
        }

        .hero-content h1 {
            font-size: 4rem;
            line-height: 1.15;
            font-weight: 800;
            color: var(--dark);
            margin-bottom: 20px;
        }

        .hero-content h1 span {
            background: var(--primary);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }

        .hero-content p {
            font-size: 1.25rem;
            color: var(--text-secondary);
            margin-bottom: 35px;
            max-width: 550px;
            font-weight: 400;
        }

        .hero-buttons {
            display: flex;
            gap: 20px;
            align-items: center;
        }

        .btn-primary {
            text-decoration: none;
            background: var(--primary);
            color: white;
            padding: 16px 38px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            box-shadow: 0 8px 25px rgba(107, 70, 193, 0.25);
            transition: var(--transition);
        }

        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 12px 30px rgba(107, 70, 193, 0.4);
        }

        .btn-secondary {
            text-decoration: none;
            background: var(--card-bg);
            color: var(--primary);
            padding: 16px 38px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 16px;
            border: 2px solid rgba(107, 70, 193, 0.15);
            transition: var(--transition);
        }

        .btn-secondary:hover {
            border-color: var(--primary);
            background: rgba(107, 70, 193, 0.02);
            transform: translateY(-2px);
        }

        /* Hero Right: 3D-like Mockup Dashboard */
        .hero-visual {
            position: relative;
            display: flex;
            justify-content: center;
            align-items: center;
            perspective: 1000px;
        }

        .mock-dashboard {
            background: var(--glass-bg);
            backdrop-filter: blur(20px);
            border: var(--card-border);
            border-radius: 24px;
            padding: 25px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 20px 50px rgba(107, 70, 193, 0.12);
            transform: rotateY(-8deg) rotateX(8deg);
            transition: transform 0.5s ease;
            position: relative;
            animation: float 6s ease-in-out infinite;
        }

        .mock-dashboard:hover {
            transform: rotateY(0deg) rotateX(0deg) scale(1.02);
        }

        .mock-card {
            background: var(--primary-color);
            color: white;
            padding: 20px;
            border-radius: 16px;
            margin-bottom: 20px;
            box-shadow: 0 10px 20px rgba(76, 29, 149, 0.3);
            position: relative;
            overflow: hidden;
        }

        .mock-card::before {
            content: '';
            position: absolute;
            width: 150px;
            height: 150px;
            background: radial-gradient(circle, rgba(255,255,255,0.1) 0%, transparent 80%);
            right: -50px;
            bottom: -50px;
        }

        .mock-card .card-chip {
            width: 35px;
            height: 25px;
            background: #F5C045;
            border-radius: 4px;
            margin-bottom: 20px;
        }

        .mock-card .card-number {
            font-size: 15px;
            letter-spacing: 2px;
            margin-bottom: 15px;
            font-weight: 300;
        }

        .mock-card .card-balance-row {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
        }

        .mock-card .card-label {
            font-size: 11px;
            text-transform: uppercase;
            opacity: 0.8;
            letter-spacing: 0.5px;
        }

        .mock-card .card-balance {
            font-size: 26px;
            font-weight: 700;
        }

        .mock-widget {
            background: var(--card-bg);
            border-radius: 14px;
            padding: 15px;
            border: var(--card-border);
            margin-bottom: 15px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }

        .mock-widget h4 {
            font-size: 13px;
            text-transform: uppercase;
            color: var(--text-secondary);
            margin-bottom: 8px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }

        .progress-bar-container {
            width: 100%;
            height: 8px;
            background: var(--bg-alt);
            border-radius: 10px;
            margin-bottom: 10px;
            overflow: hidden;
        }

        .progress-bar {
            height: 100%;
            background: var(--primary);
            border-radius: 10px;
            transition: width 1s ease-out;
        }

        .bar-stats {
            display: flex;
            justify-content: space-between;
            font-size: 11px;
            font-weight: 600;
            color: var(--text-secondary);
        }

        .mock-ai-bubble {
            background: var(--bg-alt);
            border-left: 4px solid var(--primary-light);
            border-radius: 10px;
            padding: 12px;
            font-size: 12px;
            color: var(--text-primary);
            display: flex;
            gap: 10px;
            align-items: flex-start;
            font-weight: 500;
            box-shadow: 0 4px 15px rgba(139, 92, 246, 0.05);
        }

        /* Stats Strip */
        .stats-strip {
            display: flex;
            justify-content: space-around;
            background: var(--card-bg);
            padding: 30px 4%;
            border-top: var(--card-border);
            border-bottom: var(--card-border);
            margin: 40px 0 60px 0;
            flex-wrap: wrap;
            gap: 20px;
        }

        .stat-item {
            text-align: center;
        }

        .stat-item .value {
            font-size: 2.25rem;
            font-weight: 800;
            color: var(--primary);
            margin-bottom: 2px;
        }

        .stat-item .label {
            font-size: 13px;
            font-weight: 600;
            color: var(--text-secondary);
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        /* Interactive Simulator Section */
        .simulator-section {
            background: var(--card-bg);
            border-radius: 30px;
            max-width: 1050px;
            margin: 0 auto 80px auto;
            border: var(--card-border);
            padding: 50px 40px;
            box-shadow: 0 15px 40px rgba(107, 70, 193, 0.04);
            display: grid;
            grid-template-columns: 1fr 1.1fr;
            gap: 40px;
            align-items: center;
        }

        .simulator-content h2 {
            font-size: 2.2rem;
            font-weight: 800;
            margin-bottom: 15px;
            color: var(--dark);
        }

        .simulator-content p {
            color: var(--text-secondary);
            font-size: 16px;
            margin-bottom: 30px;
        }

        .simulator-card {
            background: var(--bg-alt);
            border-radius: 20px;
            border: var(--card-border);
            padding: 30px;
        }

        .slider-group {
            margin-bottom: 25px;
        }

        .slider-header {
            display: flex;
            justify-content: space-between;
            font-weight: 700;
            margin-bottom: 10px;
            color: var(--primary);
        }

        .range-slider {
            width: 100%;
            -webkit-appearance: none;
            height: 8px;
            border-radius: 5px;
            background: var(--border-color);
            outline: none;
            cursor: pointer;
        }

        .range-slider::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background: var(--primary);
            cursor: pointer;
            box-shadow: 0 0 10px rgba(107,70,193,0.3);
            transition: transform 0.1s;
        }

        .range-slider::-webkit-slider-thumb:hover {
            transform: scale(1.2);
        }

        .simulation-output {
            background: var(--card-bg);
            border-radius: 12px;
            padding: 20px;
            border-left: 5px solid #FF9F43;
            box-shadow: 0 4px 15px rgba(0,0,0,0.02);
        }

        .sim-ai-header {
            display: flex;
            align-items: center;
            gap: 8px;
            color: #FF9F43;
            font-weight: 700;
            font-size: 14px;
            margin-bottom: 6px;
            text-transform: uppercase;
        }

        .sim-ai-text {
            color: var(--text-primary);
            font-size: 14px;
            font-style: italic;
        }

        /* Features Section */
        .features {
            max-width: 1200px;
            margin: 0 auto 100px auto;
            padding: 0 20px;
        }

        .features-header {
            text-align: center;
            margin-bottom: 60px;
        }

        .features-header h2 {
            font-size: 2.5rem;
            font-weight: 800;
            color: var(--dark);
        }

        .features-header p {
            color: var(--text-secondary);
            font-size: 17px;
            max-width: 600px;
            margin: 10px auto 0 auto;
        }

        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
            gap: 30px;
        }

        .feature-card {
            background: var(--card-bg);
            border-radius: 20px;
            padding: 35px 30px;
            border: var(--card-border);
            box-shadow: var(--shadow);
            transition: var(--transition);
            position: relative;
            overflow: hidden;
        }

        .feature-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 15px 35px rgba(107, 70, 193, 0.15);
            border-color: rgba(139, 92, 246, 0.3);
        }

        .feature-icon-wrapper {
            font-size: 26px;
            font-weight: 800;
            margin-bottom: 20px;
            color: var(--primary);
            display: inline-block;
        }

        .feature-card h3 {
            font-size: 20px;
            font-weight: 700;
            color: var(--dark);
            margin-bottom: 12px;
        }

        .feature-card p {
            color: var(--text-secondary);
            font-size: 14px;
            line-height: 1.6;
        }

        /* Footer */
        footer {
            background: #100a1c;
            color: #A09BAB;
            padding: 50px 8%;
            text-align: center;
            border-top-left-radius: 30px;
            border-top-right-radius: 30px;
        }

        footer .logo-text {
            background: var(--primary-hover);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-size: 22px;
            font-weight: 800;
            margin-bottom: 10px;
            display: inline-block;
        }

        footer p {
            font-size: 13px;
            margin-top: 15px;
            opacity: 0.8;
        }

        /* Keyframes */
        @keyframes float {
            0% { transform: rotateY(-8deg) rotateX(8deg) translateY(0px); }
            50% { transform: rotateY(-4deg) rotateX(4deg) translateY(-12px); }
            100% { transform: rotateY(-8deg) rotateX(8deg) translateY(0px); }
        }

        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.1); }
            100% { transform: scale(1); }
        }

        /* Responsive Layouts */
        @media (max-width: 968px) {
            .hero {
                grid-template-columns: 1fr;
                text-align: center;
                padding: 50px 4%;
                gap: 40px;
            }
            .hero-content h1 {
                font-size: 2.8rem;
            }
            .hero-content p {
                margin: 0 auto 30px auto;
            }
            .hero-buttons {
                justify-content: center;
            }
            .hero-visual {
                order: -1;
            }
            .simulator-section {
                grid-template-columns: 1fr;
                padding: 35px 25px;
            }
        }
    </style>
</head>
<body>

    <!-- Transparent Navigation -->
    <nav>
        <a href="index.jsp" class="logo-container">
            <span class="logo-text">PocketPilot</span>
        </a>
        <div class="nav-actions">
            <a href="login.jsp" class="nav-link">Login</a>
            <a href="signup.jsp" class="btn-nav-signup">Sign Up</a>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="hero">
        <div class="hero-content">
            <h1>Dynamic Budgeting with <span>AI Insights</span></h1>
            <p>PocketPilot helps students manage daily expenses, set target budgets, and get customized AI alerts to maximize monthly savings. Parents and counsellors can track progress instantly.</p>
            <div class="hero-buttons">
                <a href="login.jsp" class="btn-primary">Get Started</a>
                <a href="#simulator" class="btn-secondary">Try Budget Simulator</a>
            </div>
        </div>
        
        <div class="hero-visual">
            <div class="mock-dashboard">
                <!-- Mock Credit Card -->
                <div class="mock-card">
                    <div class="card-chip"></div>
                    <div class="card-number">•••• •••• •••• 2026</div>
                    <div class="card-balance-row">
                        <div>
                            <div class="card-label">Monthly Limit</div>
                            <div class="card-balance">RM 600.00</div>
                        </div>
                        <div style="text-align: right;">
                            <div class="card-label">Expenses</div>
                            <div style="font-size: 16px; font-weight: 600;">RM 390.00</div>
                        </div>
                    </div>
                </div>
                
                <!-- Mock Progress Bar Widget -->
                <div class="mock-widget">
                    <h4>Budget Utilization</h4>
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: 65%;"></div>
                    </div>
                    <div class="bar-stats">
                        <span>Used: 65%</span>
                        <span>Remaining: RM 210.00</span>
                    </div>
                </div>

                <!-- Mock AI Suggestion Widget -->
                <div class="mock-ai-bubble">
                    <span style="font-weight: bold; font-size: 16px; color: var(--primary);">AI</span>
                    <div>
                        <strong style="display: block; font-size: 13px; margin-bottom: 2px;">AI Assistant</strong>
                        "You've saved RM 45.00 on coffee this week. You are on track for a surplus!"
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Interactive Simulator Section -->
    <section class="simulator-section" id="simulator">
        <div class="simulator-content">
            <h2>See the AI difference in action</h2>
            <p>Drag the slider to test how setting smart monthly budgets translates to direct monthly savings with PocketPilot's proactive category suggestions and tracking features.</p>
            <div style="display: flex; gap: 15px; align-items: center; margin-top: 15px;">
                <div>
                    <h4 style="font-weight: 700; color: var(--dark);">Estimate Your Surplus</h4>
                    <p style="margin-bottom: 0; font-size: 14px; color: var(--text-secondary);">See how even minor cuts compound into healthy savings.</p>
                </div>
            </div>
        </div>
        
        <div class="simulator-card">
            <div class="slider-group">
                <div class="slider-header">
                    <span>Monthly Pocket Money / Budget</span>
                    <span id="sliderValDisplay">RM 600</span>
                </div>
                <input type="range" min="200" max="2500" step="50" value="600" class="range-slider" id="budgetRange" oninput="runSimulation()">
            </div>
            
            <div class="simulation-output">
                <div class="sim-ai-header">
                    <span>PocketPilot Suggestion:</span>
                </div>
                <p class="sim-ai-text" id="aiSimText">"Based on an RM 600 monthly allowance, we recommend restricting non-essentials to RM 120 (20%). Expected surplus at month end: RM 180!"</p>
            </div>
        </div>
    </section>

    <!-- Core Features Grid -->
    <section class="features">
        <div class="features-header">
            <h2>Features Designed for Financial Success</h2>
            <p>Every tools you need to build healthy spending patterns and transparency.</p>
        </div>
        
        <div class="features-grid">
            <!-- Feature 1 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">AI</div>
                <h3>AI Category Suggester</h3>
                <p>Describe your budget or expenses, and our built-in AI will dynamically analyze, suggest categories, and calculate instant aggregates.</p>
            </div>
            
            <!-- Feature 2 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">Supervision</div>
                <h3>Parent Supervision Access</h3>
                <p>Provide peace of mind. Connected parent accounts view real-time graphical progress statements and surplus/deficit reports.</p>
            </div>
            
            <!-- Feature 3 -->
            <div class="feature-card">
                <div class="feature-icon-wrapper">Advisory</div>
                <h3>Counsellor Oversight Portal</h3>
                <p>Connect with registered students upon mutual approvals to offer advisory financial sessions and review monthly spending charts.</p>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer>
        <span class="logo-text">PocketPilot</span>
        <p>Providing students and parents with smart tools to monitor budgets, manage debt risk, and master financial growth.</p>
        <p>&copy; 2026 PocketPilot. Designed for Visual Excellence and Security.</p>
    </footer>

    <!-- JS Simulator logic -->
    <script>
        function runSimulation() {
            const range = document.getElementById('budgetRange');
            const display = document.getElementById('sliderValDisplay');
            const outputText = document.getElementById('aiSimText');
            
            const budget = parseInt(range.value);
            display.textContent = 'RM ' + budget;
            
            let advice = '';
            if (budget < 400) {
                advice = `"Surviving on RM ${budget} can be tough! Target RM ${Math.round(budget * 0.1)} (10%) for emergencies. We recommend tracking basic food and books categories strictly."`;
            } else if (budget <= 800) {
                advice = `"Great student average! Setting a budget of RM ${budget} allows you to save around RM ${Math.round(budget * 0.2)} (20%). Our AI suggests coffee & transit category limitations."`;
            } else if (budget <= 1500) {
                advice = `"With RM ${budget}, you can set comfortable category limits! Aim for a 25% surplus (RM ${Math.round(budget * 0.25)}). Perfect for investing or tuition fees!"`;
            } else {
                advice = `"Living comfortably! Consider automating a savings target of RM ${Math.round(budget * 0.3)} (30%). Keep track of non-essentials so they don't leak."`;
            }
            
            outputText.textContent = advice;
        }
    </script>

<script src="js/theme.js?v=1.0.3"></script>
</body>
</html>
