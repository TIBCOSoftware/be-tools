#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [ -z "${FILE_NAME}" ]; then
    FILE_NAME=$(basename $0)
fi

APP_IMAGE="build_app_image.sh"
RMS_IMAGE="build_rms_image.sh"
TEA_IMAGE="build_teagent_image.sh"

ARG_APP_LOCATION="na"
ARG_IMAGE_VERSION="na"
ARG_DOCKER_FILE="Dockerfile_fromtar"
TEMP_FOLDER="tmp_$RANDOM"

# be related args
BE_HOME="na"
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

if [ -z "${USAGE}" ]; then
    USAGE="\nUsage: $FILE_NAME"
fi

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

if [ "$SOURCE_DIR" = "build" ]; then
    ARG_DOCKER_FILE="$RELATIVE_DIR$ARG_DOCKER_FILE"
fi

USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image (default - $ARG_DOCKER_FILE) [optional]"

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    USAGE+="\n\n [--gv-providers]            :       Names of GV providers to be included in the image. Supported value(s) - consul [optional]" 
    USAGE+="\n\n [--disable-tests]           :       Disables docker unit tests on created image. [optional]"

    ARG_GVPROVIDERS="na"
    ARG_ENABLE_TESTS="true"
fi

if [ "$SOURCE_DIR" = "build" ]; then
    USAGE+="\n\n [-s/--source]               :       Image Source (example: frominstallers,frombelocal) (default: frombelocal) [optional]"
    USAGE+="\n\n [-t/--type]                 :       Image Type (example: app,rms,tea,builder) (default: app) [optional]"
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
                echo "Invalid Option: [$key]"
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
                                    echo "Invalid Option: [$key]"
                                    ;;
                            esac
                        else
                            echo "Invalid Option: [$key]"
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
    printf "ERROR: The directory: [$ARG_APP_LOCATION] is not a valid directory. Enter a valid directory and try again.\n"
    exit 1;
elif [ "$ARG_APP_LOCATION" != "na" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory: [$ARG_APP_LOCATION] is not a valid directory. Ignoring app location.\n"
    ARG_APP_LOCATION="na"
fi

# count cdd and ear in app location
if [ "$ARG_APP_LOCATION" != "na" ]; then
    #Check App location have ear or not
    ears=$(find $ARG_APP_LOCATION -name "*.ear")
    earCnt=$(find $ARG_APP_LOCATION -name "*.ear" | wc -l)

    if [ $earCnt -ne 1 ]; then
        printf "ERROR: The directory: [$ARG_APP_LOCATION] must have single EAR file\n"
        exit 1
    fi

    #Check App location have cdd or not
    cdds=$(find $ARG_APP_LOCATION -name "*.cdd")
    cddCnt=$(find $ARG_APP_LOCATION -name "*.cdd" | wc -l)

    if [ $cddCnt -ne 1 ]; then
        printf "ERROR: The directory: [$ARG_APP_LOCATION] must have single CDD file\n"
        exit 1
    fi

    EAR_FILE_NAME="$(basename -- ${ears[0]})"
    CDD_FILE_NAME="$(basename -- ${cdds[0]})"
fi

if [[ (( "$BE_HOME" != "na" )) &&  !(( -d "$BE_HOME" )) ]]; then
    echo "ERROR: The directory: [$BE_HOME] is not a valid directory. Provide proper be-home."
    exit 1
elif [ "$BE_HOME" = "na" ]; then
    BE_HOME=$( readlink -e ../../.. )
fi

BE_HOME_REGEX="(.*.)\/(be\/[0-9]\.[0-9])$"
if ! [[ $BE_HOME =~ $BE_HOME_REGEX ]]; then
    echo "ERROR: Provide proper be home [be/<be-version>] (ex: <path to>/be/5.6)."
    exit 1
else
    BE_HOME_BASE=${BASH_REMATCH[1]}
    BE_DIR=${BASH_REMATCH[2]}
fi

ARG_BE_VERSION=$(find $BE_HOME/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
ARG_BE_VERSION=$(echo $ARG_BE_VERSION | sed -e 's/\r//g')

if [[ $ARG_BE_VERSION =~ $VERSION_REGEX ]]; then
	ARG_BE_SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR: Improper Be version: [$ARG_BE_VERSION]. Aborting."
	exit 1
fi

if [ "$FILE_NAME" != "$TEA_IMAGE" ]; then
    ## get as legacy details
    AS_LEG_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.AS_HOME | cut -d'=' -f 2)
    AS_LEG_HOME=${AS_LEG_HOME%?}
    if [ "$AS_LEG_HOME" = "" ]; then
        AS_LEG_HOME="na"
    else
        AS_LEG_HOME_REGEX="(.*.)\/(as\/[0-9]\.[0-9])$"
        if ! [[ $AS_LEG_HOME =~ $AS_LEG_HOME_REGEX ]]; then
            echo "ERROR: Update proper Activespaces(legacy) home path: [$AS_LEG_HOME] in be-engine.tra file (ex: <path-to>/as/<as-version>)."
            exit 1
        fi
        AS_LEG_HOME_BASE=${BASH_REMATCH[1]}
        AS_LEG_DIR=${BASH_REMATCH[2]}
        ARG_AS_LEG_SHORT_VERSION=$( echo ${AS_LEG_HOME}  | rev | cut -d'/' -f1 | rev )
    fi
fi

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    # get ftl details
    FTL_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.FTL_HOME | cut -d'=' -f 2)
    FTL_HOME=${FTL_HOME%?}
    if [ "$FTL_HOME" = "" ]; then
        FTL_HOME="na"
    else
        FTL_HOME_REGEX="(.*.)\/(ftl\/[0-9]\.[0-9])$"
        if ! [[ $FTL_HOME =~ $FTL_HOME_REGEX ]]; then
            echo "ERROR: Update proper FTL home path: [$FTL_HOME] in be-engine.tra file (ex: <path-to>/ftl/<ftl-version>)."
            exit 1
        fi
        FTL_HOME_BASE=${BASH_REMATCH[1]}
        FTL_DIR=${BASH_REMATCH[2]}
        ARG_FTL_SHORT_VERSION=$( echo ${FTL_HOME}  | rev | cut -d'/' -f1 | rev )
    fi

    # get as details
    AS_HOME=$(cat $BE_HOME/bin/be-engine.tra | grep ^tibco.env.ACTIVESPACES_HOME | cut -d'=' -f 2)
    AS_HOME=${AS_HOME%?}
    if [ "$AS_HOME" = "" ]; then
        AS_HOME="na"
    else
        AS_HOME_REGEX="(.*.)\/(as\/[0-9]\.[0-9])$"
        if ! [[ $AS_HOME =~ $AS_HOME_REGEX ]]; then
            echo "ERROR: Update proper Activespaces home path: [$AS_HOME] in be-engine.tra file (ex: <path-to>/as/<as-version>)."
            exit 1
        fi
        AS_HOME_BASE=${BASH_REMATCH[1]}
        AS_DIR=${BASH_REMATCH[2]}
        ARG_AS_SHORT_VERSION=$( echo ${AS_HOME}  | rev | cut -d'/' -f1 | rev )
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

if [ "$FTL_HOME" != "na" -a "$AS_LEG_HOME" != "na" ]; then
    echo "WARN: Local machine contains both FTL and AS legacy installations. Removing unused installation improves the docker image size."
fi

mkdir $TEMP_FOLDER
cp -a "../lib" $TEMP_FOLDER/

if [ "$FILE_NAME" = "$APP_IMAGE" ]; then
    cp -a "../gvproviders" $TEMP_FOLDER/
fi
if [ "$ARG_APP_LOCATION" != "na" ]; then
    mkdir -p $TEMP_FOLDER/app
    cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app
fi

#tar command for be package
BE_TAR_CMD=" tar -C $BE_HOME_BASE -cf $TEMP_FOLDER/be.tar tibcojre64 $BE_DIR/lib $BE_DIR/bin "
if [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
    BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/rms $BE_DIR/studio $BE_DIR/eclipse-platform $BE_DIR/examples/standard/WebStudio $BE_DIR/mm "
elif [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
    BE_TAR_CMD="$BE_TAR_CMD $BE_DIR/teagent $BE_DIR/mm "
fi
if [ -d "$BE_HOME/hotfix" ]; then
    BE_TAR_CMD="$BE_TAR_CMD $BE_DIR/hotfix "
fi

#execute be tar command
$BE_TAR_CMD

# check as leg if exist add it to be tar file
if [ "$AS_LEG_HOME" != "na" ]; then
    tar -C $AS_LEG_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_LEG_DIR/bin $AS_LEG_DIR/lib
    if [ -d "$AS_LEG_DIR/hotfix" ]; then
        tar -C $AS_LEG_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_LEG_DIR/hotfix
    fi
fi

# check as if exist add it to be tar file
if [ "$AS_HOME" != "na" ]; then
    tar -C $AS_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_DIR/bin $AS_DIR/lib
fi

# check ftl if exist add it to be tar file
if [ "$FTL_HOME" != "na" ]; then
    tar -C $FTL_HOME_BASE -rf $TEMP_FOLDER/be.tar $FTL_DIR/bin $FTL_DIR/lib
fi

# create another temp folder and replace be_home to /opt/tibco
RANDM_FOLDER="tmp$RANDOM"
mkdir $TEMP_FOLDER/$RANDM_FOLDER

# Exract it
tar -C $TEMP_FOLDER/$RANDM_FOLDER -xf $TEMP_FOLDER/be.tar

OPT_TIBCO="/opt/tibco"
# Replace be home in tra files with opt/tibco
echo "Replacing base directory in the files from [$BE_HOME_BASE] to /opt/tibco"

find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"

if [ "$FILE_NAME" = "$TEA_IMAGE" ]; then
    # Replace in props files
    find $TEMP_FOLDER/$RANDM_FOLDER -name 'be-teagent.props' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"

    # Replace in log4j files
    find $TEMP_FOLDER/$RANDM_FOLDER -name 'log4j*.properties' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"
fi

# Remove the annotations file
if [ -e "$TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/bin/_annotations.idx" ]; then
    rm "$TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/bin/_annotations.idx"
fi
# TODO: generate annotations idx.

REGEX_CUSTOM_CP="tibco\.env\.CUSTOM_EXT_PREPEND_CP=.*"
VALUE_CUSTOM_CP="tibco.env.CUSTOM_EXT_PREPEND_CP=/opt/tibco/be/ext"
find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$REGEX_CUSTOM_CP~$VALUE_CUSTOM_CP~g"

if [ "$FILE_NAME" = "$RMS_IMAGE" ]; then
    find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/rms/bin -name '*.cdd' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"
fi

if [ -e "$TEMP_FOLDER/app/$CDD_FILE_NAME" ]; then
    find $TEMP_FOLDER/app -name '*.cdd' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"
fi

if [ "$FTL_HOME" != "na" ]; then
    FTL_HOME_KEY="tibco.env.FTL_HOME=.*"
    FTL_HOME_VAL="tibco.env.FTL_HOME=$OPT_TIBCO/$FTL_DIR"
    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$FTL_HOME_KEY~$FTL_HOME_VAL~g"
fi

if [ "$AS_HOME" != "na" ]; then
    AS_HOME_KEY="tibco.env.ACTIVESPACES_HOME=.*"
    AS_HOME_VAL="tibco.env.ACTIVESPACES_HOME=$OPT_TIBCO/$AS_DIR"
    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$AS_HOME_KEY~$AS_HOME_VAL~g"
fi

if [ "$AS_LEG_HOME" != "na" ]; then
    AS_LEG_HOME_KEY="tibco.env.AS_HOME=.*"
    AS_LEG_HOME_VAL="tibco.env.AS_HOME=$OPT_TIBCO/$AS_LEG_DIR"
    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$AS_LEG_HOME_KEY~$AS_LEG_HOME_VAL~g"
fi

# removing all .bak files
find $TEMP_FOLDER -type f -name "*.bak" -exec rm -f {} \;

# re create be.tar
TAR_CMD="tar -C $TEMP_FOLDER/$RANDM_FOLDER -cf $TEMP_FOLDER/be.tar be tibcojre64 "

if [ "$FTL_HOME" != "na" ]; then
    TAR_CMD="$TAR_CMD ftl"
fi

if [ "$AS_HOME" != "na" -o "$AS_LEG_HOME" != "na" ]; then
    TAR_CMD="$TAR_CMD as"
fi

# execute tar cmnd
$TAR_CMD

# remove random folder
rm -rf $TEMP_FOLDER/$RANDM_FOLDER
exit 1
# building docker image
echo "INFO: Building docker image for TIBCO BusinessEvents Version: [$ARG_BE_VERSION], Image Version: [$ARG_IMAGE_VERSION] and Dockerfile: [$ARG_DOCKER_FILE]."

cp $ARG_DOCKER_FILE $TEMP_FOLDER/
docker build -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg GVPROVIDERS=$ARG_GVPROVIDERS -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER"

if [ "$?" != 0 ]; then
    echo "Docker build failed."
else
    BUILD_SUCCESS="true"
    echo "DONE: Docker build successful."
fi

echo "Deleting [$TEMP_FOLDER] folder"
rm -rf $TEMP_FOLDER

# docker unit tests
if [[ ($BUILD_SUCCESS = "true") && ($ARG_ENABLE_TESTS = "true") && ("$FILE_NAME" = "$APP_IMAGE") ]]; then
	cd ../tests
	source run_tests.sh -i $ARG_IMAGE_VERSION  -b $ARG_BE_SHORT_VERSION -c $CDD_FILE_NAME -e $EAR_FILE_NAME -al $ARG_AS_LEG_SHORT_VERSION -as $ARG_AS_SHORT_VERSION -f $ARG_FTL_SHORT_VERSION
fi