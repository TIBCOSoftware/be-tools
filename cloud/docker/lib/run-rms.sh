#!/bin/bash

#
# Entrypoint of the Quarkus RMS image (native installer, BE 7.0.0 and above).
#
# RMS is configured through properties files in its instance directory (RMS_INSTANCE_DIR). Environment variables
# outrank those files, so a container is normally configured with them alone:
#
#   RMS_DB_HOST [RMS_DB_PORT=5432] [RMS_DB_NAME=rms]   PostgreSQL to use (builds the JDBC URL)
#   RMS_DB_USER, RMS_DB_PASSWORD                       database credentials
#   QUARKUS_DATASOURCE_JDBC_URL, _USERNAME, _PASSWORD  same values in Quarkus form; these win over the RMS_DB_* ones
#   RMS_BOOTSTRAP_ADMIN_USERNAME, _EMAIL, _PASSWORD    first administrator
#   QUARKUS_HTTP_HOST                                  listen address, 0.0.0.0 unless set
#   any other Quarkus/RMS key, e.g. RMS_UI_BASE_URL for rms.ui.base-url
#
# On first start with an empty instance directory the image's seed is copied in, and be-rms-server init generates this
# container's JWT signing key pair and token-encryption key. Keep the instance directory on a volume: those keys decrypt
# the Git credentials RMS stores in its database, so losing them strands every stored credential.
#

BE_SHORT_VERSION=${BE_SHORT_VERSION:?BE_SHORT_VERSION is not set}
RMS_INSTANCE_DIR=${RMS_INSTANCE_DIR:-/opt/tibco/rms-instance/be/$BE_SHORT_VERSION}
RMS_INSTANCE_SEED_DIR=${RMS_INSTANCE_SEED_DIR:-/opt/tibco/rms-instance-seed}
BE_HOME=${BE_HOME:-/opt/tibco/be/$BE_SHORT_VERSION}
LAUNCHER=$BE_HOME/rms-server/bin/be-rms-server.sh
CONF_DIR=$RMS_INSTANCE_DIR/config
export RMS_INSTANCE_DIR BE_HOME

if [ ! -x "$LAUNCHER" ]; then
    echo "ERROR: RMS launcher $LAUNCHER not found. This is not a BE 7.0.0+ native-installer RMS image."
    exit 1
fi

if [ ! -f "$CONF_DIR/application.properties" ]; then
    echo "INFO: Seeding RMS instance directory $RMS_INSTANCE_DIR from $RMS_INSTANCE_SEED_DIR"
    mkdir -p "$RMS_INSTANCE_DIR" && cp -R "$RMS_INSTANCE_SEED_DIR/." "$RMS_INSTANCE_DIR/"
    if [ $? -ne 0 ]; then
        echo "ERROR: Could not seed $RMS_INSTANCE_DIR. Check that the directory is writable by this user."
        exit 1
    fi
fi

# A secrets file that still holds an installer placeholder on a non-comment line has no keys yet. init refuses (exit 3) to overwrite keys
# that exist, so this never regenerates them.
if grep -qE '^[^#]*@@' "$CONF_DIR/rms-secrets.properties" 2>/dev/null; then
    echo "INFO: Generating RMS key material"
    "$LAUNCHER" init
    rc=$?
    if [ $rc -ne 0 ] && [ $rc -ne 3 ]; then
        echo "ERROR: be-rms-server init failed with exit code $rc."
        exit $rc
    fi
fi

# The shipped config binds to 127.0.0.1, which is unreachable from outside a container.
export QUARKUS_HTTP_HOST=${QUARKUS_HTTP_HOST:-0.0.0.0}

if [ -n "$RMS_DB_HOST" ] && [ -z "$QUARKUS_DATASOURCE_JDBC_URL" ]; then
    export QUARKUS_DATASOURCE_JDBC_URL="jdbc:postgresql://$RMS_DB_HOST:${RMS_DB_PORT:-5432}/${RMS_DB_NAME:-rms}?options=-c%20TimeZone%3DUTC"
fi
if [ -n "$RMS_DB_USER" ] && [ -z "$QUARKUS_DATASOURCE_USERNAME" ]; then
    export QUARKUS_DATASOURCE_USERNAME="$RMS_DB_USER"
fi
if [ -n "$RMS_DB_PASSWORD" ] && [ -z "$QUARKUS_DATASOURCE_PASSWORD" ]; then
    export QUARKUS_DATASOURCE_PASSWORD="$RMS_DB_PASSWORD"
fi

# Maven, which RMS forks, needs JAVA_HOME. Use the bundled JRE: the highest numeric folder under jrehome.
if [ -z "$JAVA_HOME" ]; then
    for d in $(ls -d "${TIBCO_HOME:-/opt/tibco}"/jrehome/[0-9]* 2>/dev/null | sort -V -r); do
        if [ -x "$d/bin/java" ]; then
            export JAVA_HOME="$d"
            break
        fi
    done
fi

# RMS forks Maven for EAR builds. The installer merges the offline repository into the installing user's ~/.m2, which
# a container user does not share, so point Maven at the offline repository inside the BE home instead.
if [ -z "$MAVEN_ARGS" ] && [ -d "$BE_HOME/maven/m2-repo" ]; then
    export MAVEN_ARGS="-Dmaven.repo.local=$BE_HOME/maven/m2-repo"
fi

# exec so the JVM is PID 1 and receives the container runtime's SIGTERM
exec "$LAUNCHER" run
