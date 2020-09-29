#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

FILE_NAME=$(basename $0)

ARG_SOURCE="na"
ARG_TYPE="na"
ARG_APP_LOCATION="na"
ARG_TAG="na"
ARG_DOCKER_FILE="na"
ARG_GVPROVIDERS="na"
ARG_ENABLE_TESTS="true"

INSTALLATION_TYPE="fromlocal"

USAGE="\nUsage: $FILE_NAME"

USAGE+="\n\n [-i/--image-type]    :    Type of image. Values must be(app/rms/teagent/builder). (example: app) [required]"
USAGE+="\n\n [-a/--app-location]  :    Location where the ear, cdd are located. [required only if -i/--image-type is app]"
USAGE+="\n\n [-s/--source]        :    Path to be-home or location where installers(TIBCO BusinessEvents, Activespaces, FTL) located. [required for installers]\n"
USAGE+="                           Note: No need to specify be-home if script is executed from <BE_HOME>/cloud/docker/build folder."
USAGE+="\n\n [-t/--tag]           :    Tag or name of the image. (example: beimage:v1) [optional]"
USAGE+="\n\n [-d/--docker-file]   :    Dockerfile to be used for generating image. [optional]"
USAGE+="\n\n [--gv-providers]     :    Names of GV providers to be included in the image. Values must be (consul/http/custom). (example: consul) [optional]\n"
USAGE+="                           Note: Use this flag only if -i/--image-type is app/builder."
USAGE+="\n\n [--disable-tests]    :    Disables docker unit tests on created image. [optional]\n"
USAGE+="                           Note: Use this flag only if -i/--image-type is app/builder."
USAGE+="\n\n [-h/--help]          :    Print the usage of script. [optional]" 
USAGE+="\n\n NOTE : supply long options with '=' \n"

#Parse the arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -s|--source) 
            shift # past the key and to the value
            ARG_SOURCE="$1"
            ;;
        -s=*|--source=*)
            ARG_SOURCE="${key#*=}"
            ;;
        -i|--image-type) 
            shift # past the key and to the value
            ARG_TYPE="$1"
            ;;
        -i=*|--image-type=*)
            ARG_TYPE="${key#*=}"
	        ;;
        -a|--app-location) 
            shift # past the key and to the value
            ARG_APP_LOCATION="$1"
            ;;
        -a=*|--app-location=*)
            ARG_APP_LOCATION="${key#*=}"
	        ;;
        -t|--tag) 
            shift # past the key and to the value
            ARG_TAG="$1"
            ;;
        -t=*|--tag=*)
            ARG_TAG="${key#*=}"
	        ;;
        -d|--docker-file)
            shift # past the key and to the value
            ARG_DOCKER_FILE="$1"
            ;;
        -d=*|--docker-file=*)
            ARG_DOCKER_FILE="${key#*=}"
            ;;
        --gv-providers)
            shift # past the key and to the value
            ARG_GVPROVIDERS="$1"
            ;;
        --gv-providers=*)
            ARG_GVPROVIDERS="${key#*=}"
            ;;
        --disable-tests)
            ARG_ENABLE_TESTS="false"
            ;;
        -h|--help) 
            shift # past the key and to the value
            printf "$USAGE"
            exit 0
            ;;
        *)
            echo "Invalid Option: [$key]"
            ;;
    esac
    shift
done

# missing arguments check
MISSING_ARGS=""

if [ "$ARG_TYPE" = "na" -o -z "${ARG_TYPE// }" ]; then
    MISSING_ARGS="Image Type[-i/--image-type]"
fi

if [ "$ARG_TYPE" = "app" ]; then
    if [ "$ARG_APP_LOCATION" = "na" -o -z "${ARG_APP_LOCATION// }" ]; then
        MISSING_ARGS="App location[-a/--app-location]"
    fi
fi

if [ "$MISSING_ARGS" != "" ]; then
    printf "\nERROR: Missing mandatory argument : $MISSING_ARGS\n"
    printf "$USAGE"
    exit 1; 
fi

if [ "$ARG_SOURCE" != "na" ]; then
    BE_REGEX="TIB_businessevents-enterprise_[0-9]\.[0-9]\.[0-9]_linux26gl25_x86_64.zip"
    bePckgsCnt=$(find $ARG_SOURCE -name "${BE_REGEX}" | wc -l)
    if [ $bePckgsCnt -gt 0 ]; then
        INSTALLATION_TYPE="frominstallers"
        ARG_INSTALLER_LOCATION="$ARG_SOURCE"
    else
        BE_HOME="$ARG_SOURCE"
    fi
else
    BE_HOME="na"
fi

if [ "$INSTALLATION_TYPE" = "fromlocal" -a "$ARG_TYPE" = "builder" ]; then
    printf "\nERROR: Image creation from be local does not support image type 'builder'. Image type should be either of app,rms or teagent.\n"
    exit 1
fi

case "$ARG_TYPE" in
    "app")
        FILE_NAME="build_app_image.sh"
        if [ "$ARG_DOCKER_FILE" = "na" ]; then
            if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
                ARG_DOCKER_FILE="../frominstall/Dockerfile_fromtar"
            else
                ARG_DOCKER_FILE="../bin/Dockerfile"
            fi
        fi
        ;;
    "rms")
        FILE_NAME="build_rms_image.sh"
        if [ "$ARG_DOCKER_FILE" = "na" ]; then
            if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
                ARG_DOCKER_FILE="../frominstall/Dockerfile-rms_fromtar"
            else
                ARG_DOCKER_FILE="../bin/Dockerfile-rms"
            fi
        fi
        ;;
    "teagent")
        FILE_NAME="build_teagent_image.sh"
        if [ "$ARG_DOCKER_FILE" = "na" ]; then
            if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
                ARG_DOCKER_FILE="../frominstall/Dockerfile-teagent_fromtar"
            else
                ARG_DOCKER_FILE="../bin/Dockerfile-teagent"
            fi
        fi
        ;;
    "builder")
        FILE_NAME="create_builder_image.sh"
        if [ "$ARG_DOCKER_FILE" = "na" ]; then
            if [ "$INSTALLATION_TYPE" != "fromlocal" ]; then
                ARG_DOCKER_FILE="../s2i/Dockerfile"
            fi
        fi
        ;;
    *)
        printf "\nERROR: Invalid image type provided. Image type must be either of app,rms,teagent or builder.\n"
        exit 1
        ;;
esac

ARG_IMAGE_VERSION="$ARG_TAG"

if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    source ./frombelocal.sh
else
    source ./frominstallers.sh
fi