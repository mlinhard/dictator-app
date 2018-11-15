package com.dnastack.dictator.data;

import org.junit.Assert;
import org.junit.Test;
import javax.json.bind.Jsonb;
import javax.json.bind.JsonbBuilder;

public class ArticleSerializationTest {

    @Test
    public void testArticleSerialization() {
        Article article = new Article("We should rise", "Revolution is inevitable.");
        Jsonb builder = JsonbBuilder.create();
        String articleJson = builder.toJson(article);
        Article article2 = builder.fromJson(articleJson, Article.class);
        Assert.assertEquals(article.getTitle(), article2.getTitle());
        Assert.assertEquals(article.getContent(), article2.getContent());
    }
}
