#!/bin/bash

app_version=`git describe --tags`

rm -rf docker/target
mkdir docker/target
cp app/target/dictator-app-${app_version}.war docker/target/dictator-app.war

image_tag=docker.io/mlinhard/dictator-app:${app_version}

pushd docker
docker build -t ${image_tag} .
popd

echo "Built image: ${image_tag}"



