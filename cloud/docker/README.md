# Docker Tools

By using the scripts provided in the `docker` folder, you can containerize and run a TIBCO BusinessEvents application in Docker. The folder contains scripts and Dockerfiles that you can use to build Docker images for the following:

- TIBCO BusinessEvents Application

- TIBCO BusinessEvents Rule Management Server

- TIBCO BusinessEvents Enterprise Administrator Agent

- TIBCO BusinessEvents S2I Builder Image

## Rule Management Server (BE 7.0.0 and above)

With the native installer (the default for BE 7.0.0 and above), `--image-type rms` builds the Quarkus-based RMS image instead of the BE-engine RMS. This RMS is not a BE engine, so the build needs no ActiveSpaces, FTL, CDD or EAR and ignores `--optimize`, and the image needs an external PostgreSQL. It is built from `Dockerfile-rms` / `Dockerfile-rms.win` (target `final-native`) and started by `lib/run-rms.sh` / `lib/run-rms.bat`.

Configure the container with environment variables; they outrank the properties files in the instance directory:

| Variable | Purpose |
|---|---|
| `RMS_DB_HOST`, `RMS_DB_PORT` (5432), `RMS_DB_NAME` (rms) | PostgreSQL to connect to |
| `RMS_DB_USER`, `RMS_DB_PASSWORD` | Database credentials |
| `RMS_BOOTSTRAP_ADMIN_USERNAME`, `RMS_BOOTSTRAP_ADMIN_EMAIL`, `RMS_BOOTSTRAP_ADMIN_PASSWORD` | First administrator |
| `QUARKUS_DATASOURCE_JDBC_URL`, `_USERNAME`, `_PASSWORD` | Same database settings in Quarkus form; they win over `RMS_DB_*` |
| `QUARKUS_HTTP_HOST` | Listen address (default `0.0.0.0`, RMS listens on 8081) |

Mount a volume on the instance directory (`/opt/tibco/rms-instance/be/<version>` on Linux, `c:\tibco\rms-instance` on Windows). On first start the image seeds it and generates this container's JWT signing and token-encryption keys; the encryption key decrypts the Git credentials stored in the database, so keep the volume.

## Documentation

TIBCO BusinessEvents® documentation is available at [Containerize TIBCO BusinessEvents](https://github.com/TIBCOSoftware/be-tools/wiki/Containerize-TIBCO-BusinessEvents).
