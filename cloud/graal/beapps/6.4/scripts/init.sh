#!/bin/bash

PSP=:

BE_HOME=/home/nthota/tibco640-1/be/6.4
META_DIR=./META-INF

EXT_JARS_PATH=./extjars
OP_PATH=./bin/test
APP_JARS_PATH=../fdcache/appjar

CDD_PATH=../fdcache/cddear/fd.cdd
EAR_PATH=../fdcache/cddear/fd.ear

LIC_PATH=/home/nthota/license


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

# add be.jar to classpath
CP_PATH=$CP_PATH$APP_JARS_PATH/be.jar


# exclude jars from CP_PATH
EXCLUDE_JARS=(
    "BE_HOME/lib/ext/tpcl/opentelemetry/exporters/grpc-netty-shaded.jar"
)
for eachJar in "${EXCLUDE_JARS[@]}"; do
    eachJar="${eachJar/BE_HOME/$BE_HOME}"
    CP_PATH=${CP_PATH/$eachJar$PSP/}
done

export LD_LIBRARY_PATH=$BE_HOME/lib:$LD_LIBRARY_PATH:$BE_HOME/lib/ext/tpcl:$BE_HOME/lib/ext/tibco:$BE_HOME/lib/ext/apache

echo CP_PATH--$CP_PATH--
