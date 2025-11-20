FROM alpine:3.22

RUN apk --no-cache add libc6-compat

# Build arguments for names only
ARG BIN_NAME
ARG CDD_NAME
ARG EAR_NAME
ARG LIB_NAME

# Copy staged files/folders
COPY scripts/docker/context/bin/${BIN_NAME} /app
COPY scripts/docker/context/${CDD_NAME} /${CDD_NAME}
COPY scripts/docker/context/${EAR_NAME} /${EAR_NAME}
COPY scripts/docker/context/be-engine.tra /
COPY scripts/docker/context/license /license
COPY scripts/docker/context/lib/${LIB_NAME} /usr/lib/${LIB_NAME}

RUN chmod +x /app

ENV LD_LIBRARY_PATH=/usr/lib

ENTRYPOINT ["./app"]
