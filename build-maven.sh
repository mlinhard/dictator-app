#!/bin/bash

app_version=`git describe --tags`

pushd app
mvn versions:set -DnewVersion=${app_version}
mvn clean package -DskipTests
mvn versions:revert
popd


