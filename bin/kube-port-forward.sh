#!/bin/bash

source bin/commons.sh

MQ_NAME=dictator-mq-$1
MQ_PORT=${2:-61616}

APP_POD_COUNT=`kubectl get pod -l app=$MQ_NAME -o json | jq '.items | length'`
if [ $APP_POD_COUNT != 1 ]; then
    echo "There are multiple servers with name $MQ_NAME"
    kubectl get pod -l app=$MQ_NAME
    exit 1
fi

APP_POD_NAME=`kubectl get pod -l app=$MQ_NAME -o jsonpath={$.items[0].metadata.name}`

echo "Forwarding $APP_POD_NAME to local port $MQ_PORT ..."

kubectl port-forward $APP_POD_NAME $MQ_PORT:61616

