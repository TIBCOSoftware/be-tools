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

# Different tokens used in the script --------------------------------------
BLANK=""
BE_PRODUCT="TIB_businessevents"
INSTALLER_PLATFORM="_linux26gl25_x86_64.zip"

BE_BASE_VERSION_REGEX="${BE_PRODUCT}-${ARG_EDITION}_*${INSTALLER_PLATFORM}"
BE_HF_REGEX="${BE_PRODUCT}-hf_*_HF"


#AS_REGEX="TIB_activespaces_*_linux_x86_64.zip";
#AS_HF_REGEX="TIB_activespaces*_HF-*_linux_x86_64.zip";


#Check for BE Installer  --------------------------------------
result=$(find $ARG_INSTALLER_LOCATION -name "$BE_BASE_VERSION_REGEX")
len=$(echo ${#result})

if [ $len -eq 0 ]; then
	printf "\nERROR: TIBCO BusinessEvents Installer is not present in the target directory.\n"
	exit 1;
fi

# Get all packages(base and hf)  --------------------------------------
bePckgs=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_*$INSTALLER_PLATFORM")
bePckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_*$INSTALLER_PLATFORM" | wc -l)


#Get All HF for BE --------------------------------------
beHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "$BE_HF_REGEX*$INSTALLER_PLATFORM")
beHfCnt=$(find $ARG_INSTALLER_LOCATION -name  "$BE_HF_REGEX*$INSTALLER_PLATFORM" | wc -l)

# Check Single Base version  exist, zero or one HF exist. --------------------------------------
beBasePckgsCnt=$(expr ${bePckgsCnt} - ${beHfCnt})

if [ $bePckgsCnt -gt 1 ]; then # If more than one base versions are present
	printf "\nERROR: More than one TIBCO BusinessEvents base versions are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beHfCnt -gt 1 ]; then # If more than one hf versions are present
	printf "\nERROR: More than one TIBCO BusinessEvents HF are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beBasePckgsCnt -lt 0 ]; then # If HF is present but base version is not present
	printf "\nERROR: TIBCO BusinessEvents HF is present but TIBCO BusinessEvents Base version is not present in the target directory.\n"
	exit 1;
elif [ $bePckgsCnt -eq 1 ]; then
	#Find BE Version from installer
	BASE_PACKAGE="${bePckgs[0]}"
	ARG_VERSION=$(echo "${BASE_PACKAGE##*/}" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g" |  sed -e "s/${BE_PRODUCT}-${ARG_EDITION}"_"/${BLANK}/g") 
	#Find JER Version for given BE Version
	length=${#BE_VERSION_AND_JRE_MAP[@]}
	for (( i = 0; i < length; i++ )); do
		if [ "$ARG_VERSION" = "${BE_VERSION_AND_JRE_MAP[i]}" ];then
			ARG_JRE_VERSION=${BE_VERSION_AND_JRE_MAP[i+1]};
			break;	
		fi
	done
	if [ $beHfCnt -eq 1 ]; then # If Only one HF is present then parse the HF version
		VERSION_PACKAGE="${beHfPckgs[0]}"
		hfbepackage=$(echo "${VERSION_PACKAGE##*/}" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g")
		hfbeversion=$(echo "$hfbepackage"| cut -d'_' -f 3)
    	if [ $ARG_VERSION == $hfbeversion ];then
      		ARG_BE_HOTFIX=$(echo "${hfbepackage}"| cut -d'_' -f 4 | sed -e "s/HF-/${BLANK}/g")
		else
			printf "\nERROR: TIBCO BusinessEvents version in HF installer and TIBCO BusinessEvents Base version is not matching.\n"
			exit 1;
		fi 
		
	elif [ $beHfCnt -eq 0 ]; then
		ARG_BE_HOTFIX="na"
	fi
else
	ARG_BE_HOTFIX="na"
fi

addons="na"
BE_PROCESS_ADDON_REGEX="${BE_PRODUCT}-process_${ARG_VERSION}${INSTALLER_PLATFORM}"
BE_VIEWS_ADDON_REGEX="${BE_PRODUCT}-views_${ARG_VERSION}${INSTALLER_PLATFORM}"

#Add process addon if present --------------------------------------
processAddon=$(find $ARG_INSTALLER_LOCATION -name "$BE_PROCESS_ADDON_REGEX")
processAddonCnt=$(find $ARG_INSTALLER_LOCATION -name "$BE_PROCESS_ADDON_REGEX" | wc -l)

if [ $processAddonCnt -eq 1 ]; then
	addons="process,"
elif [ $processAddonCnt -gt 1 ]; then
	printf "\nERROR :More than one TIBCO BusinessEvents process addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi


#Add view addon if present  --------------------------------------
viewsAddon=$(find $ARG_INSTALLER_LOCATION -name "$BE_VIEWS_ADDON_REGEX")
viewsAddonCnt=$(find $ARG_INSTALLER_LOCATION -name "$BE_VIEWS_ADDON_REGEX" | wc -l)

if [ $viewsAddonCnt -eq 1 ]; then
	view="views"
	addons="$addons$view"
elif [ $viewsAddonCnt -gt 1 ]; then
	printf "\nERROR :More than one TIBCO BusinessEvents views addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi

if [ addons = "na" ]; then
	ARG_ADDONS="na"
else
	ARG_ADDONS=$addons
fi

# Validate and get TIBCO Activespaces base and hf versions

asPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_linux_x86_64.zip")
asPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_linux_x86_64.zip" |  wc -l)
asHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_HF-*_linux_x86_64.zip")
asHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_HF-*_linux_x86_64.zip" |  wc -l)

if [ $asPckgsCnt -gt 0 ]; then
	asBasePckgsCnt=$(expr ${asPckgsCnt} - ${asHfPckgsCnt})
	
	if [ $asBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR :More than one TIBCO Activespaces base versions are present in the target directory..\n"
		exit 1;
	elif [ $asHfPckgsCnt -gt 1 ]; then
		printf "\nERROR :More than one TIBCO Activespaces HF are present in the target directory.There should be only one.\n"
		exit 1;
	elif [ $asBasePckgsCnt -le 0 ]; then
		printf "\nERROR :TIBCO Activespaces HF is present but TIBCO Activespaces Base version is not present in the target directory.\n"
		exit 1;
	elif [ $asBasePckgsCnt -eq 1 ]; then
		if [ $asHfPckgsCnt -eq 1 ]; then
			asHf=$(echo "${asHfPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
			ARG_AS_HOTFIX=$(echo $asHf| cut -d'-' -f 2)
		elif [ $asHfPckgsCnt -eq 0 ]; then
			ARG_AS_HOTFIX="na"
		fi
	else
		ARG_AS_HOTFIX="na"
	fi
fi

# check for FTL and AS4 only when BE version is > 6.0.0
checkForFTLnAS4="false"
if [ "$ARG_VERSION" != "na" ]; then
	if [ $(echo "${ARG_VERSION//.}") -ge 600 ]; then
		checkForFTLnAS4="true"
	fi
fi

if [ $checkForFTLnAS4 == "true" ]; then
	# Validate and get FTL version
	ftlPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip")
	ftlPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip" |  wc -l)
	ftlHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip")
	ftlHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip" |  wc -l)
	if [ $ftlPckgsCnt -gt 0 ]; then
		ftlBasePckgsCnt=$(expr ${ftlPckgsCnt} - ${ftlHfPckgsCnt})
		
		if [ $ftlBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
			printf "\nERROR :More than one TIBCO FTL base versions are present in the target directory..\n"
			exit 1;
		elif [ $ftlHfPckgsCnt -gt 1 ]; then
			printf "\nERROR :More than one TIBCO FTL HF are present in the target directory.There should be only one.\n"
			exit 1;
		elif [ $ftlBasePckgsCnt -le 0 ]; then
			printf "\nERROR :TIBCO FTL HF is present but TIBCO FTL Base version is not present in the target directory.\n"
			exit 1;
		elif [ $ftlBasePckgsCnt -eq 1 ]; then
			FTL_BASE_PACKAGE="${ftlPckgs[0]}"
			ARG_FTL_VERSION=$(echo "${FTL_BASE_PACKAGE##*/}" | sed -e "s/_linux_x86_64.zip/${BLANK}/g" |  sed -e "s/TIB_ftl_/${BLANK}/g") 
			if [ "$ARG_FTL_VERSION" = "" ]; then
				ARG_FTL_VERSION="na"
			fi
			if [ $ftlHfPckgsCnt -eq 1 ]; then
				ftlHf=$(echo "${ftlPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
				ARG_FTL_HOTFIX=$(echo $ftlHf| cut -d'-' -f 2| cut -d' ' -f 1)
				if [[ "$ARG_FTL_VERSION" != "na" ]]; then
					ARG_FTL_VERSION=$(echo $ARG_FTL_VERSION | cut -d'_' -f 1)
				fi
			fi
		fi
	fi


	# Validate and get ACTIVESPACES version
	activespacesPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip")
	activespacesPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip" |  wc -l)
	activespacesHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip")
	activespacesHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip" |  wc -l)
	if [ $activespacesPckgsCnt -gt 0 ]; then
		activespacesBasePckgsCnt=$(expr ${activespacesPckgsCnt} - ${activespacesHfPckgsCnt})
		
		if [ $activespacesBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
			printf "\nERROR :More than one TIBCO AS base versions are present in the target directory..\n"
			exit 1;
		elif [ $activespacesHfPckgsCnt -gt 1 ]; then
			printf "\nERROR :More than one TIBCO AS HF are present in the target directory.There should be only one.\n"
			exit 1;
		elif [ $activespacesBasePckgsCnt -le 0 ]; then
			printf "\nERROR :TIBCO AS HF is present but TIBCO AS Base version is not present in the target directory.\n"
			exit 1;
		elif [ $activespacesBasePckgsCnt -eq 1 ]; then
			ACTIVESPACES_BASE_PACKAGE="${activespacesPckgs[0]}"
			ARG_ACTIVESPACES_VERSION=$(echo "${ACTIVESPACES_BASE_PACKAGE##*/}" | sed -e "s/_linux_x86_64.zip/${BLANK}/g" |  sed -e "s/TIB_as_/${BLANK}/g") 
			if [ "$ARG_ACTIVESPACES_VERSION" = "" ]; then
				ARG_ACTIVESPACES_VERSION="na"
			fi
			if [ $activespacesHfPckgsCnt -eq 1 ]; then
				activespacesHf=$(echo "${activespacesPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
				ARG_ACTIVESPACES_HOTFIX=$(echo $activespacesHf| cut -d'-' -f 2| cut -d' ' -f 1)
				if [[ "$ARG_ACTIVESPACES_VERSION" != "na" ]]; then
					ARG_ACTIVESPACES_VERSION=$(echo $ARG_ACTIVESPACES_VERSION | cut -d'_' -f 1)
				fi
			fi
		fi
	fi
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

	if [ $BUILD_SUCCESS == 'true' ]; then
		cd ../tests
		EAR_FILE_NAME="dummy.txt"
		CDD_FILE_NAME="dummy.txt"
		source run_tests.sh -i $ARG_IMAGE_VERSION  -b $SHORT_VERSION -c $CDD_FILE_NAME -e $EAR_FILE_NAME -al $AS_SHORT_VERSION -as $ACTIVESPACES_SHORT_VERSION -f $FTL_SHORT_VERSION
	fi

fi
