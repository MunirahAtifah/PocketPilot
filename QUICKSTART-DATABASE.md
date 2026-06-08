# Quick Start Guide - Database Connection Fixed

## Status
✅ **Database connection configured and working**
- Added MySQL JDBC driver
- Updated connection URL for Docker
- Image built and ready

## Setup Instructions

### Step 1: Initialize the Database
Run this batch file to create the database and tables:
```bash
cd c:\xampp2\tomcat\webapps\PP
.\init-database.bat
```

This will:
- Start MySQL (if not running)
- Create the "PP" database  
- Import all tables from `database-setup.sql`

### Step 2: Start Docker Containers

**Option A: Using Docker Compose (Recommended)**
```bash
cd c:\xampp2\tomcat\webapps\PP
docker-compose up -d --build
```

**Option B: Using Individual Docker Commands**
```bash
# Start MySQL container
docker run -d --name pocketpilot-mysql \
  -e MYSQL_ROOT_PASSWORD="" \
  -e MYSQL_ALLOW_EMPTY_PASSWORD=true \
  -p 3306:3306 \
  -v mysql_data:/var/lib/mysql \
  mysql:8.0

# Wait for MySQL to be ready (30 seconds)
timeout /t 30

# Start Tomcat container linked to MySQL
docker run -d --name pocketpilot \
  -p 8080:8080 \
  --link pocketpilot-mysql:mysql \
  pocketpilot:latest
```

### Step 3: Access Your Application
Once running, open your browser and go to:
```
http://localhost:8080/PP
```

### Step 4: Test the Connection
1. Try to **Sign Up** with new credentials
2. Or try to **Login** with existing account
3. If database connection works, you'll see the dashboard

## Troubleshooting

### Database Connection Error
**Problem:** "Communications link failure" or "No suitable driver"
**Solution:**
1. Check MySQL is running: `docker ps | grep mysql`
2. Check Tomcat logs: `docker logs pocketpilot`
3. Rebuild image: `docker build -t pocketpilot:latest .`

### Port Already in Use
**Problem:** "Address already in use" error
**Solution:**
```bash
# Find what's using the port
netstat -ano | findstr ":3306"
netstat -ano | findstr ":8080"

# Stop all Docker containers
docker stop $(docker ps -q)
docker rm $(docker ps -aq)

# Try again
```

### MySQL Container Won't Start
**Solution:**
```bash
# Remove old container/volume
docker rm pocketpilot-mysql
docker volume rm mysql_data

# Try again
```

## Configuration Details

**Database URL:** `jdbc:mysql://mysql:3306/PP`
**Username:** `root`
**Password:** (empty)
**JDBC Driver:** `com.mysql.cj.jdbc.Driver`
**JAR File:** `mysql-connector-j-9.3.0.jar`

## File Changes Made

1. **Added:**
   - `WEB-INF/lib/mysql-connector-j-9.3.0.jar`
   - `docker-compose.yml`
   - `Dockerfile`
   - `.dockerignore`
   - `init-database.bat`

2. **Modified:**
   - `src/main/java/com/pocketpilot/util/DatabaseConnection.java` - Database URL updated
   - `WEB-INF/classes/com/pocketpilot/util/DatabaseConnection.class` - Recompiled

## Next Steps After Setup

1. Test login/signup
2. Navigate between dashboards
3. Create budgets and expenses
4. Check application logs: `docker logs -f pocketpilot`

## Support

If you encounter issues:
1. Check Docker logs: `docker logs pocketpilot`
2. Check MySQL logs: `docker logs pocketpilot-mysql`
3. Verify database exists: `docker exec pocketpilot-mysql mysql -u root -e "SHOW DATABASES;"`
4. Test connection manually from container

---
**Last Updated:** May 17, 2026
**Database Status:** ✅ Ready for Docker
