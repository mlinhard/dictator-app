package com.dnastack.dictator;

import java.time.LocalDate;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.inject.Inject;
import javax.jms.JMSConnectionFactory;
import javax.jms.JMSContext;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.Queue;
import javax.jms.TextMessage;

import com.dnastack.dictator.data.Article;
import com.dnastack.dictator.data.CensoredArticle;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "CensorshipService", activationConfig = {
    @ActivationConfigProperty(propertyName = "maxSession", propertyValue = "1"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/queue/ArticleSubmissions"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge") })
@JBossLog
public class CensorshipService implements MessageListener {

    protected Long censorshipDuration;
    protected String appVersion;

    @Inject
    @JMSConnectionFactory("java:/jms/dictator-activemq")
    protected JMSContext jmsContext;

    @Resource(lookup = "java:jboss/jms/queue/PublishedArticles")
    protected Queue publishedArticlesQueue;

    protected void onMessage(String messageJson) {
        log.debugv("Received message:\n{0}", messageJson);
        Article article = ArticleSerializer.deserialize(messageJson);
        CensoredArticle censoredArticle = censor(article);
        MessageUtil msgUtil = new MessageUtil(appVersion, jmsContext, publishedArticlesQueue);
        msgUtil.send(censoredArticle);
    }

    protected CensoredArticle censor(Article article) {
        try {
            Thread.sleep(censorshipDuration);
        } catch (InterruptedException e) {
            log.error("Censor interrupted in sleep", e);
        }
        return new CensoredArticle(
                article.getTitle(),
                article.getContent(),
                LocalDate.now(),
                censorContent(article.getContent()));
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

    @PostConstruct
    public void initService() {
        try {
            censorshipDuration = Long.parseLong(System.getenv(DictatorApplication.CENSORSHIP_DURATION_PROP));
            appVersion = System.getenv(DictatorApplication.VERSION_PROP);
        } catch (Exception e) {
            log.error("Error while initializing", e);
        }
    }
}
