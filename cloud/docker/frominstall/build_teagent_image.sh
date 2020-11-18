#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

USAGE="\nUsage: build_teagent_image.sh\n"
USAGE+="[-r|--repo]                 :       The teagent image Repository (example - repo:tag) [optional]\n"
USAGE+="[-l|--be-home]              :       be-home [optional, default: "../../.." i.e; as run from its default location BE_HOME/cloud/docker/frominstall] [optional]\n"
USAGE+="[-d|--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-teagent_fromtar) [optional]\n"
USAGE+="[-h|--help]                 :       Print the usage of script [optional]\n";

ARG_DOCKER_FILE="Dockerfile-teagent_fromtar"
ARG_VERSION="na"
ARG_IMAGE_VERSION="na"
BE_HOME="../../.."
TEMP_FOLDER="tmp_$RANDOM"

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
	-d|--docker-file)
        shift # past the key and to the value
        ARG_DOCKER_FILE="$1"
        ;;
        -d=*|--docker-file=*)
        ARG_DOCKER_FILE="${key#*=}"
        ;;
	-r|--repo) 
        shift # past the key and to the value
        ARG_IMAGE_VERSION="$1"
        ;;
        -r=*|--image-version=*)
        ARG_IMAGE_VERSION="${key#*=}"
        ;;
	-l|--be-home) 
        shift # past the key and to the value
        BE_HOME="$1"
        ;;
        -l=*|--be-home=*)
        BE_HOME="${key#*=}"
        ;;
	-h|--help) 
        shift
        printf "$USAGE"
        exit 0
	    ;;
        *)
        echo "Invalid Option '$key'"
	printf "$USAGE"
        exit 1
        
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done
ARG_VERSION=$(find $BE_HOME/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
ARG_VERSION=$(echo $ARG_VERSION | sed -e 's/\r//g')
if [ "$ARG_IMAGE_VERSION" = "na" -o "$ARG_IMAGE_VERSION" = "nax" -o -z "${ARG_IMAGE_VERSION// }" ];then
	ARG_IMAGE_VERSION="teagent:$ARG_VERSION"
fi
echo "----------------------------------------------"
echo "INFO: VERSION : $ARG_VERSION"
echo "INFO: DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO: IMAGE REPO : $ARG_IMAGE_VERSION"
echo "----------------------------------------------"

DOCKER_BIN_DIR="$BE_HOME"/cloud/docker/bin
DOCKER_FROM_INSTALL="$BE_HOME"/cloud/docker/frominstall

mkdir -p $TEMP_FOLDER
cp -a "../lib" $TEMP_FOLDER/
if [ "$BE_HOME" = "../../.." ]
then
  perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER
else
  perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $BE_HOME
fi

if [ "$?" != 0 ]; then
  echo "Creating BE archive failed"
  rm -rf $TEMP_FOLDER
  exit $?
fi

VERSION_REGEX=([0-9]\.[0-9]).*
if [[ $ARG_VERSION =~ $VERSION_REGEX ]]
then
	SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR: Improper version $ARG_VERSION. Aborting."
	exit 1
fi

echo "INFO: Building docker image for TIBCO BusinessEvents Version:$ARG_VERSION and Image Repo:$ARG_IMAGE_VERSION and Dockerfile:$ARG_DOCKER_FILE"
cp $ARG_DOCKER_FILE $TEMP_FOLDER/
docker build -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER"

if [ "$?" != 0 ]; then
  echo "Docker build failed."
  rm -rf $TEMP_FOLDER
  exit $?
else
  echo "DONE: Docker build successful."
  rm -rf $TEMP_FOLDER
  exit 0
fi
