FROM tomcat:9.0-jdk17-openjdk-slim

# Install Maven (optional, for building with Maven locally)
# RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Clear out default Tomcat apps
RUN rm -rf /usr/local/tomcat/webapps/*

# Create the target deployment directory
RUN mkdir -p /usr/local/tomcat/webapps/PP/WEB-INF/classes

# Copy project files into the container
COPY ./WEB-INF /usr/local/tomcat/webapps/PP/WEB-INF
COPY ./*.jsp /usr/local/tomcat/webapps/PP/
COPY ./css /usr/local/tomcat/webapps/PP/css
COPY ./js /usr/local/tomcat/webapps/PP/js

EXPOSE 8080
CMD ["catalina.sh", "run"]