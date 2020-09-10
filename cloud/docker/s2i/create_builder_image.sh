#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#


#Map used to store the BE and it's comapatible JRE version
declare -a BE_VERSION_AND_JRE_MAP
BE_VERSION_AND_JRE_MAP=("5.6.0" "1.8.0" "5.6.1" "11" "6.0.0" "11")


if [ -z "${USAGE}" ]; then
 USAGE="\nUsage: create_builder_image.sh"
fi
USAGE+="\n\n [-l|--installers-location]  :       Location where TIBCO BusinessEvents and other required installers are located [required]"
USAGE+="\n\n [-d|--docker-file]          :       Dockerfile to be used for generating image.(default Dockerfile) [optional]"
USAGE+="\n\n [--disable-tests]           :       Disables docker unit tests on created image. [optional]"
USAGE+="\n\n [--gv-providers]            :       Names of GV providers to be included in the image. Supported value(s) - consul [optional]" 
if [[ "$*" == *nos2i* ]]; then
USAGE+="\n\n [-a|--app-location]         :       Location where the application ear, cdd and other files are located [required]"
USAGE+="\n\n [-r|--repo]                 :       The app image Repository (example - fdc:latest) [required]"
else
USAGE+="\n\n [-r|--repo]                 :       The builder image Repository (example - s2ibuilder:latest) [required]"
fi
USAGE+="\n\n [-h|--help]           	     :       Print the usage of script [optional]"
USAGE+="\n\n NOTE : supply long options with '=' \n"

BE_TAG="com.tibco.be"
S2I_DOCKER_FILE_BASE="bin/Dockerfile"
S2I_DOCKER_FILE_APP="Dockerfile"
ARG_DOCKERFILE_NAME="Dockerfile"
ARG_EDITION="enterprise"
ARG_VERSION="na"
ARG_ADDONS="na"
ARG_INSTALLER_LOCATION="na"
ARG_BE_HOTFIX="na"
ARG_AS_HOTFIX="na"
ARG_JRE_VERSION="na"
IS_S2I="true"
ARG_APP_LOCATION="na"
ARG_IMAGE_VERSION="na"
ARG_DOCKER_FILE="Dockerfile"
TEMP_FOLDER="tmp_$RANDOM"
AS_VERSION="na"
AS_SHORT_VERSION="na"
FTL_VERSION="na"
FTL_SHORT_VERSION="na"
ARG_FTL_HOTFIX="na"
ACTIVESPACES_VERSION="na"
ACTIVESPACES_SHORT_VERSION="na"
ARG_ACTIVESPACES_HOTFIX="na"
ARG_GVPROVIDERS="na"
ARG_ACTIVESPACES_VERSION="na"
ARG_FTL_VERSION="na"
ARG_ENABLE_TESTS="true"

#Parse the arguments

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
        --nos2i)
        shift # past the key and to the value
        IS_S2I="false"
		;;
        --disable-tests)
        ARG_ENABLE_TESTS="false"
        ;;
        -a|--app-location)
        shift # past the key and to the value
        ARG_APP_LOCATION="$1"
        ;;
        -a=*|--app-location=*)
        ARG_APP_LOCATION="${key#*=}"
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

MISSING_ARGS="-"
FIRST=1


if [ "$ARG_INSTALLER_LOCATION" = "na" -o "$ARG_INSTALLER_LOCATION" = "nax" -o -z "${ARG_INSTALLER_LOCATION// }" ]
then
  if [ $FIRST = 1 ]
  then
  	MISSING_ARGS="$MISSING_ARGS Installers Location[-l|--installers-location]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Installers Location[-l|--installers-location]"
  fi
fi


if  [ "$IS_S2I" != "true" ] ; then
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
fi

#if  [ "$IS_S2I" != "true" ] ; then
if [ "$ARG_IMAGE_VERSION" = "na" -o "$ARG_IMAGE_VERSION" = "nax" -o -z "${ARG_IMAGE_VERSION// }" ]
then
  if [ $FIRST = 1 ]
  then
    MISSING_ARGS="$MISSING_ARGS Image version[-r|--repo]"image-version
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Image version[-r|--repo]"
  fi
fi
#fi


if [ "$MISSING_ARGS" != "-" ]
then
  printf "\nERROR:Missing mandatory argument(s) : $MISSING_ARGS\n"
  printf "$USAGE"
  exit 1;
fi


if [ ! -d "$ARG_INSTALLER_LOCATION" ]
then
  printf "ERROR:The directory - $ARG_INSTALLER_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
  exit 1;
fi


if [ "$IS_S2I" != "true" ]; then
 if [ ! -d "$ARG_APP_LOCATION" ]
 then
  printf "ERROR:The directory - $ARG_APP_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
  exit 1;
 fi
fi

# check be
source ../common/check_be.sh

# check be addons
source ../common/check_beaddons.sh

# check as legacy
source ../common/check_asleg.sh

# check for FTL and AS4 only when BE version is > 6.0.0
checkForFTLnAS4="false"
if [ "$ARG_VERSION" != "na" ]; then
	if [ $(echo "${ARG_VERSION//.}") -ge 600 ]; then
		checkForFTLnAS4="true"
	fi
fi

if [ $checkForFTLnAS4 == "true" ]; then
	# validate ftl
	source ../common/check_ftl.sh

	# validate as
	source ../common/check_as.sh
fi

echo "INFO:Supplied Arguments :"
echo "----------------------------------------------"
echo "INFO:VERSION : $ARG_VERSION"
echo "INFO:EDITION : $ARG_EDITION"
echo "INFO:INSTALLER DIRECTORY : $ARG_INSTALLER_LOCATION"
echo "INFO:APPLICATION DATA DIRECTORY : $ARG_APP_LOCATION"
echo "INFO:ADDONS : $ARG_ADDONS"
echo "INFO:DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO:BE-HF : $ARG_BE_HOTFIX"
echo "INFO:AS Legacy-HF : $ARG_AS_HOTFIX"
if [[ $ARG_FTL_VERSION != "na" ]]; then
	echo "INFO:FTL VERSION : $ARG_FTL_VERSION"
	if [[ $ARG_FTL_HOTFIX != "na" ]]; then
		echo "INFO:FTL-HF : $ARG_FTL_HOTFIX"	
	fi
fi
if [[ $ARG_ACTIVESPACES_VERSION != "na" ]]; then
	echo "INFO:ACTIVESPACES VERSION : $ARG_ACTIVESPACES_VERSION"
	if [[ $ARG_ACTIVESPACES_HOTFIX != "na" ]]; then
		echo "INFO:ACTIVESPACES - HF : $ARG_ACTIVESPACES_HOTFIX"
	fi
fi
echo "INFO:IMAGE VERSION : $ARG_IMAGE_VERSION"
echo "----------------------------------------------"

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
