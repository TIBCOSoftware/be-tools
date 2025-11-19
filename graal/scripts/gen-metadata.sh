#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> [-u <PU>] [-e <EXTERNAL_JARS_PATH>]"
    echo "  -s <BE_HOME>            Path to BE Home (mandatory)"
    echo "  -a <APP_HOME>           Path to Application Home (mandatory)"
    echo "  -u <PU>                 Processing Unit name (default: default)"
    echo "  -e <EXTERNAL_JARS_PATH> Path to external jars (default: ./extjars)"
    echo "  -h                      Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:u:e:h" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        u) PU=$OPTARG ;;
        e) EXTERNAL_JARS_PATH=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

EXTERNAL_JARS_PATH="${EXTERNAL_JARS_PATH:-./extjars}"

source init.sh

# Default values for optional parameters
PU="${PU:-default}"
OUTPUT_PATH="$APP_HOME/META-INF-$PU"

# Display the values for verification
echo "BE_HOME: $BE_HOME"
echo "APP_HOME: $APP_HOME"
echo "PU: $PU"
echo "EXTERNAL_JARS_PATH: $EXTERNAL_JARS_PATH"
echo "LICENSE_PATH: $LICENSE_PATH"
echo "OUTPUT_PATH: $OUTPUT_PATH"

# Step 1: Check if BE_HOME and APP_HOME exist
if [ ! -d "$BE_HOME" ]; then
    echo "Error: BE_HOME directory does not exist: $BE_HOME"
    exit 1
fi

if [ ! -d "$APP_HOME" ]; then
    echo "Error: APP_HOME directory does not exist: $APP_HOME"
    exit 1
fi

source init.sh

echo "Using meta_dir: $OUTPUT_PATH"

echo creating metadata for inference
    java \
    -server \
    -Xms1024m \
    -Xmx1024m \
    -Xss2m \
    -XX:MaxMetaspaceSize=256m \
    --add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED \
    --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED \
    --add-opens=java.base/sun.nio.ch=ALL-UNNAMED \
    --add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED \
    --add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED \
    --add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED \
    --add-opens=java.base/java.io=ALL-UNNAMED \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    --add-opens=java.base/java.util=ALL-UNNAMED \
    --add-opens=java.base/java.lang=ALL-UNNAMED \
    --add-opens=java.base/java.util.concurrent=ALL-UNNAMED \
    --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED \
    --add-opens=java.base/sun.security.ssl=ALL-UNNAMED \
    --add-opens=java.base/sun.net.util=ALL-UNNAMED \
    --add-opens=java.xml/com.sun.org.apache.xerces.internal.jaxp=ALL-UNNAMED \
    --add-opens=java.xml/com.sun.xml.internal.stream=ALL-UNNAMED \
    --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED \
    --add-opens=java.base/sun.util.calendar=ALL-UNNAMED \
    --add-opens=java.base/sun.net=ALL-UNNAMED \
    --add-opens=java.base/jdk.internal.access=ALL-UNNAMED \
    --add-opens=java.base/java.net=ALL-UNNAMED \
    --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED \
    --add-opens=java.base/java.math=ALL-UNNAMED \
    --add-opens=java.sql/java.sql=ALL-UNNAMED \
    --add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
    --add-opens=java.base/java.time=ALL-UNNAMED \
    --add-opens=java.base/java.text=ALL-UNNAMED \
    --add-opens=java.management/sun.management=ALL-UNNAMED \
    --add-opens=java.desktop/java.awt.font=ALL-UNNAMED \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    -DTIB_ACTIVATION=$LICENSE_PATH \
    -agentlib:native-image-agent=config-merge-dir=$OUTPUT_PATH \
    -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain \
    --propFile $BE_HOME/bin/be-engine.tra -u $PU -c "$CDD_FILE" "$EAR_FILE"
