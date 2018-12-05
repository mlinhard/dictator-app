package com.dnastack.dictator;

import javax.jms.JMSContext;
import javax.jms.JMSException;
import javax.jms.Queue;
import javax.jms.TextMessage;

import com.dnastack.dictator.data.Article;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class MessageUtil {

    private String appVersion;
    private JMSContext jmsContext;
    private Queue queue;

    public void send(Article article) {
        try {
            TextMessage message = jmsContext.createTextMessage();
            message.setStringProperty(DictatorApplication.VERSION_PROP, appVersion);
            message.setText(ArticleSerializer.serialize(article));
            jmsContext.createProducer().send(queue, message);
        } catch (JMSException e) {
            throw new RuntimeException("Error while sending", e);
        }
    }
}
