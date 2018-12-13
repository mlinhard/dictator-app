package com.dnastack.dictator;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;

import org.jboss.logging.Logger;

import com.dnastack.dictator.data.CensoredArticle;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "PressMonitoringService", activationConfig = {
    @ActivationConfigProperty(propertyName = "maxSession", propertyValue = "1"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/topic/CensoredArticles"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Topic"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge"),
    @ActivationConfigProperty(propertyName = "subscriptionDurability", propertyValue = "Durable"),
    @ActivationConfigProperty(propertyName = "subscriptionName", propertyValue = "PressMonitoringSub"),
    @ActivationConfigProperty(propertyName = "clientId", propertyValue = "PressMonitoring") })
@JBossLog
public class PressMonitoringService extends DelayedMessageListener {

    protected void onMessage(String messageJson) {
        CensoredArticle article = ArticleSerializer.deserializeCensored(messageJson);
        if (article.getDatePosted() == null) {
            log.infov("Censored article \"{0}\"\nCensored at {1}\nPosted at UNKNOWN date",
                    article.getTitle(),
                    article.getCheckedAt(),
                    article.getDatePosted());
        } else {
            log.infov("Censored article \"{0}\"\nCensored at {1}\nPosted at {2}",
                    article.getTitle(),
                    article.getCheckedAt(),
                    article.getDatePosted());
        }
    }

    @Override
    protected Logger getLog() {
        return log;
    }

    @Override
    protected Long getDelay() {
        return Long.parseLong(System.getenv(DictatorApplication.MONITORING_DURATION_PROP));
    }

}
