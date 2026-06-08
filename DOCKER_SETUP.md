# Docker Setup Guide for PocketPilot

## Prerequisites
1. **Docker Desktop** installed (Windows: [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop))
2. Your web application compiled and ready in the webapps directory
3. Command line access (PowerShell or CMD)

## Building the Docker Image

### Step 1: Navigate to Your Project Root
```bash
cd c:\xampp2\tomcat\webapps\PP
```

### Step 2: Build the Docker Image
```bash
docker build -t pocketpilot:latest .
```

**What this does:**
- `-t pocketpilot:latest` - Tags the image with the name "pocketpilot" and version "latest"
- `.` - Uses the Dockerfile in the current directory

**Expected Output:**
```
[+] Building 15.2s
 => [internal] load build definition from Dockerfile
 => [1/3] FROM tomcat:9.0-jdk11-openjdk-slim
 => [2/3] RUN rm -rf /usr/local/tomcat/webapps/*
 => [3/3] COPY ./ /usr/local/tomcat/webapps/PP
 => exporting to image
 => => writing image sha256:abc123...
```

## Running the Docker Container

### Option 1: Basic Run (Foreground)
```bash
docker run -p 8080:8080 pocketpilot:latest
```

**Parameters:**
- `-p 8080:8080` - Maps port 8080 from container to your machine
- Port format: `<your-machine-port>:<container-port>`

### Option 2: Background Run (Detached)
```bash
docker run -d -p 8080:8080 --name pocketpilot pocketpilot:latest
```

**Parameters:**
- `-d` - Run in detached mode (background)
- `--name pocketpilot` - Give your container a friendly name

## Accessing Your Application

Once the container is running, access it at:
```
http://localhost:8080/PP
```

## Useful Docker Commands

### Check Running Containers
```bash
docker ps
```

### View Container Logs
```bash
docker logs pocketpilot
# For live logs:
docker logs -f pocketpilot
```

### Stop the Container
```bash
docker stop pocketpilot
```

### Start a Stopped Container
```bash
docker start pocketpilot
```

### Remove a Container
```bash
docker rm pocketpilot
```

### List All Images
```bash
docker images
```

### Remove an Image
```bash
docker rmi pocketpilot:latest
```

## Troubleshooting

### Container Exits Immediately
- **Check logs:** `docker logs pocketpilot`
- **Ensure your JSP files are in the correct location** (should be in the root or webapps/PP folder)

### Port Already in Use
```bash
# Use a different port:
docker run -p 9090:8080 pocketpilot:latest
# Then access at http://localhost:9090/PP
```

### File Not Found Errors
- Verify that all JSP files, CSS, JS, and WEB-INF folder are in `c:\xampp2\tomcat\webapps\PP`
- Rebuild the image after adding files: `docker build -t pocketpilot:latest .`

### Database Connection Issues
- If using a local MySQL/database, update your connection strings to reference the Docker host
- On Windows/Mac with Docker Desktop, use `host.docker.internal` instead of `localhost`

## Next Steps

1. **Build the image:** `docker build -t pocketpilot:latest .`
2. **Run the container:** `docker run -d -p 8080:8080 --name pocketpilot pocketpilot:latest`
3. **Test the app:** Open `http://localhost:8080/PP` in your browser
4. **Check logs if needed:** `docker logs -f pocketpilot`

## Docker Compose (Optional)

For more advanced setups with database, create a `docker-compose.yml`:

```yaml
version: '3.8'

services:
  tomcat:
    build: .
    ports:
      - "8080:8080"
    environment:
      - CATALINA_OPTS=-Xmx512M
    volumes:
      - ./logs:/usr/local/tomcat/logs
    restart: unless-stopped

  # Uncomment if you need MySQL
  # db:
  #   image: mysql:8.0
  #   environment:
  #     MYSQL_ROOT_PASSWORD: root
  #     MYSQL_DATABASE: PP
  #   ports:
  #     - "3306:3306"
  #   volumes:
  #     - mysql_data:/var/lib/mysql

# volumes:
#   mysql_data:
```

Then run: `docker-compose up -d`
