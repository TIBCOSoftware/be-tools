#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

FILE_NAME=$(basename $0)
SOURCE_DIR=$(basename $(pwd))

ARG_IMAGE_SOURCE="frombelocal"
ARG_IMAGE_TYPE="app"
RELATIVE_DIR=""
ARGS=""

USAGE="\nUsage: $FILE_NAME"

#Parse the arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -s|--source) 
            shift # past the key and to the value
            ARG_IMAGE_SOURCE="$1"
            ;;
        -s=*|--source=*)
            ARG_IMAGE_SOURCE="${key#*=}"
            ;;
        -t|--type) 
            shift # past the key and to the value
            ARG_IMAGE_TYPE="$1"
            ;;
        -t=*|--type=*)
            ARG_IMAGE_TYPE="${key#*=}"
	        ;;
        *)
            ARGS+="$1 "
            ;;
    esac
    shift
done

if ! [ "$ARG_IMAGE_SOURCE" = "frominstallers" -o "$ARG_IMAGE_SOURCE" = "frombelocal" ]; then
    ARG_IMAGE_SOURCE="frombelocal"
fi

if ! [ "$ARG_IMAGE_TYPE" = "app" -o "$ARG_IMAGE_TYPE" = "rms" -o "$ARG_IMAGE_TYPE" = "tea" -o "$ARG_IMAGE_TYPE" = "builder" ]; then
    ARG_IMAGE_TYPE="app"
fi

if [ "$ARG_IMAGE_SOURCE" = "frombelocal" -a "$ARG_IMAGE_TYPE" = "builder" ]; then
    echo "ERROR: 'frombelocal' does not support image type 'builder'. changing image type to 'app'."
    ARG_IMAGE_TYPE="app"
fi

case "$ARG_IMAGE_TYPE" in
    "app")
        FILE_NAME="build_app_image.sh"
        ;;
    "rms")
        FILE_NAME="build_rms_image.sh"
        ;;
    "tea")
        FILE_NAME="build_teagent_image.sh"
        ;;
    "builder")
        FILE_NAME="create_builder_image.sh"
        ;;
esac

if [ "$ARG_IMAGE_SOURCE" = "frombelocal" ]; then
    RELATIVE_DIR="../frominstall/"
    source ./frombelocal.sh $ARGS
else
    RELATIVE_DIR="../bin/"
    source ./frominstallers.sh $ARGS
fi