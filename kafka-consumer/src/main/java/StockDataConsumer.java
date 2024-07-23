import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.common.serialization.StringDeserializer;
import com.datastax.driver.core.Cluster;
import com.datastax.driver.core.Session;

import java.util.Collections;
import java.util.Properties;

public class StockDataConsumer {
    public static void main(String[] args) {
        Properties props = new Properties();
        // Kafka broker address
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "stock-data-consumer-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        // Kafka topic to consume
        KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props);
        consumer.subscribe(Collections.singletonList("stock-market-data"));
        // Cassandra cluster address
        Cluster cluster = Cluster.builder().addContactPoint("cassandra").build();
        Session session = cluster.connect("stockdata");
        // Consume messages from Kafka and insert into Cassandra
        while (true) {
            ConsumerRecords<String, String> records = consumer.poll(100);
            for (ConsumerRecord<String, String> record : records) {
                String key = record.key();
                String value = record.value();
                session.execute("INSERT INTO stocks (symbol, data) VALUES (?, ?)", key, value);
            }
        }
    }
}