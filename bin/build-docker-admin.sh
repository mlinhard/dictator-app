#!/bin/bash

source bin/commons.sh

pushd app
mvn versions:set -DnewVersion=${APP_VERSION}
mvn clean package -DskipTests -P admin
mvn versions:revert
popd


echo "Built MQ Admin version ${APP_VERSION}"




