# Stage 1: Build
FROM maven:3.8-openjdk-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# Stage 2: Run
FROM tomcat:9.0-jdk17-openjdk-slim

# 1. Purge default apps
RUN rm -rf /usr/local/tomcat/webapps/*

# 2. Copy the file as ROOT.war
# Tomcat will automatically deploy this at the root context (/)
COPY --from=build /app/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080
CMD ["catalina.sh", "run"]