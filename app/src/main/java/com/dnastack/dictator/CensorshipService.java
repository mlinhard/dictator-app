package com.dnastack.dictator;

import static com.dnastack.dictator.MessageUtil.send;

import java.time.LocalDate;

import javax.annotation.PostConstruct;
import javax.annotation.Resource;
import javax.ejb.ActivationConfigProperty;
import javax.ejb.MessageDriven;
import javax.inject.Inject;
import javax.jms.JMSConnectionFactory;
import javax.jms.JMSContext;
import javax.jms.Queue;
import javax.jms.Topic;

import org.jboss.logging.Logger;

import com.dnastack.dictator.data.Article;
import com.dnastack.dictator.data.CensoredArticle;

import lombok.extern.jbosslog.JBossLog;

@MessageDriven(name = "CensorshipService", activationConfig = {
    @ActivationConfigProperty(propertyName = "maxSession", propertyValue = "1"),
    @ActivationConfigProperty(propertyName = "destinationLookup", propertyValue = "java:jboss/jms/queue/ArticleSubmissions"),
    @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue"),
    @ActivationConfigProperty(propertyName = "acknowledgeMode", propertyValue = "Auto-acknowledge"),
    @ActivationConfigProperty(propertyName = "clientId", propertyValue = "Censorship")})
@JBossLog
public class CensorshipService extends DelayedMessageListener {

    protected String appVersion;

    @Inject
    @JMSConnectionFactory("java:/jms/dictator-activemq")
    protected JMSContext jmsContext;

    @Resource(lookup = "java:jboss/jms/queue/PublishedArticles")
    protected Queue publishedArticlesQueue;

    @Resource(lookup = "java:jboss/jms/topic/CensoredArticles")
    protected Topic censoredArticlesTopic;

    protected void onMessage(String messageJson) {
        log.infov("Processing message version {0}", appVersion);
        Article article = ArticleSerializer.deserialize(messageJson);
        CensoredArticle censoredArticle = censor(article);
        if ("OK".equals(censoredArticle.getCheckResult())) {
            send(jmsContext, publishedArticlesQueue, appVersion, censoredArticle);
        } else {
            send(jmsContext, censoredArticlesTopic, appVersion, censoredArticle);
        }
    }

    protected CensoredArticle censor(Article article) {
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
    protected Logger getLog() {
        return log;
    }

    @Override
    protected Long getDelay() {
        return Long.parseLong(System.getenv(DictatorApplication.CENSORSHIP_DURATION_PROP));
    }

    @PostConstruct
    public void initService() {
        try {
            appVersion = System.getenv(DictatorApplication.VERSION_PROP);
        } catch (Exception e) {
            log.error("Error while initializing", e);
        }
    }
}
