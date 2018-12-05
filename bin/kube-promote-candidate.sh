#!/bin/bash

source bin/commons.sh

OLD_VERSION=`kubectl get svc dictator-app -o json | jq '.spec.selector.version' -r`
NEW_VERSION=`kubectl get svc dictator-app-candidate -o json | jq '.spec.selector.version' -r`

count=`kubectl get pod -l app=dictator-app,version=$OLD_VERSION -o json | jq '.items | length'`
if [ $count != 1 ]; then
    echo "There are multiple dictator app pods version $OLD_VERSION"
    kubectl get pod -l app=dictator-app,version=$OLD_VERSION
    exit 1
fi
OLD_APP_POD_NAME=`kubectl get pod -l app=dictator-app,version=$OLD_VERSION -o jsonpath={$.items[0].metadata.name}`

count=`kubectl get pod -l app=dictator-app,version=$NEW_VERSION -o json | jq '.items | length'`
if [ $count != 1 ]; then
    echo "There are multiple dictator app pods version $NEW_VERSION"
    kubectl get pod -l app=dictator-app,version=$NEW_VERSION
    exit 1
fi
NEW_APP_POD_NAME=`kubectl get pod -l app=dictator-app,version=$NEW_VERSION -o jsonpath={$.items[0].metadata.name}`


echo "Promoting candidate version $NEW_VERSION to production"
echo "(previous version was $OLD_VERSION)"
echo ""
echo "Old pod: $OLD_APP_POD_NAME"
echo "New pod: $NEW_APP_POD_NAME"
echo ""
echo "Switching service dictator-app to $NEW_APP_POD_NAME ..."

# reset possibly changed descriptors
git checkout kube/*.yml

replace_env_kube APP_VERSION ${NEW_VERSION}
replace_env_kube SERVICE_NAME dictator-app

kubectl apply -f kube/app-service.yml

git checkout kube/*.yml

echo "Deleting old $OLD_VERSION deployment ..."

kubectl delete all -l app=dictator-app,version=$OLD_VERSION

