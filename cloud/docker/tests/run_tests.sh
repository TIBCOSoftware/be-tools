#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

## default arguments
ARG_IMAGE_NAME=na
ARG_BE_VERSION=na
ARG_AS_LEG_VERSION=na
ARG_AS_VERSION=na
ARG_FTL_VERSION=na

## local variables
TEMP_FOLDER="tmp_$RANDOM"

## usage
if [ -z "${USAGE}" ]; then
  USAGE="\nUsage: run_tests.sh"
fi

USAGE+="\n\n [ -i|--image-name]           : Be app image name with tag <image-name>:<tag> ex(be6:v1) [required]"
USAGE+="\n\n [ -b|--be-version]           : Be version in x.x format ex(5.6) [required]"
USAGE+="\n\n [-al|--as-legacy-version]    : Activespaces legacy version in x.x format ex(2.4) [optional]"
USAGE+="\n\n [-as|--as-version]           : Activespaces version in x.x format ex(4.4) [optional]"
USAGE+="\n\n [ -f|--ftl-version]          : Ftl version in x.x format ex(6.4) [optional]"
USAGE+="\n\n [ -h|--help]                 : Print the usage of script [optional]"
USAGE+="\n\n NOTE : supply long options with '=' \n\n"


## arguments check
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -i|--image-name)
        shift # past the key and to the value
        ARG_IMAGE_NAME="$1"
        ;;
        -i=*|--image-name=*)
        ARG_IMAGE_NAME="${key#*=}"
        ;;
		    -b|--be-version)
        shift # past the key and to the value
        ARG_BE_VERSION="$1"
        ;;
        -b=*|--be-version=*)
        ARG_BE_VERSION="${key#*=}"
        ;;
        -al|--as-legacy-version)
        shift # past the key and to the value
        ARG_AS_LEG_VERSION="$1"
        ;;
        -al=*|--as-legacy-version=*)
        ARG_AS_LEG_VERSION="${key#*=}"
	      ;;
        -as|--as-version)
        shift # past the key and to the value
        ARG_AS_VERSION="$1"
        ;;
        -as=*|--as-version=*)
        ARG_AS_VERSION="${key#*=}"
        ;;
        -f|--ftl-version)
        shift # past the key and to the value
        ARG_FTL_VERSION="$1"
        ;;
        -f=*|--ftl-version=*)
        ARG_FTL_VERSION="${key#*=}"
        ;;
        -h|--help)
        shift # past the key and to the value
        printf "$USAGE"
        exit 0
	      ;;
	      *)
        echo "Invalid Option '$key'"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done

## validating and appending config files based on argument values
echo "-----------------------------------------------"
if [ $ARG_IMAGE_NAME == na ]; then
  echo "ERROR: Be app image name is mandatory "
  printf " ${USAGE} "
  exit 1;
else
  echo "INFO: image name         --[${ARG_IMAGE_NAME}]"
fi

CONFIG_FILE_ARGS=''

## be version validation
if [ $ARG_BE_VERSION != na ]; then
  echo "INFO: be version         --[${ARG_BE_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/be-${ARG_BE_VERSION}-testcases.yaml "
else
  echo "ERROR: Be version is mandatory "
  printf " ${USAGE} "
  exit 1;
fi

## as legacy version validation
if [ $ARG_AS_LEG_VERSION != na ]; then
  echo "INFO: as legacy version  --[${ARG_AS_LEG_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/as-${ARG_AS_LEG_VERSION}-${ARG_BE_VERSION}-testcases.yaml "
fi

## as version validation
if [ $ARG_AS_VERSION != na ]; then
  echo "INFO: as version         --[${ARG_AS_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/as-${ARG_AS_VERSION}-${ARG_BE_VERSION}-testcases.yaml "
fi

## ftl version validation
if [ $ARG_FTL_VERSION != na ]; then
  echo "INFO: ftl version        --[${ARG_FTL_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/ftl-${ARG_FTL_VERSION}-${ARG_BE_VERSION}-testcases.yaml "
fi

echo "-----------------------------------------------"
echo ""

## generate testcases
source generate_testcases.sh

echo "INFO: Running container structure tests on BE application image [$ARG_IMAGE_NAME]."

## docker test command
docker run -i --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${PWD}:/test gcr.io/gcp-runtimes/container-structure-test:latest \
    test \
    --image ${ARG_IMAGE_NAME} \
    ${CONFIG_FILE_ARGS}

## rem temp dir
rm -r ${TEMP_FOLDER}