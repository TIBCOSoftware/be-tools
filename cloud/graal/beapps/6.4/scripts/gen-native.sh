#!/bin/bash

source init.sh

mv $META_DIR/reflect-config.json $META_DIR/reflect-config-bkp.json
jq 'map(select(.name | test("^jdk\\.internal\\.") | not))'  $META_DIR/reflect-config-bkp.json > $META_DIR/reflect-config.json
rm $META_DIR/reflect-config-bkp.json

echo building native image 
    native-image \
    --enable-url-protocols=https \
    --enable-url-protocols=http \
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
    -o $OP_PATH \
    --initialize-at-run-time=org.apache.logging.log4j,org.apache.logging.slf4j,io.netty,sun.reflect.misc.Trampoline \
    --initialize-at-build-time=com.datastax.oss.driver.internal.core.util.Dependency,com.sun.xml.xsom.impl.AnnotationImpl\$LocatorImplUnmodifiable,com.datastax.oss.driver.shaded.guava.common.collect.RegularImmutableList,com.datastax.oss.driver.shaded.guava.common.collect.SingletonImmutableList,java.nio,com.tibco.be.functions.file.LowByteCharsetProvider
