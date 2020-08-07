#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

USAGE="\nUsage: build_app_image.sh"
source ../s2i/create_builder_image.sh $@ --nos2i


#Check App location have ear or not
ears=$(find $ARG_APP_LOCATION -name "*.ear")
earCnt=$(find $ARG_APP_LOCATION -name "*.ear" | wc -l)

 if [ $earCnt -ne 1 ]; then
	printf "ERROR:The directory - $ARG_APP_LOCATION must have single EAR file\n"
	exit 1
 fi

#Check App location have cdd or not
cdds=$(find $ARG_APP_LOCATION -name "*.cdd")
cddCnt=$(find $ARG_APP_LOCATION -name "*.cdd" | wc -l)

 if [ $cddCnt -ne 1 ]; then
	printf "ERROR:The directory - $ARG_APP_LOCATION must have single CDD file\n"
	exit 1

 fi

EAR_FILE_NAME="$(basename -- ${ears[0]})"
CDD_FILE_NAME="$(basename -- ${cdds[0]})"


mkdir -p $TEMP_FOLDER/app

cp $ARG_APP_LOCATION/$CDD_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/$EAR_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app

echo "INFO:CDD FILE NAME : $CDD_FILE_NAME"
echo "INFO:EAR FILE NAME : $EAR_FILE_NAME"

CURRENT_DIR=$( cd $(dirname $0) ; pwd -P )

cp $ARG_DOCKER_FILE $TEMP_FOLDER

ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"

docker build --force-rm -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_INSTALLER_LOCATION" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg FTL_VERSION="$FTL_VERSION" --build-arg FTL_SHORT_VERSION="$FTL_SHORT_VERSION" --build-arg FTL_PRODUCT_HOTFIX="$ARG_FTL_HOTFIX" --build-arg ACTIVESPACES_VERSION="$ACTIVESPACES_VERSION" --build-arg ACTIVESPACES_SHORT_VERSION="$ACTIVESPACES_SHORT_VERSION" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="$ARG_ACTIVESPACES_HOTFIX" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  BUILD_SUCCESS='true'
  echo "DONE: Docker build successful."
fi

echo "Deleting temporary intermediate image.."
docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
echo "Deleting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER

if [ $BUILD_SUCCESS == 'true' ]; then
	cd ../tests
	source run_tests.sh -i $ARG_IMAGE_VERSION  -b $SHORT_VERSION -c $CDD_FILE_NAME -e $EAR_FILE_NAME -al $AS_SHORT_VERSION -as $ACTIVESPACES_SHORT_VERSION -f $FTL_SHORT_VERSION
fi