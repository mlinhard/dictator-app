package com.dnastack.dictator.data;

import java.time.LocalDate;

import org.junit.Assert;
import org.junit.Test;

import com.dnastack.dictator.ArticleSerializer;

public class ArticleSerializationTest {

    @Test
    public void testArticleSerialization() {
        Article article = new Article("We should rise", "Revolution is inevitable.", LocalDate.now());
        String articleJson = ArticleSerializer.serialize(article);
        Article article2 = ArticleSerializer.deserialize(articleJson);
        Assert.assertEquals(article.getTitle(), article2.getTitle());
        Assert.assertEquals(article.getContent(), article2.getContent());
    }

    @Test
    public void testCensoredArticleSerialization() {
        LocalDate now = LocalDate.now();
        CensoredArticle article = new CensoredArticle("We should rise", "Revolution is inevitable.", now, now, "CENSORED");
        String articleJson = ArticleSerializer.serialize(article);
        CensoredArticle article2 = ArticleSerializer.deserializeCensored(articleJson);
        Assert.assertEquals(article.getTitle(), article2.getTitle());
        Assert.assertEquals(article.getContent(), article2.getContent());
        Assert.assertEquals(article.getCheckedAt(), article2.getCheckedAt());
        Assert.assertEquals(article.getCheckResult(), article2.getCheckResult());
    }
}
