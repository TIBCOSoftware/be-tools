#!/bin/bash

BUILD_OPTION=$1
PSP=:

BE_HOME=/home/nthota/tibco640/be/6.4
BE_APP_VER=640

# BE_HOME=/home/nthota/tibco/be/6.3
# BE_APP_VER=632

# BE_HOME=/home/nthota/tibco630/be/6.3
# BE_APP_VER=630

BE_APP_NAME=cache-ignite
# BE_APP_NAME=inmem

BE_APP_HOME=/home/nthota/git/be-tools/cloud/graal/beapps/$BE_APP_VER/$BE_APP_NAME
META_DIR=$BE_APP_HOME/META-INF/native-image
EXT_JARS_PATH=/home/nthota/git/be-tools/cloud/graal/extjars

allJarsInPath(){
    DIRPATH=$1
    allFiles=`find $DIRPATH -type f`
    CPPATH=""
    for eachFile in $allFiles
    do
        if [[ "$eachFile" == *".jar" ]]; then
            CPPATH=$CPPATH$eachFile$PSP
        fi
    done
    echo $CPPATH
}

CP_PATH=`allJarsInPath $BE_HOME/lib`
CP_EXT_JARS=`allJarsInPath $EXT_JARS_PATH`

if [ "$CP_EXT_JARS" != "" ]; then
    CP_PATH=$CP_PATH$CP_EXT_JARS
fi

# add be.jsr o classpath
CP_PATH=$CP_PATH$BE_APP_HOME/jar/be.jar

#copy excludejars.txt to bin and update excludejars.txt with BE_HOME value
cp excludejars.txt bin/ 
sed -i'.bak' "s~BE_HOME~$BE_HOME~g" bin/excludejars.txt
#remove from CP_PATH
sed -i 's/\r$//' bin/excludejars.txt
for eachJar in $(cat "bin/excludejars.txt" ) ; do
    CP_PATH=${CP_PATH/$eachJar$PSP/}
done
#remove copied file
rm bin/excludejars.txt*

echo CP_PATH $CP_PATH

export LD_LIBRARY_PATH=$BE_HOME/lib:$LD_LIBRARY_PATH:$BE_HOME/lib/ext/tpcl:$BE_HOME/lib/ext/tibco:$BE_HOME/lib/ext/apache

if [[ "$BUILD_OPTION" == "" || "$BUILD_OPTION" == "1" ]]; then
    echo building native image $BE_APP_NAME$BE_APP_VER
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
    -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --no-fallback --enable-url-protocols=http -H:ConfigurationFileDirectories=$META_DIR -o bin/$BE_APP_NAME$BE_APP_VER \
    --initialize-at-run-time=org.apache.logging.log4j,org.apache.logging.slf4j,io.netty \
    --initialize-at-build-time=com.datastax.oss.driver.internal.core.util.Dependency,com.sun.xml.xsom.impl.AnnotationImpl\$LocatorImplUnmodifiable,com.datastax.oss.driver.shaded.guava.common.collect.RegularImmutableList,com.datastax.oss.driver.shaded.guava.common.collect.SingletonImmutableList,java.nio
fi

if [ "$BUILD_OPTION" = "2" ]; then
    echo creating metadata 
    # $BE_HOME/../../tibcojre64/21/bin/java \
    # -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    # -Dlicense.license_source=https://gasdbeqa02.dev.tibco.com:7070/?fp=65de63b9b2edd62fc46404451e539a6e17265ecb658749daf22c3dd355306227  \
    # -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"

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
    -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    -Dlicense.license_source=https://guwdbeqa01.c.prj-be-dev-66600.internal:7070/?fp=604ea148dfe70a605b8f861320eb6b11721b0d140d952d9ede01ba9b05044d17  \
    -agentlib:native-image-agent=config-output-dir=$META_DIR-cache -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
    
    # -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
    
    #-agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"

    #-agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi

# if [ "$BUILD_OPTION" = "3" ]; then
#     echo running native image $BE_APP_NAME$BE_APP_VER
#     ./bin/$BE_APP_NAME$BE_APP_VER \
#     -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
#     -Dlicense.license_source=https://gasdbeqa02.dev.tibco.com:7070/?fp=65de63b9b2edd62fc46404451e539a6e17265ecb658749daf22c3dd355306227 \
#     --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
# fi

if [ "$BUILD_OPTION" = "4" ]; then
    echo creating metadata cache
    # $BE_HOME/../../tibcojre64/21/bin/java \
    # -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    # -Dlicense.license_source=https://gasdbeqa02.dev.tibco.com:7070/?fp=65de63b9b2edd62fc46404451e539a6e17265ecb658749daf22c3dd355306227  \
    # -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"

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
    -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    --add-opens=java.base/java.nio=ALL-UNNAMED \
    -Dlicense.license_source=https://guwdbeqa01.c.prj-be-dev-66600.internal:7070/?fp=604ea148dfe70a605b8f861320eb6b11721b0d140d952d9ede01ba9b05044d17  \
    -agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
    
    # -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
    
    #-agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"

    #-agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi

if [ "$BUILD_OPTION" = "3" ]; then
    echo running native image $BE_APP_NAME$BE_APP_VER
    ./bin/$BE_APP_NAME$BE_APP_VER \
    -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    -Dlicense.license_source=https://guwdbeqa01.c.prj-be-dev-66600.internal:7070/?fp=604ea148dfe70a605b8f861320eb6b11721b0d140d952d9ede01ba9b05044d17 \
    -Dextended.properties="--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/sun.security.ssl=ALL-UNNAMED --add-opens=java.base/sun.net.util=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.jaxp=ALL-UNNAMED --add-opens=java.xml/com.sun.xml.internal.stream=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=java.base/sun.net=ALL-UNNAMED --add-opens=java.base/jdk.internal.access=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED --add-opens=java.sql/java.sql=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.management/sun.management=ALL-UNNAMED --add-opens=java.desktop/java.awt.font=ALL-UNNAMED" \
    --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi

if [ "$BUILD_OPTION" = "5" ]; then
    echo running native image $BE_APP_NAME$BE_APP_VER
    ./bin/$BE_APP_NAME$BE_APP_VER \
    -DLD_LIBRARY_PATH=$LD_LIBRARY_PATH  \
    -Dlicense.license_source=https://guwdbeqa01.c.prj-be-dev-66600.internal:7070/?fp=604ea148dfe70a605b8f861320eb6b11721b0d140d952d9ede01ba9b05044d17 \
    -Dextended.properties="--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/sun.security.ssl=ALL-UNNAMED --add-opens=java.base/sun.net.util=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.jaxp=ALL-UNNAMED --add-opens=java.xml/com.sun.xml.internal.stream=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=java.base/sun.net=ALL-UNNAMED --add-opens=java.base/jdk.internal.access=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED --add-opens=java.sql/java.sql=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.management/sun.management=ALL-UNNAMED --add-opens=java.desktop/java.awt.font=ALL-UNNAMED" \
    --propFile $BE_HOME/bin/be-engine.tra -u cache -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi