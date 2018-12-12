#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD




list_queue() {
    local queue
    queue=$1
    MQ="dictator-mq-$2"
    MQ_POD=`get_pod_name "$MQ" "-"`
    MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=addresses,address=\\\"$queue\\\",subcomponent=queues,routing-type=\\\"anycast\\\",queue=\\\"$queue\\\"\",
        \"operation\": \"listMessagesAsJSON(java.lang.String)\",
        \"arguments\": [ null ]
    }"
    messages=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.value' -r | jq '.'`
    elements=`echo $messages | jq '.[0].elements'`
    if [ "$elements" != "null" ]; then
        messages=$elements
    fi
    if [ "$messages" != "null" ]; then
        current_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION==\"$APP_VERSION\")] | length"`
        different_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION!=\"$APP_VERSION\")] | length"`
        
        echo -e "    Version \e[94m$APP_VERSION\e[0m messages: \e[35m$current_ver_len\e[0m"
        echo -e "    Other messages: \e[35m$different_ver_len\e[0m"
    else
        echo -e "    \e[35mNo messages\e[0m"
    fi 
    
}

list_delivering_queue() {
    local queue
    queue=$1
    MQ="dictator-mq-$2"
    MQ_POD=`get_pod_name "$MQ" "-"`
    MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=addresses,address=\\\"$queue\\\",subcomponent=queues,routing-type=\\\"anycast\\\",queue=\\\"$queue\\\"\",
        \"operation\": \"listDeliveringMessagesAsJSON()\",
        \"arguments\": [ ]
    }"
    messages=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.value' -r | jq '.'`
    elements=`echo $messages | jq '.[0].elements'`
    if [ "$elements" != "null" ]; then
        messages=$elements
    fi
    if [ "$messages" != "null" ]; then
        current_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION==\"$APP_VERSION\")] | length"`
        different_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION!=\"$APP_VERSION\")] | length"`
        
        echo -e "    Delivering version \e[94m$APP_VERSION\e[0m messages: \e[35m$current_ver_len\e[0m"
        echo -e "    Delivering other messages: \e[35m$different_ver_len\e[0m"
    else
        echo -e "    \e[35mDelivering no messages\e[0m"
    fi 
    
}


echo -e "\e[34mdictator-mq-b\e[0m:"
echo "  ArticleSubmissions"
list_queue jms.queue.ArticleSubmissions b
list_delivering_queue jms.queue.ArticleSubmissions b
echo "  PublishedArticles"
list_queue jms.queue.PublishedArticles b
list_delivering_queue jms.queue.PublishedArticles b

echo -e "\e[32mdictator-mq-g\e[0m"
echo "  ArticleSubmissions"
list_queue jms.queue.ArticleSubmissions g
list_delivering_queue jms.queue.ArticleSubmissions g
echo "  PublishedArticles"
list_queue jms.queue.PublishedArticles g
list_delivering_queue jms.queue.PublishedArticles g



