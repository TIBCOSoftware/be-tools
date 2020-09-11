#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

#Map used to store the BE and it's comapatible JRE version
declare -a BE_VERSION_AND_JRE_MAP
BE_VERSION_AND_JRE_MAP=("5.6.0" "1.8.0" "5.6.1" "11" "6.0.0" "11")

FILE_NAME=$(basename $0)
SOURCE_DIR=$(basename $(pwd))

APP_IMAGE="build_app_image.sh"
RMS_IMAGE="build_rms_image.sh"
TEA_IMAGE="build_teagent_image.sh"
BUILDER_IMAGE="create_builder_image.sh"

ARG_INSTALLER_LOCATION="na"
ARG_APP_LOCATION="na"
ARG_IMAGE_VERSION="na"
ARG_DOCKER_FILE="Dockerfile"
TEMP_FOLDER="tmp_$RANDOM"

USAGE="\nUsage: $FILE_NAME"
USAGE+="\n\n [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]"

if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
    USAGE+="\n\n [-r/--repo]                 :       The teagent image Repository (example - repo:tag) [optional]"
    USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-teagent) [optional]"

    ARG_DOCKER_FILE="Dockerfile-teagent"
elif [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
    USAGE+="\n\n [-a/--app-location]         :       Location where the RMS ear, cdd are located [optional]"
    USAGE+="\n\n [-r/--repo]                 :       The app image Repository (example - repo:tag) [optional]"
    USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-rms) [optional]"

    ARG_DOCKER_FILE="Dockerfile-rms"
elif [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    USAGE+="\n\n [-a/--app-location]         :       Location where the application ear, cdd and other files are located [required]"
    USAGE+="\n\n [-r/--repo]                 :       The app image Repository (example - fdc:latest) [required]"
elif [ "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
    USAGE+="\n\n [-r/--repo]                 :       The builder image Repository (example - s2ibuilder:latest) [required]"
fi

if [ "$FILE_NAME" = "$APP_IMAGE" -o "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
    USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image.(default Dockerfile) [optional]"
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
        -l|--installers-location) 
            shift # past the key and to the value
            ARG_INSTALLER_LOCATION="$1"
            ;;
        -l=*|--installers-location=*)
            ARG_INSTALLER_LOCATION="${key#*=}"
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
            if [ "$FILE_NAME" = "$RMS_IMAGE" -o "$FILE_NAME" = "$APP_IMAGE" -o "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
                case "$key" in
                    -a|--app-location) 
                        shift # past the key and to the value
                        ARG_APP_LOCATION="$1"
                        ;;
                    -a=*|--app-location=*)
                        ARG_APP_LOCATION="${key#*=}"
                        ;;
                    *)
                        if [ "$FILE_NAME" = "$APP_IMAGE" -o "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
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
                        fi

                        if [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
                            echo "Invalid Option '$key'"
                        fi

                esac
            fi

            if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
                echo "Invalid Option '$key'"
            fi
    esac
    shift
done

# missing arguments check
MISSING_ARGS=""
FIRST=1

if [ "$ARG_INSTALLER_LOCATION" = "na" -o -z "${ARG_INSTALLER_LOCATION// }" ]; then
    MISSING_ARGS="Installers Location[-l/--installers-location]"
    FIRST=0
fi

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    if [ "$ARG_APP_LOCATION" = "na" -o -z "${ARG_APP_LOCATION// }" ]; then
        if [ $FIRST = 1 ]; then
  	        MISSING_ARGS="Application Location[-a/--app-location]"
	        FIRST=0
        else
            MISSING_ARGS="$MISSING_ARGS , Application Location[-a/--app-location]"
        fi
    fi
fi

if [ "$FILE_NAME" = "$APP_IMAGE" -o "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
    if [ "$ARG_IMAGE_VERSION" = "na" -o -z "${ARG_IMAGE_VERSION// }" ]; then
        if [ $FIRST = 1 ]; then
            MISSING_ARGS="Image version[-r/--repo]"image-version
	        FIRST=0
        else
            MISSING_ARGS="$MISSING_ARGS , Image version[-r/--repo]"
        fi
    fi
fi

if [ "$MISSING_ARGS" != "" ]; then
    printf "\nERROR:Missing mandatory argument(s) : $MISSING_ARGS\n"
    printf "$USAGE"
    exit 1; 
fi

# check installer location exist or not
if [ ! -d "$ARG_INSTALLER_LOCATION" ]; then
    printf "ERROR:The directory - $ARG_INSTALLER_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
    exit 1;
fi

# app location directory check for app image case
if [ "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
    # incase of builder image app location is not needed
    ARG_APP_LOCATION="na"
elif [ "$FILE_NAME" = "$APP_IMAGE" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR:The directory - $ARG_APP_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
    exit 1;
# other cases if app location provided checking the directory exist or not
elif [ "$ARG_APP_LOCATION" != "na" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR:The directory - $ARG_APP_LOCATION is not a valid directory. Ignoring app location.\n"
    ARG_APP_LOCATION="na"
fi

# count cdd and ear in app location
if [ "$ARG_APP_LOCATION" != "na" ]; then
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
fi

# check be and its hot fixes
source ../common/check_be.sh

if [ "$FILE_NAME" != "$TEA_IMAGE" ]; then
    # check as legacy and its hot fixes
    source ../common/check_asleg.sh
fi


if [ "$FILE_NAME" = "$APP_IMAGE" -o "$FILE_NAME" = "$BUILDER_IMAGE" ]; then
    # check be addons
    source ../common/check_beaddons.sh

    # check for FTL and AS4 only when BE version is > 6.0.0
    if [ "$ARG_VERSION" != "na" ]; then
        if [ $(echo "${ARG_VERSION//.}") -ge 600 ]; then
            # validate ftl
            source ../common/check_ftl.sh

            # validate as
            source ../common/check_as.sh
        fi
    fi
fi

# image name check
if [ "$ARG_IMAGE_VERSION" = "na" -o -z "${ARG_IMAGE_VERSION// }" ]; then
    if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
        ARG_IMAGE_VERSION="teagent:$ARG_VERSION";
    elif [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
        ARG_IMAGE_VERSION="rms:$ARG_VERSION";
    fi
fi

# information display
echo "INFO: Supplied Arguments   :"
echo "------------------------------------------------------------------------------"
echo "INFO: INSTALLER DIRECTORY          : [$ARG_INSTALLER_LOCATION]"

if ! [ "$ARG_APP_LOCATION" = "na" ]; then
    echo "INFO: APPLICATION DATA DIRECTORY   : [$ARG_APP_LOCATION]"
fi

echo "INFO: BE EDITION                   : [$ARG_EDITION]"
echo "INFO: BE VERSION                   : [$ARG_VERSION]"

if ! [ "$ARG_BE_HOTFIX" = "na" -o -z "${ARG_BE_HOTFIX// }" ]; then
    echo "INFO: BE HF                        : [$ARG_BE_HOTFIX]"
fi

if ! [ "$ARG_ADDONS" = "na" -o -z "${ARG_ADDONS// }" ]; then
    echo "INFO: BE ADDONS                    : [$ARG_ADDONS]"
fi

if ! [ "$ARG_AS_LEG_VERSION" = "na" -o -z "${ARG_AS_LEG_VERSION// }" ]; then
    echo "INFO: AS LEGACY VERSION            : [$ARG_AS_LEG_VERSION]"
    if ! [ "$ARG_AS_LEG_HOTFIX" = "na" -o -z "${ARG_AS_LEG_HOTFIX// }" ]; then
        echo "INFO: AS LEGACY HF                 : [$ARG_AS_LEG_HOTFIX]"
    fi
fi

if ! [ "$ARG_FTL_VERSION" = "na" -o -z "${ARG_FTL_VERSION// }" ]; then
    echo "INFO: FTL VERSION                  : [$ARG_FTL_VERSION]"
    if ! [ "$ARG_FTL_HOTFIX" = "na" -o -z "${ARG_FTL_HOTFIX// }" ]; then
        echo "INFO: FTL HF                       : [$ARG_FTL_HOTFIX]"
    fi
fi

if ! [ "$ARG_AS_VERSION" = "na" -o -z "${ARG_AS_VERSION// }" ]; then
    echo "INFO: AS VERSION                   : [$ARG_AS_VERSION]"
    if ! [ "$ARG_AS_HOTFIX" = "na" -o -z "${ARG_AS_HOTFIX// }" ]; then
        echo "INFO: AS HF                        : [$ARG_AS_HOTFIX]"
    fi
fi

if ! [ -z "${EAR_FILE_NAME//}" -o -z "${CDD_FILE_NAME//}" ]; then
    echo "INFO: CDD FILE NAME                : [$CDD_FILE_NAME]"
    echo "INFO: EAR FILE NAME                : [$EAR_FILE_NAME]"    
fi

echo "INFO: DOCKERFILE                   : [$ARG_DOCKER_FILE]"
echo "INFO: IMAGE VERSION                : [$ARG_IMAGE_VERSION]"

echo "------------------------------------------------------------------------------"


exit 1