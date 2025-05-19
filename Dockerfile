# Build stage (Maven)
FROM maven:3.6.3-jdk-8 AS build

WORKDIR /app

# Copia o POM primeiro para aproveitar cache de dependências
COPY pom.xml .
RUN mvn dependency:go-offline

# Copia o código fonte e empacota
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime stage (JBoss)
FROM jboss/wildfly:18.0.1.Final

# Configura o JBoss
RUN /opt/jboss/wildfly/bin/add-user.sh admin Admin#123 --silent
COPY --from=build /app/target/workflow.war /opt/jboss/wildfly/standalone/deployments/

# Expõe portas (8080 = aplicação, 9990 = admin console)
EXPOSE 8080 9990

# Inicia o JBoss em modo standalone
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]