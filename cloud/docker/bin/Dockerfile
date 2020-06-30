#
# BusinessEvents Dockerfile
#
ARG BE_PRODUCT_VERSION
ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG AS_VERSION
ARG JRE_VERSION
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME
ARG AS_SHORT_VERSION
ARG FTL_VERSION
ARG FTL_SHORT_VERSION
ARG AS4X_VERSION
ARG AS4X_SHORT_VERSION

FROM ubuntu:20.10 as intermediate

ARG BE_PRODUCT_VERSION
ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG BE_PRODUCT_EDITION
ARG BE_PRODUCT_TARGET_DIR
ARG BE_PRODUCT_ADDONS
ARG BE_PRODUCT_HOTFIX
ARG AS_PRODUCT_HOTFIX
ARG AS_VERSION
ARG FTL_VERSION
ARG FTL_SHORT_VERSION
ARG FTL_PRODUCT_HOTFIX
ARG AS4X_VERSION
ARG AS4X_SHORT_VERSION
ARG AS4X_PRODUCT_HOTFIX
ARG DOCKERFILE_NAME
ARG JRE_VERSION
ARG TEMP_FOLDER
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME
ARG AS_SHORT_VERSION
ARG GVPROVIDERS

LABEL be-intermediate-image=true

RUN apt-get update \
 && apt-get install -y unzip procps findutils

COPY lib/*.pm lib/*.py lib/*.sh installers/* lib/run /home/tibco/be/
COPY gvproviders /home/tibco/be/gvproviders

ENV TIBCO_HOME=/opt/tibco \
 BE_HOME=/opt/tibco/be/${BE_SHORT_VERSION} \
 JRE_VERSION=${JRE_VERSION} \
 JRE_HOME=/opt/tibco/tibcojre64/${JRE_VERSION} \
 AS_VERSION=${AS_VERSION} \
 BE_PRODUCT_VERSION=${BE_PRODUCT_VERSION}

WORKDIR /home/tibco/be
RUN chmod +x *.sh *.pm
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_ftl('$FTL_VERSION','$FTL_PRODUCT_HOTFIX')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_as4x('$AS4X_VERSION','$AS4X_PRODUCT_HOTFIX')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_be('$BE_PRODUCT_VERSION','enterprise','$BE_PRODUCT_ADDONS','$BE_PRODUCT_HOTFIX','$AS_PRODUCT_HOTFIX','$AS_VERSION')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::replaceRunbeVersionToken('$BE_PRODUCT_VERSION','./run')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::generateAnnotationIndexes('/opt/tibco/be/${BE_SHORT_VERSION}', '/opt/tibco/tibcojre64/${JRE_VERSION}')" \
 && rm -rf as_installers be_installers ftl_installers ftl_installers_hf as4x_installers as4x_installers_hf *.zip \
 && find . -regex "./Dockerfile.*" ! -name '$DOCKERFILE_NAME' -delete

WORKDIR /opt/tibco/be/$BE_SHORT_VERSION/bin/
RUN echo \ >> be-engine.tra \
 && echo "java.property.be.engine.cluster.as.discover.url=%AS_DISCOVER_URL%" >> be-engine.tra  \
 && echo "java.property.be.engine.cluster.as.listen.url=%AS_LISTEN_URL%" >> be-engine.tra \
 && echo "java.property.be.engine.cluster.as.remote.listen.url=%AS_REMOTE_LISTEN_URL%" >> be-engine.tra \
 && echo "java.property.com.sun.management.jmxremote.rmi.port=%jmx_port%" >> be-engine.tra

#set ftl home in tra file
RUN sed -i "s@tibco.env.FTL_HOME=@tibco.env.FTL_HOME=/opt/tibco/ftl/$FTL_SHORT_VERSION@g" be-engine.tra

#set as4x home in tra file
RUN sed -i "s@tibco.env.ACTIVESPACES_HOME=@tibco.env.ACTIVESPACES_HOME=/opt/tibco/as/$AS4X_SHORT_VERSION@g" be-engine.tra

# Setup gv providers
RUN chmod +x /home/tibco/be/gvproviders/*.sh && /home/tibco/be/gvproviders/setup.sh ${GVPROVIDERS}

# Cleanup.
RUN mkdir -p /opt/tibco/as/${AS_SHORT_VERSION}/ \
    && mkdir -p /opt/tibco/as/${AS_SHORT_VERSION}/bin \
    && mkdir -p /opt/tibco/as/${AS_SHORT_VERSION}/lib \
    && mkdir -p /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib \
    && mkdir -p /opt/tibco/as/${AS4X_SHORT_VERSION}/lib \
    && rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/gwt \
    && rm -rf /opt/tibco/be/${BE_SHORT_VERSION}/lib/ext/tpcl/tomsawyer

#Discard intermediate image and just copy the installation to a new image.
FROM ubuntu:20.10

ARG BE_PRODUCT_VERSION
ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG AS_VERSION
ARG AS_SHORT_VERSION
ARG JRE_VERSION
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME
ARG FTL_VERSION
ARG FTL_SHORT_VERSION
ARG AS4X_VERSION
ARG AS4X_SHORT_VERSION

COPY app/${CDD_FILE_NAME} /opt/tibco/be/application/
COPY app/${EAR_FILE_NAME} /opt/tibco/be/application/ear/
COPY app/* /opt/tibco/be/ext/

COPY --from=intermediate /home/tibco/be /home/tibco/be

# copy jre
COPY --from=intermediate /opt/tibco/tibcojre64/${JRE_VERSION} /opt/tibco/tibcojre64/${JRE_VERSION}
# copy be related files
COPY --from=intermediate /opt/tibco/be/${BE_SHORT_VERSION}/bin/be-engine* /opt/tibco/be/${BE_SHORT_VERSION}/bin/
COPY --from=intermediate /opt/tibco/be/${BE_SHORT_VERSION}/bin/*.idx /opt/tibco/be/${BE_SHORT_VERSION}/bin/
COPY --from=intermediate /opt/tibco/be/${BE_SHORT_VERSION}/lib /opt/tibco/be/${BE_SHORT_VERSION}/lib
# copy as2 related files
COPY --from=intermediate /opt/tibco/as/${AS_SHORT_VERSION}/bin /opt/tibco/as/${AS_SHORT_VERSION}/bin
COPY --from=intermediate /opt/tibco/as/${AS_SHORT_VERSION}/lib /opt/tibco/as/${AS_SHORT_VERSION}/lib
# copy ftl related files
COPY --from=intermediate /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib /opt/tibco/ftl/${FTL_SHORT_VERSION}/lib
# copy as4x related files
COPY --from=intermediate /opt/tibco/as/${AS4X_SHORT_VERSION}/lib /opt/tibco/as/${AS4X_SHORT_VERSION}/lib

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
