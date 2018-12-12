package com.dnastack.dictator;

import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

import org.jboss.logging.Logger;

public abstract class DelayedMessageListener implements MessageListener {

    private Long delay;

    protected abstract void onMessage(String message);

    protected abstract Logger getLog();

    protected abstract Long getDelay();

    @Override
    public void onMessage(Message message) {
        Logger log = getLog();
        try {
            String version = message.getStringProperty(DictatorApplication.VERSION_PROP);
            log.infov("Received message version {0}", version);
            if (message instanceof TextMessage) {
                String text = ((TextMessage) message).getText();
                if (text == null) {
                    log.warn("Ignoring empty TextMessage");
                } else {
                    log.debugv("Received message:\n{0}", message);
                    try {
                        if (delay == null) {
                            delay = getDelay();
                        }
                        Thread.sleep(delay);
                    } catch (InterruptedException e) {
                        log.error("Delayed message listener interrupted in sleep", e);
                    }
                    onMessage(text);
                }
            } else {
                log.warn("Ignoring non-TextMessage");
            }
        } catch (Exception e) {
            log.error("Error while receiving message", e);
        }
    }
}
