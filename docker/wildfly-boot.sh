#!/bin/bash

echo "Configuring Dictator WildFly Image"

sed -i "s/\${ACTIVEMQ_USER}/${ACTIVEMQ_USER}/g" /opt/dictator/addons.cli
sed -i "s/\${ACTIVEMQ_HOST}/${ACTIVEMQ_HOST}/g" /opt/dictator/addons.cli
sed -i "s/\${ACTIVEMQ_PORT}/${ACTIVEMQ_PORT}/g" /opt/dictator/addons.cli
sed -i "s/\${ACTIVEMQ_PASSWORD}/${ACTIVEMQ_PASSWORD}/g" /opt/dictator/addons.cli

/opt/jboss/wildfly/bin/jboss-cli.sh --timeout=300000 --file=/opt/dictator/addons.cli

echo "Starting Dictator WildFly Image"

/opt/jboss/wildfly/bin/standalone.sh -b 0.0.0.0
