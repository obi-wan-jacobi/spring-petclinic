#STAGE1: Base Image
FROM openjdk:17-jdk-slim AS build
RUN apt update && apt -y install locales && locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
RUN apt-get update && \
    apt-get install -y maven unzip

#STAGE2: Copy artifacts
WORKDIR /tmp
COPY pom.xml /tmp/
COPY .mvn /tmp/.mvn
COPY mvnw /tmp/
RUN chmod +x /tmp/mvnw
COPY src /tmp/src
RUN /tmp/mvnw package

#STAGE3: Runtime configuration
FROM openjdk:17-jdk-slim
COPY --from=build /tmp/target/*.jar spring-boot-application.jar

#STAGE4: Expose required port
EXPOSE 8080

# Create user and set ownership and permissions as required
RUN adduser --disabled-password --gecos "" acamtestuser && chown -R acamtestuser /tmp
USER acamtestuser

ENTRYPOINT ["java", "-jar", "/spring-boot-application.jar"]