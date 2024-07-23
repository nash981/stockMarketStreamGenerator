FROM openjdk:11-jre-slim
COPY target/stock-data-producer.jar /app/stock-data-producer.jar
WORKDIR /app
CMD ["java", "-jar", "stock-data-producer.jar"]