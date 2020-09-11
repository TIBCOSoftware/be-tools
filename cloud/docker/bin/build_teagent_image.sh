#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source ../common/common.sh


mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/{installers,app}
cp -a "../lib" $TEMP_FOLDER/

export PERL5LIB="../lib"
VALIDATION_RESULT=$(perl -Mbe_docker_install -e "be_docker_install::validate('$ARG_INSTALLER_LOCATION','$ARG_VERSION','$ARG_EDITION','$ARG_ADDONS','$ARG_BE_HOTFIX','$ARG_AS_HOTFIX','na','na','$TEMP_FOLDER');")

if [ "$?" = 0 ]
then
  printf "$VALIDATION_RESULT\n"
  exit 1;
fi


echo "INFO:Copying Packages.."

while read -r line
do
    name="$line"
    cp $name $TEMP_FOLDER/installers
done < "$TEMP_FOLDER/package_files.txt"

echo "INFO:Building docker image for TIBCO BusinessEvents Version:$ARG_VERSION and Image Version:$ARG_IMAGE_VERSION and Docker file:$ARG_DOCKER_FILE"

VERSION_REGEX=([0-9]\.[0-9]).*
if [[ $ARG_VERSION =~ $VERSION_REGEX ]]
then
	SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR:Improper version.Aborting."
	echo "Deleting temporary intermediate image.."
 	docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
 	echo "Deleteting $TEMP_FOLDER folder"
	rm -rf $TEMP_FOLDER
	exit 1
fi

cp $ARG_DOCKER_FILE $TEMP_FOLDER
ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"
docker build --force-rm -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION"  --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX"  --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE  --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  echo "DONE: Docker build successful."
fi

 echo "Deleting temporary intermediate image.."
 docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
 echo "Deleteting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER
