package com.dnastack.dictator.admin;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

import javax.json.Json;
import javax.json.JsonObject;
import javax.json.stream.JsonGenerator;
import javax.json.stream.JsonGeneratorFactory;

import org.junit.Ignore;
import org.junit.Test;

import com.dnastack.dictator.admin.MqAdminController.ConnectorInfo;

@Ignore
public class MqAdminControllerTest {

    @Test
    public void testAdmin() {
        System.out.println("Connecting");
        try (MqAdminController controller = new MqAdminController("localhost", 61617, "dictator", "ourleader")) {
            ConnectorInfo connector = controller.getConnectors().stream()
                    .filter(c -> "blue-green-bridge".equals(c.getName()))
                    .findFirst()
                    .orElseThrow(() -> new AssertionError("blue-green-bridge connector not found"));

            System.out.println(String.format("Connector %s found: params: %s", connector.getName(), connector.getParams()));
            System.out.println("Creating bridge ...");
            controller.createBridge("blue-green-bridge", "ArticleSubmissions", null, "blue-green-bridge", "dictator", "ourleader");
            System.out.println("Destroing bridge ...");
            controller.destroyBridge("blue-green-bridge");
            System.out.println("Done.");
        } catch (Exception e) {
            StringWriter sw = new StringWriter();
            PrintWriter w = new PrintWriter(sw);
            e.printStackTrace(w);
            JsonObject errorJson = Json.createObjectBuilder()
                    .add("Message", e.getMessage() == null ? "" : e.getMessage())
                    .add("Stacktrace", sw.toString()).build();

            Map<String, Object> properties = new HashMap<>(1);
            properties.put(JsonGenerator.PRETTY_PRINTING, true);
            JsonGeneratorFactory jf = Json.createGeneratorFactory(properties);
            JsonGenerator jg = jf.createGenerator(System.out);
            jg.write(errorJson);
            jg.flush();
            System.out.flush();
        }
    }


}
