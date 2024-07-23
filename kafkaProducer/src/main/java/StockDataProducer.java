import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.Producer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;

public class StockDataProducer {
    public static void main(String[] args) {
        // Kafka broker address
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        // Setting up Kakfa producer
        Producer<String, String> producer = new KafkaProducer<>(props);
        // TODO: Generate stock data and send to Kafka
        // Currently, we are sending 100 random data messages to Kafka
        for (int i = 0; i < 100; i++) {
            String key = "stock-" + i;
            String value = "Stock data " + i;
            ProducerRecord<String, String> record = new ProducerRecord<>("stock-market-data", key, value);
            producer.send(record);
        }

        producer.close();
    }
}