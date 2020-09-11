#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source ../common/common.sh

if [[ "$*" == *nos2i* ]]; then
	IS_S2I="false"
else
	IS_S2I="true"
fi

BE_TAG="com.tibco.be"
S2I_DOCKER_FILE_BASE="bin/Dockerfile"
S2I_DOCKER_FILE_APP="Dockerfile"


mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/installers
cp -a "../lib" $TEMP_FOLDER/
cp -a "../gvproviders" $TEMP_FOLDER/

 export PERL5LIB="../lib"

 VALIDATION_RESULT=$(perl -Mbe_docker_install -e "be_docker_install::validate('$ARG_INSTALLER_LOCATION','$ARG_VERSION','$ARG_EDITION','$ARG_ADDONS','$ARG_BE_HOTFIX','$ARG_AS_HOTFIX','$ARG_FTL_HOTFIX','$ARG_ACTIVESPACES_HOTFIX','$TEMP_FOLDER');")

if [ "$?" = 0 ]
then
  printf "$VALIDATION_RESULT\n"
  exit 1;
fi


echo "INFO:Copying Packages.."

CURRENT_DIR=$( cd $(dirname $0) ; pwd -P )

while read -r line
do
    name="$line"
	cp $name $TEMP_FOLDER/installers
    done < "$TEMP_FOLDER/package_files.txt"

  AS_VERSION=$(perl -nle 'print $1 if m{.*activespaces.*([\d].[\d].[\d])_linux}' $TEMP_FOLDER/package_files.txt)

if [ "$AS_VERSION" = "" ]; then
	AS_VERSION="na"
fi

if [[ $strname =~ 3(.+)r ]]; then
    strresult=${BASH_REMATCH[1]}
fi

if [[ ($AS_VERSION != "na") && ($ARG_FTL_VERSION != "na") ]]; then
	echo "WARN: The directory - $ARG_INSTALLER_LOCATION contains both FTL and AS legacy installers. Removing unused installer improves the docker image size."
fi

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
if [[ "$AS_VERSION" != "na" ]]
	then
	if [[ $AS_VERSION =~ $VERSION_REGEX ]]
	then
		AS_SHORT_VERSION=${BASH_REMATCH[1]};
	else
		echo "ERROR:Improper As version.Aborting."
		echo "Deleting temporary intermediate image.."
 		docker rmi -f $(docker images -q -f "label=be-intermediate-image=true")
 		echo "Deleteting $TEMP_FOLDER folder"
		rm -rf $TEMP_FOLDER
		exit 1
	fi
fi

# Evaluate FTL version & short version
FTL_VERSION=$ARG_FTL_VERSION
if [[ "$FTL_VERSION" != "na" ]]; then
	if [[ $FTL_VERSION =~ $VERSION_REGEX ]]; then
		FTL_SHORT_VERSION=${BASH_REMATCH[1]};
	else
		echo "ERROR:Improper FTL version.Aborting."
		echo "Deleteting $TEMP_FOLDER folder"
		rm -rf $TEMP_FOLDER
		exit 1
	fi
fi

# Evaluate ACTIVESPACES version & short version
ACTIVESPACES_VERSION=$ARG_ACTIVESPACES_VERSION
if [[ "$ACTIVESPACES_VERSION" != "na" ]]; then
	if [[ $ACTIVESPACES_VERSION =~ $VERSION_REGEX ]]; then
		ACTIVESPACES_SHORT_VERSION=${BASH_REMATCH[1]};
	else
		echo "ERROR:Improper activespaces version.Aborting."
		echo "Deleteting $TEMP_FOLDER folder"
		rm -rf $TEMP_FOLDER
		exit 1
	fi
fi

if [ "$IS_S2I" = "true" ]; then
	cd ../bin
	cp $ARG_DOCKER_FILE $CURRENT_DIR/$TEMP_FOLDER

	cd ../s2i

	ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"

	mkdir -p $TEMP_FOLDER/app
	cd $TEMP_FOLDER/app
	touch dummy.txt
	cd ../..

	docker build --force-rm -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_INSTALLER_LOCATION" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg FTL_VERSION="$FTL_VERSION" --build-arg FTL_SHORT_VERSION="$FTL_SHORT_VERSION" --build-arg FTL_PRODUCT_HOTFIX="$ARG_FTL_HOTFIX" --build-arg ACTIVESPACES_VERSION="$ACTIVESPACES_VERSION" --build-arg ACTIVESPACES_SHORT_VERSION="$ACTIVESPACES_SHORT_VERSION" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="$ARG_ACTIVESPACES_HOTFIX" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER --build-arg CDD_FILE_NAME=dummy.txt --build-arg EAR_FILE_NAME=dummy.txt --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$BE_TAG":"$ARG_VERSION"-"$ARG_VERSION" $TEMP_FOLDER

	if [ "$?" != 0 ]; then
		echo "Docker build failed."
	else
		find . -name \*.zip -delete
		rm "$ARG_INSTALLER_LOCATION/package_files.txt"
		echo "DONE: Docker build successful."
		BUILD_SUCCESS='true'
	fi

	echo "Deleting temporary intermediate image.."
	docker rmi -f  $(docker images -q -f "label=be-intermediate-image=true")
	echo "Deleting $TEMP_FOLDER folder"
	rm -rf $TEMP_FOLDER

	docker build -f $S2I_DOCKER_FILE_APP --build-arg BE_TAG="$BE_TAG" --build-arg ARG_VERSION="$ARG_VERSION" -t "$ARG_IMAGE_VERSION" .

	docker rmi -f "$BE_TAG":"$ARG_VERSION"-"$ARG_VERSION"

	rm -rf app

	if [[ ($BUILD_SUCCESS == 'true') && ($ARG_ENABLE_TESTS == "true") ]]; then
		cd ../tests
		EAR_FILE_NAME="dummy.txt"
		CDD_FILE_NAME="dummy.txt"
		source run_tests.sh -i $ARG_IMAGE_VERSION  -b $SHORT_VERSION -c $CDD_FILE_NAME -e $EAR_FILE_NAME -al $AS_SHORT_VERSION -as $ACTIVESPACES_SHORT_VERSION -f $FTL_SHORT_VERSION
	fi

fi
