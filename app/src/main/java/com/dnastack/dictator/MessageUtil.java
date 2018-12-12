package com.dnastack.dictator;

import javax.jms.Destination;
import javax.jms.JMSContext;
import javax.jms.JMSException;
import javax.jms.TextMessage;

import com.dnastack.dictator.data.Article;

public class MessageUtil {

    public static void send(JMSContext jmsContext, Destination destination, String appVersion, Article article) {
        try {
            TextMessage message = jmsContext.createTextMessage();
            message.setStringProperty(DictatorApplication.VERSION_PROP, appVersion);
            message.setText(ArticleSerializer.serialize(article));
            jmsContext.createProducer().send(destination, message);
        } catch (JMSException e) {
            throw new RuntimeException("Error while sending", e);
        }
    }

}
