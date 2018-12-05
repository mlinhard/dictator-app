#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

OLD_VERSION=`kubectl get svc dictator-app -o json | jq '.spec.selector.version' -r`
NEW_VERSION=`kubectl get svc dictator-app-candidate -o json | jq '.spec.selector.version' -r`

OLD_APP_POD_NAME=`get_pod_name "dictator-app" "$OLD_VERSION"`
OLD_POD_MQ=`kubectl get pod $OLD_APP_POD_NAME -o json | jq '.spec.containers[0].env[] | select(.name=="ACTIVEMQ_HOST").value' -r`

if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    NEW_APP_POD_NAME=`get_pod_name "dictator-app" "$NEW_VERSION"`
    NEW_POD_MQ=`kubectl get pod $NEW_APP_POD_NAME -o json | jq '.spec.containers[0].env[] | select(.name=="ACTIVEMQ_HOST").value' -r`
fi

MQ_B="dictator-mq-b"
MQ_G="dictator-mq-g"
MQ_B_POD=`get_pod_name "$MQ_B" "-"`
MQ_G_POD=`get_pod_name "$MQ_G" "-"`

MQ_B_REST=http://$MQ_B.$APP_DOMAIN/console/jolokia
MQ_G_REST=http://$MQ_G.$APP_DOMAIN/console/jolokia

MQ_B_CONN_TO=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_B_REST/read/org.apache.activemq.artemis:broker=%22$MQ_B_POD%22/Connectors" | jq '.value[0][2].host' -r`
MQ_G_CONN_TO=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_G_REST/read/org.apache.activemq.artemis:broker=%22$MQ_G_POD%22/Connectors" | jq '.value[0][2].host' -r`

BridgeName="blue-green-bridge-ArticleSubmissions"
BridgeStatus=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_B_REST/read/org.apache.activemq.artemis:broker=%22$MQ_B_POD%22,component=bridges,name=%22$BridgeName%22/Name" | jq '.status'`
if [ "$BridgeStatus" == "200" ]; then
    MQ_B_BRIDGE_STATUS="\e[1m\e[33mENABLED\e[0m"
else
    MQ_B_BRIDGE_STATUS="DISABLED"
fi
BridgeStatus=`curl -s -u "$ARTEMIS_USERNAME:$ARTEMIS_PASSWORD" "$MQ_G_REST/read/org.apache.activemq.artemis:broker=%22$MQ_G_POD%22,component=bridges,name=%22$BridgeName%22/Name" | jq '.status'`
if [ "$BridgeStatus" == "200" ]; then
    MQ_G_BRIDGE_STATUS="\e[1m\e[33mENABLED\e[0m"
else
    MQ_G_BRIDGE_STATUS="DISABLED"
fi


echo "--------------------------------------"
echo -e "\e[1mProduction\e[0m:"
echo "    Pod: $OLD_APP_POD_NAME"
echo "Version: $OLD_VERSION"
echo "     MQ: $OLD_POD_MQ"
echo "--------------------------------------"
if [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    echo -e "\e[1mCandidate\e[0m:"
    echo "    Pod: $NEW_APP_POD_NAME"
    echo "Version: $NEW_VERSION"
    echo "     MQ: $NEW_POD_MQ"
    echo "--------------------------------------"
fi
echo -e "\e[34mBlue MQ\e[0m:"
echo "   Name: $MQ_B"
echo "    Pod: $MQ_B_POD"
echo -e " Bridge: $MQ_B -> $MQ_B_CONN_TO [$MQ_B_BRIDGE_STATUS]"
echo "--------------------------------------"
echo -e "\e[32mGreen MQ\e[0m:"
echo "   Name: $MQ_G"
echo "    Pod: $MQ_G_POD"
echo -e " Bridge: $MQ_G -> $MQ_G_CONN_TO [$MQ_G_BRIDGE_STATUS]"
echo "--------------------------------------"

