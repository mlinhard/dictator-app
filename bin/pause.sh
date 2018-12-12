#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

usage() {
    echo -e "USAGE bin/pause.sh {\e[34mb\e[0m|\e[32mg\e[0m} {submitted|published|censored} {p|r} - pause/resume given address"
    echo -e "      bin/pause.sh {\e[34mb\e[0m|\e[32mg\e[0m} - print address statuses in given mq"
}

get_status() {
    local OPERATION_JSON
    local ROUTING
    local ADDRESS
    local QUEUE
    ROUTING=$1
    ADDRESS=$2
    QUEUE=$3

    OPERATION_JSON="{
        \"type\": \"read\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=addresses,address=\\\"$ADDRESS\\\",subcomponent=queues,routing-type=\\\"$ROUTING\\\",queue=\\\"$QUEUE\\\"\"
        \"attribute\": \"Paused\"
    }"

    result=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.'`
    status=`echo $result | jq '.status'`
    if [ "$status" == "200" ]; then
        echo $result | jq '.value'
    else
        echo "ERROR"
    fi
}

if [ $# != 3 -a $# != 1 ]; then
    usage
    exit 1
fi

if [ "$1" == "b" ]; then
    MQ_PRINT="\e[34mdictator-mq-b\e[0m"
elif [ "$1" == "g" ]; then
    MQ_PRINT="\e[32mdictator-mq-g\e[0m"
else
    usage
    exit 1
fi

if [ "$2" == "submitted" ]; then
    ROUTING="anycast"
    ADDRESS="jms.queue.ArticleSubmissions"
    QUEUE="jms.queue.ArticleSubmissions"
elif [ "$2" == "published" ]; then
    ROUTING="anycast"
    ADDRESS="jms.queue.PublishedArticles"
    QUEUE="jms.queue.PublishedArticles"
elif [ "$2" == "censored" ]; then
    ROUTING="multicast"
    ADDRESS="jms.topic.CensoredArticles"
    QUEUE="PressMonitoring.PressMonitoringSub"
elif [ $# != 1 ]; then
    usage
    exit 1
fi

if [ "$3" == "p" ]; then
    OP="pause"
    OP_PRINT="Pausing"
elif [ "$3" == "r" ]; then
    OP="resume"
    OP_PRINT="Resuming"
else
    OP="check"
fi

MQ="dictator-mq-$1"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia

if [ "$OP" == "check" ]; then
    echo -e "Status of addresses in $MQ_PRINT:"

    echo -e "submitted: \e[35m`get_status anycast jms.queue.ArticleSubmissions jms.queue.ArticleSubmissions`\e[0m"
    echo -e "published: \e[35m`get_status anycast jms.queue.PublishedArticles jms.queue.PublishedArticles`\e[0m"
    echo -e "censored: \e[35m`get_status multicast jms.topic.CensoredArticles PressMonitoring.PressMonitoringSub`\e[0m"
else 
    echo -e "$OP_PRINT $ADDRESS in $MQ_PRINT ..."

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\",component=addresses,address=\\\"$ADDRESS\\\",subcomponent=queues,routing-type=\\\"$ROUTING\\\",queue=\\\"$QUEUE\\\"\"
        \"operation\": \"$OP()\",
        \"arguments\": [ ]
    }"

    result=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.'`
    status=`echo $result | jq '.status'`
    if [ "$status" == "200" ]; then
        echo "Done."
    else
        echo $result
    fi
fi


