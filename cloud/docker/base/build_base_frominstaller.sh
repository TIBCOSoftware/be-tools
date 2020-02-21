#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source ../base/get_parameters.sh $@
cd ../base
ARG_DOCKER_FILE="Dockerfile-base-frominstaller"

mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/{installers,app}
cp $ARG_DOCKER_FILE $TEMP_FOLDER
ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"
cp -a "../lib" $TEMP_FOLDER/
cp -a "../gvproviders" $TEMP_FOLDER/
cp $ARG_APP_LOCATION/$CDD_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/$EAR_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app

getASVersion

IMAGE_NAME=$BE_TAG:$ARG_VERSION
echo "INFO:TEMP FOLDER: $TEMP_FOLDER"

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  echo "DONE: Docker build successful."
fi


echo "Dockerfile $ARG_DOCKER_FILE"
docker build -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$IMAGE_NAME" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_INSTALLER_LOCATION" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER -t "$IMAGE_NAME" $TEMP_FOLDER

echo "Deleting temporary intermediate image.."
docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
#echo "Deleting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER

