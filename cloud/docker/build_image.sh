#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source ./scripts/utils.sh
FILE_NAME=$(basename $0)

# image type variables
IMAGE_NAME=""
APP_IMAGE="app"
RMS_IMAGE="rms"
TEA_IMAGE="teagent"
BUILDER_IMAGE="s2ibuilder"

TEMP_FOLDER="tmp_$RANDOM"

# input variables
ARG_SOURCE="na"
ARG_TYPE="na"
ARG_APP_LOCATION="na"
ARG_TAG="na"
ARG_DOCKER_FILE="na"
ARG_GVPROVIDER="na"
ARG_ENABLE_TESTS="true"
ARG_BUILD_TOOL=""

# be related args
BE_HOME="na"
ARG_INSTALLER_LOCATION="na"
ARG_EDITION="enterprise"
ARG_BE_VERSION="na"
ARG_BE_SHORT_VERSION="na"
ARG_BE_HOTFIX="na"
ARG_JRE_VERSION="na"

BE_PRODUCT="TIB_businessevents"
INSTALLER_PLATFORM="_linux26gl25_x86_64.zip"
BE_BASE_PKG_REGEX="${BE_PRODUCT}-${ARG_EDITION}_[0-9]\.[0-9]\.[0-9]${INSTALLER_PLATFORM}"
VALIDATE_FTL_AS="false"

#Map used to store the BE and it's comapatible JRE version
declare -a BE_VERSION_AND_JRE_MAP
BE_VERSION_AND_JRE_MAP=("5.6.0" "1.8.0" "5.6.1" "11" "6.0.0" "11" "6.1.0" "11" "6.1.1" "11" )

# as legacy related args
AS_LEG_HOME="na"
ARG_AS_LEG_VERSION="na"
ARG_AS_LEG_SHORT_VERSION="na"
ARG_AS_LEG_HOTFIX="na"

# ftl related args
FTL_HOME="na"
ARG_FTL_VERSION="na"
ARG_FTL_SHORT_VERSION="na"
ARG_FTL_HOTFIX="na"

# as related args
AS_HOME="na"
ARG_AS_VERSION="na"
ARG_AS_SHORT_VERSION="na"
ARG_AS_HOTFIX="na"

# s2i builder related args
BE_TAG="com.tibco.be"
S2I_DOCKER_FILE_APP="./dockerfiles/Dockerfile-s2i"

# default installation type fromlocal
INSTALLATION_TYPE="fromlocal"

USAGE="\nUsage: $FILE_NAME"

USAGE+="\n\n [-i/--image-type]    :    Type of the image to build (\"$APP_IMAGE\"|\"$RMS_IMAGE\"|\"$TEA_IMAGE\"|\"$BUILDER_IMAGE\") [required]\n"
USAGE+="                           Note: For $BUILDER_IMAGE image usage refer to be-tools wiki."
USAGE+="\n\n [-a/--app-location]  :    Path to BE application where cdd, ear & optional supporting jars are present\n"
USAGE+="                           Note: Required if --image-type is \"$APP_IMAGE\"\n"
USAGE+="                                 Optional if --image-type is \"$RMS_IMAGE\"\n"
USAGE+="                                 Ignored  if --image-type is \"$TEA_IMAGE\" or \"$BUILDER_IMAGE\""
USAGE+="\n\n [-s/--source]        :    Path to BE_HOME or TIBCO installers (BusinessEvents, Activespaces or FTL) are present (default \"../../\")"
USAGE+="\n\n [-t/--tag]           :    Name and optionally a tag in the 'name:tag' format [optional]"
USAGE+="\n\n [-d/--docker-file]   :    Dockerfile to be used for generating image [optional]"
USAGE+="\n\n [--gv-provider]      :    Name of GV provider to be included in the image (\"consul\"|\"http\"|\"custom\") [optional]\n"
USAGE+="                           To add more than one GV use comma separated format ex: \"consul,http\" \n"
USAGE+="                           Note: This flag is ignored if --image-type is \"$TEA_IMAGE\""
USAGE+="\n\n [--disable-tests]    :    Disables docker unit tests on created image (applicable only for \"$APP_IMAGE\" and \"$BUILDER_IMAGE\" image types) [optional]"
USAGE+="\n\n [-b/--build-tool]    :    Build tool to be used (\"docker\"|\"buildah\") (default is \"docker\")\n"
USAGE+="                           Note: $BUILDER_IMAGE image and docker unit tests not supported for buildah."
USAGE+="\n\n [-h/--help]          :    Print the usage of script [optional]"
USAGE+="\n\n NOTE : supply long options with '=' \n"

#Parse the arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        -s|--source) 
            shift # past the key and to the value
            ARG_SOURCE="$1"
            ;;
        -s=*|--source=*)
            ARG_SOURCE="${key#*=}"
            ;;
        -i|--image-type) 
            shift # past the key and to the value
            ARG_TYPE="$1"
            ;;
        -i=*|--image-type=*)
            ARG_TYPE="${key#*=}"
	        ;;
        -a|--app-location) 
            shift # past the key and to the value
            ARG_APP_LOCATION="$1"
            ;;
        -a=*|--app-location=*)
            ARG_APP_LOCATION="${key#*=}"
	        ;;
        -t|--tag) 
            shift # past the key and to the value
            ARG_TAG="$1"
            ;;
        -t=*|--tag=*)
            ARG_TAG="${key#*=}"
	        ;;
        -d|--docker-file)
            shift # past the key and to the value
            ARG_DOCKER_FILE="$1"
            ;;
        -d=*|--docker-file=*)
            ARG_DOCKER_FILE="${key#*=}"
            ;;
        --gv-provider)
            shift # past the key and to the value
            ARG_GVPROVIDER="$1"
            ;;
        --gv-provider=*)
            ARG_GVPROVIDER="${key#*=}"
            ;;
        -b|--build-tool)
            shift # past the key and to the value
            ARG_BUILD_TOOL="$1"
            ;;
        -b=*|--build-tool=*)
            ARG_BUILD_TOOL="${key#*=}"
            ;;
        --disable-tests)
            ARG_ENABLE_TESTS="false"
            ;;
        -h|--help) 
            shift # past the key and to the value
            printf "$USAGE"
            exit 0
            ;;
        *)
            echo "Invalid Option: [$key]"
            ;;
    esac
    shift
done

# missing arguments check
MISSING_ARGS=""

if [ "$ARG_TYPE" = "na" -o -z "${ARG_TYPE// }" ]; then
    MISSING_ARGS="Image Type[-i/--image-type]"
fi

if [ "$ARG_TYPE" = "app" ]; then
    if [ "$ARG_APP_LOCATION" = "na" -o -z "${ARG_APP_LOCATION// }" ]; then
        MISSING_ARGS="App location[-a/--app-location]"
    fi
fi

if [ "$MISSING_ARGS" != "" ]; then
    printf "\nERROR: Missing mandatory argument : $MISSING_ARGS\n"
    printf "$USAGE"
    exit 1; 
fi

if [ "$ARG_SOURCE" != "na" ]; then
    bePckgsCnt=$(find $ARG_SOURCE -name "${BE_BASE_PKG_REGEX}" -maxdepth 1 2>/dev/null | wc -l) 
    if [ $bePckgsCnt -gt 0 ]; then
        INSTALLATION_TYPE="frominstallers"
        ARG_INSTALLER_LOCATION="$ARG_SOURCE"
    else
        BE_HOME="$ARG_SOURCE"
    fi
else
    BE_HOME="na"
fi

# assign image type and docker files to variables
IMAGE_NAME="$ARG_TYPE"
DOCKER_FILE=""
case "$ARG_TYPE" in
    "$APP_IMAGE")
        DOCKER_FILE="./dockerfiles/Dockerfile"
        ;;
    "$RMS_IMAGE")
        DOCKER_FILE="./dockerfiles/Dockerfile-rms"
        ;;
    "$TEA_IMAGE")
        DOCKER_FILE="./dockerfiles/Dockerfile-teagent"
        ;;
    "$BUILDER_IMAGE")
        DOCKER_FILE="./dockerfiles/Dockerfile"
        ;;
    *)
        printf "\nERROR: Invalid image type provided. Image type must be either of $APP_IMAGE,$RMS_IMAGE,$TEA_IMAGE or $BUILDER_IMAGE.\n"
        exit 1
        ;;
esac

# assign proper docker file to ARG_DOCKER_FILE variable
if [ "$ARG_DOCKER_FILE" = "na" ]; then
    if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
        ARG_DOCKER_FILE="$DOCKER_FILE"_fromtar
    else
        ARG_DOCKER_FILE="$DOCKER_FILE"
    fi
fi

# check the docker file existance
if ! [ -e $ARG_DOCKER_FILE ]; then
    printf "\nERROR: Dockerfile: [$ARG_DOCKER_FILE] not exist. Please provide proper dockerfile.\n"
    exit 1
fi

# check be-home/installer location
if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    if [[ (( "$BE_HOME" != "na" )) &&  !(( -d "$BE_HOME" )) ]]; then
        printf "\nERROR: The directory: [$BE_HOME] is not a valid directory. Provide proper path to be-home or installers location.\n"
        exit 1
    elif [ "$BE_HOME" = "na" ]; then
        BE_HOME=$( readlink -e ../.. )
    fi

    BE_HOME_REGEX="(.*.)\/(be\/[0-9]\.[0-9])$"
    if ! [[ $BE_HOME =~ $BE_HOME_REGEX ]]; then
        printf "\nERROR: Provide proper be home [be/<be-version>] (ex: <path to>/be/6.0). OR Path to installers location.\n"
        exit 1
    else
        BE_HOME_BASE=${BASH_REMATCH[1]}
        BE_DIR=${BASH_REMATCH[2]}
    fi
fi

# check app location
if [ "$IMAGE_NAME" = "$BUILDER_IMAGE" -o "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
    # incase of builder/teagent image app location is not needed
    ARG_APP_LOCATION="na"
elif [ "$IMAGE_NAME" = "$APP_IMAGE" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory: [$ARG_APP_LOCATION] is not a valid directory. Enter a valid directory and try again.\n"
    exit 1;
elif [ "$ARG_APP_LOCATION" != "na" -a ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory: [$ARG_APP_LOCATION] is not a valid directory. Ignoring app location.\n"
    ARG_APP_LOCATION="na"
fi

# count cdd and ear in app location if exist
if [ "$ARG_APP_LOCATION" != "na" ]; then
    #Check App location have ear or not
    ears=$(find $ARG_APP_LOCATION -name "*.ear")
    earCnt=$(find $ARG_APP_LOCATION -name "*.ear" | wc -l)

    if [ $earCnt -ne 1 ]; then
        printf "ERROR: The directory: [$ARG_APP_LOCATION] must have single EAR file.\n"
        exit 1
    fi

    #Check App location have cdd or not
    cdds=$(find $ARG_APP_LOCATION -name "*.cdd")
    cddCnt=$(find $ARG_APP_LOCATION -name "*.cdd" | wc -l)

    if [ $cddCnt -ne 1 ]; then
        printf "ERROR: The directory: [$ARG_APP_LOCATION] must have single CDD file.\n"
        exit 1
    fi

    EAR_FILE_NAME="$(basename -- ${ears[0]})"
    CDD_FILE_NAME="$(basename -- ${cdds[0]})"
fi

# assign image tag to ARG_IMAGE_VERSION variable
ARG_IMAGE_VERSION="$ARG_TAG"

# get product details for both fromlocal and frominstallers
if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    VERSION_REGEX=([0-9]\.[0-9]).*

    ARG_BE_VERSION=$(find $BE_HOME/uninstaller_scripts/post-install.properties -type f | xargs grep  'beVersion=' | cut -d'=' -f2)
    ARG_BE_VERSION=$(echo $ARG_BE_VERSION | sed -e 's/\r//g')

    if [[ $ARG_BE_VERSION =~ $VERSION_REGEX ]]; then
        ARG_BE_SHORT_VERSION=${BASH_REMATCH[1]};
    else
        printf "\nERROR: Improper Be version: [$ARG_BE_VERSION]. Aborting.\n"
        exit 1
    fi

    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        TRA_FILE="rms/bin/be-rms.tra"
    else
        TRA_FILE="bin/be-engine.tra"
    fi
    TRA_FILE_NAME=$(basename $TRA_FILE)

    if [ "$IMAGE_NAME" != "$TEA_IMAGE" ]; then

        VALIDATE_FTL_AS=$(validateFTLandAS $ARG_BE_VERSION $IMAGE_NAME $RMS_IMAGE )

        ## get as legacy details
        AS_LEG_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.AS_HOME | cut -d'=' -f 2)
        if [ "$IMAGE_NAME" != "$RMS_IMAGE" ]; then
            AS_LEG_HOME=${AS_LEG_HOME%?}
        fi
        
        if [ "$AS_LEG_HOME" = "" ]; then
            AS_LEG_HOME="na"
        else
            # check directory exist
            if ! [ -d "$AS_LEG_HOME" ]; then
                printf "\nERROR: The directory: [$AS_LEG_HOME] not exist. Ignoring Activespaces(legacy) installation.\n"
                AS_LEG_HOME="na"
            else
                AS_LEG_HOME_REGEX="(.*.)\/(as\/[0-9]\.[0-9])$"
                if ! [[ $AS_LEG_HOME =~ $AS_LEG_HOME_REGEX ]]; then
                    printf "\nERROR: Update proper Activespaces(legacy) home path: [$AS_LEG_HOME] in $TRA_FILE_NAME file (ex: <path-to>/as/<as-version>).\n"
                    exit 1
                fi
                AS_LEG_HOME_BASE=${BASH_REMATCH[1]}
                AS_LEG_DIR=${BASH_REMATCH[2]}
                ARG_AS_LEG_SHORT_VERSION=$( echo ${AS_LEG_HOME}  | rev | cut -d'/' -f1 | rev )
            fi
        fi
    fi

    if [ "$VALIDATE_FTL_AS" = "true" ]; then
        # get ftl details
        FTL_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.FTL_HOME | cut -d'=' -f 2)
        if [ "$IMAGE_NAME" != "$RMS_IMAGE" ]; then
            FTL_HOME=${FTL_HOME%?}
        fi
        if [ "$FTL_HOME" = "" ]; then
            FTL_HOME="na"
        else
            # check directory exist
            if ! [ -d "$FTL_HOME" ]; then
                printf "\nERROR: The directory: [$FTL_HOME] not exist. Ignoring FTL installation.\n"
                FTL_HOME="na"
            else
                FTL_HOME_REGEX="(.*.)\/(ftl\/[0-9]\.[0-9])$"
                if ! [[ $FTL_HOME =~ $FTL_HOME_REGEX ]]; then
                    printf "\nERROR: Update proper FTL home path: [$FTL_HOME] in $TRA_FILE_NAME file (ex: <path-to>/ftl/<ftl-version>).\n"
                    exit 1
                fi
                FTL_HOME_BASE=${BASH_REMATCH[1]}
                FTL_DIR=${BASH_REMATCH[2]}
                ARG_FTL_SHORT_VERSION=$( echo ${FTL_HOME}  | rev | cut -d'/' -f1 | rev )
            fi
        fi

        # get as details
        AS_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.ACTIVESPACES_HOME | cut -d'=' -f 2)
        if [ "$IMAGE_NAME" != "$RMS_IMAGE" ]; then
            AS_HOME=${AS_HOME%?}
        fi
        if [ "$AS_HOME" = "" ]; then
            AS_HOME="na"
        else
            # check directory exist
            if ! [ -d "$AS_HOME" ]; then
                printf "\nERROR: The directory: [$AS_HOME] not exist. Ignoring Activespaces installation.\n"
                AS_HOME="na"
            else
                AS_HOME_REGEX="(.*.)\/(as\/[0-9]\.[0-9])$"
                if ! [[ $AS_HOME =~ $AS_HOME_REGEX ]]; then
                    printf "\nERROR: Update proper Activespaces home path: [$AS_HOME] in $TRA_FILE_NAME file (ex: <path-to>/as/<as-version>).\n"
                    exit 1
                fi
                AS_HOME_BASE=${BASH_REMATCH[1]}
                AS_DIR=${BASH_REMATCH[2]}
                ARG_AS_SHORT_VERSION=$( echo ${AS_HOME}  | rev | cut -d'/' -f1 | rev )
            fi
        fi
    fi
else
    #version regex for all products
    VERSION_REGEX=([0-9]\.[0-9]).[0-9]
    HF_VERSION_REGEX=([0-9]\{3\})

    # file list array to hold all installers
    FILE_LIST=()
    # file list index
    FILE_LIST_INDEX=0

    # check be and its hot fixes
    source ./scripts/be.sh

    if [ "$ARG_BE_VERSION" = "na" ]; then
        echo "ERROR: Unable to identify TIBCO BusinessEvents."
        exit 1
    fi

    if [ "$IMAGE_NAME" != "$TEA_IMAGE" ]; then
        # check as legacy and its hot fixes
        source ./scripts/asleg.sh

        # check be addons
        source ./scripts/beaddons.sh

        VALIDATE_FTL_AS=$(validateFTLandAS $ARG_BE_VERSION $IMAGE_NAME $RMS_IMAGE )
    fi

    # check for FTL and AS4 only when VALIDATE_FTL_AS is true
    if [ "$VALIDATE_FTL_AS" = "true" ]; then
        # validate ftl
        source ./scripts/ftl.sh

        # validate as
        source ./scripts/as.sh
    fi
    
fi

#Find JRE Version for given BE Version
length=${#BE_VERSION_AND_JRE_MAP[@]}	
for (( i = 0; i < length; i++ )); do
    if [ "$ARG_BE_VERSION" = "${BE_VERSION_AND_JRE_MAP[i]}" ];then
        ARG_JRE_VERSION=${BE_VERSION_AND_JRE_MAP[i+1]};
        break;	
    fi
done

# assign image name if not provided
if [ "$ARG_IMAGE_VERSION" = "na" -o -z "${ARG_IMAGE_VERSION// }" ]; then
    ARG_IMAGE_VERSION="$IMAGE_NAME:$ARG_BE_VERSION";
fi

OS_NAME=$(uname -s)
if [ "$OS_NAME" = "Darwin" -a "$INSTALLATION_TYPE" = "fromlocal" ]; then
    echo "ERROR: Building image using local installtion is not supported on MAC."
    exit 1
fi

CHECK_FOR_BUILDAH="false"
if [ "$ARG_BUILD_TOOL" == "" ]; then
    ARG_BUILD_TOOL="docker"
    CHECK_FOR_BUILDAH="true"
fi

if ! [[ "$ARG_BUILD_TOOL" = "docker" || "$ARG_BUILD_TOOL" = "buildah" ]]; then
    echo "ERROR: Build tool[$ARG_BUILD_TOOL] is not valid. Only docker/buildah tool is supported."
    exit 1
fi

if [ "$OS_NAME" = "Darwin" -a "$ARG_BUILD_TOOL" = "buildah" ]; then
    echo "ERROR: Build tool [$ARG_BUILD_TOOL] is not supported on MAC."
    exit 1
fi

# check for build tool existance
if [ "$ARG_BUILD_TOOL" == "docker" ]; then
    DOCKER_PKG=$( which docker )
    if [ "$DOCKER_PKG" == "" ]; then
        if [ "$CHECK_FOR_BUILDAH" == "false" ]; then
            echo "ERROR: Build tool[docker] not found. Please install docker."
            exit 1
        else
            echo "WARN: Build tool[docker] not found. Checking for the build tool[buildah]."
            ARG_BUILD_TOOL="buildah"
        fi
    else
        echo "INFO: Building container image with the build tool[docker]."
    fi
fi

if [ "$ARG_BUILD_TOOL" == "buildah" ]; then
    BUILDAH_PKG=$( which buildah )
    if [ "$BUILDAH_PKG" == "" ]; then
        if [ "$CHECK_FOR_BUILDAH" == "false" ]; then
            echo "ERROR: Build tool[buildah] not found. Please install buildah."
        else
            echo "ERROR: Build tool[buildah] also not found. Please install either docker or buildah."
        fi
        exit 1
    else
        echo "INFO: Building container image with the build tool[buildah]."
    fi
fi

# information display
echo "INFO: Supplied/Derived Data:"
echo "------------------------------------------------------------------------------"

if ! [ "$ARG_INSTALLER_LOCATION" = "na" ]; then
    echo "INFO: INSTALLER DIRECTORY          : [$ARG_INSTALLER_LOCATION]"
fi

if ! [ "$ARG_APP_LOCATION" = "na" ]; then
    echo "INFO: APPLICATION DATA DIRECTORY   : [$ARG_APP_LOCATION]"
fi

if ! [ "$BE_HOME" = "na" -o -z "${BE_HOME// }" ]; then
    echo "INFO: BE HOME                      : [$BE_HOME]"
fi

echo "INFO: BE VERSION                   : [$ARG_BE_VERSION]"

if ! [ "$ARG_BE_HOTFIX" = "na" -o -z "${ARG_BE_HOTFIX// }" ]; then
    echo "INFO: BE HF                        : [$ARG_BE_HOTFIX]"
fi

if ! [ "$ARG_ADDONS" = "na" -o -z "${ARG_ADDONS// }" ]; then
    echo "INFO: BE ADDONS                    : [$ARG_ADDONS]"
fi

if ! [ "$AS_LEG_HOME" = "na" -o -z "${AS_LEG_HOME// }" ]; then
    echo "INFO: AS LEGACY HOME               : [$AS_LEG_HOME]"
fi

if ! [ "$ARG_AS_LEG_VERSION" = "na" -o -z "${ARG_AS_LEG_VERSION// }" ]; then
    echo "INFO: AS LEGACY VERSION            : [$ARG_AS_LEG_VERSION]"
    if ! [ "$ARG_AS_LEG_HOTFIX" = "na" -o -z "${ARG_AS_LEG_HOTFIX// }" ]; then
        echo "INFO: AS LEGACY HF                 : [$ARG_AS_LEG_HOTFIX]"
    fi
fi

if ! [ "$FTL_HOME" = "na" -o -z "${FTL_HOME// }" ]; then
    echo "INFO: FTL HOME                     : [$FTL_HOME]"
fi

if ! [ "$ARG_FTL_VERSION" = "na" -o -z "${ARG_FTL_VERSION// }" ]; then
    echo "INFO: FTL VERSION                  : [$ARG_FTL_VERSION]"
    if ! [ "$ARG_FTL_HOTFIX" = "na" -o -z "${ARG_FTL_HOTFIX// }" ]; then
        echo "INFO: FTL HF                       : [$ARG_FTL_HOTFIX]"
    fi
fi

if ! [ "$AS_HOME" = "na" -o -z "${AS_HOME// }" ]; then
    echo "INFO: AS HOME                      : [$AS_HOME]"
fi

if ! [ "$ARG_AS_VERSION" = "na" -o -z "${ARG_AS_VERSION// }" ]; then
    echo "INFO: AS VERSION                   : [$ARG_AS_VERSION]"
    if ! [ "$ARG_AS_HOTFIX" = "na" -o -z "${ARG_AS_HOTFIX// }" ]; then
        echo "INFO: AS HF                        : [$ARG_AS_HOTFIX]"
    fi
fi

if ! [ -z "${EAR_FILE_NAME// }" -o -z "${CDD_FILE_NAME// }" ]; then
    echo "INFO: CDD FILE NAME                : [$CDD_FILE_NAME]"
    echo "INFO: EAR FILE NAME                : [$EAR_FILE_NAME]"    
fi

echo "INFO: DOCKERFILE                   : [$ARG_DOCKER_FILE]"
echo "INFO: IMAGE TAG                    : [$ARG_IMAGE_VERSION]"
echo "INFO: BUILD TOOL                   : [$ARG_BUILD_TOOL]"

if ! [ "$ARG_GVPROVIDER" = "na" -o -z "${ARG_GVPROVIDER// }" ]; then
    ARG_GVPROVIDER=$(removeDuplicatesAndFormatGVs $ARG_GVPROVIDER)
    echo "INFO: GV PROVIDER                  : [$ARG_GVPROVIDER]"
fi

echo "INFO: JRE VERSION                  : [$ARG_JRE_VERSION]"

echo "------------------------------------------------------------------------------"

if [ "$IMAGE_NAME" = "$RMS_IMAGE" -a "$ARG_AS_LEG_SHORT_VERSION" = "na" ]; then
    if [ $(echo "${ARG_BE_VERSION//.}") -lt 611 ]; then
        printf "\nERROR: TIBCO Activespaces(legacy) Required for RMS.\n\n"
        exit 1
    fi
fi

if [ "$IMAGE_NAME" = "$BUILDER_IMAGE" -a "$ARG_BUILD_TOOL" = "buildah" ]; then
    printf "\nERROR: s2ibuilder image is not supported with buildah tool.\n\n"
    exit 1
fi

if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    if [ "$FTL_HOME" != "na" -a "$AS_LEG_HOME" != "na" ]; then
        printf "\nWARN: Local machine contains both FTL and Activespaces(legacy) installations. Removing unused installation improves the container image size.\n\n"
    fi
    if [ "$IMAGE_NAME" != "$TEA_IMAGE" -a "$AS_LEG_HOME" = "na" ]; then
        if ! [ $(echo "${ARG_BE_VERSION//.}") -ge 600 ]; then
            printf "\nWARN: TIBCO Activespaces(legacy) will not be installed as AS_HOME is not defined in $TRA_FILE_NAME file.\n\n"
        fi
    fi
else
    if [ "$IMAGE_NAME" != "$TEA_IMAGE" -a "$ARG_AS_LEG_VERSION" = "na" ]; then
        if ! [ $(echo "${ARG_BE_VERSION//.}") -ge 600 ]; then
            printf "\nWARN: TIBCO Activespaces(legacy) will not be installed as no package found in the installer location.\n\n"
        fi
    fi
    if [[ ( "$ARG_AS_LEG_VERSION" != "na" ) && ( "$ARG_FTL_VERSION" != "na" ) ]]; then
        printf "\nWARN: The directory: [$ARG_INSTALLER_LOCATION] contains both FTL and Activespaces(legacy) installers. Removing unused installer improves the container image size.\n\n"
    fi
fi

mkdir -p $TEMP_FOLDER/{installers,app}
cp -a "./lib" $TEMP_FOLDER/

if [ "$ARG_APP_LOCATION" != "na" ]; then
    cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app
fi

if [ "$IMAGE_NAME" != "$TEA_IMAGE" ]; then
    mkdir -p $TEMP_FOLDER/gvproviders
    cp ./gvproviders/*.sh $TEMP_FOLDER/gvproviders
    if [ "$ARG_GVPROVIDER" = "na" -o -z "${ARG_GVPROVIDER// }" ]; then
        ARG_GVPROVIDER="na"
    else
        oIFS="$IFS"; IFS=','; declare -a GVs=($ARG_GVPROVIDER); IFS="$oIFS"; unset oIFS
        
        for GV in "${GVs[@]}"
        do
            if [ "$GV" = "http" -o "$GV" = "consul" ]; then
                mkdir -p $TEMP_FOLDER/gvproviders/$GV
                cp -a ./gvproviders/$GV/*.sh $TEMP_FOLDER/gvproviders/$GV
            else
                if [ -d "./gvproviders/$GV" ]; then
                    # check for setup.sh & run.sh
                    if ! [ -f "./gvproviders/$GV/setup.sh" ]; then
                        echo "ERROR: setup.sh is required for the GV provider[$GV] under the directory - [./gvproviders/$GV/]"
                        rm -rf $TEMP_FOLDER; exit 1;
                    elif ! [ -f "./gvproviders/$GV/run.sh" ]; then
                        echo "ERROR: run.sh is required for the GV provider[$GV] under the directory - [./gvproviders/$GV/]"
                        rm -rf $TEMP_FOLDER; exit 1;
                    fi
                    mkdir -p $TEMP_FOLDER/gvproviders/$GV
                    cp -a ./gvproviders/$GV/* $TEMP_FOLDER/gvproviders/$GV
                else
                    echo "ERROR: GV provider[$GV] is not supported."
                    rm -rf $TEMP_FOLDER; exit 1;
                fi
            fi
        done
    fi
fi

if [ "$IMAGE_NAME" = "$RMS_IMAGE" -a "$ARG_APP_LOCATION" = "na" ]; then
    EAR_FILE_NAME="RMS.ear"
	CDD_FILE_NAME="RMS.cdd"
    touch $TEMP_FOLDER/app/dummyrms.txt
fi

# configurations for s2i builder image
if [ "$IMAGE_NAME" = "$BUILDER_IMAGE" ]; then
	touch $TEMP_FOLDER/app/dummy.txt
    EAR_FILE_NAME="dummy.txt"
	CDD_FILE_NAME="dummy.txt"
    FINAL_BUILDER_IMAGE_TAG=$ARG_IMAGE_VERSION
    ARG_IMAGE_VERSION=$(echo "$BE_TAG":"$ARG_BE_VERSION"-"$ARG_BE_VERSION")
    cp -a "./s2i" $TEMP_FOLDER/
fi

# create be tar/ copy installers to temp folder
if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    #tar command for be package
    BE_TAR_CMD=" tar -C $BE_HOME_BASE -cf $TEMP_FOLDER/be.tar tibcojre64 $BE_DIR/lib $BE_DIR/bin "
    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/rms $BE_DIR/studio $BE_DIR/eclipse-platform $BE_DIR/examples/standard/WebStudio $BE_DIR/mm "
    elif [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        BE_TAR_CMD="$BE_TAR_CMD $BE_DIR/teagent $BE_DIR/mm "
    fi
    if [ -d "$BE_HOME/decisionmanager" ]; then
        BE_TAR_CMD="$BE_TAR_CMD $BE_DIR/decisionmanager "
    fi
    if [ -d "$BE_HOME/hotfix" ]; then
        BE_TAR_CMD="$BE_TAR_CMD $BE_DIR/hotfix "
    fi

    echo "INFO: Adding [$BE_DIR] to tar file."
    #execute be tar command
    $BE_TAR_CMD

    # check as leg if exist add it to be tar file
    if [ "$AS_LEG_HOME" != "na" ]; then
        echo "INFO: Adding [$AS_LEG_DIR] to tar file."
        tar -C $AS_LEG_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_LEG_DIR/lib #$AS_LEG_DIR/bin
        if [ -d "$AS_LEG_DIR/hotfix" ]; then
            tar -C $AS_LEG_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_LEG_DIR/hotfix
        fi
    fi

    # check as if exist add it to be tar file
    if [ "$AS_HOME" != "na" ]; then
        echo "INFO: Adding [$AS_DIR] to tar file."
        tar -C $AS_HOME_BASE -rf $TEMP_FOLDER/be.tar $AS_DIR/lib #$AS_DIR/bin
    fi

    # check ftl if exist add it to be tar file
    if [ "$FTL_HOME" != "na" ]; then
        echo "INFO: Adding [$FTL_DIR] to tar file."
        tar -C $FTL_HOME_BASE -rf $TEMP_FOLDER/be.tar $FTL_DIR/lib #$FTL_DIR/bin
    fi

    # create another temp folder and replace be_home to /opt/tibco
    RANDM_FOLDER="tmp$RANDOM"
    mkdir $TEMP_FOLDER/$RANDM_FOLDER

    # Exract it
    tar -C $TEMP_FOLDER/$RANDM_FOLDER -xf $TEMP_FOLDER/be.tar

    OPT_TIBCO="/opt/tibco"
    # Replace be home in tra files with opt/tibco
    echo "INFO: Replacing base directory in the files from [$BE_HOME_BASE] to [/opt/tibco]."

    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"

    if [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        # Replace in props files
        find $TEMP_FOLDER/$RANDM_FOLDER -name 'be-teagent.props' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"

        # Replace in log4j files
        find $TEMP_FOLDER/$RANDM_FOLDER -name 'log4j*.properties' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"
    fi

    REGEX_CUSTOM_CP="tibco\.env\.CUSTOM_EXT_PREPEND_CP=.*"
    VALUE_CUSTOM_CP="tibco.env.CUSTOM_EXT_PREPEND_CP=/opt/tibco/be/ext"
    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$REGEX_CUSTOM_CP~$VALUE_CUSTOM_CP~g"

    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/rms/bin -name '*.cdd' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"
    fi

    if [ -e "$TEMP_FOLDER/app/$CDD_FILE_NAME" ]; then
        find $TEMP_FOLDER/app -name '*.cdd' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g" 2>/dev/null
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

    #remove unecessary files from bin folder
    CURR_DIR=$PWD
    cd $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/bin
    ls | grep -v "be-engine*" | xargs rm 2>/dev/null
    echo "java.property.be.engine.jmx.connector.port=%jmx_port%" >> be-engine.tra
    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        echo "java.property.be.engine.jmx.connector.port=%jmx_port%" >> ../rms/bin/be-rms.tra
    fi
    cp "$BE_HOME/bin/dbkeywordmap.xml" .
    if [ -e "$BE_HOME/bin/cassandrakeywordmap.xml" ]; then
        cp "$BE_HOME/bin/cassandrakeywordmap.xml" .
    fi
    cd $CURR_DIR

    # removing all .bak files
    find $TEMP_FOLDER -type f -name "*.bak" -exec rm -f {} \;

    rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/eclipse 2>/dev/null
    rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$FTL_DIR/lib/simplejson 2>/dev/null

    #removing tomsawyer and gwt
    if [ "$IMAGE_NAME" != "$RMS_IMAGE" ]; then
        rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/gwt 2>/dev/null
        rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/tomsawyer 2>/dev/null
    fi

    if [ "$IMAGE_NAME" = "$RMS_IMAGE" -o "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/aws -type f -not -name 'guava*' -delete 2>/dev/null
    fi

    if [[ "$ARG_APP_LOCATION" != "na" && "$IMAGE_NAME" = "$APP_IMAGE" ]] || [[ "$IMAGE_NAME" = "$BUILDER_IMAGE" ]]; then
        mkdir -p $TEMP_FOLDER/$RANDM_FOLDER/be/{application/ear,ext}
        cp $TEMP_FOLDER/app/* $TEMP_FOLDER/$RANDM_FOLDER/be/ext
        cp $TEMP_FOLDER/$RANDM_FOLDER/be/ext/$CDD_FILE_NAME $TEMP_FOLDER/$RANDM_FOLDER/be/application
        cp $TEMP_FOLDER/$RANDM_FOLDER/be/ext/$EAR_FILE_NAME $TEMP_FOLDER/$RANDM_FOLDER/be/application/ear
        rm -f $TEMP_FOLDER/$RANDM_FOLDER/be/ext/${CDD_FILE_NAME} $TEMP_FOLDER/$RANDM_FOLDER/be/ext/${EAR_FILE_NAME}
    fi

    if [ "$IMAGE_NAME" = "$RMS_IMAGE" -a "$ARG_APP_LOCATION" != "na" ]; then
        mkdir -p $TEMP_FOLDER/$RANDM_FOLDER/be/ext
        cp $TEMP_FOLDER/app/* $TEMP_FOLDER/$RANDM_FOLDER/be/ext/
        cp $TEMP_FOLDER/$RANDM_FOLDER/be/ext/$CDD_FILE_NAME $TEMP_FOLDER/$RANDM_FOLDER/be/ext/$EAR_FILE_NAME $TEMP_FOLDER/$RANDM_FOLDER/be/${ARG_BE_SHORT_VERSION}/rms/bin
        rm -f $TEMP_FOLDER/$RANDM_FOLDER/be/ext/${CDD_FILE_NAME} $TEMP_FOLDER/$RANDM_FOLDER/be/ext/${EAR_FILE_NAME}
    fi

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
    rm -rf $TEMP_FOLDER/$RANDM_FOLDER 2>/dev/null
else
    for i in "${FILE_LIST[@]}" ; do
        echo "INFO: Copying package: [$i]"
        cp $i $TEMP_FOLDER/installers 
    done
fi

# building docker image
printf "\nINFO: Building container image.\n\n\n"

cp $ARG_DOCKER_FILE $TEMP_FOLDER
ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"
if [ -z "$DOCKER_BUILDKIT" ]; then
    export DOCKER_BUILDKIT=1
fi

if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    if [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        BUILD_ARGS=$(echo --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" --build-arg JRE_VERSION=$ARG_JRE_VERSION -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER")
    else
        BUILD_ARGS=$(echo --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg DOCKERFILE_NAME="$ARG_DOCKER_FILE" --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg GVPROVIDER=$ARG_GVPROVIDER --build-arg JRE_VERSION=$ARG_JRE_VERSION -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER")
    fi
else
    if [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        BUILD_ARGS=$(echo --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION"  --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX"  --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE  --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER)
    else
        BUILD_ARGS=$(echo --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg AS_VERSION="$ARG_AS_LEG_VERSION" --build-arg AS_SHORT_VERSION="$ARG_AS_LEG_SHORT_VERSION" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_LEG_HOTFIX" --build-arg FTL_VERSION="$ARG_FTL_VERSION" --build-arg FTL_SHORT_VERSION="$ARG_FTL_SHORT_VERSION" --build-arg FTL_PRODUCT_HOTFIX="$ARG_FTL_HOTFIX" --build-arg ACTIVESPACES_VERSION="$ARG_AS_VERSION" --build-arg ACTIVESPACES_SHORT_VERSION="$ARG_AS_SHORT_VERSION" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg GVPROVIDER=$ARG_GVPROVIDER --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg TEMP_FOLDER=$TEMP_FOLDER -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER)
    fi
fi

if [ "$ARG_BUILD_TOOL" = "buildah" ]; then
    SKIP_CONTAINER_TESTS="true"
    buildah bud -f $TEMP_FOLDER/$ARG_DOCKER_FILE $BUILD_ARGS
else
    docker build --force-rm -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} $BUILD_ARGS
fi

if [ "$?" != 0 ]; then
    echo "ERROR: Container build failed."
else
    BUILD_SUCCESS="true"
    # additional steps for s2i builder image
    if [ "$IMAGE_NAME" = "$BUILDER_IMAGE" ]; then
        docker build -f $S2I_DOCKER_FILE_APP --build-arg ARG_IMAGE_VERSION="$ARG_IMAGE_VERSION" -t "$FINAL_BUILDER_IMAGE_TAG" $TEMP_FOLDER/s2i
        docker rmi -f "$ARG_IMAGE_VERSION"
        ARG_IMAGE_VERSION=$FINAL_BUILDER_IMAGE_TAG
    fi
fi

if [ "$ARG_BUILD_TOOL" = "docker" ]; then
    if [ "$DOCKER_BUILDKIT" = 1 ]; then
        docker builder prune -f
    fi

    export INTERMEDIATE_IMAGE=$(docker images -q -f "label=be-intermediate-image=true")

    if [ "$INSTALLATION_TYPE" != "fromlocal" -a "$INTERMEDIATE_IMAGE" != "" ]; then
        echo "INFO: Deleting temporary intermediate image."
        docker rmi -f $INTERMEDIATE_IMAGE
    fi
fi

echo "INFO: Deleting folder: [$TEMP_FOLDER]."
rm -rf $TEMP_FOLDER

if [ "$BUILD_SUCCESS" = "true" ]; then
    echo "INFO: Container build successfull using the build tool[$ARG_BUILD_TOOL]. Image Name: [$ARG_IMAGE_VERSION]"
    # docker unit tests
    if [ "$SKIP_CONTAINER_TESTS" != "true" ]; then
        if [[ ($ARG_ENABLE_TESTS = "true") && (("$IMAGE_NAME" = "$BUILDER_IMAGE") || ("$IMAGE_NAME" = "$APP_IMAGE")) ]]; then
            cd ./tests
            source run_tests.sh -i $ARG_IMAGE_VERSION  -b $ARG_BE_SHORT_VERSION -al $ARG_AS_LEG_SHORT_VERSION -as $ARG_AS_SHORT_VERSION -f $ARG_FTL_SHORT_VERSION
        fi
    fi
fi
