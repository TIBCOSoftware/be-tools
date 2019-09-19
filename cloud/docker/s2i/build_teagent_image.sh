#!/bin/bash

USAGE="\nUsage: build_teagent_image.sh"
USAGE+="\n\n [-l/--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]\n"
USAGE+="\n\n [-r/--repo]                 :       The teagent image Repository (example - repo:tag) [optional]"
USAGE+="\n\n [-d/--dockerfile]           :       Dockerfile to be used for generating image (default - Dockerfile.teagent for linux container.) [optional]\n" 
USAGE+="\n\n NOTE : supply long options with '=' \n"

ARG_INSTALLER_LOCATION="na"
ARG_VERSION="5.6.0"
ARG_ADDONS="na"
ARG_BE_HOTFIX="na"
ARG_IMAGE_VERSION="teagent"
ARG_JRE_VERSION="1.8.0"
ARG_DOCKER_FILE="Dockerfile-teagent"
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


if [ ! -d "$ARG_INSTALLER_LOCATION" ]
then
  printf "ERROR:The directory - $ARG_INSTALLER_LOCATION is not a valid directory.Enter a valid directory and try again.\n"
  exit 1;
fi


# Different tokens used in the script --------------------------------------
BLANK=""
BE_PRODUCT="TIB_businessevents"
INSTALLER_PLATFORM="_linux26gl25_x86_64.zip"
BE_BASE_VERSION_REGEX="${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}${INSTALLER_PLATFORM}"
BE_HF_REGEX="${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}_HF"


#Check for 5.6.0 Installer  --------------------------------------
result=$(find $ARG_INSTALLER_LOCATION -name "$BE_BASE_VERSION_REGEX")
len=0
for name in "${result[@]}"
do
	name=$(echo "${name}" | sed -e 's/^[ \t]*//')
	if [[ ! -z "$name" ]] ; then
		 let len++
	fi   
done

if [ $len -eq 0 ]; then
	printf "\nERROR :TIBCO BusinessEvents (${ARG_VERSION}) is not present in the target directory.There should be only one.\n"
	exit 1;
fi

# Get all packages(base and hf) for 5.6.0 --------------------------------------
bePckgs=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_${ARG_VERSION}*$INSTALLER_PLATFORM")
bePckgsCnt=0
for name in "${bePckgs[@]}"
	do
		name=$(echo "${name}" | sed -e 's/^[ \t]*//')
		if [[ ! -z "$name" ]] ; then
			 let bePckgsCnt++
		fi    
done


#Get All HF for --------------------------------------
beHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "$BE_HF_REGEX*$INSTALLER_PLATFORM")
beHfCnt=0
for name in "${beHfPckgs[@]}"
	do
		name=$(echo "${name}" | sed -e 's/^[ \t]*//')
		if [[ ! -z "$name" ]] ; then
			 let beHfCnt++
		fi    
done

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

echo "INFO:Supplied Arguments :"
echo "----------------------------------------------"
echo "INFO:VERSION : $ARG_VERSION"
echo "INFO:EDITION : $ARG_EDITION"
echo "INFO:INSTALLER DIRECTORY : $ARG_INSTALLER_LOCATION"
echo "INFO:DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO:HF : $ARG_BE_HOTFIX"
echo "INFO:IMAGE VERSION : $BE_PRODUCT_IMAGE_VERSION"

echo "----------------------------------------------"


mkdir $TEMP_FOLDER
mkdir -p $TEMP_FOLDER/{installers,app}
cp -a "../lib/" $TEMP_FOLDER/

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
docker build --force-rm -f $ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$ARG_IMAGE_VERSION"  --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX"  --build-arg DOCKERFILE_NAME=$ARG_DOCKER_FILE  --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg TEMP_FOLDER=$TEMP_FOLDER -t "$ARG_IMAGE_VERSION" $TEMP_FOLDER



if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  echo "DONE: Docker build successful."
fi

 echo "Deleting temporary intermediate image.."
 docker rmi $(docker images -q -f "label=be-intermediate-image=true")
 echo "Deleteting $TEMP_FOLDER folder"
rm -rf $TEMP_FOLDER
