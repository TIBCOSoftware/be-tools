#!/bin/bash

BUILD_OPTION=$1
PSP=:

BE_HOME=/home/naresh/tibco/be/6.3
BE_APP_VER=630
BE_APP_NAME=inmem

BE_APP_HOME=/home/naresh/be-tools/cloud/graal/beapps/$BE_APP_VER/$BE_APP_NAME
META_DIR=$BE_APP_HOME/META-INF/native-image
EXT_JARS_PATH=/home/naresh/be-tools/cloud/graal/extjars

allJarsInPath(){
    DIRPATH=$1
    allFiles=`find $DIRPATH -type f`
    CPPATH=""
    for eachFile in $allFiles
    do
        if [[ "$eachFile" == *".jar" ]]; then
            if [  $eachFile != $BE_HOME/lib/ext/tpcl/opentelemetry/exporters/grpc-netty-shaded.jar -a $eachFile != $BE_HOME/lib/ext/tpcl/netty-all.jar  -a $eachFile != $BE_HOME/lib/ext/tpcl/jackson-dataformat-cbor-2.13.3.jar -a $eachFile != $BE_HOME/lib/ext/tpcl/jackson-dataformat-cbor.jar -a $eachFile != $BE_HOME/lib/ext/tpcl/jackson-databind.jar ];
            then
                CPPATH=$CPPATH$eachFile$PSP
            fi
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

# echo CP_PATH $CP_PATH

if [[ "$BUILD_OPTION" == "" || "$BUILD_OPTION" == "1" ]]; then
    echo building native image $BE_APP_NAME$BE_APP_VER
    native-image -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --no-fallback --enable-url-protocols=http -H:ConfigurationFileDirectories=$META_DIR -o bin/$BE_APP_NAME$BE_APP_VER --initialize-at-run-time=org.apache.logging.log4j,org.apache.logging.slf4j,io.netty --initialize-at-build-time=com.datastax.oss.driver.internal.core.util.Dependency
fi

if [ "$BUILD_OPTION" = "2" ]; then
    echo creating metadata 
    java -agentlib:native-image-agent=config-output-dir=$META_DIR -classpath "$CP_PATH" com.tibco.cep.container.standalone.BEMain --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi

if [ "$BUILD_OPTION" = "3" ]; then
    echo running native image $BE_APP_NAME$BE_APP_VER
    ./bin/$BE_APP_NAME$BE_APP_VER --propFile $BE_HOME/bin/be-engine.tra -u default -c "$BE_APP_HOME/cddear/fd.cdd" "$BE_APP_HOME/cddear/fd.ear"
fi
