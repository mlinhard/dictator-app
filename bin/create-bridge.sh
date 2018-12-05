#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

if [ "$1" == "b" ]; then
    echo -e "Creating bridge \e[34mdictator-mq-b\e[0m -> \e[32mdictator-mq-g\e[0m ..."
elif [ "$1" == "g" ]; then
    echo -e "Creating bridge \e[32mdictator-mq-g\e[0m -> \e[34mdictator-mq-b\e[0m ..."
else
    echo -e "Please enter which bridge to create \e[34mb\e[0m or \e[32mg\e[0m"
    exit 1
fi

MQ="dictator-mq-$1"
MQ_POD=`get_pod_name "$MQ" "-"`
MQ_REST=http://$MQ.$APP_DOMAIN/console/jolokia

create_bridge_for_queue() {
    BRIDGE_NAME="\"blue-green-bridge-$1\""
    BRIDGE_QUEUE="\"jms.queue.$1\""
    BRIDGE_FORWARDING_ADDRESS=null
    BRIDGE_FILTER_STRING=null
    BRIDGE_TRANSFORMER_CLASS=null
    BRIDGE_TRANSFORMER_PROPERTIES=null
    BRIDGE_RETRY_INTERVAL=10000
    BRIDGE_RETRY_INTERVAL_MULTIPLIER=10
    BRIDGE_INITIAL_CONNECT_ATTEMPTS=-1
    BRIDGE_RECONNECT_ATTEMPTS=-1
    BRIDGE_USE_DUPLICATE_DETECTION=true
    BRIDGE_CONFIRMATION_WINDOW_SIZE=100
    BRIDGE_PRODUCER_WINDOW_SIZE=100
    BRIDGE_CLIENT_FAILURE_CHECK_PERIOD=15000
    BRIDGE_STATIC_CONNECTOR_NAMES="\"blue-green-bridge\""
    BRIDGE_USE_DISCOVERY_GROUP=false
    BRIDGE_HA=false
    BRIDGE_USER="\"$ARTEMIS_USERNAME\""
    BRIDGE_PASSWORD="\"$ARTEMIS_PASSWORD\""

    OPERATION_JSON="{
        \"type\": \"exec\",
        \"mbean\": \"org.apache.activemq.artemis:broker=\\\"$MQ_POD\\\"\",
        \"operation\": \"createBridge(java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,java.lang.String,long,double,int,int,boolean,int,int,long,java.lang.String,boolean,boolean,java.lang.String,java.lang.String)\",
        \"arguments\": [
            $BRIDGE_NAME,
            $BRIDGE_QUEUE,
            $BRIDGE_FORWARDING_ADDRESS,
            $BRIDGE_FILTER_STRING,
            $BRIDGE_TRANSFORMER_CLASS,
            $BRIDGE_TRANSFORMER_PROPERTIES,
            $BRIDGE_RETRY_INTERVAL,
            $BRIDGE_RETRY_INTERVAL_MULTIPLIER,
            $BRIDGE_INITIAL_CONNECT_ATTEMPTS,
            $BRIDGE_RECONNECT_ATTEMPTS,
            $BRIDGE_USE_DUPLICATE_DETECTION,
            $BRIDGE_CONFIRMATION_WINDOW_SIZE,
            $BRIDGE_PRODUCER_WINDOW_SIZE,
            $BRIDGE_CLIENT_FAILURE_CHECK_PERIOD,
            $BRIDGE_STATIC_CONNECTOR_NAMES,
            $BRIDGE_USE_DISCOVERY_GROUP,
            $BRIDGE_HA,
            $BRIDGE_USER,
            $BRIDGE_PASSWORD
        ]
    }"

    result=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_REST" -d "$OPERATION_JSON" | jq '.'`
    status=`echo $result | jq '.status'`
    if [ "$status" == "200" ]; then
        echo "Bridge for queue $1 created"
    else
        echo $result
    fi
}

create_bridge_for_queue "ArticleSubmissions"
create_bridge_for_queue "PublishedArticles"


