package com.dnastack.dictator;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;

import org.jboss.logging.Logger;

import com.dnastack.dictator.data.CensoredArticle;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "PublishingService", activationConfig = {
    @ActivationConfigProperty(propertyName = "maxSession", propertyValue = "1"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/queue/PublishedArticles"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge"),
    @ActivationConfigProperty(propertyName = "clientId", propertyValue = "Publishing") })
@JBossLog
public class PublishingService extends DelayedMessageListener {

    protected void publish(CensoredArticle article) {
        log.infov("Publishing article \"{0}\"\n{1}",
                article.getTitle(),
                article.getContent());
    }

    @Override
    protected void onMessage(String messageJson) {
        publish(ArticleSerializer.deserializeCensored(messageJson));
    }

    @Override
    protected Logger getLog() {
        return log;
    }

    @Override
    protected Long getDelay() {
        return Long.parseLong(System.getenv(DictatorApplication.PUBLISHING_DURATION_PROP));
    }

}
