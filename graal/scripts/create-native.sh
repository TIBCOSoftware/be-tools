#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> [-e <EXTERNAL_JARS_PATH>]"
    echo "  -s <BE_HOME>            Path to BE Home (mandatory)"
    echo "  -a <APP_HOME>           Path to Application Home (mandatory)"
    echo "  -e <EXTERNAL_JARS_PATH> Path to external jars (default: ./extjars)"
    echo "  -h                      Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:e:h" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        e) EXTERNAL_JARS_PATH=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

EXTERNAL_JARS_PATH="${EXTERNAL_JARS_PATH:-./extjars}"

source init.sh

echo "Merging metadata..."
./merge-metadata.sh -a "$APP_HOME"
echo ""

OUTPUT_PATH=$APP_HOME/bin/$(basename "$CDD_FILE" .cdd)
# Validate if output directory exists, create it if not
if [ ! -d "$APP_HOME/bin" ]; then
  echo "Output directory '$APP_HOME/bin' does not exist. Creating it now."
  mkdir -p "$APP_HOME/bin"
fi

META_DIR="$APP_HOME/META-INF"

mv $META_DIR/reflect-config.json $META_DIR/reflect-config-bkp.json
jq 'map(select(.name | test("^jdk\\.internal\\.") | not))'  $META_DIR/reflect-config-bkp.json > $META_DIR/reflect-config.json
rm $META_DIR/reflect-config-bkp.json

echo building native image 
    native-image \
    --enable-url-protocols=https \
    --enable-url-protocols=http \
    --enable-monitoring=all \
    --add-exports=java.base/sun.net.util=ALL-UNNAMED \
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
    -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain \
    --no-fallback \
    -H:ConfigurationFileDirectories=$META_DIR \
    -o $OUTPUT_PATH \
    --initialize-at-run-time=org.apache.logging.log4j,org.apache.logging.slf4j,io.netty,sun.reflect.misc.Trampoline \
    --initialize-at-build-time=com.datastax.oss.driver.internal.core.util.Dependency,com.sun.xml.xsom.impl.AnnotationImpl\$LocatorImplUnmodifiable,com.datastax.oss.driver.shaded.guava.common.collect.RegularImmutableList,com.datastax.oss.driver.shaded.guava.common.collect.SingletonImmutableList,java.nio,com.tibco.be.functions.file.LowByteCharsetProvider

if [ $? -eq 0 ]; then
  echo "Native image creation successfully in $OUTPUT_PATH."
else
  echo "Error: native image creation failed."
  exit 1
fi