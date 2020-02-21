#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source ../base/get_parameters.sh $@
cd ../base
ARG_DOCKER_FILE="Dockerfile-base-frominstall"
ARG_VERSION=""

TEMP_FOLDER="tmp_$RANDOM"
ARG_GVPROVIDERS="na"
echo "BE HOME $ARG_INSTALLER_LOCATION"
ARG_VERSION=$(find $ARG_INSTALLER_LOCATION/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
ARG_VERSION=$(echo $ARG_VERSION | sed -e 's/\r//g')

AS_VERSION=$(find $ARG_INSTALLER_LOCATION/uninstaller_scripts/post-install.properties -type f | xargs grep  'asVersionShort=' | cut -d'=' -f2)
AS_VERSION=$(echo $AS_VERSION | sed -e 's/\r//g')

DOCKER_BIN_DIR="$ARG_INSTALLER_LOCATION"/cloud/docker/bin
DOCKER_FROM_INSTALL="$ARG_INSTALLER_LOCATION"/cloud/docker/frominstall

mkdir -p $TEMP_FOLDER/app
cp -a "../lib" $TEMP_FOLDER/
cp -a "../gvproviders" $TEMP_FOLDER/
cp $ARG_APP_LOCATION/$CDD_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/$EAR_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app

if [ "$ARG_INSTALLER_LOCATION" = "../../.." ]
then
  perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER
else
  perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $ARG_INSTALLER_LOCATION
fi

if [ "$?" != 0 ]; then
  echo "Creating BE archive failed"
  rm -rf $TEMP_FOLDER
  exit $?
fi

IMAGE_NAME=$BE_TAG:$ARG_VERSION
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

docker build -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$IMAGE_NAME" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_INSTALLER_LOCATION" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_VERSION" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$IMAGE_NAME" $TEMP_FOLDER

echo "Deleting temporary intermediate image.."
docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
#echo "Deleting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER
