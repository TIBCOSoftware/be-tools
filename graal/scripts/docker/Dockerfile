FROM alpine:3.22

RUN apk --no-cache add libc6-compat

# Build arguments for names only
ARG BIN_NAME
ARG CDD_NAME
ARG EAR_NAME
ARG LIB_NAME

# Copy staged files/folders
COPY docker/context/bin/${BIN_NAME} /app
COPY docker/context/${CDD_NAME} /${CDD_NAME}
COPY docker/context/${EAR_NAME} /${EAR_NAME}
COPY docker/context/be-engine.tra /
COPY docker/context/license /license
COPY docker/context/lib/${LIB_NAME} /usr/lib/${LIB_NAME}

RUN chmod +x /app

ENV LD_LIBRARY_PATH=/usr/lib

ENTRYPOINT ["./app"]
