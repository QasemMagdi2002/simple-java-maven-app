# STAGE 1: Build stage (using a small Maven image)
FROM maven:3.9.6-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy only pom.xml first to leverage Docker layer caching for dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy the rest of the source and build the application
COPY src ./src
RUN mvn clean package -DskipTests

# STAGE 2: Runtime stage (using a minimal JRE image)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create a non-root user for security
RUN addgroup -S commitcrab && adduser -S crabuser -G commitcrab
USER crabuser

# Copy ONLY the built jar from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port (standard for Spring Boot/Java apps)
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
