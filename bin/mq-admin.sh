#!/bin/bash

source bin/commons.sh

check_def ARTEMIS_USERNAME
check_def ARTEMIS_PASSWORD

MQ_ADMIN_JAR=app/target/dictator-app-$APP_VERSION.jar


export MQ_ADMIN_HOST=${MQ_ADMIN_HOST:-"localhost"}
export MQ_ADMIN_PORT=${MQ_ADMIN_PORT:-"61616"}
export MQ_ADMIN_USER=${MQ_ADMIN_USER:-$ARTEMIS_USERNAME}
export MQ_ADMIN_PASS=${MQ_ADMIN_PASS:-$ARTEMIS_PASSWORD}

java -jar $MQ_ADMIN_JAR $@
