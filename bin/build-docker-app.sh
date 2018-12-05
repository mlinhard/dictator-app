#!/bin/bash

source bin/commons.sh

image_tag=${GCR_PREFIX}/dictator-app:${APP_VERSION}

pushd app
mvn versions:set -DnewVersion=${APP_VERSION}
mvn clean package -DskipTests
mvn versions:revert
popd

rm -rf docker/target
mkdir docker/target
cp app/target/dictator-app-${APP_VERSION}.war docker/target/dictator-app.war

pushd docker
docker build -t ${image_tag} .
popd

docker push ${image_tag}

echo "Built and pushed image: ${image_tag}"




