package com.dnastack.dictator;

import javax.ws.rs.POST;
import javax.ws.rs.Path;

import com.dnastack.dictator.data.Article;

import lombok.extern.jbosslog.JBossLog;

@Path("/news/article")
@JBossLog
public class NewsRest {

    @POST
    public Article create(Article article) {
        log.infov("Received article:\n{0}", article);
        return article;
    }

}
