#!/bin/bash

USAGE="\nUsage: build_rms_image.sh"
USAGE+="\n\n [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]"
USAGE+="\n\n [-a/--app-location]         :       Location where the RMS ear, cdd are located [optional]"
USAGE+="\n\n [-r/--repo]                 :       The app image Repository (example - repo:tag) [optional]"
USAGE+="\n\n [-d/--docker-file]          :       Dockerfile to be used for generating image (default - Dockerfile-rms) [optional]" 
USAGE+="\n\n [-h/--help]           	     :       Print the usage of script [optional]" 
USAGE+="\n\n NOTE : supply long options with '=' \n"

ARG_INSTALLER_LOCATION="na"
ARG_APP_LOCATION="na"
ARG_VERSION="5.6.0"
ARG_ADDONS="na"
ARG_APP_LOCATION="na"
ARG_BE_HOTFIX="na"
ARG_AS_HOTFIX="na"
ARG_IMAGE_VERSION="rms:$ARG_VERSION"
ARG_JRE_VERSION="1.8.0"
ARG_DOCKER_FILE="Dockerfile-rms"
ARG_EDITION="enterprise"
TEMP_FOLDER="tmp_$RANDOM"
AS_VERSION="na"


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

#if [ "$ARG_APP_LOCATION" = "na" -o "$ARG_APP_LOCATION" = "nax" -o -z "${ARG_APP_LOCATION// }" ]
#then
 # if [ $FIRST = 1 ]
  #then 
  #	MISSING_ARGS="$MISSING_ARGS Application Location[-a|--app-location]"
#	FIRST=0
 # else
  #  MISSING_ARGS="$MISSING_ARGS , Application Location[-a|--app-location]"
  #fi
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


#if [ ! -d "$ARG_APP_LOCATION" ]
#then
 # printf "ERROR:The directory - $ARG_APP_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
  #exit 1;
#fi


#Check App location have ear or not
if [[ "$ARG_APP_LOCATION" != "na" ]]
then
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
fi
# Different tokens used in the script --------------------------------------
BLANK=""
BE_PRODUCT="TIB_businessevents"
INSTALLER_PLATFORM="_linux26gl25_x86_64.zip"
BE_BASE_VERSION_REGEX="${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}${INSTALLER_PLATFORM}"
BE_HF_REGEX="${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}_HF"
BE_PROCESS_ADDON_REGEX="${BE_PRODUCT}-process_${ARG_VERSION}${INSTALLER_PLATFORM}"
BE_VIEWS_ADDON_REGEX="${BE_PRODUCT}-views_${ARG_VERSION}${INSTALLER_PLATFORM}"
AS_REGEX="TIB_activespaces*_linux_x86_64.zip";
AS_HF_REGEX="TIB_activespaces*_HF-*_linux_x86_64.zip";


#Check for 5.6.0 Installer  --------------------------------------
result=$(find $ARG_INSTALLER_LOCATION -name "$BE_BASE_VERSION_REGEX")
len=$(find $ARG_INSTALLER_LOCATION -name "$BE_BASE_VERSION_REGEX" | wc -l)

if [ $len -eq 0 ]; then
	printf "\nERROR :TIBCO BusinessEvents (${ARG_VERSION}) is not present in the target directory.There should be only one.\n"
	exit 1;
fi

# Get all packages(base and hf) for 5.6.0 --------------------------------------
bePckgs=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}*$INSTALLER_PLATFORM")
bePckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}*$INSTALLER_PLATFORM" | wc -l)


#Get All HF for BE --------------------------------------
beHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "$BE_HF_REGEX*$INSTALLER_PLATFORM")
beHfCnt=$(find $ARG_INSTALLER_LOCATION -name  "$BE_HF_REGEX*$INSTALLER_PLATFORM" | wc -l)

# Check Single Base version for 5.6.0 exist, zero or one HF exist. --------------------------------------

beBasePckgsCnt=$(expr ${bePckgsCnt} - ${beHfCnt})

if [ $beBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
	printf "\nERROR :More than one TIBCO BusinessEvents base versions are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beHfCnt -gt 1 ]; then # If more than one hf versions are present
	printf "\nERROR :More than one TIBCO BusinessEvents HF are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beBasePckgsCnt -le 0 ]; then # If HF is present but base version is not present
	printf "\nERROR :TIBCO BusinessEvents HF is present but TIBCO BusinessEvents Base version is not present in the target directory.\n"
	exit 1;	
elif [ $beBasePckgsCnt -eq 1 ]; then
	if [ $beHfCnt -eq 1 ]; then # If Only one HF is present then parse the HF version
		beversion=$(echo "${beHfPckgs[0]}" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g")
	    ARG_BE_HOTFIX=$(echo $beversion| cut -d'_' -f 5)
	elif [ $beHfCnt -eq 0 ]; then
		ARG_BE_HOTFIX="na"
	fi	
else 
	ARG_BE_HOTFIX="na"	
fi

addons="na"

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

if [ "$MISSING_ARGS" != "-" ]
then
  printf "\nERROR:Missing mandatory argument(s) : $MISSING_ARGS\n"
  printf "$USAGE"
  exit 1;
fi

if [ "$ARG_BE_HOTFIX" = "nax" -o -z "${ARG_BE_HOTFIX// }" ]
then
  printf "\nERROR:The value for [--hf] is blank.\n"
  printf "$USAGE"
  exit 1;
fi

if [ "$ARG_AS_HOTFIX" = "nax" -o -z "${ARG_AS_HOTFIX// }" ]
then
  printf "\nERROR:The value for [--as-hf] is blank.\n"
  printf "$USAGE"
  exit 1;
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
echo "INFO:AS-HF : $ARG_AS_HOTFIX"
echo "INFO:IMAGE VERSION : $ARG_IMAGE_VERSION"

echo "----------------------------------------------"




#if [ ! -d "$ARG_APP_LOCATION" ]
#then
 # printf "ERROR:The directory - $ARG_APP_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
  #exit 1;
#fi




mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/{installers,app}
cp -a "../lib" $TEMP_FOLDER/
if [[ "$ARG_APP_LOCATION" != "na" ]]
then
	cp $ARG_APP_LOCATION/* $TEMP_FOLDER/app
fi

export PERL5LIB="../lib"
VALIDATION_RESULT=$(perl -Mbe_docker_install -e "be_docker_install::validate('$ARG_INSTALLER_LOCATION','$ARG_VERSION','$ARG_EDITION','$ARG_ADDONS','$ARG_BE_HOTFIX','$ARG_AS_HOTFIX','$TEMP_FOLDER');")

if [ "$?" = 0 ]
then
  printf "$VALIDATION_RESULT\n"
  exit 1;
fi


echo "INFO:Copying Packages.."

CURRENT_DIR=$( cd $(dirname $0) ; pwd -P )

#cd $ARG_INSTALLER_LOCATION
#find . -name '*.zip' | cpio -pdm $CURRENT_DIR
#cd $CURRENT_DIR


while read -r line
do
    name="$line"
    cp $name $TEMP_FOLDER/installers
done < "$TEMP_FOLDER/package_files.txt"



#AS_PKG=$(perl -nle 'print $& if m{.*activespaces.*([\d].[\d].[\d])_linux}' $ARG_INSTALLER_LOCATION/package_files.txt)

AS_VERSION=$(perl -nle 'print $1 if m{.*activespaces.*([\d].[\d].[\d])_linux}' $TEMP_FOLDER/package_files.txt)
if [ "$AS_VERSION" = "" ]; then
	echo "ERROR:TIBCO Activespaces required for RMS"
 	echo "Deleting temporary intermediate image.."
 	docker rmi $(docker images -q -f "label=be-intermediate-image=true")
 	echo "Deleteting $TEMP_FOLDER folder"
	rm -rf $TEMP_FOLDER
	exit 1
fi

if [[ $strname =~ 3(.+)r ]]; then
    strresult=${BASH_REMATCH[1]}
fi

echo "INFO:Building docker image for TIBCO BusinessEvents Version:$ARG_VERSION and Image Version:$ARG_IMAGE_VERSION and Docker file:$ARG_DOCKER_FILE"

VERSION_REGEX=([0-9]\.[0-9]).*
if [[ $ARG_VERSION =~ $VERSION_REGEX ]]
then
	SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR:Improper version.Aborting."
	echo "Deleting temporary intermediate image.."
 	docker rmi $(docker images -q -f "label=be-intermediate-image=true")
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
 		docker rmi $(docker images -q -f "label=be-intermediate-image=true")
 		echo "Deleteting $TEMP_FOLDER folder"
		rm -rf $TEMP_FOLDER
		exit 1
	fi
fi

cp $ARG_DOCKER_FILE $TEMP_FOLDER
ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"
docker build --force-rm -f $TEMP_FOLDER/$ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_INSTALLER_LOCATION" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER --build-arg CDD_FILE_NAME=$CDD_FILE_NAME --build-arg EAR_FILE_NAME=$EAR_FILE_NAME -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  echo "DONE: Docker build successful."
fi

 echo "Deleting temporary intermediate image.."
 docker rmi $(docker images -q -f "label=be-intermediate-image=true")
 echo "Deleteting $TEMP_FOLDER folder"
 
rm -rf $TEMP_FOLDER
