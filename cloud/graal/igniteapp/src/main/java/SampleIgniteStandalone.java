// SampleIgniteStandalone.java
import org.apache.ignite.Ignite;
import org.apache.ignite.Ignition;
import org.apache.ignite.configuration.IgniteConfiguration;

import java.util.HashMap;
import java.util.Map;

public class SampleIgniteStandalone {
    public static void main(String[] args) {
        // Set a system property to avoid shutdown hook issues
        System.setProperty("IGNITE_NO_SHUTDOWN_HOOK", "true");

        // Create Ignite configuration
        IgniteConfiguration cfg = new IgniteConfiguration();

        // Set a unique instance name
        cfg.setIgniteInstanceName("sampleNode");

        // Optionally, set user attributes (as in your code)
        Map<String, Object> userAttrs = new HashMap<>();
        userAttrs.put("APP_NAME", "SampleApp");
        userAttrs.put("MEMBER_NAME", "sampleNode");
        cfg.setUserAttributes(userAttrs);

        // Start Ignite node
        try (Ignite ignite = Ignition.start(cfg)) {
            System.out.println("Ignite node started: " + ignite.name());
            // Keep the node running for demonstration
            Thread.sleep(10_000);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}