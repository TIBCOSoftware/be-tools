#
# BusinessEvents Dockerfile

ARG BE_PRODUCT_VERSION

FROM com.tibco.be:${BE_PRODUCT_VERSION} as bebase

ARG KINESIS_CHANNEL_FLAG
ARG BE_SHORT_VERSION

RUN if [ "$KINESIS_CHANNEL_FLAG" = "1" ]; then rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/aws; fi

#Discard intermediate image and just copy the installation to a new image.
FROM ubuntu:latest

ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG AS_VERSION
ARG AS_SHORT_VERSION
ARG JRE_VERSION
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME


COPY app/${CDD_FILE_NAME} /opt/tibco/be/application/
COPY app/${EAR_FILE_NAME} /opt/tibco/be/application/ear/
COPY app/* /opt/tibco/be/ext/


COPY --from=bebase /home/tibco/be /home/tibco/be

COPY --from=bebase /opt/tibco/tibcojre64/${JRE_VERSION} /opt/tibco/tibcojre64/${JRE_VERSION}

COPY --from=bebase /opt/tibco/be/${BE_SHORT_VERSION}/bin/be-engine* /opt/tibco/be/${BE_SHORT_VERSION}/bin/
#COPY --from=bebase /opt/tibco/be/${BE_SHORT_VERSION}/bin/_annotations* /opt/tibco/be/${BE_SHORT_VERSION}/bin
RUN rm -f /opt/tibco/be/${BE_SHORT_VERSION}/bin/*.sql
COPY --from=bebase /opt/tibco/be/${BE_SHORT_VERSION}/lib /opt/tibco/be/${BE_SHORT_VERSION}/lib

COPY --from=bebase /opt/tibco/as/${AS_SHORT_VERSION}/bin /opt/tibco/as/${AS_SHORT_VERSION}/bin
COPY --from=bebase /opt/tibco/as/${AS_SHORT_VERSION}/lib /opt/tibco/as/${AS_SHORT_VERSION}/lib

LABEL "TIBCO BusinessEvents Version"=$BE_PRODUCT_VERSION \
      "TIBCO BusinessEvents Docker Image Version"=$BE_PRODUCT_IMAGE_VERSION

ENV PU=default \
 ENGINE_NAME=be-engine \
 LOG_LEVEL=na \
 AS_DISCOVER_URL=self \
 AS_PROXY_NODE=false \
 TIBCO_HOME=/opt/tibco \
 BE_HOME=/opt/tibco/be/${BE_SHORT_VERSION} \
 AS_VERSION=${AS_VERSION} \
 AS_HOME=/opt/tibco/as/${AS_SHORT_VERSION} \
 JRE_VERSION=${JRE_VERSION} \
 JRE_HOME=/opt/tibco/tibcojre64/${JRE_VERSION} \
 BE_PRODUCT_VERSION=${BE_PRODUCT_VERSION} \
 CDD_FILE=/opt/tibco/be/application/${CDD_FILE_NAME} \
 EAR_FILE=/opt/tibco/be/application/ear/${EAR_FILE_NAME}

RUN mkdir -p /mnt/tibco/be/logs \
 && mkdir -p /mnt/tibco/be/data-store

#Logs, data-store and RMS volumes
VOLUME /mnt/tibco/be/logs \
 /mnt/tibco/be/data-store \
 /opt/tibco/be/${BE_SHORT_VERSION}/rms/shared

# These will always be the listen port for AS and AS Remote URL
EXPOSE 50000 50001

# JMX Port
EXPOSE 5555

WORKDIR /home/tibco/be
CMD ["./run"]
