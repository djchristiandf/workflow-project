# Build stage
FROM maven:3.6.3-jdk-8 AS build
WORKDIR /app

# Primeiro copia apenas o POM para aproveitar cache de dependências
COPY pom.xml .
RUN mvn dependency:go-offline

# Depois copia o resto do código fonte
COPY src ./src
RUN mvn clean package

# Runtime stage
FROM tomcat:8.5.54-jdk8-openjdk
COPY --from=build /app/target/workflow.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]