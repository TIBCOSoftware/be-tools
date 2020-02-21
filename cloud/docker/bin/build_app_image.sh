#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

USAGE="\nUsage: build_app_image.sh"
source ../base/get_parameters.sh $@

echo "INFO:Supplied Arguments :"
echo "----------------------------------------------"
echo "INFO:VERSION : $ARG_VERSION"
echo "INFO:EDITION : $ARG_EDITION"
echo "INFO:INSTALLER DIRECTORY : $ARG_INSTALLER_LOCATION"
echo "INFO:APPLICATION DATA DIRECTORY : $ARG_APP_LOCATION"
echo "INFO:ADDONS : $ARG_ADDONS"
echo "INFO:DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO:BE-HF : $ARG_BE_HOTFIX"
echo "INFO:AS-HF : $ARG_AS_HOTFIX"
echo "INFO:IMAGE VERSION : $ARG_IMAGE_VERSION"
echo "INFO:CDD FILE NAME : $CDD_FILE_NAME"
echo "INFO:EAR FILE NAME : $EAR_FILE_NAME" 
echo "INFO:TEMP FOLDER: $TEMP_FOLDER"

echo "----------------------------------------------"

if [[ "$(docker images -q $BE_TAG:$ARG_VERSION 2> /dev/null)" == "" ]]; then
 source ../base/build_base_image.sh $@
fi

cd ../bin
mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/{installers,app}
cp -a "../lib" $TEMP_FOLDER/
cp -a "../gvproviders" $TEMP_FOLDER/
cp $ARG_APP_LOCATION/$CDD_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/$EAR_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app

ARG_DOCKER_FILE="Dockerfile"

result=$(find "$ARG_INSTALLER_LOCATION" -type f -iname 'post-install.properties') 
if [ -z "$result" ]
then
	getASVersion
else
	if [ "$ARG_INSTALLER_LOCATION" = "../../.." ]
	then
  		perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER
	else
  		perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $ARG_INSTALLER_LOCATION
	fi

	if [ "$?" != 0 ]; then
  		echo "Creating BE archive failed"
  		rm -rf "$DOCKER_FROM_INSTALL"/$TEMP_FOLDER
  		exit $?
	fi
	AS_VERSION=$(find $ARG_INSTALLER_LOCATION/uninstaller_scripts/post-install.properties -type f | xargs grep  'asVersionShort=' | cut -d'=' -f2)
	AS_VERSION=$(echo $AS_VERSION | sed -e 's/\r//g')
	AS_SHORT_VERSION=$AS_VERSION
fi

getKinesisFlag
KINESIS_CHANNEL_FLAG=$?

cp $ARG_DOCKER_FILE $TEMP_FOLDER


ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)" 
echo "INFO:TEMP FOLDER: $TEMP_FOLDER"

docker build --force-rm -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg KINESIS_CHANNEL_FLAG=$KINESIS_CHANNEL_FLAG -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  echo "DONE: Docker build successful."
fi

echo "Deleting temporary intermediate image.."
docker rmi -f $(docker images -f "dangling=true" -q)
echo "Deleteting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER
