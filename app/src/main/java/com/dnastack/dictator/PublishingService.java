package com.dnastack.dictator;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.TextMessage;

import com.dnastack.dictator.data.CensoredArticle;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "PublishingService", activationConfig = {
    @ActivationConfigProperty(propertyName = "maxSession", propertyValue = "1"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/queue/PublishedArticles"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge") })
@JBossLog
public class PublishingService implements MessageListener {

    protected void onMessage(String messageJson) {
        log.debugv("Received message:\n{0}", messageJson);
        publish(ArticleSerializer.deserializeCensored(messageJson));
    }

    protected void publish(CensoredArticle article) {
        if ("OK".equals(article.getCheckResult())) {
            log.infov("Publishing article \"{0}\"\n{1}",
                    article.getTitle(),
                    article.getContent());
        } else {
            log.infov("Censored article \"{0}\"\nCensored at {1}",
                    article.getTitle(),
                    article.getCheckedAt());
        }
    }

    protected String censorContent(String content) {
        if (content.contains("dictator is corrupt")) {
            return "CENSORED";
        } else {
            return "OK";
        }
    }

    @Override
    public void onMessage(Message message) {
        try {
            log.infov("Received message version {0}", message.getStringProperty(DictatorApplication.VERSION_PROP));
            if (message instanceof TextMessage) {
                onMessage(((TextMessage) message).getText());
            } else {
                log.warn("Ignoring non-TextMessage");
            }
        } catch (Exception e) {
            log.error("Error while receiving message", e);
        }
    }

}
