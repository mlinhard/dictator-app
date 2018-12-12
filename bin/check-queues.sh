#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD


list_queue() {
    local queue
    address=$1
    queue=$2
    routing=$3
    delivering=$4

    if [ "$delivering" == "d" ]; then
        op="listDeliveringMessagesAsJSON()"
        args="[ ]"
        delivering_print="(deliv.)"
    else
        op="listMessagesAsJSON(java.lang.String)"
        args="[ null ]"
        delivering_print=""
    fi

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=addresses,address=\\\"$address\\\",subcomponent=queues,routing-type=\\\"$routing\\\",queue=\\\"$queue\\\"\",
        \"operation\": \"$op\",
        \"arguments\": $args
    }"
    messages=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.value' -r | jq '.'`
    elements=`echo $messages | jq '.[0].elements'`
    if [ "$elements" != "null" ]; then
        messages=$elements
    fi
    fmt="%40s \e[35m%16s\e[0m \e[35m%16s\e[0m\n"
    if [ "$messages" != "null" ]; then
        current_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION==\"$APP_VERSION\")] | length"`
        different_ver_len=`echo $messages | jq "[.[] | select(.APP_VERSION!=\"$APP_VERSION\")] | length"`
        printf "$fmt" "$delivering_print $address" "$current_ver_len" "$different_ver_len"
    else
        printf "$fmt" "$delivering_print $address" "-" "-"
    fi 
}


MQ="dictator-mq-b"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia


printf "\e[34m%40s\e[0m \e[94m%16s\e[0m %16s\n" $MQ "$APP_VERSION" "Other"

list_queue jms.queue.ArticleSubmissions jms.queue.ArticleSubmissions anycast n
list_queue jms.queue.ArticleSubmissions jms.queue.ArticleSubmissions anycast d
list_queue jms.queue.PublishedArticles jms.queue.PublishedArticles anycast n
list_queue jms.queue.PublishedArticles jms.queue.PublishedArticles anycast d
list_queue jms.topic.CensoredArticles PressMonitoring.PressMonitoringSub multicast n
list_queue jms.topic.CensoredArticles PressMonitoring.PressMonitoringSub multicast d

MQ="dictator-mq-g"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia
printf "\e[32m%40s\e[0m \e[94m%16s\e[0m %16s\n" $MQ "$APP_VERSION" "Other"

list_queue jms.queue.ArticleSubmissions jms.queue.ArticleSubmissions anycast n
list_queue jms.queue.ArticleSubmissions jms.queue.ArticleSubmissions anycast d
list_queue jms.queue.PublishedArticles jms.queue.PublishedArticles anycast n
list_queue jms.queue.PublishedArticles jms.queue.PublishedArticles anycast d
list_queue jms.topic.CensoredArticles PressMonitoring.PressMonitoringSub multicast n
list_queue jms.topic.CensoredArticles PressMonitoring.PressMonitoringSub multicast d




