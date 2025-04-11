#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

isCLIKey()
{
    KEY_NAME=$1
    KEY="false"

    case "$KEY_NAME" in
        -s|--source)
            KEY="true"
            ;;
        -i|--image-type)
            KEY="true"
            ;;
        -a|--app-location)
            KEY="true"
            ;;
        -t|--tag)
            KEY="true"
            ;;
        -d|--docker-file)
            KEY="true"
            ;;
        --config-provider)
            KEY="true"
            ;;
        -b|--build-tool)
            KEY="true"
            ;;
        --optimize)
            KEY="true"
            ;;
    esac

    echo $KEY
}

check_cdd_and_ear() {
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
}

deleteTempImage() {
    if docker image inspect $PERL_UTILITY_IMAGE_NAME > /dev/null 2>&1; then
        docker rmi -f $PERL_UTILITY_IMAGE_NAME > /dev/null 2>&1;
    fi
}

source ./scripts/utils.sh
FILE_NAME=$(basename $0)

# image type variables
IMAGE_NAME=""
APP_IMAGE="app"
RMS_IMAGE="rms"
TEA_IMAGE="teagent"
BUILDER_IMAGE="s2ibuilder"
BASE_IMAGE="base"

TEMP_FOLDER="tmp_$RANDOM"

# input variables
ARG_SOURCE="na"
ARG_TYPE="na"
ARG_APP_LOCATION="na"
ARG_TAG="na"
ARG_DOCKER_FILE="na"
ARG_CONFIGPROVIDER="na"
ARG_ENABLE_TESTS="true"
ARG_BUILD_TOOL=""
ARG_USE_OPEN_JDK="false"
ARG_OPTIMIZE="na"

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
BE_BASE_PKG_REGEX="${BE_PRODUCT}-${ARG_EDITION}_[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}${INSTALLER_PLATFORM}"
VALIDATE_FTL_AS="false"

#Map used to store the BE and it's comapatible JRE version
declare -a BE_VERSION_AND_JRE_MAP
BE_VERSION_AND_JRE_MAP=("5.6.0" "1.8.0" "5.6.1" "11" "6.0.0" "11" "6.1.0" "11" "6.1.1" "11" "6.1.2" "11" "6.2.0" "11" "6.2.1" "11" "6.2.2" "11" "6.3.0" "11" "6.3.1" "17" "6.3.2" "17")

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

# hawk related args
HAWK_HOME="na"
ARG_HAWK_VERSION="na"
ARG_HAWK_SHORT_VERSION="na"
ARG_HAWK_HOTFIX="na"

# tea related args
TEA_HOME="na"
ARG_TEA_VERSION="na"
ARG_TEA_HOTFIX="na"
ARG_PYTHON_VERSION=python3

# s2i builder related args
BE_TAG="com.tibco.be"
S2I_DOCKER_FILE_APP="./dockerfiles/Dockerfile-s2i"

# default installation type fromlocal
INSTALLATION_TYPE="fromlocal"

# openjdk related vars
OPEN_JDK_VERSION="na"
OPEN_JDK_FILENAME="na"

JAVA_HOME_DIR_NAME=tibcojre64

# JRE SUPPLEMENT  related args
ARG_JRESPLMNT_VERSION="na"
ARG_JRESPLMNT_SHORT_VERSION="na"
ARG_JRESPLMNT_HOTFIX="na"

#Pre check perl existance
IS_PERL_INSTALLED="false"
if command -v perl >/dev/null 2>&1; then
    IS_PERL_INSTALLED="true"
else
    #install perl utility image
    DOCKER_PKG=$( which docker )
    if [ "$DOCKER_PKG" == "" ]; then
        echo "ERROR: Build tool[docker] not found. Please install docker or perl."
        exit 1
    fi
    PERL_UTILITY_IMAGE_NAME="be-perl-utility-$TEMP_FOLDER:v1"
    docker run --name=mytempcontainer-$TEMP_FOLDER -it docker.io/library/ubuntu:20.04 /bin/bash -c "apt-get update > /dev/null 2>&1 && apt-get install -y unzip > /dev/null 2>&1 && exit" > /dev/null 2>&1 && docker commit mytempcontainer-$TEMP_FOLDER $PERL_UTILITY_IMAGE_NAME > /dev/null 2>&1 && docker rm mytempcontainer-$TEMP_FOLDER > /dev/null 2>&1
fi

# container image size optimize related vars
if [ "$IS_PERL_INSTALLED" = "true" ]; then
    OPTIMIZATION_SUPPORTED_MODULES=$(perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::get_all_modules_print_friendly()')
else
    OPTIMIZATION_SUPPORTED_MODULES=$(docker run --rm -v .:/app -w /app $PERL_UTILITY_IMAGE_NAME perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::get_all_modules_print_friendly()')
fi

INCLUDE_MODULES="na"

USAGE="\nUsage: $FILE_NAME"

USAGE+="\n\n [-i/--image-type]    :    Type of the image to build (\"$APP_IMAGE\"|\"$RMS_IMAGE\"|\"$TEA_IMAGE\"|\"$BUILDER_IMAGE\"|\"$BASE_IMAGE\") [required]"
USAGE+="\n\n [-a/--app-location]  :    Path to BE application where cdd, ear & optional supporting jars are present\n"
USAGE+="                           Note: Required if --image-type is \"$APP_IMAGE\"\n"
USAGE+="                                 Optional if --image-type is \"$RMS_IMAGE\"\n"
USAGE+="                                 Ignored  if --image-type is \"$TEA_IMAGE\",\"$BUILDER_IMAGE\" or \"$BASE_IMAGE\" "
USAGE+="\n\n [-s/--source]        :    Path to BE_HOME or TIBCO installers (BusinessEvents, Activespaces or FTL) are present (default \"../../\")\n"
USAGE+="                           Note: Alternatively, use the base docker image name, applicable only if --image-type is $APP_IMAGE"
USAGE+="\n\n [-t/--tag]           :    Name and optionally a tag in the 'name:tag' format [optional]"
USAGE+="\n\n [-d/--docker-file]   :    Dockerfile to be used for generating image [optional]"
USAGE+="\n\n [--config-provider]  :    Name of Config Provider to be included in the image (\"gvconsul\"|\"gvhttp\"|\"gvcyberark\"|\"cmcncf\"|\"custom\") [optional]\n"
USAGE+="                           To add more than one Config Provider use comma separated format ex: \"gvconsul,gvhttp\" \n"
USAGE+="                           Note: This flag is ignored if --image-type is \"$TEA_IMAGE\""
USAGE+="\n\n [--disable-tests]    :    Disables docker unit tests on created image (applicable only for \"$APP_IMAGE\" , \"$BASE_IMAGE\" and \"$BUILDER_IMAGE\" image types) [optional]"
USAGE+="\n\n [-b/--build-tool]    :    Build tool to be used (\"docker\"|\"buildah\") (default is \"docker\")\n"
USAGE+="                           Note: $BUILDER_IMAGE image and docker unit tests not supported for buildah."
USAGE+="\n\n [-o/--openjdk]       :    Uses OpenJDK instead of tibcojre [optional]\n"
USAGE+="                           Note: Place OpenJDK installer archive along with TIBCO installers.\n"
USAGE+="                                 OpenJDK can be downloaded from https://jdk.java.net/java-se-ri/11."
USAGE+="\n\n [--optimize]         :    Enables container image size optimization [optional]\n"
USAGE+="                           When CDD/EAR available, most of the modules are identified automatically.\n"
USAGE+="                           Additional module names can be passed as comma separated string. Ex: \"process,query,pattern,analytics\" \n"
USAGE+="                           Supported modules: $OPTIMIZATION_SUPPORTED_MODULES."
USAGE+="\n\n [-h/--help]          :    Print the usage of script [optional]"
USAGE+="\n\n NOTE : supply long options with '=' \n"

#Parse the arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    FLAG_CLIKEY="false"
    case "$key" in
        -s|--source)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_SOURCE="$1"
            fi
            ;;
        -s=*|--source=*)
            ARG_SOURCE="${key#*=}"
            ;;
        -i|--image-type)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_TYPE="$1"
            fi
            ;;
        -i=*|--image-type=*)
            ARG_TYPE="${key#*=}"
	        ;;
        -a|--app-location)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_APP_LOCATION="$1"
            fi
            ;;
        -a=*|--app-location=*)
            ARG_APP_LOCATION="${key#*=}"
	        ;;
        -t|--tag)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_TAG="$1"
            fi
            ;;
        -t=*|--tag=*)
            ARG_TAG="${key#*=}"
	        ;;
        -d|--docker-file)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_DOCKER_FILE="$1"
            fi
            ;;
        -d=*|--docker-file=*)
            ARG_DOCKER_FILE="${key#*=}"
            ;;
        --config-provider)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_CONFIGPROVIDER="$1"
            fi
            ;;
        --config-provider=*)
            ARG_CONFIGPROVIDER="${key#*=}"
            ;;
        -b|--build-tool)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "false" ]; then
                ARG_BUILD_TOOL="$1"
            fi
            ;;
        -b=*|--build-tool=*)
            ARG_BUILD_TOOL="${key#*=}"
            ;;
        --disable-tests)
            ARG_ENABLE_TESTS="false"
            ;;
        -o|--openjdk)
            ARG_USE_OPEN_JDK="true"
            ;;
        --optimize)
            shift # past the key and to the value
            FLAG_CLIKEY=$(isCLIKey $1 )
            if [ "$FLAG_CLIKEY" = "true" ]; then
                ARG_OPTIMIZE=""
            else
                ARG_OPTIMIZE="$1"
            fi
            ;;
        --optimize=*)
            ARG_OPTIMIZE="${key#*=}"
            ;;
        -h|--help)
            shift # past the key and to the value
            printf "$USAGE"
            deleteTempImage
            exit 0
            ;;
        *)
            echo "Invalid Option: [$key]"
            ;;
    esac
    if [ "$FLAG_CLIKEY" = "false" ]; then
        shift
    fi
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

IMAGE_NAME="$ARG_TYPE"

CHECK_FOR_BUILDAH="false"
if [ "$ARG_BUILD_TOOL" == "" ]; then
    ARG_BUILD_TOOL="docker"
    CHECK_FOR_BUILDAH="true"
fi

if ! [[ "$ARG_BUILD_TOOL" = "docker" || "$ARG_BUILD_TOOL" = "buildah" ]]; then
    echo "ERROR: Build tool[$ARG_BUILD_TOOL] is not valid. Only docker/buildah tool is supported."
    exit 1
fi

OS_NAME=$(uname -s)
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
    fi
fi

if [ "$ARG_SOURCE" != "na" ]; then
    # check here if source is docker image
    if [ "$ARG_BUILD_TOOL" = "docker" -a "$IMAGE_NAME" = "$APP_IMAGE" ]; then
        if docker image inspect "$ARG_SOURCE" > /dev/null 2>&1 || docker pull "$ARG_SOURCE" > /dev/null 2>&1; then
            if [ "$IS_PERL_INSTALLED" = "false" ]; then
                deleteTempImage
            fi
            source ./scripts/appfrombaseimage.sh
        fi
    elif [ "$ARG_BUILD_TOOL" = "buildah" -a "$IMAGE_NAME" = "$APP_IMAGE" ]; then
        if buildah inspect "$ARG_SOURCE" > /dev/null 2>&1 || buildah pull "$ARG_SOURCE" > /dev/null 2>&1; then
            source ./scripts/appfrombaseimage.sh
        fi
    fi
    bePckgsCnt=$(find $ARG_SOURCE -maxdepth 1 | grep -E "${BE_BASE_PKG_REGEX}" 2>/dev/null | wc -l)
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
    "$BUILDER_IMAGE" | "$BASE_IMAGE")
        DOCKER_FILE="./dockerfiles/Dockerfile"
        ;;
    *)
        printf "\nERROR: Invalid image type provided. Image type must be either of $APP_IMAGE,$RMS_IMAGE,$TEA_IMAGE,$BUILDER_IMAGE or $BASE_IMAGE.\n"
        exit 1
        ;;
esac

# assign proper docker file to ARG_DOCKER_FILE variable
if [ "$ARG_DOCKER_FILE" = "na" -o -z "${ARG_DOCKER_FILE// }" ]; then
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
        if [ "$IMAGE_NAME" = "$APP_IMAGE" ]; then
            printf "\nERROR: The directory: [$BE_HOME] is not a valid directory. Provide proper path to be-home, installers location or valid base image.\n"
        else
            printf "\nERROR: The directory: [$BE_HOME] is not a valid directory. Provide proper path to be-home or installers location.\n"
        fi
        exit 1
    elif [ "$BE_HOME" = "na" ]; then
        BE_HOME=$( readlink -e ../.. )
    fi

    BE_HOME_REGEX="(.*.)\/(be\/[0-9]{1,}\.[0-9]{1,})$"
    if ! [[ $BE_HOME =~ $BE_HOME_REGEX ]]; then
        printf "\nERROR: Provide proper be home [be/<be-version>] (ex: <path to>/be/6.0). OR Path to installers location.\n"
        exit 1
    else
        BE_HOME_BASE=${BASH_REMATCH[1]}
        BE_DIR=${BASH_REMATCH[2]}
    fi
fi

# check app location
if [ "$IMAGE_NAME" = "$BUILDER_IMAGE" -o "$IMAGE_NAME" = "$TEA_IMAGE" -o "$IMAGE_NAME" = "$BASE_IMAGE" ]; then
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
    check_cdd_and_ear
fi

# assign image tag to ARG_IMAGE_VERSION variable
ARG_IMAGE_VERSION="$ARG_TAG"

# get product details for both fromlocal and frominstallers
if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    VERSION_REGEX=([0-9]{1,}\.[0-9]{1,}).*

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
    elif [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        TRA_FILE="teagent/bin/be-teagent.tra"
    else
        TRA_FILE="bin/be-engine.tra"
    fi
    TRA_FILE_NAME=$(basename $TRA_FILE)

    if [ "$IMAGE_NAME" != "$TEA_IMAGE" ]; then

        VALIDATE_FTL_AS=$(validateFTLandAS $ARG_BE_VERSION $IMAGE_NAME $RMS_IMAGE )

        ## get as legacy details
        AS_LEG_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.AS_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
        
        if [ "$AS_LEG_HOME" = "" ]; then
            AS_LEG_HOME="na"
        else
            # check directory exist
            if ! [ -d "$AS_LEG_HOME" ]; then
                printf "\nERROR: The directory: [$AS_LEG_HOME] not exist. Ignoring Activespaces(legacy) installation.\n"
                AS_LEG_HOME="na"
            else
                AS_LEG_HOME_REGEX="(.*.)\/(as\/[0-9]{1,}\.[0-9]{1,})$"
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
        FTL_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.FTL_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
        if [ "$FTL_HOME" = "" ]; then
            FTL_HOME="na"
        else
            # check directory exist
            if ! [ -d "$FTL_HOME" ]; then
                printf "\nERROR: The directory: [$FTL_HOME] not exist. Ignoring FTL installation.\n"
                FTL_HOME="na"
            else
                FTL_HOME_REGEX="(.*.)\/(ftl\/[0-9]{1,}\.[0-9]{1,})$"
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
        AS_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.ACTIVESPACES_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
        if [ "$AS_HOME" = "" ]; then
            AS_HOME="na"
        else
            # check directory exist
            if ! [ -d "$AS_HOME" ]; then
                printf "\nERROR: The directory: [$AS_HOME] not exist. Ignoring Activespaces installation.\n"
                AS_HOME="na"
            else
                AS_HOME_REGEX="(.*.)\/(as\/[0-9]{1,}\.[0-9]{1,})$"
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

    if [ $(echo "${ARG_BE_VERSION//.}") -ge 622 -a  "$IMAGE_NAME" = "$APP_IMAGE" ]; then
        # get hawk details
        HAWK_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.HAWK_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
        if [ "$HAWK_HOME" = "" ]; then
            HAWK_HOME="na"
        else
            # check directory exist
            if ! [ -d "$HAWK_HOME" ]; then
                printf "\nERROR: The directory: [$HAWK_HOME] not exist. Ignoring HAWK installation.\n"
                HAWK_HOME="na"
            else
                HAWK_HOME_REGEX="(.*.)\/(hawk\/[0-9]{1,}\.[0-9]{1,})$"
                if ! [[ $HAWK_HOME =~ $HAWK_HOME_REGEX ]]; then
                    printf "\nERROR: Update proper HAWK home path: [$HAWK_HOME] in $TRA_FILE_NAME file (ex: <path-to>/hawk/<hawk-version>).\n"
                    exit 1
                fi
                HAWK_HOME_BASE=${BASH_REMATCH[1]}
                HAWK_DIR=${BASH_REMATCH[2]}
                ARG_HAWK_SHORT_VERSION=$( echo ${HAWK_HOME}  | rev | cut -d'/' -f1 | rev )
            fi
        fi
    fi

    if [ $(echo "${ARG_BE_VERSION//.}") -ge 630 -a  "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        # get tea details
        TEA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TEA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
        if [ "$TEA_HOME" = "" ]; then
            echo "ERROR: TEA_HOME is not set in TEA tra file"
            exit 1
        else
            # check directory exist
            if ! [ -d "$TEA_HOME" ]; then
                printf "\nERROR: TEA HOME directory: [$TEA_HOME] not exist.\n"
                exit 1
            else
                TEA_HOME_REGEX="(.*.)\/(tea\/[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,})$"
                if ! [[ $TEA_HOME =~ $TEA_HOME_REGEX ]]; then
                    printf "\nERROR: Update proper TEA home path: [$TEA_HOME] in $TRA_FILE_NAME file (ex: <path-to>/tea/<tea-version>).\n"
                    exit 1
                fi
                TEA_HOME_BASE=${BASH_REMATCH[1]}
                TEA_DIR=${BASH_REMATCH[2]}
                ARG_TEA_VERSION=$( echo ${TEA_HOME}  | rev | cut -d'/' -f1 | rev )
            fi
        fi
        if [ "$ARG_TEA_VERSION" = "na" ]; then
            echo "ERROR: Unable to capture TEA server version from TEA_HOME[$TEA_HOME]. Please check TEA_HOME is set properly in TEA tra file"
            exit 1
        fi
        ARG_PYTHON_VERSION=python2
    fi

    #get installed jre details
    TRA_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
else
    #version regex for all products
    VERSION_REGEX=([0-9]{1,}\.[0-9]{1,}).[0-9]{1,}
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
    
    # check hawk installer
    if [ $(echo "${ARG_BE_VERSION//.}") -ge 622 -a  "$IMAGE_NAME" = "$APP_IMAGE" ]; then
        source ./scripts/hawk.sh
    fi

    # check tea installer
    if [ $(echo "${ARG_BE_VERSION//.}") -ge 630 -a  "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        source ./scripts/tea.sh
        if [ "$ARG_TEA_VERSION" = "na" ]; then
            echo "ERROR: TEA server installer not found in installer location[$ARG_INSTALLER_LOCATION]"
            exit 1
        fi
        ARG_PYTHON_VERSION=python2
    fi

    # check jresplmnt installer
    source ./scripts/jresplmnt.sh
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

if [ "$OS_NAME" = "Darwin" -a "$INSTALLATION_TYPE" = "fromlocal" ]; then
    echo "ERROR: Building image using local installation is not supported on MAC."
    exit 1
fi

if [ "$ARG_USE_OPEN_JDK" == "true" ]; then
    if [ "$INSTALLATION_TYPE" = "frominstallers" ]; then
        source ./scripts/openjdk.sh
        if [ "$ARG_JRE_VERSION" != "$OPEN_JDK_VERSION" ]; then
            echo "ERROR: OpenJDK Version [$OPEN_JDK_VERSION] and BE supported JRE Runtime Version [$ARG_JRE_VERSION] mismatch"
            exit 1
        fi
        #java home directory name changed to openjdk
        JAVA_HOME_DIR_NAME=openjdk
    fi
fi

if [ $(echo "${ARG_BE_VERSION//.}") -ge 620 -a "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
    DEFAULT_RMS_MODULES="as2,as4,ftl,store,ignite,http"
    if [ "$ARG_OPTIMIZE" != "" -a "$ARG_OPTIMIZE" != "na" ]; then
        ARG_OPTIMIZE="$ARG_OPTIMIZE,$DEFAULT_RMS_MODULES"
    else
        ARG_OPTIMIZE="$DEFAULT_RMS_MODULES"
    fi
fi

if ! [ "$ARG_OPTIMIZE" = "na" ]; then
    if [ $(echo "${ARG_BE_VERSION//.}") -lt 620 ]; then
        printf "\nWARN: Container optimization is supported only for BE versions 6.2.0 and above. Continuing build without optimization...\n\n"
    else
        if [ ! \( -z "${EAR_FILE_NAME// }" -o -z "${CDD_FILE_NAME// }" \) ]; then
            CDDFILE="$ARG_APP_LOCATION/$CDD_FILE_NAME"
            EARFILE="$ARG_APP_LOCATION/$EAR_FILE_NAME"
        else
            CDDFILE="na"
            EARFILE="na"
        fi

        if [ "$IS_PERL_INSTALLED" = "true" ]; then
            INCLUDE_MODULES=$(perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::parse_optimize_modules("'$ARG_OPTIMIZE'","'$CDDFILE'","'$EARFILE'")')
        else
            if [ "$ARG_BUILD_TOOL" == "buildah" ]; then
                deleteTempImage
                echo "ERROR: perl not found. Please install perl."
                exit 1
            fi
            
            if [ "$CDDFILE" != "na" -a "$EARFILE" != "na" ]; then
                mkdir -p $TEMP_FOLDER
                cp $CDDFILE $EARFILE $TEMP_FOLDER
                CDDFILE="$TEMP_FOLDER/$CDD_FILE_NAME"
                EARFILE="$TEMP_FOLDER/$EAR_FILE_NAME"
                INCLUDE_MODULES=$(docker run --rm -v .:/app -w /app $PERL_UTILITY_IMAGE_NAME perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::parse_optimize_modules("'$ARG_OPTIMIZE'","'$CDDFILE'","'$EARFILE'")')
            else
                INCLUDE_MODULES=$(docker run --rm -v .:/app -w /app $PERL_UTILITY_IMAGE_NAME perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::parse_optimize_modules("'$ARG_OPTIMIZE'","na","na")')
            fi
        fi
    fi
fi

if [ "$ARG_JRE_VERSION" = "na" ]; then
    echo "ERROR: Unsupported be version[$ARG_BE_VERSION]"
    exit 1
fi

# information display
echo "INFO: Supplied/Derived Data:"
echo "------------------------------------------------------------------------------"

echo "INFO: Building container image with the build tool[$ARG_BUILD_TOOL]."    

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

if ! [ "$HAWK_HOME" = "na" -o -z "${HAWK_HOME// }" ]; then
    echo "INFO: HAWK HOME                    : [$HAWK_HOME]"
fi

if ! [ "$ARG_HAWK_VERSION" = "na" -o -z "${ARG_HAWK_VERSION// }" ]; then
    echo "INFO: HAWK VERSION                 : [$ARG_HAWK_VERSION]"
    if ! [ "$ARG_HAWK_HOTFIX" = "na" -o -z "${ARG_HAWK_HOTFIX// }" ]; then
        echo "INFO: HAWK HF                      : [$ARG_HAWK_HOTFIX]"
    fi
fi

if ! [ "$TEA_HOME" = "na" -o -z "${TEA_HOME// }" ]; then
    echo "INFO: TEA HOME                     : [$TEA_HOME]"
fi

if ! [ "$ARG_TEA_VERSION" = "na" -o -z "${ARG_TEA_VERSION// }" ]; then
    echo "INFO: TEA VERSION                  : [$ARG_TEA_VERSION]"
    if ! [ "$ARG_TEA_HOTFIX" = "na" -o -z "${ARG_TEA_HOTFIX// }" ]; then
        echo "INFO: TEA HF                       : [$ARG_TEA_HOTFIX]"
    fi
fi

if ! [ "$ARG_JRESPLMNT_VERSION" = "na" -o -z "${ARG_JRESPLMNT_VERSION// }" ]; then
    echo "INFO: JRESPLMNT VERSION            : [$ARG_JRESPLMNT_VERSION]"
    if ! [ "$ARG_JRESPLMNT_HOTFIX" = "na" -o -z "${ARG_JRESPLMNT_HOTFIX// }" ]; then
        echo "INFO: JRESPLMNT HF                 : [$ARG_JRESPLMNT_HOTFIX]"
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

if ! [ "$ARG_CONFIGPROVIDER" = "na" -o -z "${ARG_CONFIGPROVIDER// }" ]; then
    ARG_CONFIGPROVIDER=$(RemoveDuplicatesAndFormatCPs $ARG_CONFIGPROVIDER)
    echo "INFO: CONFIG PROVIDER              : [$ARG_CONFIGPROVIDER]"
fi

if [ "$OPEN_JDK_VERSION" != "na" ]; then
    echo "INFO: OPEN JDK VERSION             : [$OPEN_JDK_VERSION]"
    if [ "$OPEN_JDK_FILENAME" != "na" ]; then
        echo "INFO: OPEN JDK FILENAME            : [$OPEN_JDK_FILENAME]"
    fi
else
    echo "INFO: JRE VERSION                  : [$ARG_JRE_VERSION]"
fi

if [ "$INCLUDE_MODULES" != "na" ]; then
    echo "INFO: CONTAINER OPTIMIZATION       : [Enabled]"
    if [ "$INCLUDE_MODULES" != "" ]; then
        echo "INFO: CONTAINER OPTIMIZING FOR     : [$INCLUDE_MODULES]"
    fi
fi

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
    mkdir -p $TEMP_FOLDER/configproviders
    cp ./configproviders/*.sh $TEMP_FOLDER/configproviders
    if [ "$ARG_CONFIGPROVIDER" = "na" -o -z "${ARG_CONFIGPROVIDER// }" ]; then
        ARG_CONFIGPROVIDER="na"
    else
        oIFS="$IFS"; IFS=','; declare -a CPs=($ARG_CONFIGPROVIDER); IFS="$oIFS"; unset oIFS
        
        for CP in "${CPs[@]}"
        do
            if [ "$CP" = "gvhttp" -o "$CP" = "gvconsul" -o "$CP" = "gvcyberark" -o "$CP" = "cmcncf" ]; then
                mkdir -p $TEMP_FOLDER/configproviders/$CP
                cp -a ./configproviders/$CP/*.sh $TEMP_FOLDER/configproviders/$CP
            else
                if [ -d "./configproviders/$CP" ]; then
                    # check for setup.sh & run.sh
                    if ! [ -f "./configproviders/$CP/setup.sh" ]; then
                        echo "ERROR: setup.sh is required for the Config Provider[$CP] under the directory - [./configproviders/$CP/]"
                        rm -rf $TEMP_FOLDER; exit 1;
                    elif ! [ -f "./configproviders/$CP/run.sh" ]; then
                        echo "ERROR: run.sh is required for the Config Provider[$CP] under the directory - [./configproviders/$CP/]"
                        rm -rf $TEMP_FOLDER; exit 1;
                    fi
                    mkdir -p $TEMP_FOLDER/configproviders/$CP
                    cp -a ./configproviders/$CP/* $TEMP_FOLDER/configproviders/$CP
                else
                    echo "ERROR: Config Provider[$CP] is not supported."
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

# configurations for base image
if [ "$IMAGE_NAME" = "$BASE_IMAGE" ]; then
	touch $TEMP_FOLDER/app/base.txt
    EAR_FILE_NAME="base.txt"
	CDD_FILE_NAME="base.txt"
fi

DEL_LIST_FILE_NAME="deletelist.txt"
if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
    DEL_LIST_FILE_NAME="deletelistrms.txt"
fi

if ! [ "$INCLUDE_MODULES" = "na" ]; then
    if [ "$IS_PERL_INSTALLED" = "true" ]; then
        perl -e 'require "./lib/be_container_optimize.pl"; be_container_optimize::prepare_delete_list("'$INCLUDE_MODULES'","'$TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME'")'
    else
        docker run --rm -v .:/app -w /app $PERL_UTILITY_IMAGE_NAME perl -e 'require "./lib/be_container_optimize.pl"; be_container_optimize::prepare_delete_list("'$INCLUDE_MODULES'","'$TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME'")'
    fi
fi

if [ "$INSTALLATION_TYPE" != "fromlocal" ]; then
    sed -i'.bak' "s~BE_HOME~/opt/tibco/be/$ARG_BE_SHORT_VERSION~g" $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME
    sed -i'.bak' "s~JAVA_HOME~/opt/tibco/$JAVA_HOME_DIR_NAME/$ARG_JRE_VERSION~g" $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME
    rm $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME.bak 2>/dev/null
fi

# create be tar/ copy installers to temp folder
if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    #tar command for be package
    BE_TAR_CMD=" tar -C $BE_HOME_BASE -cf $TEMP_FOLDER/be.tar $BE_DIR/lib $BE_DIR/bin "
    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/rms $BE_DIR/studio $BE_DIR/examples/standard/WebStudio $BE_DIR/mm "
        [ -d "$BE_HOME/eclipse-platform" ] && BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/eclipse-platform "
        [ -e "$BE_HOME/pom.xml" ] && BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/pom.xml "
        [ -e "$BE_HOME/examples/pom.xml" ] && BE_TAR_CMD="$BE_TAR_CMD  $BE_DIR/examples/pom.xml "
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

    # check hawk if exist add it to be tar file
    if [ "$HAWK_HOME" != "na" ]; then
        echo "INFO: Adding [$HAWK_DIR] to tar file."
        tar -C $HAWK_HOME_BASE -rf $TEMP_FOLDER/be.tar $HAWK_DIR/lib #$HAWK_DIR/bin
    fi

    # check tea if exist add it to be tar file
    if [ "$TEA_HOME" != "na" ]; then
        echo "INFO: Adding [$TEA_DIR] to tar file."
        tar -C $TEA_HOME_BASE -rf $TEMP_FOLDER/be.tar $TEA_DIR/agentlib #$TEA_DIR/bin
    fi

    # create another temp folder and replace be_home to /opt/tibco
    RANDM_FOLDER="tmp$RANDOM"
    mkdir $TEMP_FOLDER/$RANDM_FOLDER

    # Extract it
    tar -C $TEMP_FOLDER/$RANDM_FOLDER -xf $TEMP_FOLDER/be.tar

    OPT_TIBCO="/opt/tibco"
    # Replace be home in tra files with opt/tibco
    echo "INFO: Replacing base directory in the files from [$BE_HOME_BASE] to [/opt/tibco]."

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

    if [ "$HAWK_HOME" != "na" ]; then
        HAWK_HOME_KEY="tibco.env.HAWK_HOME=.*"
        HAWK_HOME_VAL="tibco.env.HAWK_HOME=$OPT_TIBCO/$HAWK_DIR"
        find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$HAWK_HOME_KEY~$HAWK_HOME_VAL~g"
    fi

    if [ "$TEA_HOME" != "na" ]; then
        TEA_HOME_KEY="tibco.env.TEA_HOME=.*"
        TEA_HOME_VAL="tibco.env.TEA_HOME=$OPT_TIBCO/$TEA_DIR"
        find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$TEA_HOME_KEY~$TEA_HOME_VAL~g"
    fi

    #remove unecessary files from bin folder
    CURR_DIR=$PWD
    cd $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/bin
    ls | grep -v "be-engine*" | xargs rm 2>/dev/null
    
    if [ "$IMAGE_NAME" = "$RMS_IMAGE" ]; then
        echo "java.property.be.engine.jmx.connector.port=%jmx_port%" >> ../rms/bin/be-rms.tra
    elif [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        echo "java.property.be.engine.jmx.connector.port=%jmx_port%" >> ../teagent/bin/be-teagent.tra
    else
        echo "java.property.be.engine.jmx.connector.port=%jmx_port%" >> be-engine.tra
    fi

    if [ -e $BE_HOME/bin/dbkeywordmap.xml ]; then
        cp "$BE_HOME/bin/dbkeywordmap.xml" .
    fi
    
    if [ -e "$BE_HOME/bin/cassandrakeywordmap.xml" ]; then
        cp "$BE_HOME/bin/cassandrakeywordmap.xml" .
    fi
    cd $CURR_DIR

    find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/eclipse/plugins -type f -not -name '*bpmn*' -delete 2>/dev/null
    rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$FTL_DIR/lib/simplejson 2>/dev/null

    #removing tomsawyer and gwt
    if [ "$IMAGE_NAME" != "$RMS_IMAGE" ]; then
        rm -rf $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/gwt 2>/dev/null
        find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/tomsawyer -type f -not -name 'xml*' -delete 2>/dev/null
    fi

    if [ "$IMAGE_NAME" = "$RMS_IMAGE" -o "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        find $TEMP_FOLDER/$RANDM_FOLDER/$BE_DIR/lib/ext/tpcl/aws -type f -not -name 'guava*' -delete 2>/dev/null
    fi

    if [[ "$ARG_APP_LOCATION" != "na" && "$IMAGE_NAME" = "$APP_IMAGE" ]] || [[ "$IMAGE_NAME" = "$BUILDER_IMAGE" ]] || [[ "$IMAGE_NAME" = "$BASE_IMAGE" ]] ; then
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

    # setting java home directory name to java in case of local installation
    JAVA_HOME_DIR_NAME=java
    
    mkdir -p $TEMP_FOLDER/$RANDM_FOLDER/$JAVA_HOME_DIR_NAME/$ARG_JRE_VERSION
    cp -r $TRA_JAVA_HOME/* $TEMP_FOLDER/$RANDM_FOLDER/$JAVA_HOME_DIR_NAME/$ARG_JRE_VERSION
    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$TRA_JAVA_HOME~/opt/tibco/$JAVA_HOME_DIR_NAME/$ARG_JRE_VERSION~g"

    find $TEMP_FOLDER/$RANDM_FOLDER -name '*.tra' -print0 | xargs -0 sed -i.bak  "s~$BE_HOME_BASE~$OPT_TIBCO~g"

    
    sed -i  "s~BE_HOME~$TEMP_FOLDER/$RANDM_FOLDER/be/$ARG_BE_SHORT_VERSION~g" $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME
    sed -i  "s~JAVA_HOME~$TEMP_FOLDER/$RANDM_FOLDER/$JAVA_HOME_DIR_NAME/$ARG_JRE_VERSION~g" $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME
    
    for filename in $(cat $TEMP_FOLDER/lib/$DEL_LIST_FILE_NAME ) ; do
        rm -rf $filename 2>/dev/null
    done
    
    # removing all .bak files
    find $TEMP_FOLDER -type f -name "*.bak" -exec rm -f {} \;

    # re create be.tar
    TAR_CMD="tar -C $TEMP_FOLDER/$RANDM_FOLDER -cf $TEMP_FOLDER/be.tar be $JAVA_HOME_DIR_NAME "

    if [ "$FTL_HOME" != "na" ]; then
        TAR_CMD="$TAR_CMD ftl"
    fi

    if [ "$AS_HOME" != "na" -o "$AS_LEG_HOME" != "na" ]; then
        TAR_CMD="$TAR_CMD as"
    fi

    if [ "$HAWK_HOME" != "na" ]; then
        TAR_CMD="$TAR_CMD hawk"
    fi

    if [ "$TEA_HOME" != "na" ]; then
        TAR_CMD="$TAR_CMD tea"
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

BUILD_ARGS=$(echo  --build-arg BE_PRODUCT_VERSION="$ARG_BE_VERSION" --build-arg BE_SHORT_VERSION="$ARG_BE_SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" )
BUILD_ARGS=$(echo $BUILD_ARGS --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg OPEN_JDK_FILENAME=$OPEN_JDK_FILENAME )
BUILD_ARGS=$(echo $BUILD_ARGS --build-arg JRESPLMNT_VERSION="$ARG_JRESPLMNT_VERSION" --build-arg JRESPLMNT_PRODUCT_HOTFIX="$ARG_JRESPLMNT_HOTFIX" )

BUILD_ARGS_CDD_EAR_CONFG=$(echo --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME --build-arg CONFIGPROVIDER=$ARG_CONFIGPROVIDER )
BUILD_ARGS_AS=$(echo --build-arg AS_VERSION="$ARG_AS_LEG_VERSION" --build-arg AS_SHORT_VERSION="$ARG_AS_LEG_SHORT_VERSION" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_LEG_HOTFIX" )
BUILD_ARGS_FTL=$(echo --build-arg FTL_VERSION="$ARG_FTL_VERSION" --build-arg FTL_SHORT_VERSION="$ARG_FTL_SHORT_VERSION" --build-arg FTL_PRODUCT_HOTFIX="$ARG_FTL_HOTFIX" )
BUILD_ARGS_HAWK=$(echo --build-arg HAWK_VERSION="$ARG_HAWK_VERSION" --build-arg HAWK_SHORT_VERSION="$ARG_HAWK_SHORT_VERSION" --build-arg HAWK_PRODUCT_HOTFIX="$ARG_HAWK_HOTFIX" )
BUILD_ARGS_ACTIVESPACES=$(echo --build-arg ACTIVESPACES_VERSION="$ARG_AS_VERSION" --build-arg ACTIVESPACES_SHORT_VERSION="$ARG_AS_SHORT_VERSION" --build-arg ACTIVESPACES_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" )

if [ "$INSTALLATION_TYPE" = "fromlocal" ]; then
    if [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        BUILD_ARGS=$(echo $BUILD_ARGS --build-arg PYTHON_VERSION="$ARG_PYTHON_VERSION" )
    else
        BUILD_ARGS=$(echo $BUILD_ARGS $BUILD_ARGS_CDD_EAR_CONFG )
    fi
else
    if [ "$IMAGE_NAME" = "$TEA_IMAGE" ]; then
        BUILD_ARGS=$(echo $BUILD_ARGS --build-arg PYTHON_VERSION="$ARG_PYTHON_VERSION"    --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX"   --build-arg TEA_VERSION="$ARG_TEA_VERSION" --build-arg TEA_PRODUCT_HOTFIX="$ARG_TEA_HOTFIX" )
    else
        BUILD_ARGS=$(echo $BUILD_ARGS  --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" $BUILD_ARGS_AS $BUILD_ARGS_FTL $BUILD_ARGS_HAWK $BUILD_ARGS_ACTIVESPACES $BUILD_ARGS_CDD_EAR_CONFG )
    fi
fi

BUILD_ARGS=$(echo $BUILD_ARGS -t "$ARG_IMAGE_VERSION" "$TEMP_FOLDER" )

if [ "$ARG_BUILD_TOOL" = "buildah" ]; then
    SKIP_CONTAINER_TESTS="true"
    buildah bud -f $TEMP_FOLDER/$ARG_DOCKER_FILE $BUILD_ARGS
else
    docker build --force-rm -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} $BUILD_ARGS
    # docker build --progress=plain --no-cache --force-rm -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} $BUILD_ARGS
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

    if [ "$IS_PERL_INSTALLED" = "false" ]; then
        deleteTempImage
    fi

    if [ "$DOCKER_BUILDKIT" = 1 ]; then
        docker builder prune -f
    fi

    export INTERMEDIATE_IMAGE=$(docker images -q -f "label=be-intermediate-image=true")

    if [ "$INTERMEDIATE_IMAGE" != "" ]; then
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
        if [ $ARG_ENABLE_TESTS = "true" ]; then
            cd ./tests
            source run_tests.sh -i $ARG_IMAGE_VERSION  -b $ARG_BE_SHORT_VERSION -al $ARG_AS_LEG_SHORT_VERSION -as $ARG_AS_SHORT_VERSION -f $ARG_FTL_SHORT_VERSION -hk $ARG_HAWK_SHORT_VERSION -ts $ARG_TEA_VERSION --image-type $IMAGE_NAME --java-dir-name $JAVA_HOME_DIR_NAME
        fi
    fi
fi
