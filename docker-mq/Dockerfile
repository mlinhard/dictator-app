FROM vromero/activemq-artemis:2.4.0

ENV ARTEMIS_USERNAME "dictator"
ENV ARTEMIS_PASSWORD "ourleader"
ENV ARTEMIS_MIN_MEMORY "128M"
ENV ARTEMIS_MAX_MEMORY "128M"

USER root

COPY ["config/overrides/", "/var/lib/artemis/etc-override/"]
COPY ["config/jolokia/jolokia-access.xml","/var/lib/artemis/etc/jolokia-access.xml"]

RUN chown artemis:artemis /var/lib/artemis/etc/jolokia-access.xml ; \
    chown -R artemis:artemis /var/lib/artemis/etc-override

USER artemis
VOLUME ["/var/lib/artemis/data"]
