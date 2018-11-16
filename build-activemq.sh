#!/bin/bash

app_version=`git describe --tags`

image_tag=${image_prefix}dictator-activemq:${app_version}

pushd docker-activemq
docker build -t ${image_tag} .
popd

echo "Built image: ${image_tag}"


