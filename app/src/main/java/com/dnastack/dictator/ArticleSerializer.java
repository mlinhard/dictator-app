package com.dnastack.dictator;

import javax.json.bind.JsonbBuilder;

import com.dnastack.dictator.data.Article;
import com.dnastack.dictator.data.CensoredArticle;

public class ArticleSerializer {

    public static String serialize(Article article) {
        return JsonbBuilder.create().toJson(article);
    }

    public static Article deserialize(String articleJson) {
        return JsonbBuilder.create().fromJson(articleJson, Article.class);
    }

    public static CensoredArticle deserializeCensored(String articleJson) {
        return JsonbBuilder.create().fromJson(articleJson, CensoredArticle.class);
    }
}
