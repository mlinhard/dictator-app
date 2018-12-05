#!/bin/bash

source bin/commons.sh

# reset possibly changed descriptors
git checkout kube/*.yml

MQ_NAME="dictator-mq-b"
MQ_NAME_OTHER="dictator-mq-g"

replace_env_kube APP_VERSION ${APP_VERSION}
replace_env_kube MQ_NAME ${MQ_NAME}
replace_env_kube MQ_NAME_OTHER ${MQ_NAME_OTHER}
replace_env_kube APP_DOMAIN ${APP_DOMAIN}
replace_env_kube GOOGLE_PROJECT ${GOOGLE_PROJECT}
replace_env_kube GCR_PREFIX ${GCR_PREFIX}
replace_env_kube SERVICE_NAME dictator-app

kubectl apply -f kube/app-deployment.yml
kubectl apply -f kube/app-service.yml

# Re-apply dictator-app-candidate service
git checkout kube/app-service.yml
replace_env SERVICE_NAME dictator-app-candidate kube/app-service.yml
replace_env APP_VERSION ${APP_VERSION} kube/app-service.yml
kubectl apply -f kube/app-service.yml

kubectl apply -f kube/ingress.yml

kubectl apply -f kube/mq-pvc.yml
kubectl apply -f kube/mq-deployment.yml
kubectl apply -f kube/mq-service.yml

# switch B/G roles
git checkout kube/*.yml

MQ_NAME="dictator-mq-g"
MQ_NAME_OTHER="dictator-mq-b"

replace_env_kube APP_VERSION ${APP_VERSION}
replace_env_kube MQ_NAME ${MQ_NAME}
replace_env_kube MQ_NAME_OTHER ${MQ_NAME_OTHER}
replace_env_kube APP_DOMAIN ${APP_DOMAIN}
replace_env_kube GOOGLE_PROJECT ${GOOGLE_PROJECT}
replace_env_kube GCR_PREFIX ${GCR_PREFIX}

kubectl apply -f kube/mq-pvc.yml
kubectl apply -f kube/mq-deployment.yml
kubectl apply -f kube/mq-service.yml

# reset possibly changed descriptors
git checkout kube/*.yml

