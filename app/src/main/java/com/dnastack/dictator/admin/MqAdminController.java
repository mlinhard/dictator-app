package com.dnastack.dictator.admin;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.apache.activemq.artemis.api.core.TransportConfiguration;
import org.apache.activemq.artemis.api.core.client.ActiveMQClient;
import org.apache.activemq.artemis.api.core.client.ClientMessage;
import org.apache.activemq.artemis.api.core.client.ClientRequestor;
import org.apache.activemq.artemis.api.core.client.ClientSession;
import org.apache.activemq.artemis.api.core.client.ClientSessionFactory;
import org.apache.activemq.artemis.api.core.client.ServerLocator;
import org.apache.activemq.artemis.api.core.management.ManagementHelper;
import org.apache.activemq.artemis.api.core.management.ResourceNames;
import org.apache.activemq.artemis.core.remoting.impl.netty.NettyConnectorFactory;
import org.apache.activemq.artemis.core.remoting.impl.netty.TransportConstants;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.ToString;

public class MqAdminController implements AutoCloseable {

    

    private static final String MANAGEMENT_QUEUE = "activemq.management";
    private ClientSession session;
    private ClientRequestor requestor;

    public MqAdminController(String host, int port, String username, String password) {
        try {
            Map<String, Object> connectionParams = new HashMap<String, Object>();
            connectionParams.put(TransportConstants.HOST_PROP_NAME, host);
            connectionParams.put(TransportConstants.PORT_PROP_NAME, port);
            TransportConfiguration transportConfiguration = new TransportConfiguration(NettyConnectorFactory.class.getName(), connectionParams);
            ServerLocator locator = ActiveMQClient.createServerLocatorWithoutHA(transportConfiguration);
            ClientSessionFactory factory = locator.createSessionFactory();
            this.session = factory.createSession(username, password, false, true, true, true, 10);
            this.session.start();
            this.requestor = new ClientRequestor(session, MANAGEMENT_QUEUE);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Error while connecting to Artemis ActiveMQ Admin interface", e);
        }
    }

    private Object operationInvocation(String resourceName, String operation, Object... parameters) {
        try {
            ClientMessage message = session.createMessage(false);
            ManagementHelper.putOperationInvocation(message, resourceName, operation, parameters);
            ClientMessage reply = requestor.request(message);
            return ManagementHelper.getResult(reply);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("Error while executing getQueueNames", e);
        }
    }

    public List<String> getQueueNames() {
        return Arrays.asList((Object[]) operationInvocation(ResourceNames.BROKER, "getQueueNames"))
                .stream()
                .map(o -> ((String) o))
                .collect(Collectors.toList());
    }

    @SuppressWarnings("unchecked")
    public List<ConnectorInfo> getConnectors() {
        return Arrays.asList((Object[]) operationInvocation(ResourceNames.BROKER, "getConnectors"))
                .stream()
                .map(o -> {
                    Object[] t = (Object[]) o;
                    return new ConnectorInfo((String) t[0], (String) t[1], (Map<String, Object>) t[2]);
                })
                .collect(Collectors.toList());
    }

    /**
     * Create Core Bridge
     * 
     * @param name Name of the bridge
     * @param queueName Name of the source queue
     * @param forwardingAddress Forwarding address. This is the address on the target server that the message will be forwarded to. If a forwarding address is
     *        not specified, then the original address of the message will be retained.
     * @param connectorNames comma separated list of connector names
     * @param user User name
     * @param password User password
     */
    public void createBridge(
            String name,
            String queueName,
            String forwardingAddress,
            String connectorNames,
            String user,
            String password) {
        String filterString = null; // Filter of the bridge
        String transformerClassName = null; // Class name of the bridge transformer
        long retryInterval = 10000; // Connection retry interval
        double retryIntervalMultiplier = 10; // Connection retry interval multiplier
        int initialConnectAttempts = -1; // Number of initial connection attempts
        int reconnectAttempts = -1; // Number of reconnection attempts
        boolean useDuplicateDetection = true; // Use duplicate detection
        int confirmationWindowSize = 100; // Confirmation window size
        long clientFailureCheckPeriod = 15000; // Period to check client failure
        boolean useDiscoveryGroup = false; // use discovery group
        boolean ha = false; // Is it using HA

        operationInvocation(ResourceNames.BROKER, "createBridge",
                name,
                queueName,
                forwardingAddress,
                filterString,
                transformerClassName,
                retryInterval,
                retryIntervalMultiplier,
                initialConnectAttempts,
                reconnectAttempts,
                useDuplicateDetection,
                confirmationWindowSize,
                clientFailureCheckPeriod,
                connectorNames,
                useDiscoveryGroup,
                ha,
                user,
                password);
    }

    public void destroyBridge(String name) {
        operationInvocation(ResourceNames.BROKER, "destroyBridge", name);
    }

    @Override
    public void close() throws Exception {
        if (requestor != null) {
            requestor.close();
        }
        if (session != null) {
            session.close();
        }
    }

    @Getter
    @Setter
    @AllArgsConstructor
    @ToString
    public static class ConnectorInfo {

        private String name;
        private String clazz;
        private Map<String, Object> params;

    }
}
