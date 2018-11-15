package com.dnastack.dictator;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "CensorshipService", activationConfig = {
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/queue/ArticleSubmissions"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge") })
@JBossLog
public class CensorshipService implements MessageListener {


    public void onMessage(String messageJson) {
        log.infov("Received message:\n{0}", messageJson);
    }

    @Override
    public void onMessage(Message message) {
        if (message instanceof TextMessage) {
            try {
                onMessage(((TextMessage) message).getText());
            } catch (JMSException e) {
                log.error("Error while receiving message", e);
            }
        }
    }

}
