
#!/bin/bash

if [ ! -d "$ARG_APP_LOCATION" ]; then
    printf "ERROR: The directory: [$ARG_APP_LOCATION] is not a valid directory. Enter a valid directory and try again.\n"
    exit 1;
fi

# count cdd and ear in app location if exist
if [ "$ARG_APP_LOCATION" != "na" ]; then
    check_cdd_and_ear
else
    echo "ERROR: Please provide the application(cdd/ear) location."
    exit 1
fi

if [ "$ARG_TAG" = "na" ]; then
    ARG_IMAGE_NAME="appfrom$ARG_SOURCE"
else
    ARG_IMAGE_NAME=$ARG_TAG
fi

if [ "$ARG_DOCKER_FILE" = "na" ]; then
    ARG_DOCKER_FILE="./dockerfiles/Dockerfile.BaseImage"
fi

# information display
echo "INFO: Supplied/Derived Data:"
echo "------------------------------------------------------------------------------"

echo "INFO: Building container image with the build tool[$ARG_BUILD_TOOL]."

echo "INFO: SOURCE IMAGE                 : [$ARG_SOURCE]"
echo "INFO: APPLICATION DATA DIRECTORY   : [$ARG_APP_LOCATION]"
echo "INFO: CDD FILE NAME                : [$CDD_FILE_NAME]"
echo "INFO: EAR FILE NAME                : [$EAR_FILE_NAME]"
echo "INFO: DOCKERFILE                   : [$ARG_DOCKER_FILE]"
echo "INFO: IMAGE TAG                    : [$ARG_IMAGE_NAME]"

echo "------------------------------------------------------------------------------"

mkdir -p $TEMP_FOLDER/app
cp -r $ARG_APP_LOCATION/* $TEMP_FOLDER/app
cp $ARG_DOCKER_FILE $TEMP_FOLDER
ARG_DOCKER_FILE="$(basename -- $ARG_DOCKER_FILE)"


BUILD_ARGS=" --build-arg BASE_IMAGE=$ARG_SOURCE "
BUILD_ARGS="$BUILD_ARGS --build-arg CDD_FILE_NAME=$CDD_FILE_NAME "
BUILD_ARGS="$BUILD_ARGS --build-arg EAR_FILE_NAME=$EAR_FILE_NAME "

BUILD_ARGS="$BUILD_ARGS -t $ARG_IMAGE_NAME $TEMP_FOLDER"

if [ "$ARG_BUILD_TOOL" = "buildah" ]; then
    buildah bud -f $TEMP_FOLDER/$ARG_DOCKER_FILE $BUILD_ARGS
else
    docker build --force-rm -f $TEMP_FOLDER/${ARG_DOCKER_FILE##*/} $BUILD_ARGS
fi

if [ "$?" != 0 ]; then
    echo "ERROR: Container build failed."
else
    echo "INFO: Container build successfull using the build tool[$ARG_BUILD_TOOL]. Image Name: [$ARG_IMAGE_NAME]"
fi

echo "INFO: Deleting folder: [$TEMP_FOLDER]."
rm -rf $TEMP_FOLDER

exit 0