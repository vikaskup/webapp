# ---------- Stage 1: Build ----------
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

# ---------- Stage 2: Extract Layers ----------
FROM eclipse-temurin:17-jre-jammy AS extract
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
RUN java -Djarmode=layertools -jar app.jar extract

# ---------- Stage 3: Runtime ----------
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

# Copy Spring Boot layers
COPY --from=extract /app/dependencies/ ./
COPY --from=extract /app/spring-boot-loader/ ./
COPY --from=extract /app/snapshot-dependencies/ ./
COPY --from=extract /app/application/ ./

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]
