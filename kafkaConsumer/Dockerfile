FROM openjdk:11-jre-slim
COPY target/stock-data-consumer.jar /app/stock-data-consumer.jar
WORKDIR /app
CMD ["java", "-jar", "stock-data-consumer.jar"]