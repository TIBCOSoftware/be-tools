
#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#
#
# BusinessEvents Dockerfile
#
ARG BE_PRODUCT_VERSION
ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG AS_VERSION
ARG JRE_VERSION
ARG OPEN_JDK_FILENAME
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME
ARG AS_SHORT_VERSION
ARG FTL_VERSION
ARG FTL_SHORT_VERSION
ARG ACTIVESPACES_VERSION
ARG ACTIVESPACES_SHORT_VERSION

FROM docker.io/library/ubuntu:20.04 as intermediate

ARG BE_PRODUCT_VERSION
ARG BE_SHORT_VERSION
ARG BE_PRODUCT_IMAGE_VERSION
ARG BE_PRODUCT_ADDONS
ARG BE_PRODUCT_HOTFIX
ARG AS_PRODUCT_HOTFIX
ARG AS_VERSION
ARG FTL_VERSION
ARG FTL_SHORT_VERSION
ARG FTL_PRODUCT_HOTFIX
ARG ACTIVESPACES_VERSION
ARG ACTIVESPACES_SHORT_VERSION
ARG ACTIVESPACES_PRODUCT_HOTFIX
ARG HAWK_VERSION
ARG HAWK_SHORT_VERSION
ARG HAWK_PRODUCT_HOTFIX
ARG JRE_VERSION
ARG OPEN_JDK_FILENAME
ARG CDD_FILE_NAME
ARG EAR_FILE_NAME
ARG AS_SHORT_VERSION

LABEL be-intermediate-image=true

RUN apt-get update \
 && apt-get install -y unzip procps findutils tar

COPY lib/*.pm lib/*.py lib/*.sh installers/* lib/run lib/deletelist.txt /home/tibco/be/
COPY configproviders /home/tibco/be/configproviders
COPY app/* /opt/tibco/be/ext/

ENV TIBCO_HOME=/opt/tibco \
 BE_HOME=/opt/tibco/be/${BE_SHORT_VERSION} \
 JRE_VERSION=${JRE_VERSION} \
 AS_VERSION=${AS_VERSION} \
 BE_PRODUCT_VERSION=${BE_PRODUCT_VERSION}

WORKDIR /home/tibco/be
RUN chmod +x *.sh *.pm run
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_hawk('$HAWK_VERSION','$HAWK_PRODUCT_HOTFIX')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_ftl('$FTL_VERSION','$FTL_PRODUCT_HOTFIX')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_activespaces('$ACTIVESPACES_VERSION','$ACTIVESPACES_PRODUCT_HOTFIX')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_be('$BE_PRODUCT_VERSION','enterprise','$BE_PRODUCT_ADDONS','$BE_PRODUCT_HOTFIX','$AS_PRODUCT_HOTFIX','$AS_VERSION')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::replaceRunbeVersionToken('$BE_PRODUCT_VERSION','./run')"
RUN perl -I. -Mbe_docker_install -e "be_docker_install::generateAnnotationIndexes('/opt/tibco/be/${BE_SHORT_VERSION}', '/opt/tibco/tibcojre64/${JRE_VERSION}')" \
 && rm -rf as_installers as_installers-hf be_installers ftl_installers ftl_installers_hf hawk_installer hawk_installer-hf activespaces_installers activespaces_installers_hf *.zip
RUN ./prepare_finalimage.sh

RUN chgrp -R 0 /tibco_home && chmod -R g=u /tibco_home \
    && chgrp -R 0 /home/tibco && chmod -R g=u /home/tibco

RUN mkdir -p /mnt/tibco/be/logs \
 && mkdir -p /mnt/tibco/be/data-store \
 && chgrp -R 0 /mnt/tibco/ \
 && chmod -R g=u /mnt/tibco/

#Discard intermediate image and just copy the installation to a new image.
FROM docker.io/library/ubuntu:20.04

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
ARG ACTIVESPACES_VERSION
ARG ACTIVESPACES_SHORT_VERSION
ARG GVPROVIDER
ARG DEBIAN_FRONTEND=noninteractive

COPY --from=intermediate /home/tibco /home/tibco

COPY --from=intermediate /tibco_home /opt/tibco

COPY --from=intermediate /mnt/tibco /mnt/tibco

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
 BE_PRODUCT_VERSION=${BE_PRODUCT_VERSION} \
 CDD_FILE=/opt/tibco/be/application/${CDD_FILE_NAME} \
 EAR_FILE=/opt/tibco/be/application/ear/${EAR_FILE_NAME} \
 JAVA_TOOL_OPTIONS="-Dfile.encoding=UTF8"

# Setup gv providers
RUN chmod +x /home/tibco/be/configproviders/*.sh && /home/tibco/be/configproviders/setup.sh ${GVPROVIDER}

RUN ln -s /opt/tibco/be/${BE_SHORT_VERSION} /opt/tibco/be/latest

#Logs, data-store and RMS volumes
VOLUME /mnt/tibco/be/logs \
 /mnt/tibco/be/data-store

# These will always be the listen port for AS and AS Remote URL #5555 for JMX port
EXPOSE 50000 50001 5555

WORKDIR /home/tibco/be
CMD ["./run"]
