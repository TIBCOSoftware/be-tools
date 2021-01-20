#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

## default arguments
ARG_IMAGE_NAME=na
ARG_BE_SHORT_VERSION=na
ARG_CDD_FILE_NAME=na
ARG_EAR_FILE_NAME=na
ARG_AS_LEG_SHORT_VERSION=na
ARG_AS_SHORT_VERSION=na
ARG_FTL_SHORT_VERSION=na
ARG_GV_PROVIDER=na
ARG_KEY_VALUE_PAIRS=''

## local variables
TEMP_FOLDER="tmp_$RANDOM"
FIXED_TESTCASES="be.yaml,as.yaml,aslegacy.yaml,ftl.yaml,consulgv.yaml,httpgv.yaml"

## usage
if [ -z "${USAGE}" ]; then
  USAGE="\nUsage: run_tests.sh"
fi

USAGE+="\n\n [ -i|--image-name]           : BE app image name with tag <image-name>:<tag> ex(be6:v1) [required]"
USAGE+="\n\n [ -b|--be-version]           : BE version in x.x format ex(6.1) [required]"
USAGE+="\n\n [-al|--as-legacy-version]    : AS legacy version in x.x format ex(2.4) [optional]"
USAGE+="\n\n [-as|--as-version]           : ACTIVESPACES version in x.x format ex(4.5) [optional]"
USAGE+="\n\n [ -f|--ftl-version]          : FTL version in x.x format ex(6.5) [optional]"
USAGE+="\n\n [-kv|--key-value-pair]       : Key value pairs to replace in yaml files ex(JRE_VERSION=11) can be multiple [optional]"
USAGE+="\n\n [-gv|--gv-provider]          : GV Provider value ex(consul) [optional]"
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
        ARG_BE_SHORT_VERSION="$1"
        ;;
        -b=*|--be-version=*)
        ARG_BE_SHORT_VERSION="${key#*=}"
        ;;
        -al|--as-legacy-version)
        shift # past the key and to the value
        ARG_AS_LEG_SHORT_VERSION="$1"
        ;;
        -al=*|--as-legacy-version=*)
        ARG_AS_LEG_SHORT_VERSION="${key#*=}"
	      ;;
        -as|--as-version)
        shift # past the key and to the value
        ARG_AS_SHORT_VERSION="$1"
        ;;
        -as=*|--as-version=*)
        ARG_AS_SHORT_VERSION="${key#*=}"
        ;;
        -gv|--gv-provider)
        shift # past the key and to the value
        ARG_GV_PROVIDER="$1"
        ;;
        -gv=*|--gv-provider=*)
        ARG_GV_PROVIDER="${key#*=}"
        ;;
        -f|--ftl-version)
        shift # past the key and to the value
        ARG_FTL_SHORT_VERSION="$1"
        ;;
        -f=*|--ftl-version=*)
        ARG_FTL_SHORT_VERSION="${key#*=}"
        ;;
        -kv|--key-value-pair)
        shift # past the key and to the value
        ARG_KEY_VALUE_PAIRS+=" $1"
        ;;
        -kv=*|--key-value-pair=*)
        ARG_KEY_VALUE_PAIRS+=" ${key#*=}"
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

DOCKER_CONTEXT_TLS=$(docker context inspect -f="{{.TLSMaterial.docker}}")
DOCKER_HOST=$(docker context inspect -f="{{.Endpoints.docker.Host}}")

if [[ $DOCKER_CONTEXT_TLS =~ pem  && $DOCKER_HOST =~ tcp:// ]]; then
  echo "Skipping docker container structure tests, as docker context is not pointing to local docker daemon"
  exit 0
fi

echo ""
echo "=================RUNNING CONTAINER STRUCTURE TESTS================="
echo ""

## validating and appending config files based on argument values
echo "-----------------------------------------------"
if [ $ARG_IMAGE_NAME == na ]; then
  echo "ERROR: Be app image name is mandatory "
  printf " ${USAGE} "
  exit 1;
else
  echo "INFO: image name:          [${ARG_IMAGE_NAME}]"
fi

CONFIG_FILE_ARGS=''
SED_EXP=''

## be version validation
if [ $ARG_BE_SHORT_VERSION != na ]; then
  echo "INFO: be version:          [${ARG_BE_SHORT_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/be.yaml "
  SED_EXP+=" -e s/BE_SHORT_VERSION/${ARG_BE_SHORT_VERSION}/g "
else
  echo "ERROR: Be version is mandatory "
  printf " ${USAGE} "
  exit 1;
fi

## as legacy version validation
if [ $ARG_AS_LEG_SHORT_VERSION != na ]; then
  echo "INFO: as legacy version:   [${ARG_AS_LEG_SHORT_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/aslegacy.yaml "
  SED_EXP+=" -e s/AS_LEG_SHORT_VERSION/${ARG_AS_LEG_SHORT_VERSION}/g "
fi

## as version validation
if [ $ARG_AS_SHORT_VERSION != na ]; then
  echo "INFO: as version:          [${ARG_AS_SHORT_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/as.yaml "
  SED_EXP+=" -e s/AS_SHORT_VERSION/${ARG_AS_SHORT_VERSION}/g "
fi

## ftl version validation
if [ $ARG_FTL_SHORT_VERSION != na ]; then
  echo "INFO: ftl version:         [${ARG_FTL_SHORT_VERSION}]"
  CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/ftl.yaml "
  SED_EXP+=" -e s/FTL_SHORT_VERSION/${ARG_FTL_SHORT_VERSION}/g "
fi

## GV provider validation
if [ $ARG_GV_PROVIDER != na ]; then
  echo "INFO: gv provider:         [${ARG_GV_PROVIDER}]"
  if [ "$ARG_GV_PROVIDER" = "consul" ]; then
    CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/consulgv.yaml "
  elif [ "$ARG_GV_PROVIDER" = "http" ]; then
    CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/httpgv.yaml "
  fi
fi

## key value pairs validation
if [ "${ARG_KEY_VALUE_PAIRS}" != "" ]; then
  echo "INFO: key value pairs:     [${ARG_KEY_VALUE_PAIRS}]"
  for kv in $ARG_KEY_VALUE_PAIRS ; do
    if [[ $kv != *"="* ]]; then
      echo "ERROR: Invalid key value pairs"
      printf " ${USAGE} "
      exit 1
    else
      KEY=$(echo $kv | cut -d'=' -f1)
      VAL=$(echo $kv | cut -d'=' -f2)
      ## setting kv pair as top values in sed expression string
      if [[ $SED_EXP == *"$KEY"* ]]; then
        SED_EXP=" -e s/${KEY}/${VAL}/g $SED_EXP"
      else
        SED_EXP+=" -e s/${KEY}/${VAL}/g "
      fi
    fi
  done
fi

echo "-----------------------------------------------"
echo ""

## copying testcases and updating ftl/as/be short versions
mkdir ${TEMP_FOLDER}
FILES=${PWD}/testcases/*
for f in $FILES ; do
  FILE_NAME=$(basename ${f})
  sed  ${SED_EXP} $f  > ${PWD}/${TEMP_FOLDER}/${FILE_NAME}
  if [[ ${FIXED_TESTCASES} != *${FILE_NAME}* ]]; then
    CONFIG_FILE_ARGS+=" --config /test/${TEMP_FOLDER}/${FILE_NAME} "
  fi
done

## docker test command
docker run -i --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${PWD}:/test gcr.io/gcp-runtimes/container-structure-test:v1.9.1 \
    test \
    --image ${ARG_IMAGE_NAME} \
    ${CONFIG_FILE_ARGS}

## rem temp dir
rm -r ${TEMP_FOLDER}

echo ""
echo "=================END OF CONTAINER STRUCTURE TESTS=================="
echo ""
