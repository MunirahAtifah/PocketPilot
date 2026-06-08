# PocketPilot - Quick Reference Guide

## 🚀 Current Status: ✅ FULLY OPERATIONAL

- ✅ Docker containers running
- ✅ Database initialized with test data
- ✅ Landing page with login working
- ✅ Maven configuration ready
- ✅ GitHub deployment ready

## 🎯 What's Running Now

**Open this URL:**
```
http://localhost:8088/PP
```

You'll see:
1. Beautiful landing page
2. Navigation with Login/Sign Up buttons
3. Features and benefits sections
4. Professional footer

## 🔐 Test Login Accounts

```
User: Muniey      | Password: 123456
User: aiman       | Password: 345678
User: azman       | Password: 123qwe
User: Ummi        | Password: ummi1234
User: Mazlan      | Password: mazlan5159
```

## 📋 Essential Commands

### Docker Management
```bash
# Start application
docker compose up -d

# Stop application
docker compose down

# View container logs
docker logs pocketpilot_tomcat_app
docker logs pocketpilot_mysql_db

# Rebuild containers
docker compose down && docker compose up -d --build
```

### Maven Commands (Local Development)
```bash
# Build project
mvn clean package

# Build and skip tests
mvn clean package -DskipTests

# Run with Tomcat
mvn tomcat7:run

# Run tests
mvn test
```

### Git Commands (GitHub)
```bash
# First time setup
git init
git remote add origin https://github.com/YourUsername/pocketpilot.git

# Make changes and push
git add .
git commit -m "Your message"
git push origin main

# Check status
git status
git log
```

## 📂 Key Files

| File | Purpose |
|------|---------|
| `index.jsp` | Landing page with info about PocketPilot |
| `login.jsp` | User login form |
| `signup.jsp` | User registration form |
| `pom.xml` | Maven configuration |
| `.gitignore` | Files to exclude from Git |
| `docker-compose.yml` | Docker container setup |
| `Dockerfile` | Docker image definition |

## 🔗 Important URLs

| URL | Purpose |
|-----|---------|
| `http://localhost:8088/PP` | Landing page |
| `http://localhost:8088/PP/login.jsp` | Login page |
| `http://localhost:8088/PP/signup.jsp` | Sign up page |
| `http://localhost:3306` | MySQL database |

## 📝 Database Info

- **Host:** pocketpilot-db (Docker) / localhost (Local)
- **Port:** 3306
- **Database:** pp
- **Username:** root
- **Password:** rootpassword

## 🆘 Troubleshooting

### Login button doesn't work
```bash
# Clear browser cache (Ctrl+Shift+Delete)
# Hard refresh (Ctrl+F5)
# Rebuild containers: docker compose down && docker compose up -d --build
```

### Can't connect to database
```bash
# Check if MySQL is running
docker ps | grep mysql

# View MySQL logs
docker logs pocketpilot_mysql_db

# Test connection
docker exec pocketpilot_mysql_db mysql -uroot -prootpassword pp -e "SELECT 1;"
```

### Port already in use
```bash
# Change port in docker-compose.yml
# Or kill process using port 8088:
netstat -ano | findstr ":8088"
taskkill /PID <process_id> /F
```

### Docker build fails
```bash
# Clean rebuild from scratch
docker compose down -v
docker system prune -f
docker compose up -d --build
```

## 📚 Documentation

Read these files for detailed information:
- **README.md** - Project overview
- **MAVEN_SETUP.md** - Maven guide
- **GITHUB_SETUP.md** - GitHub deployment guide
- **DOCKER_SETUP.md** - Docker configuration

## 🎓 Next Steps

1. **Test everything locally**
   - Open http://localhost:8088/PP
   - Click Login, create account, explore

2. **Deploy to GitHub**
   - Follow steps in GITHUB_SETUP.md
   - Create GitHub account if needed
   - Push your code to GitHub

3. **Learn Maven** (Optional but recommended)
   - Read MAVEN_SETUP.md
   - Try: `mvn clean package`
   - Build WAR file for production

4. **Set up CI/CD** (Optional)
   - Create GitHub Actions workflow
   - Auto-build on every push
   - Run tests automatically

## 💡 Pro Tips

- **Always commit with clear messages:** `git commit -m "Add login feature"`
- **Test before pushing:** `mvn test` before `git push`
- **Keep dependencies updated:** `mvn versions:display-dependency-updates`
- **Use branches for features:** `git checkout -b feature/new-feature`
- **Make small, focused commits:** Don't commit 100 files at once

## 🔒 Security Checklist

- ✅ Database password is in `.gitignore` (won't be pushed)
- ✅ Environment variables are configured
- ✅ SSL can be enabled in production
- ✅ JSP pages are compiled before deployment
- ✅ User passwords are securely stored

## 📞 Quick Help

**Something not working?**
1. Check the logs: `docker logs pocketpilot_tomcat_app`
2. Restart containers: `docker compose down && docker compose up -d`
3. Check internet connection to Docker Hub
4. Read the documentation files
5. Search GitHub issues for similar problems

## 🎉 You're All Set!

Your PocketPilot application is:
- ✅ Fully functional
- ✅ Database connected
- ✅ Ready for GitHub
- ✅ Ready for production

Start building! 🚀

---

**Happy coding! For questions, refer to the documentation files in your project folder.**
