#!/bin/bash

USAGE="\nUsage: create_builder_image.sh"
USAGE+="\n\n [-l|--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]"
USAGE+="\n\n [-v|--version]              :       TIBCO BusinessEvents product version (3 part number) [required]"
USAGE+="\n\n [-i|--image-version]        :       Version|tag to be given to the image ('v01' for example) [required]"
USAGE+="\n\n [-a|--addons]               :       Comma separated values for required addons : process|views [optional]"
USAGE+="\n\n [--hf]                      :       Additional TIBCO BusinessEvents hotfix version ('1' for example) [optional]\n"
USAGE+="\n\n [--as-hf]                   :       Additional TIBCO ActiveSpaces hotfix version ('1' for example) [optional]\n"
USAGE+="\n\n [-d|--docker-file]          :       Dockerfile to be used for generating image.(default Dockerfile) [optional]\n"
USAGE+="\n\n NOTE : supply long options with '=' \n"

BE_TAG="com.tibco.be"
ARG_DOCKER_FILE="bin/Dockerfile"
S2I_DOCKER_FILE="s2i/Dockerfile"
ARG_DOCKERFILE_NAME="Dockerfile"
ARG_EDITION="enterprise"
ARG_VERSION="na"
ARG_ADDONS="na"
ARG_TARGET_DIR="na"
ARG_BE_HOTFIX="na"
ARG_AS_HOTFIX="na"
ARG_JRE_VERSION="1.8.0"

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
		-v|--version)
        shift # past the key and to the value
        ARG_VERSION="$1"
        ;;
        -v=*|--version=*)
        ARG_VERSION="${key#*=}"
        ;;
		-i|--image-version)
        shift # past the key and to the value
        BE_PRODUCT_IMAGE_VERSION="$1"
        ;;
        -i=*|--image-version=*)
        BE_PRODUCT_IMAGE_VERSION="${key#*=}"
        ;;
		-a|--addons)
        shift # past the key and to the value
        ARG_ADDONS="$1"
        ;;
        -a=*|--addons*)
        ARG_ADDONS="${key#*=}"
        ;;
		-l|--installers-location)
        shift # past the key and to the value
        ARG_TARGET_DIR="$1"
        ;;
        -l=*|--installers-location=*)
        ARG_TARGET_DIR="${key#*=}"
        ;;
		--hf)
        shift # past the key and to the value
        ARG_BE_HOTFIX="$1"
        ;;
        --hf=*)
        ARG_BE_HOTFIX="${key#*=}"
        ;;
		--as-hf)
        shift # past the key and to the value
        ARG_AS_HOTFIX="$1"
        ;;
        --as-hf=*)
        ARG_AS_HOTFIX="${key#*=}"
        ;;
        *)
        echo "Invalid Option '$key'"
        ;;
    esac
    # Shift after checking all the cases to get the next option
    shift
done

echo "INFO:Supplied Arguments :"
echo "----------------------------------------------"
echo "INFO:VERSION : $ARG_VERSION"
echo "INFO:EDITION : $ARG_EDITION"
echo "INFO:TARGET DIRECTORY : $ARG_TARGET_DIR"
echo "INFO:ADDONS : $ARG_ADDONS"
echo "INFO:DOCKERFILE : $ARG_DOCKER_FILE"
echo "INFO:HF : $ARG_BE_HOTFIX"
echo "INFO:AS-HF : $ARG_AS_HOTFIX"
echo "INFO:IMAGE VERSION : $BE_PRODUCT_IMAGE_VERSION"
echo "----------------------------------------------"

MISSING_ARGS="-"
FIRST=1

if [ "$ARG_TARGET_DIR" = "na" -o "$ARG_TARGET_DIR" = "nax" -o -z "${ARG_TARGET_DIR// }" ]
then
  if [ $FIRST = 1 ]
  then
  	MISSING_ARGS="$MISSING_ARGS Installers Location[-l|--installers-location]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Installers Location[-l|--installers-location]"
  fi
fi

if [ "$ARG_VERSION" = "na" -o "$ARG_VERSION" = "nax" -o -z "${ARG_VERSION// }" ]
then
  if [ $FIRST = 1 ]
  then
    MISSING_ARGS="$MISSING_ARGS Version[-v|--version]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Version[-v|--version]"
  fi
fi

if [ "$BE_PRODUCT_IMAGE_VERSION" = "na" -o "$BE_PRODUCT_IMAGE_VERSION" = "nax" -o -z "${BE_PRODUCT_IMAGE_VERSION// }" ]
then
  if [ $FIRST = 1 ]
  then
    MISSING_ARGS="$MISSING_ARGS Image version[-i|--image-version]"
	FIRST=0
  else
    MISSING_ARGS="$MISSING_ARGS , Image version[-i|--image-version]"
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

if [ ! -d "$ARG_TARGET_DIR" ]
then
  printf "ERROR:The directory - $ARG_TARGET_DIR is not a valid directory.Enter a valid directory and try again.\n"
  exit 1;
fi

#FILE_NAME=$( cd $(dirname $0) ; cd .. ; cd lib ; pwd -P )
#echo "INFO:FILE_NAME : $FILE_NAME"

cp -R $ARG_TARGET_DIR/be_docker_install.pm be_docker_install.pm

VALIDATION_RESULT=$(perl -Mbe_docker_install -e "be_docker_install::validate('$ARG_TARGET_DIR','$ARG_VERSION','$ARG_EDITION','$ARG_ADDONS','$ARG_BE_HOTFIX','$ARG_AS_HOTFIX', '$ARG_TARGET_DIR');")

if [ "$?" = 0 ]
then
  printf "$VALIDATION_RESULT\n"
  exit 1;
fi

rm be_docker_install.pm

echo "INFO:Copying Packages.."

cd ..
mkdir -p installers
CURRENT_DIR=$( cd $(dirname $0) ; pwd -P )

echo "INFO:CURRENT_DIR : $CURRENT_DIR"

while read -r line
do
    name="$line"
  #  cp $name .
    cp $name installers
done < "$ARG_TARGET_DIR/package_files.txt"

AS_PKG=$(perl -nle 'print $& if m{.*activespaces.*([\d].[\d].[\d])_linux}' $ARG_TARGET_DIR/package_files.txt)

AS_VERSION=$(perl -nle 'print $1 if m{.*activespaces.*([\d].[\d].[\d])_linux}' $ARG_TARGET_DIR/package_files.txt)

if [[ $strname =~ 3(.+)r ]]; then
    strresult=${BASH_REMATCH[1]}
fi

echo "INFO:Building docker image for TIBCO BusinessEvents Version:$ARG_VERSION and Image Version:$BE_PRODUCT_IMAGE_VERSION and Docker file:$ARG_DOCKER_FILE"

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

mkdir -p app
cd app
touch dummy.txt
cd ..

docker build -f $ARG_DOCKER_FILE --build-arg BE_PRODUCT_VERSION="$ARG_VERSION" --build-arg BE_SHORT_VERSION="$SHORT_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$BE_PRODUCT_IMAGE_VERSION" --build-arg BE_PRODUCT_EDITION="$ARG_EDITION" --build-arg BE_PRODUCT_TARGET_DIR="$ARG_TARGET_DIR" --build-arg BE_PRODUCT_ADDONS="$ARG_ADDONS" --build-arg BE_PRODUCT_HOTFIX="$ARG_BE_HOTFIX" --build-arg AS_PRODUCT_HOTFIX="$ARG_AS_HOTFIX" --build-arg AS_VERSION="$AS_VERSION" --build-arg AS_SHORT_VERSION="$AS_SHORT_VERSION" --build-arg DOCKERFILE_NAME=$ARG_DOCKERFILE_NAME --build-arg JRE_VERSION=$ARG_JRE_VERSION --build-arg CDD_FILE_NAME=dummy.txt --build-arg EAR_FILE_NAME=dummy.txt -t "$BE_TAG":"$ARG_VERSION"-"$BE_PRODUCT_IMAGE_VERSION" .

if [ "$?" != 0 ]; then
  echo "Docker build failed."
else
  find . -name \*.zip -delete
  rm "$ARG_TARGET_DIR/package_files.txt"
  echo "DONE: Docker build successful."
fi

echo "Deleting temporary intermediate image.."
docker rmi $(docker images -q -f "label=be-intermediate-image=true")


docker build -f $S2I_DOCKER_FILE --build-arg BE_TAG="$BE_TAG" --build-arg ARG_VERSION="$ARG_VERSION" --build-arg BE_PRODUCT_IMAGE_VERSION="$BE_PRODUCT_IMAGE_VERSION" -t s2ibuilder:01 .

docker rmi -f "$BE_TAG":"$ARG_VERSION"-"$BE_PRODUCT_IMAGE_VERSION"

rm -rf installers app
