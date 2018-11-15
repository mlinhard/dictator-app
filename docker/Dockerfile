FROM jboss/wildfly:14.0.1.Final

ADD wildfly-addons.cli /opt/dictator/addons.cli
ADD wildfly-boot.sh /opt/dictator/boot.sh

RUN CFG_DIR=/opt/jboss/wildfly/standalone/configuration ; \
    mv $CFG_DIR/standalone-full.xml $CFG_DIR/standalone.xml

USER root
RUN chown -R jboss:jboss /opt/dictator
USER jboss

ADD target/dictator-app.war /opt/jboss/wildfly/standalone/deployments

ENTRYPOINT /opt/dictator/boot.sh
