#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

if [ "$1" == "b" ]; then
    echo -e "Updating \e[34mdictator-mq-b\e[0m ..."
    MQ_NAME_OTHER="dictator-mq-g"
elif [ "$1" == "g" ]; then
    echo -e "Updating \e[32mdictator-mq-g\e[0m ..."
    MQ_NAME_OTHER="dictator-mq-b"
else
    echo -e "Please enter which MQ server to update \e[34mb\e[0m or \e[32mg\e[0m"
    exit 1
fi

MQ_NAME="dictator-mq-$1"
MQ_POD=`get_pod_name "$MQ" "-"`

# reset possibly changed descriptors
git checkout kube/*.yml

replace_env_kube APP_VERSION ${APP_VERSION}
replace_env_kube MQ_NAME ${MQ_NAME}
replace_env_kube MQ_NAME_OTHER ${MQ_NAME_OTHER}
replace_env_kube GCR_PREFIX ${GCR_PREFIX}

kubectl apply -f kube/mq-pvc.yml
kubectl apply -f kube/mq-deployment.yml
kubectl apply -f kube/mq-service.yml

# reset possibly changed descriptors
git checkout kube/*.yml

