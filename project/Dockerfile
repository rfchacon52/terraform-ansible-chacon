# Use a base image with Java (e.g., OpenJDK)
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the packaged JAR file into the container
COPY target/*.jar app.jar

# Expose the port your application runs on (if applicable)
EXPOSE 8080

# Command to run your application
CMD ["java", "-jar", "app.jar"]


