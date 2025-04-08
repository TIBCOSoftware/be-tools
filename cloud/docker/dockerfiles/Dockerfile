# BusinessEvents Dockerfile

# Define arguments
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

# Use an intermediate image
FROM docker.io/library/ubuntu:24.04 AS intermediate

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
ARG JRESPLMNT_VERSION
ARG JRESPLMNT_PRODUCT_HOTFIX

LABEL be-intermediate-image=true

# Install necessary packages
RUN apt-get update && apt-get install -y unzip procps findutils tar

# Copy necessary files
COPY lib/*.pm lib/*.py lib/*.sh installers/* lib/run lib/deletelist.txt /home/tibco/be/
COPY configproviders /home/tibco/be/configproviders
COPY app/* /opt/tibco/be/ext/

# Set environment variables
ENV TIBCO_HOME=/opt/tibco \
    BE_HOME=/opt/tibco/be/${BE_SHORT_VERSION} \
    JRE_VERSION=${JRE_VERSION} \
    AS_VERSION=${AS_VERSION} \
    BE_PRODUCT_VERSION=${BE_PRODUCT_VERSION}

# Set working directory
WORKDIR /home/tibco/be

# Set permissions
RUN chmod +x *.sh *.pm run

# Install packages
RUN perl -I. -Mbe_docker_install -e "be_docker_install::install_package_with_silentfile('hawk','oihr','$HAWK_VERSION','$HAWK_PRODUCT_HOTFIX')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::install_package_withtar('ftl','$FTL_VERSION','$FTL_PRODUCT_HOTFIX')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::install_package_withtar('as','$ACTIVESPACES_VERSION','$ACTIVESPACES_PRODUCT_HOTFIX')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::install_be('$BE_PRODUCT_VERSION','enterprise','$BE_PRODUCT_ADDONS','$BE_PRODUCT_HOTFIX','$AS_PRODUCT_HOTFIX','$AS_VERSION')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::install_package_with_universal_installer('JRESupplement','jresplmnt','$JRESPLMNT_VERSION','$JRESPLMNT_PRODUCT_HOTFIX')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::replaceRunbeVersionToken('$BE_PRODUCT_VERSION','./run')" \
 && perl -I. -Mbe_docker_install -e "be_docker_install::generateAnnotationIndexes('/opt/tibco/be/${BE_SHORT_VERSION}', '/opt/tibco/tibcojre64/${JRE_VERSION}')" \
 && rm -rf JRESupplement_installers as_installers as_installers-hf be_installers ftl_installers ftl_installers_hf hawk_installer hawk_installer-hf activespaces_installers activespaces_installers_hf *.zip \
 && ./prepare_finalimage.sh

# Set permissions
RUN chgrp -R 0 /tibco_home && chmod -R g=u /tibco_home \
    && chgrp -R 0 /home/tibco && chmod -R g=u /home/tibco

# Create necessary directories
RUN mkdir -p /mnt/tibco/be/logs /mnt/tibco/be/data-store \
    && chgrp -R 0 /mnt/tibco/ && chmod -R g=u /mnt/tibco/

# Discard intermediate image and copy installation to a new image
FROM docker.io/library/ubuntu:24.04 AS final 

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
ARG CONFIGPROVIDER
ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=24.04

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

# Setup Config Providers
RUN chmod +x /home/tibco/be/configproviders/*.sh && /home/tibco/be/configproviders/setup.sh ${CONFIGPROVIDER}

RUN ln -s /opt/tibco/be/${BE_SHORT_VERSION} /opt/tibco/be/latest

#Using chisel library to create a rootfs with necessary files and folders with mentioned chisel package slices
# Setup chisel 
ARG TARGETARCH
ADD https://github.com/canonical/chisel/releases/download/v0.9.1/chisel_v0.9.1_linux_${TARGETARCH}.tar.gz chisel.tar.gz
RUN tar -xvf chisel.tar.gz -C /usr/bin/ \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y ca-certificates

WORKDIR /rootfs
RUN chisel cut --release ubuntu-${UBUNTU_RELEASE} --root /rootfs \
   base-files_base \
   ca-certificates_data \
   libstdc++6_libs \
   bash_bins \
   coreutils_bins \
   perl-base_bins \
   perl-modules-5.38_core \
   gawk_bins \
   grep_bins

FROM scratch

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
ARG CONFIGPROVIDER
ARG DEBIAN_FRONTEND=noninteractive
ARG UBUNTU_RELEASE=24.04

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
	
#Manually copying few folders,commands and libs to the final image 

COPY --from=final /rootfs /
COPY --from=final /home/ /home/
COPY --from=final /opt/ /opt/
COPY --from=final /bin/hostname /bin/
COPY --from=final /usr/bin/awk /usr/bin/awk 
COPY --from=final /lib/x86_64-linux-gnu/libz.so.1 /lib/x86_64-linux-gnu/libz.so.1
COPY --from=final /lib/x86_64-linux-gnu/libpam.so.0 /lib/x86_64-linux-gnu/libpam.so.0
COPY --from=final /lib/x86_64-linux-gnu/libaudit.so.1 /lib/x86_64-linux-gnu/libaudit.so.1
COPY --from=final /lib/x86_64-linux-gnu/libcap-ng.so.0 /lib/x86_64-linux-gnu/libcap-ng.so.0


# Logs, data-store, and RMS volumes
VOLUME /mnt/tibco/be/logs /mnt/tibco/be/data-store

# Expose ports
EXPOSE 50000 50001 5555

WORKDIR /home/tibco/be
CMD ["./run"]
