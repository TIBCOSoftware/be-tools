#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> [-t <IMAGE_NAME>]"
    echo "  -s <BE_HOME>            Path to BE Home (mandatory)"
    echo "  -a <APP_HOME>           Path to Application Home (mandatory)"
    echo "  -t <IMAGE_NAME>         Provide docker image name (default: be-graal-image)"
    echo "  -h                      Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:t:h" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        t) IMAGE_NAME=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Load environment variables
source init.sh

IMAGE_NAME="${IMAGE_NAME:-be-graal-image}"

# Derive names from paths using basename
OUTPUT_PATH=$APP_HOME/bin/$(basename "$CDD_FILE" .cdd)
BIN_NAME=$(basename "$OUTPUT_PATH")

CDD_NAME=$(basename "$CDD_FILE")
EAR_NAME=$(basename "$EAR_FILE")

LIB_PATH=$(find "$BE_HOME/lib/ext/tpcl" -name "*.so.*" -print -quit)
LIB_NAME=$(basename "$LIB_PATH")

LICENSE_PATH=$(echo "$LICENSE_PATH" | tr -d '\r')
LICENSE_PATH=$(eval echo "$LICENSE_PATH")

# Create a staging area inside the build context
mkdir -p docker/context/bin
mkdir -p docker/context/license
mkdir -p docker/context/lib

# Copy files into the staging area
cp "$OUTPUT_PATH" docker/context/bin/
cp "$CDD_FILE" docker/context/
cp "$EAR_FILE" docker/context/
cp "$BE_HOME/bin/be-engine.tra" docker/context/
cp -r "$LICENSE_PATH" docker/context/
cp "$LIB_PATH" docker/context/lib/


# Build Docker image with args
docker build \
  --build-arg BIN_NAME="$(basename "$OUTPUT_PATH")" \
  --build-arg CDD_NAME="$(basename "$CDD_FILE")" \
  --build-arg EAR_NAME="$(basename "$EAR_FILE")" \
  --build-arg LIB_NAME="$(basename "$LIB_PATH")" \
  -t $IMAGE_NAME \
  -f docker/Dockerfile .

if [ $? -eq 0 ]; then
  echo "Docker image '$IMAGE_NAME' built successfully."
else
  echo "Error: docker image build failed."
fi

rm -rf docker/context