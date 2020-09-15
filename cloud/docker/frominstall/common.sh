#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

FILE_NAME=$(basename $0)

APP_IMAGE="build_app_image.sh"
RMS_IMAGE="build_rms_image.sh"
TEA_IMAGE="build_teagent_image.sh"

ARG_APP_LOCATION="na"
ARG_IMAGE_VERSION="na"
ARG_DOCKER_FILE="Dockerfile_fromtar"
TEMP_FOLDER="tmp_$RANDOM"

# be related args
BE_HOME="../../.."
ARG_BE_VERSION="na"
ARG_BE_SHORT_VERSION="na"

# as legacy related args
AS_LEG_HOME="na"
ARG_AS_LEG_SHORT_VERSION="na"

# ftl related args
FTL_HOME="na"
ARG_FTL_SHORT_VERSION="na"

# as related args
AS_HOME="na"
ARG_AS_SHORT_VERSION="na"

VERSION_REGEX=([0-9]\.[0-9]).*
SHORT_VERSION_REGEX=([0-9]\.[0-9])*

USAGE="\nUsage: $FILE_NAME"

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    USAGE+="\n\n [-a/--app-location]         :       Location where the application ear, cdd and other files are located [required]"
    USAGE+="\n\n [-r/--repo]                 :       The app image Repository (example - fdc:latest) [required]"
fi

USAGE+="\n\n [-l/--be-home]              :       be-home (default - ../../.. i.e; as run from its default location BE_HOME/cloud/docker/frominstall) [optional]"

if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
    USAGE+="\n\n [-r/--repo]                 :       The teagent image Repository (example - repo:tag) [optional]"

    ARG_DOCKER_FILE="Dockerfile-teagent_fromtar"
elif [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
    USAGE+="\n\n [-a/--app-location]         :       Location where the RMS ear, cdd are located [optional]"
    USAGE+="\n\n [-r/--repo]                 :       The app image Repository (example - repo:tag) [optional]"

    ARG_DOCKER_FILE="Dockerfile-rms_fromtar"
fi

USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image (default - $ARG_DOCKER_FILE) [optional]"

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    USAGE+="\n\n [--gv-providers]            :       Names of GV providers to be included in the image. Supported value(s) - consul [optional]" 
    USAGE+="\n\n [--disable-tests]           :       Disables docker unit tests on created image. [optional]"

    ARG_GVPROVIDERS="na"
    ARG_ENABLE_TESTS="true"
fi

USAGE+="\n\n [-h/--help]           	     :       Print the usage of script [optional]" 
USAGE+="\n\n NOTE : supply long options with '=' \n"

#Parse the arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -l|--be-home) 
            shift # past the key and to the value
            BE_HOME="$1"
            ;;
        -l=*|--be-home=*)
            BE_HOME="${key#*=}"
            ;;
        -r|--repo) 
            shift # past the key and to the value
            ARG_IMAGE_VERSION="$1"
            ;;
        -r=*|--repo=*)
            ARG_IMAGE_VERSION="${key#*=}"
	        ;;
        -d|--docker-file)
            shift # past the key and to the value
            ARG_DOCKER_FILE="$1"
            ;;
        -d=*|--docker-file=*)
            ARG_DOCKER_FILE="${key#*=}"
            ;;
        -h|--help) 
            shift # past the key and to the value
            printf "$USAGE"
            exit 0
            ;;
        *)
            if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
                echo "Invalid Option '$key'"
            else
                case "$key" in
                    -a|--app-location) 
                        shift # past the key and to the value
                        ARG_APP_LOCATION="$1"
                        ;;
                    -a=*|--app-location=*)
                        ARG_APP_LOCATION="${key#*=}"
                        ;;
                    *)
                        if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
                            case "$key" in
                                --gv-providers)
                                    shift # past the key and to the value
                                    ARG_GVPROVIDERS="$1"
                                    ;;
                                --gv-providers=*)
                                    ARG_GVPROVIDERS="${key#*=}"
                                    ;;
                                --disable-tests)
                                    ARG_ENABLE_TESTS="false"
                                    ;;
                                *)
                                    echo "Invalid Option '$key'"
                                    ;;
                            esac
                        else
                            echo "Invalid Option '$key'"
                        fi
                esac
            fi
    esac
    shift
done

# missing arguments check
MISSING_ARGS=""
FIRST=1

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    if [ "$ARG_APP_LOCATION" = "na" -o -z "${ARG_APP_LOCATION// }" ]; then
        if [ $FIRST = 1 ]; then
  	        MISSING_ARGS="Application Location[-a/--app-location]"
	        FIRST=0
        else
            MISSING_ARGS="$MISSING_ARGS , Application Location[-a/--app-location]"
        fi
    fi

    if [ "$ARG_IMAGE_VERSION" = "na" -o -z "${ARG_IMAGE_VERSION// }" ]; then
        if [ $FIRST = 1 ]; then
            MISSING_ARGS="Image version[-r/--repo]"
	        FIRST=0
        else
            MISSING_ARGS="$MISSING_ARGS , Image version[-r/--repo]"
        fi
    fi
fi

if [ "$MISSING_ARGS" != "" ]; then
    printf "\nERROR: Missing mandatory argument(s) : $MISSING_ARGS\n"
    printf "$USAGE"
    exit 1; 
fi

if [ "$FILE_NAME" = "$APP_IMAGE" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory - $ARG_APP_LOCATION is not a valid directory. Enter a valid directory and try again.\n"
    exit 1;
elif [ "$ARG_APP_LOCATION" != "na" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory - $ARG_APP_LOCATION is not a valid directory. Ignoring app location.\n"
    ARG_APP_LOCATION="na"
fi

# count cdd and ear in app location
if [ "$ARG_APP_LOCATION" != "na" ]; then
    #Check App location have ear or not
    ears=$(find $ARG_APP_LOCATION -name "*.ear")
    earCnt=$(find $ARG_APP_LOCATION -name "*.ear" | wc -l)

    if [ $earCnt -ne 1 ]; then
        printf "ERROR: The directory - $ARG_APP_LOCATION must have single EAR file\n"
        exit 1
    fi

    #Check App location have cdd or not
    cdds=$(find $ARG_APP_LOCATION -name "*.cdd")
    cddCnt=$(find $ARG_APP_LOCATION -name "*.cdd" | wc -l)

    if [ $cddCnt -ne 1 ]; then
        printf "ERROR: The directory - $ARG_APP_LOCATION must have single CDD file\n"
        exit 1

    fi

    EAR_FILE_NAME="$(basename -- ${ears[0]})"
    CDD_FILE_NAME="$(basename -- ${cdds[0]})"
fi

# TO DO check be home
ARG_BE_VERSION=$(find $BE_HOME/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
ARG_BE_VERSION=$(echo $ARG_BE_VERSION | sed -e 's/\r//g')

if [[ $ARG_BE_VERSION =~ $VERSION_REGEX ]]; then
	ARG_BE_SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR: Improper Be version: [$ARG_BE_VERSION]. Aborting."
	exit 1
fi

if [ "$FILE_NAME" != "$TEA_IMAGE" ]; then
    ## get as legacy version
    AS_LEG_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.AS_HOME | cut -d'=' -f 2)
    AS_LEG_HOME=${AS_LEG_HOME%?}
    if [ "$AS_LEG_HOME" = "" ]; then
        AS_LEG_HOME="na"
    else
        ARG_AS_LEG_SHORT_VERSION=$( echo ${AS_LEG_HOME}  | rev | cut -d'/' -f1 | rev )
        if ! [[ $ARG_AS_LEG_SHORT_VERSION =~ $SHORT_VERSION_REGEX ]]; then
            echo "ERROR: Improper As legacy version: [$ARG_AS_LEG_SHORT_VERSION]. Aborting."
            exit 1
        fi
    fi
fi

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    # get ftl home
    FTL_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.FTL_HOME | cut -d'=' -f 2)
    FTL_HOME=${FTL_HOME%?}
    echo [$FTL_HOME]
    if [ "$FTL_HOME" = "" ]; then
        FTL_HOME="na"
    else
        ARG_FTL_SHORT_VERSION=$( echo ${FTL_HOME}  | rev | cut -d'/' -f1 | rev )
        if ! [[ $ARG_FTL_SHORT_VERSION =~ $SHORT_VERSION_REGEX ]]; then
            echo "ERROR: Improper FTL version: [$ARG_FTL_SHORT_VERSION]. Aborting."
            exit 1
        fi
    fi
    echo ARG_FTL_SHORT_VERSION:[$ARG_FTL_SHORT_VERSION]

    # get activespaces home
    AS_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.ACTIVESPACES_HOME | cut -d'=' -f 2)
    AS_HOME=${AS_HOME%?}
    if [ "$AS_HOME" = "" ]; then
        AS_HOME="na"
    else
        ARG_AS_SHORT_VERSION=$( echo ${AS_HOME}  | rev | cut -d'/' -f1 | rev )
        if ! [[ $ARG_AS_SHORT_VERSION =~ $SHORT_VERSION_REGEX ]]; then
            echo "ERROR: Improper As version: [$ARG_AS_SHORT_VERSION]. Aborting."
            exit 1
        fi
    fi
fi

# image name check
if [ "$ARG_IMAGE_VERSION" = "na" -o -z "${ARG_IMAGE_VERSION// }" ]; then
    if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
        ARG_IMAGE_VERSION="teagent:$ARG_BE_VERSION";
    elif [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
        ARG_IMAGE_VERSION="rms:$ARG_BE_VERSION";
    fi
fi

# information display
echo "INFO: Supplied Arguments   :"
echo "------------------------------------------------------------------------------"

if ! [ "$ARG_APP_LOCATION" = "na" ]; then
    echo "INFO: APPLICATION DATA DIRECTORY   : [$ARG_APP_LOCATION]"
fi

if ! [ "$BE_HOME" = "na" -o -z "${BE_HOME// }" ]; then
    echo "INFO: BE HOME                      : [$BE_HOME]"
fi

if ! [ "$AS_LEG_HOME" = "na" -o -z "${AS_LEG_HOME// }" ]; then
    echo "INFO: AS LEGACY HOME               : [$AS_LEG_HOME]"
fi

if ! [ "$FTL_HOME" = "na" -o -z "${FTL_HOME// }" ]; then
    echo "INFO: FTL HOME                     : [$FTL_HOME]"
fi

if ! [ "$AS_HOME" = "na" -o -z "${AS_HOME// }" ]; then
    echo "INFO: AS HOME                      : [$AS_HOME]"
fi

if ! [ -z "${EAR_FILE_NAME//}" -o -z "${CDD_FILE_NAME//}" ]; then
    echo "INFO: CDD FILE NAME                : [$CDD_FILE_NAME]"
    echo "INFO: EAR FILE NAME                : [$EAR_FILE_NAME]"    
fi

echo "INFO: DOCKERFILE                   : [$ARG_DOCKER_FILE]"
echo "INFO: IMAGE VERSION                : [$ARG_IMAGE_VERSION]"

echo "------------------------------------------------------------------------------"

mkdir $TEMP_FOLDER
cp -a "../lib" $TEMP_FOLDER/

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    cp -a "../gvproviders" $TEMP_FOLDER/
fi
if [ "$ARG_APP_LOCATION" != "na" ]; then
    mkdir -p $TEMP_FOLDER/app
    cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app
fi

perl ../lib/genbetar.pl $(pwd)/$TEMP_FOLDER $BE_HOME $FTL_HOME $AS_HOME

if [ "$?" != 0 ]; then
    echo "ERROR: Creating BE archive failed"
    rm -rf $TEMP_FOLDER
    exit $?
fi

# building docker image
echo "INFO: Building docker image for TIBCO BusinessEvents Version: [$ARG_BE_VERSION], Image Version: [$ARG_IMAGE_VERSION] and Dockerfile: [$ARG_DOCKER_FILE]."

cp $ARG_DOCKER_FILE $TEMP_FOLDER/
docker build -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER"

echo "Deleting [$TEMP_FOLDER] folder"
rm -rf $TEMP_FOLDER

if [ "$?" != 0 ]; then
    echo "Docker build failed."
else
    BUILD_SUCCESS="true"
    echo "DONE: Docker build successful."
fi

# docker unit tests
if [[ ($BUILD_SUCCESS = "true") && ($ARG_ENABLE_TESTS = "true") && ("$FILE_NAME" = "$APP_IMAGE") ]]; then
	cd ../tests
	source run_tests.sh -i $ARG_IMAGE_VERSION  -b $ARG_BE_SHORT_VERSION -c $CDD_FILE_NAME -e $EAR_FILE_NAME -al $ARG_AS_LEG_SHORT_VERSION -as $ARG_AS_SHORT_VERSION -f $ARG_FTL_SHORT_VERSION
fi