# Stage 1: build the WAR with Maven (JDK 25)
FROM maven:3.9-eclipse-temurin-25 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests

# Stage 2: run it on Tomcat 11
FROM tomcat:11.0-jdk25-temurin
RUN rm -rf /usr/local/tomcat/webapps/*
# ROOT.war makes the site load at / instead of /EventSphere
COPY --from=build /app/target/EventSphere.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
