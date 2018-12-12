#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

if [ "$1" == "b" ]; then
    echo -e "Destroying bridge \e[34mdictator-mq-b\e[0m -> \e[32mdictator-mq-g\e[0m ..."
elif [ "$1" == "g" ]; then
    echo -e "Destroying bridge \e[32mdictator-mq-g\e[0m -> \e[34mdictator-mq-b\e[0m ..."
else
    echo -e "Please enter which bridge to destroy \e[34mb\e[0m or \e[32mg\e[0m"
    exit 1
fi

MQ="dictator-mq-$1"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia

destroy_bridge_for_queue() {

    BRIDGE_NAME="\"blue-green-bridge-$1\""

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\"\",
        \"operation\": \"destroyBridge(java.lang.String)\",
        \"arguments\": [ $BRIDGE_NAME ]
    }"

    result=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.'`
    status=`echo $result | jq '.status'`
    if [ "$status" == "200" ]; then
        echo "Bridge for queue $1 destroyed"
    else
        echo $result
    fi

}

destroy_bridge_for_queue "ArticleSubmissions"
destroy_bridge_for_queue "PublishedArticles"
destroy_bridge_for_queue "CensoredArticles"


