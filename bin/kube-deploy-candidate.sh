#!/bin/bash

source bin/commons.sh


APP_POD_COUNT=`kubectl get pod -l app=dictator-app -o json | jq '.items | length'`
if [ $APP_POD_COUNT != 1 ]; then
    echo "There are multiple dictator app pods"
    kubectl get pod -l app=dictator-app
    exit 1
fi

APP_POD_NAME=`kubectl get pod -l app=dictator-app -o jsonpath={$.items[0].metadata.name}`
MQ_NAME_OTHER=`kubectl get pod $APP_POD_NAME -o json | jq '.spec.containers[0].env[] | select(.name=="ACTIVEMQ_HOST").value' -r`

if [ "$MQ_NAME_OTHER" = "dictator-mq-g" ]; then
  MQ_NAME="dictator-mq-b"
elif [ "$MQ_NAME_OTHER" = "dictator-mq-b" ]; then
  MQ_NAME="dictator-mq-g"
else
    echo "Unexpected MQ server: $MQ_NAME_OTHER"
    exit 1
fi


echo "Existing pod: $APP_POD_NAME"
echo "uses MQ server: $MQ_NAME_OTHER"
echo "new MQ server: $MQ_NAME"
echo "new version: $APP_VERSION"

# reset possibly changed descriptors
git checkout kube/*.yml

replace_env_kube APP_VERSION ${APP_VERSION}
replace_env_kube MQ_NAME ${MQ_NAME}
replace_env_kube MQ_NAME_OTHER ${MQ_NAME_OTHER}
replace_env_kube APP_DOMAIN ${APP_DOMAIN}
replace_env_kube GOOGLE_PROJECT ${GOOGLE_PROJECT}
replace_env_kube GCR_PREFIX ${GCR_PREFIX}
replace_env_kube SERVICE_NAME dictator-app-candidate

kubectl apply -f kube/app-deployment.yml
kubectl apply -f kube/app-service.yml

git checkout kube/*.yml
