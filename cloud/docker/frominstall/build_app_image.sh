#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

USAGE="\nUsage: build_app_image.sh\n"
USAGE+="[-a|--app-location]         :       Location where the application ear, cdd and other files are located [required]\n"
USAGE+="[-r|--repo]                 :       The app image Repository (example - fdc:latest) [required]\n"
USAGE+="[-l|--be-home]              :       be-home [optional, default: "../../.." i.e; as run from its default location BE_HOME/cloud/docker/frominstall] [optional]\n"
USAGE+="[-d|--docker-file]          :       Dockerfile to be used for generating image (default: Dockerfile_fromtar) [optional]\n"
USAGE+="[--gv-providers]            :       Names of GV providers to be included in the image. Supported value(s) - consul [optional]\n"
USAGE+="[-h|--help]                 :       Print the usage of script [optional]\n";
USAGE+="[-c|--cluster-type]          :      Provide the type of cluster as AS2x/FTL\n";

ARG_DOCKER_FILE="Dockerfile_fromtar"
ARG_APP_LOCATION="na"
ARG_VERSION="na"
ARG_IMAGE_VERSION="na"
BE_HOME="../../.."
FTL_HOME=/opt/tibco/ftl/6.4
TEMP_FOLDER="tmp_$RANDOM"
ARG_GVPROVIDERS="na"
ARG_CLUSTER_TYPE="na"

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
	--gv-providers)
        shift # past the key and to the value
        ARG_GVPROVIDERS="$1"
        ;;
        --gv-providers=*)
        ARG_GVPROVIDERS="${key#*=}"
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
	-a|--app-location) 
        shift # past the key and to the value
        ARG_APP_LOCATION="$1"
        ;;
        -a=*|--app-location=*)
        ARG_APP_LOCATION="${key#*=}"
        ;;
  -c|--cluster-type) 
        shift # past the key and to the value
        ARG_CLUSTER_TYPE="$1"
        ;;
        -a=*|--cluster-type=*)
        ARG_CLUSTER_TYPE="${key#*=}"
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

MISSING_ARGS="-"
FIRST=1

if [ "$ARG_APP_LOCATION" = "na" -o "$ARG_APP_LOCATION" = "nax" -o -z "${ARG_APP_LOCATION// }" ]
then
  if [ $FIRST = 1 ]
  then 
  	MISSING_ARGS="$MISSING_ARGS Application Location[-a|--app-location]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Application Location[-a|--app-location]"
  fi
fi

if [ "$ARG_IMAGE_VERSION" = "na" -o "$ARG_IMAGE_VERSION" = "nax" -o -z "${ARG_IMAGE_VERSION// }" ]
then
  if [ $FIRST = 1 ]
  then
    MISSING_ARGS="$MISSING_ARGS Image repo[-r|--repo]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Image repo[-r|--repo]"
  fi
fi

if [ "$ARG_CLUSTER_TYPE" = "na" -o "$ARG_CLUSTER_TYPE" = "nax" -o -z "${ARG_CLUSTER_TYPE// }" ]
then
  if [ $FIRST = 1 ]
  then
    MISSING_ARGS="$MISSING_ARGS clusterType [-c|--cluster-type]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , clusterType [-c|--cluster-type]"
  fi
fi

if [ "$MISSING_ARGS" != "-" ]
then
  printf "\nERROR: Missing mandatory argument(s) : $MISSING_ARGS\n"
  printf "$USAGE"
  exit 1;
fi

if [ ! -d "$ARG_APP_LOCATION" ]
then
  printf "ERROR: The directory - $ARG_APP_LOCATION is not a valid directory. Enter a valid directory and try again.\n"
  exit 1;
fi

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
ARG_VERSION=$(find $BE_HOME/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
ARG_VERSION=$(echo $ARG_VERSION | sed -e 's/\r//g')
echo "----------------------------------------------"
echo "INFO: VERSION : $ARG_VERSION"
echo "INFO: APPLICATION DATA DIRECTORY : $ARG_APP_LOCATION"
echo "INFO: DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO: IMAGE REPO : $ARG_IMAGE_VERSION"
echo "INFO: CDD FILE NAME : $CDD_FILE_NAME"
echo "INFO: EAR FILE NAME : $EAR_FILE_NAME"
echo "INFO: CLUSTER TYPE: $ARG_CLUSTER_TYPE"
echo "----------------------------------------------"

DOCKER_BIN_DIR="$BE_HOME"/cloud/docker/bin
DOCKER_FROM_INSTALL="$BE_HOME"/cloud/docker/frominstall

mkdir -p $TEMP_FOLDER/app
cp -a "../lib" $TEMP_FOLDER/
cp -a "../gvproviders" $TEMP_FOLDER/
cp $ARG_APP_LOCATION/$CDD_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/$EAR_FILE_NAME $TEMP_FOLDER/app
cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app

# if [ "$BE_HOME" = "../../.." ]
# then
#   perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER
# else
#   perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $BE_HOME
# fi

if [ $ARG_CLUSTER_TYPE == "FTL" ]; then
    perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $BE_HOME $ARG_CLUSTER_TYPE $FTL_HOME
else
    perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $BE_HOME $ARG_CLUSTER_TYPE
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
docker build -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER"

if [ "$?" != 0 ]; then
  echo "Docker build failed."
  rm -rf $TEMP_FOLDER
  exit $?
else
  echo "DONE: Docker build successful."
  # rm -rf $TEMP_FOLDER
  exit 0
fi
