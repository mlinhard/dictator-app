#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD


get_bridge() {
    local queue
    local bridge
    queue=$1
    bridge=$2

    OPERATION_JSON="{
        \"type\": \"read\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=bridges,name=\\\"$bridge\\\"\",
        \"attribute\": \"Name\"
    }"
    value=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.value' -r`
    if [ "$value" != "null" ]; then
        printf "%30s \e[1m\e[33m%16s\e[0m\n" $queue "ENABLED"
    else
        printf "%30s \e[37m%16s\e[0m\n" $queue "DISABLED"
    fi 
}


MQ="dictator-mq-b"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia


printf "\e[34m%30s\e[0m %16s\n" $MQ "Status"

get_bridge ArticleSubmissions "blue-green-bridge-ArticleSubmissions"
get_bridge PublishedArticles "blue-green-bridge-PublishedArticles"
get_bridge CensoredArticles "blue-green-bridge-CensoredArticles"

MQ="dictator-mq-g"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia
printf "\e[32m%30s\e[0m %16s\n" $MQ "Status"

get_bridge ArticleSubmissions "blue-green-bridge-ArticleSubmissions"
get_bridge PublishedArticles "blue-green-bridge-PublishedArticles"
get_bridge CensoredArticles "blue-green-bridge-CensoredArticles"




