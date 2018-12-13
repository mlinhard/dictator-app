#!/bin/bash

source bin/commons.sh


if [ "$1" == "b" ]; then
    MQ_PRINT="\e[34mdictator-mq-b\e[0m"
elif [ "$1" == "g" ]; then
    MQ_PRINT="\e[32mdictator-mq-g\e[0m"
else
    echo -e "Please enter which MQ to port-forward \e[34mb\e[0m or \e[32mg\e[0m"
    exit 1
fi


MQ_NAME=dictator-mq-$1
MQ_PORT=${2:-61616}

APP_POD_COUNT=`kubectl get pod -l app=$MQ_NAME -o json | jq '.items | length'`
if [ $APP_POD_COUNT != 1 ]; then
    echo "There are multiple servers with name $MQ_NAME"
    kubectl get pod -l app=$MQ_NAME
    exit 1
fi

APP_POD_NAME=`kubectl get pod -l app=$MQ_NAME -o jsonpath={$.items[0].metadata.name}`

echo -e "Forwarding $MQ_PRINT ($APP_POD_NAME) to local port $MQ_PORT ..."

kubectl port-forward $APP_POD_NAME $MQ_PORT:61616

