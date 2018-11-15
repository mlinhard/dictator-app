#!/bin/bash

app_version=`git describe --tags`

pushd app
mvn versions:set -DnewVersion=${app_version}
mvn clean package -DskipTests
mvn versions:revert
popd

rm -rf docker/target
mkdir docker/target
mv app/target/dictator-app-${app_version}.war docker/target/dictator-app.war

pushd docker
docker build -t docker.io/mlinhard/dictator-app:${app_version} .
popd


