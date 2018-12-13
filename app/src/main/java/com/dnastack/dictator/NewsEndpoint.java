package com.dnastack.dictator;

import static com.dnastack.dictator.MessageUtil.send;

import java.time.LocalDate;

import javax.annotation.Resource;
import javax.inject.Inject;
import javax.jms.JMSConnectionFactory;
import javax.jms.JMSContext;
import javax.jms.Queue;
import javax.json.bind.JsonbBuilder;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Configuration;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;

import com.dnastack.dictator.data.Article;

import lombok.extern.jbosslog.JBossLog;

@Path("/news/article")
@JBossLog
public class NewsEndpoint {

    @Inject
    @JMSConnectionFactory("java:/jms/dictator-activemq")
    protected JMSContext jmsContext;

    @Resource(lookup = "java:jboss/jms/queue/ArticleSubmissions")
    private Queue articleSubmissionsQueue;

    @Context
    private Configuration configuration;

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response create(Article article) {
        try {
            String articleJson = JsonbBuilder.create().toJson(article);
            log.debugv("Received article:\n{0}", articleJson);
            if (article.getDatePosted() == null) {
                article.setDatePosted(LocalDate.now());
            }
            send(jmsContext, articleSubmissionsQueue, getVersion(), article);
            return Response.accepted().build();
        } catch (Exception e) {
            log.error("Exception occured during article posting", e);
            throw e;
        }
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Article healthCheck() {
        return new Article("Dictator App version " + getVersion(), "Our dictator is awesome.", null);
    }

    private String getVersion() {
        return (String) configuration.getProperty("APP_VERSION");
    }

}
