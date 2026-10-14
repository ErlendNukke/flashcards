# syntax=docker/dockerfile:1

FROM eclipse-temurin:25-jdk AS build
WORKDIR /app

COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
COPY src ./src
RUN chmod +x mvnw && ./mvnw -B -DskipTests package

FROM eclipse-temurin:25-jre
WORKDIR /app

RUN useradd --system --create-home --uid 10001 flashcards

COPY --from=build /app/target/flashcards-api-*.jar /app/app.jar
USER flashcards

ENV SPRING_PROFILES_ACTIVE=prod
ENV PORT=8080

EXPOSE 8080
ENTRYPOINT ["java","-XX:+UseContainerSupport","-XX:MaxRAMPercentage=75.0","-jar","/app/app.jar"]
