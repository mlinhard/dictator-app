#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

APP_PORT=${1:-8080}
ARTEMIS_HOST=${2:-localhost}
ARTEMIS_PORT=${3:-61616}
CENSORSHIP_DURATION=${CENSORSHIP_DURATION:-3000}

echo "Running Dictator app on localhost:${1}, connected to ${2}:${3}"

docker run -it -p ${APP_PORT}:8080 --network bridge \
    -e ACTIVEMQ_HOST=${ARTEMIS_HOST} \
    -e ACTIVEMQ_PORT=${ARTEMIS_PORT} \
    -e ACTIVEMQ_USER=${ARTEMIS_USERNAME} \
    -e ACTIVEMQ_PASSWORD=${ARTEMIS_PASSWORD} \
    -e CENSORSHIP_DURATION=${CENSORSHIP_DURATION} \
    ${GCR_PREFIX}/dictator-app:${APP_VERSION}
