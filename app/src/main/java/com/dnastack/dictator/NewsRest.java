package com.dnastack.dictator;

import javax.json.bind.JsonbBuilder;
import javax.ws.rs.Consumes;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import com.dnastack.dictator.data.Article;

import lombok.extern.jbosslog.JBossLog;

@Path("/news/article")
@JBossLog
public class NewsRest {

    @POST
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Article create(Article article) {
        log.infov("Received article:\n{0}", JsonbBuilder.create().toJson(article));
        return article;
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Article healthCheck() {
        return new Article("Our dictator is awesome", "Yes, and let me add that he's awesome.");
    }
}
