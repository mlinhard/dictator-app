package com.dnastack.dictator.admin;

import static java.lang.String.format;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.MessageProducer;
import javax.jms.Session;

import org.apache.activemq.artemis.jms.client.ActiveMQConnectionFactory;

import com.dnastack.dictator.ArticleSerializer;
import com.dnastack.dictator.admin.MqAdminController.ConnectorInfo;
import com.dnastack.dictator.data.Article;

public class MqAdminTool {

    private static final String QUEUE_ARTICLE_SUBMISSIONS = "jms.queue.ArticleSubmissions";
    private static final String QUEUE_PUBLISHED_ARTICLES = "jms.queue.PublishedArticles";

    private String activeMqHost;
    private Integer activeMqPort;
    private String activeMqUser;
    private String activeMqPass;
    private String targetActiveMqHost;
    private Integer targetActiveMqPort;
    private MqAdminController mqAdmin;

    private static void log(String msg, Object... params) {
        System.out.println(String.format(msg, params));
    }

    public MqAdminTool(String activeMqHost, Integer activeMqPort, String activeMqUser, String activeMqPass) {
        this.activeMqHost = activeMqHost;
        this.activeMqPort = activeMqPort;
        this.activeMqUser = activeMqUser;
        this.activeMqPass = activeMqPass;
        mqAdmin = new MqAdminController(activeMqHost, activeMqPort, activeMqUser, activeMqPass);
        ConnectorInfo connector = mqAdmin.getConnectors().stream()
                .filter(c -> "blue-green-bridge".equals(c.getName()))
                .findFirst()
                .orElseThrow(() -> new RuntimeException("blue-green-bridge connector not found"));
        targetActiveMqHost = (String) connector.getParams().get("host");
        targetActiveMqPort = Integer.parseInt((String) connector.getParams().get("port"));
        if (targetActiveMqHost == null || targetActiveMqPort == null) {
            throw new RuntimeException("MQ server doesn't have host or port properties in the connector");
        }
        log("MQ Admin endpoint configured with ActiveMQ at %s:%s", activeMqHost, activeMqPort);
    }

    public void sendArticleViaJms(String title, String content) throws JMSException {
        Article article = new Article(title, content);
        try (
                ActiveMQConnectionFactory f = new ActiveMQConnectionFactory(format("tcp://%s:%d", activeMqHost, activeMqPort));
                Connection connection = f.createConnection(activeMqUser, activeMqPass);
                Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE)) {
            connection.start();
            MessageProducer producer = session.createProducer(session.createQueue(QUEUE_ARTICLE_SUBMISSIONS));
            log("Sending article %s: %s", title, content);
            producer.send(session.createTextMessage(ArticleSerializer.serialize(article)));
            producer.close();
            log("Article sent.", title, content);
        }
    }

    public void createBridge() {
        log("Creating bridge for ArticleSubmissions ...");
        mqAdmin.createBridge("blue-green-bridge-ArticleSubmissions", QUEUE_ARTICLE_SUBMISSIONS, null, "blue-green-bridge", activeMqUser, activeMqPass);
        log("Creating bridge for PublishedArticles ...");
        mqAdmin.createBridge("blue-green-bridge-PublishedArticles", QUEUE_PUBLISHED_ARTICLES, null, "blue-green-bridge", activeMqUser, activeMqPass);

        log("Bridge created from %s:%s to %s:%s", activeMqHost, activeMqPort, targetActiveMqHost, targetActiveMqPort);
    }

    public void destroyBridge() {
        log("Destroying bridge for ArticleSubmissions ...");
        mqAdmin.destroyBridge("blue-green-bridge-ArticleSubmissions");
        log("Destroying bridge for PublishedArticles ...");
        mqAdmin.destroyBridge("blue-green-bridge-PublishedArticles");

        log("Destroyed bridge from %s:%s to %s:%s", activeMqHost, activeMqPort, targetActiveMqHost, targetActiveMqPort);
    }

    public void bridgeInfo() {
        log("Source server: %s:%s", activeMqHost, activeMqPort);
        log("Target server: %s:%s", targetActiveMqHost, targetActiveMqPort);
    }

    public static void main(String[] args) {
        if (args.length == 0) {
            log("USAGE: mq-admin.sh send <host> <port> <user> <pass> <title> <content>");
            log("       mq-admin.sh create-bridge <host> <port> <user> <pass>");
            log("       mq-admin.sh destroy-bridge <host> <port> <user> <pass>");
            log("       mq-admin.sh bridge-info <host> <port> <user> <pass>");
            log("(or you can leave out <host> <port> <user> <pass> options if you supply them as env vars:");
            log("MQ_ADMIN_HOST, MQ_ADMIN_HOST, MQ_ADMIN_USER, MQ_ADMIN_PASS)");
            return;
        }
        String command = args[0];
        String envHost = System.getenv("MQ_ADMIN_HOST");
        String envPort = System.getenv("MQ_ADMIN_PORT");
        String envUser = System.getenv("MQ_ADMIN_USER");
        String envPass = System.getenv("MQ_ADMIN_PASS");
        MqAdminTool tool = null;
        boolean envVarConfig = false;
        if (envHost != null && envPort != null && envUser != null && envPass != null) {
            tool = new MqAdminTool(envHost, Integer.parseInt(envPort), envUser, envPass);
            envVarConfig = true;
        } else {
            tool = new MqAdminTool(args[1], Integer.parseInt(args[2]), args[3], args[4]);
        }

        try {
            if ("send".equals(command)) {
                String title = args[envVarConfig ? 1 : 5];
                String content = args[envVarConfig ? 2 : 6];
                tool.sendArticleViaJms(title, content);
            } else if ("create-bridge".equals(command)) {
                tool.createBridge();
            } else if ("destroy-bridge".equals(command)) {
                tool.destroyBridge();
            } else if ("bridge-info".equals(command)) {
                tool.bridgeInfo();
            } else {
                throw new Exception("Unknown command: " + command);
            }
        } catch (Exception e) {
            log("ERROR: %s", e.getMessage());
            e.printStackTrace();
            System.exit(1);
        }
    }
}
