#!/bin/bash

source init.sh

META_DIR="${1:-$META_DIR}"
PU="${2:-default}"

echo "Using meta_dir: $META_DIR"

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
    -DTIB_ACTIVATION=$LIC_PATH \
    -agentlib:native-image-agent=config-merge-dir=$META_DIR \
    -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain \
    --propFile $BE_HOME/bin/be-engine.tra -u $PU -c "$CDD_PATH" "$EAR_PATH"
