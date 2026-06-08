# PocketPilot - Smart Budget Management System

## Overview

PocketPilot is a web-based budget management system designed for students and parents to track expenses, create budgets, and monitor spending patterns. Built with Java, JSP, MySQL, and Tomcat.

## 🎯 Features

- **Expense Tracking** - Record and categorize all spending
- **Budget Planning** - Create and manage monthly budgets
- **Family Supervision** - Parents can monitor children's spending with secure codes
- **Progress Reports** - Generate detailed PDF reports
- **User Roles** - Student, Parent, and Student Counselor roles
- **Secure Access** - Encrypted passwords and session management

## 🛠 Technology Stack

- **Backend:** Java 17, Servlet, JSP
- **Database:** MySQL 8.0
- **Build Tool:** Maven 3.8+
- **Server:** Apache Tomcat 9.0
- **Containerization:** Docker & Docker Compose
- **Frontend:** HTML5, CSS3, JavaScript

## 📋 Prerequisites

### For Local Development
- **Java 17 JDK** - [Download](https://www.oracle.com/java/technologies/downloads/#java17)
- **Maven 3.8+** - [Download](https://maven.apache.org/download.cgi)
- **MySQL 8.0** - [Download](https://dev.mysql.com/downloads/mysql/)

### For Docker Deployment
- **Docker** - [Download](https://www.docker.com/products/docker-desktop)
- **Docker Compose** - Included with Docker Desktop

## 🚀 Quick Start

### Option 1: Using Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/YourUsername/pocketpilot.git
cd pocketpilot

# Start the application with Docker Compose
docker compose up -d

# Access the application
# http://localhost:8088/PP
```

The database will be automatically initialized on first startup.

### Option 2: Local Development with Maven

```bash
# Clone the repository
git clone https://github.com/YourUsername/pocketpilot.git
cd pocketpilot

# Build the project
mvn clean package

# Run with Tomcat Maven Plugin
mvn tomcat7:run

# Access the application
# http://localhost:8080/PP
```

### Option 3: Manual Local Setup

```bash
# 1. Set up MySQL database
mysql -u root -p < database-setup.sql
mysql -u root -p < notification-setup.sql

# 2. Build the project
mvn clean package

# 3. Deploy to Tomcat
cp target/PP.war $TOMCAT_HOME/webapps/

# 4. Start Tomcat
$TOMCAT_HOME/bin/startup.sh

# Access the application
# http://localhost:8080/PP
```

## 📝 Maven Commands

```bash
# Build the project
mvn clean package

# Build and skip tests
mvn clean package -DskipTests

# Run tests
mvn test

# Run with Tomcat Maven plugin
mvn tomcat7:run

# Clean build artifacts
mvn clean

# Install dependencies locally
mvn dependency:resolve

# Generate project documentation
mvn site
```

## 🗂 Project Structure (Maven Standard)

```
pocketpilot/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/pocketpilot/
│   │   │       ├── controller/        # Servlets
│   │   │       ├── dao/               # Database operations
│   │   │       ├── model/             # Entity classes
│   │   │       ├── servlet/           # Additional servlets
│   │   │       └── util/              # Utility classes
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   ├── web.xml            # Deployment descriptor
│   │       │   ├── classes/
│   │       │   └── lib/
│   │       ├── *.jsp                  # JSP pages
│   │       ├── css/                   # Stylesheets
│   │       └── js/                    # JavaScript files
│   └── test/
│       └── java/                      # Unit tests
├── docker-compose.yml                 # Docker configuration
├── Dockerfile                         # Docker image definition
├── pom.xml                            # Maven configuration
├── .gitignore                         # Git ignore rules
└── README.md                          # Project documentation
```

## 🔐 Default Test Accounts

After initial setup, you can log in with these credentials:

| Username | Password | Role |
|----------|----------|------|
| Muniey | 123456 | Student |
| aiman | 345678 | Student |
| azman | 123qwe | Parent |
| Ummi | ummi1234 | Parent |
| Mazlan | mazlan5159 | Parent |
| Fara | fara13 | Student |
| Ali | 3456789 | Parent |

## 🐳 Docker Configuration

### Docker Compose Services

```yaml
pocketpilot-db:
  - MySQL 8.0 database
  - Port: 3306
  - Database: pp
  - Username: root
  - Password: rootpassword

pocketpilot-web:
  - Tomcat 9.0 web server
  - Port: 8088
  - Built from Dockerfile with Maven
```

### Building Docker Image Manually

```bash
# Build the Docker image
docker build -t pocketpilot:latest .

# Run the container
docker run -d -p 8088:8080 --name pocketpilot pocketpilot:latest
```

## 📦 Database Setup

### Automatic (Docker)

Database initializes automatically with these scripts:
- `database-setup.sql` - Creates tables and sample data
- `notification-setup.sql` - Creates notification system

### Manual (Local)

```bash
# Create database and tables
mysql -u root -p < database-setup.sql
mysql -u root -p < notification-setup.sql

# Or use batch file on Windows
./init-database.bat
```

## 🔧 Configuration

### Database Connection
Edit `src/main/java/com/pocketpilot/util/DatabaseConnection.java`:

```java
private static final String DB_URL = "jdbc:mysql://localhost:3306/pp";
private static final String DB_USER = "root";
private static final String DB_PASSWORD = "your_password";
```

### Tomcat Context
Configured in `docker-compose.yml` and `pom.xml`
- Application Path: `/PP`
- Port: 8088 (Docker) / 8080 (Local)

## 🧪 Testing

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=YourTestClass

# Run with coverage
mvn clean test jacoco:report
```

## 🚢 Deployment to GitHub

### 1. Create GitHub Repository

```bash
# Initialize git (if not already done)
git init

# Add GitHub remote
git remote add origin https://github.com/YourUsername/pocketpilot.git

# Set default branch
git branch -M main
```

### 2. Prepare for Deployment

```bash
# Update pom.xml with your repository URL
# Update .gitignore (already provided)
# Review .dockerignore
```

### 3. Push to GitHub

```bash
# Stage all files
git add .

# Commit changes
git commit -m "Initial commit: PocketPilot with Maven configuration"

# Push to GitHub
git push -u origin main
```

### 4. GitHub Actions (Optional - CI/CD)

Create `.github/workflows/maven.yml`:

```yaml
name: Maven Build

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-java@v2
        with:
          java-version: '17'
          distribution: 'temurin'
      - run: mvn clean package
```

## 📚 API Endpoints

### Authentication
- `POST /PP/LoginServlet` - User login
- `POST /PP/SignupServlet` - User registration
- `GET /PP/LogoutServlet` - User logout

### Budget Management
- `POST /PP/AddBudgetServlet` - Create budget
- `POST /PP/UpdateBudgetServlet` - Update budget
- `POST /PP/DeleteBudgetServlet` - Delete budget

### Expense Management
- `POST /PP/AddExpenseServlet` - Add expense
- `POST /PP/UpdateExpenseServlet` - Update expense
- `POST /PP/DeleteExpenseServlet` - Delete expense

### Dashboard & Reports
- `GET /PP/DashboardServlet` - Student dashboard
- `GET /PP/ParentDashboardServlet` - Parent dashboard
- `GET /PP/TrackingProgress` - Progress reports

## 🆘 Troubleshooting

### Docker Issues

```bash
# View container logs
docker logs pocketpilot_tomcat_app
docker logs pocketpilot_mysql_db

# Stop and remove containers
docker compose down

# Rebuild from scratch
docker compose down -v
docker compose up -d --build
```

### Database Connection Error

```bash
# Check if MySQL container is running
docker ps | grep mysql

# Test database connection
docker exec -it pocketpilot_mysql_db mysql -uroot -prootpassword -e "SHOW DATABASES;"
```

### Port Already in Use

```bash
# Find process using port
netstat -ano | findstr ":8088"

# Kill process (Windows)
taskkill /PID <process_id> /F

# Or change port in docker-compose.yml
```

## 📞 Support

For issues or questions:
1. Check existing GitHub issues
2. Create a new GitHub issue with:
   - Description of the problem
   - Steps to reproduce
   - Error logs/screenshots
   - Your environment (OS, Java version, etc.)

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 Changelog

### Version 1.0.0 (Current)
- Initial Maven-based project setup
- Docker containerization
- Complete budget and expense tracking
- Family supervision features
- PDF report generation
- Multi-role support (Student, Parent, Counselor)

## 🙏 Acknowledgments

- Apache Tomcat
- MySQL Community
- iText PDF Library
- All contributors and testers

---

**Happy budgeting! 💰**
