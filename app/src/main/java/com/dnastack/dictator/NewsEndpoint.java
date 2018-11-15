package com.dnastack.dictator;

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

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response create(Article article) {
        String articleJson = JsonbBuilder.create().toJson(article);
        log.debugv("Received article:\n{0}", articleJson);
        jmsContext.createProducer().send(articleSubmissionsQueue, articleJson);
        return Response.accepted().build();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Article healthCheck() {
        return new Article("Our dictator is awesome", "Yes, and let me add that he's awesome.");
    }
}
