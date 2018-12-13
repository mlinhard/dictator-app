#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD


usage() {
    echo -e "USAGE bin/logs.sh {\e[34mb\e[0m|\e[32mg\e[0m|a|c} - show logs for"
    echo "      b - Blue MQ"
    echo "      g - Green MQ"
    echo "      a - App"
    echo "      c - App candidate"
}

if [ "$1" == "b" ]; then
    service_name="dictator-mq-b"
    app_name=$service_name
elif [ "$1" == "g" ]; then
    service_name="dictator-mq-g"
    app_name=$service_name
elif [ "$1" == "a" ]; then
    service_name="dictator-app"
    app_name="dictator-app"
elif [ "$1" == "c" ]; then
    service_name="dictator-app-candidate"
    app_name="dictator-app"
else
    usage
    exit 1
fi


version=`kubectl get svc $service_name -o json | jq '.spec.selector.version' -r`
pod_name=`get_pod_name $app_name "$version"`

kubectl logs -f $pod_name
