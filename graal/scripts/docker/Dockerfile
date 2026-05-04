FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends perl libstdc++6 && rm -rf /var/lib/apt/lists/*

# Build arguments for filenames resolved at build time
ARG BIN_NAME
ARG CDD_NAME
ARG EAR_NAME

# Copy native binary, application files, and config
COPY scripts/docker/context/bin/${BIN_NAME} /app
COPY scripts/docker/context/${CDD_NAME} /${CDD_NAME}
COPY scripts/docker/context/${EAR_NAME} /${EAR_NAME}
COPY scripts/docker/context/be-engine.tra /be-engine.tra
COPY scripts/docker/context/license /license

# Copy only the BE-specific shared libraries
COPY scripts/docker/context/lib/ /usr/lib/

# be_docker_run.pm at the path the run script expects via its own PERL5LIB export
COPY scripts/docker/context/be_docker_run.pm /home/tibco/be/be_docker_run.pm

# Mount point for user-supplied *.props files (run script reads from /opt/tibco/be/application)
RUN mkdir -p /opt/tibco/be/application /home/tibco/be

# run script from cloud/docker/lib/run patched to invoke native binary instead of be-engine
COPY scripts/docker/context/run /run.sh
RUN chmod +x /app /run.sh

# CDD_FILE and EAR_FILE env vars consumed by the run script (same pattern as cloud/docker)
ENV CDD_FILE=/${CDD_NAME}
ENV EAR_FILE=/${EAR_NAME}

# PU and ENGINE_NAME can be overridden at runtime: docker run -e PU=<name> -e ENGINE_NAME=<name> <image>
ENV PU=default
ENV ENGINE_NAME=be-engine
ENV LD_LIBRARY_PATH=/usr/lib

ENTRYPOINT ["/run.sh"]
