FROM alpine:3.22

# libc6-compat: glibc symlinks; gcompat: full glibc ABI compatibility layer for Oracle GraalVM binaries
RUN apk --no-cache add libc6-compat gcompat

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

# Copy only the BE-specific shared libraries resolved by ldd
COPY scripts/docker/context/lib/ /usr/lib/

# Copy the generated entrypoint (CDD/EAR paths baked in, PU read from env at runtime)
COPY scripts/docker/context/entrypoint.sh /entrypoint.sh
RUN chmod +x /app /entrypoint.sh

# PU can be overridden at runtime: docker run -e PU=<name> <image>
ENV PU=default
ENV LD_LIBRARY_PATH=/usr/lib

ENTRYPOINT ["/entrypoint.sh"]
