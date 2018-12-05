#!/bin/bash

source bin/commons.sh

image_tag=${GCR_PREFIX}/dictator-activemq:${APP_VERSION}

pushd docker-mq
docker build -t ${image_tag} .
popd

docker push ${image_tag}

echo "Built and pushed image: ${image_tag}"




