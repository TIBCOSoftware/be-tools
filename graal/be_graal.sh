#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> -e <EXTERNAL_JARS_PATH> -t <IMAGE_NAME> [-m] [-c] [-n] [-r] [-d] [-h]"
    echo "  -m                       Generate metadata"
    echo "  -c                       Clean metadata"
    echo "  -n                       Create native image"
    echo "  -r                       Run the native image"
    echo "  -d                       Build Docker image from native binary"
    echo "  -s <BE_HOME>             Path to BE Home"
    echo "  -a <APP_HOME>            Path to BE application directory with cdd and ear"
    echo "  -u <PU>                  Processing Unit name (default: default)"
    echo "  -e <EXTERNAL_JARS_PATH>  Path to External Jars (default: extjars)"
    echo "  -t <IMAGE_NAME>          Provide docker image name (default: be-graal-image)"
    echo "  -h                       Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:u:e:t:mcrndh" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        u) PU=$OPTARG ;;
        e) EXTERNAL_JARS_PATH=$OPTARG ;;
        t) IMAGE_NAME=$OPTARG ;;
        m) GENERATE_METADATA=true ;;
        c) CLEAN_METADATA=true ;;
        d) DOCKER_IMAGE=true ;;
        n) CREATE_NATIVE=true ;;
        r) RUN_NATIVE_IMAGE=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check if GraalVM Java is available in the system path
check_graalvm() {
  echo "Checking for GraalVM Java..."

  # Check if java is in the PATH
  if ! command -v java &>/dev/null; then
    echo "Error: java command not found in PATH. Please ensure GraalVM is installed and in your PATH."
    exit 1
  fi

  # Check if GraalVM is being used by checking the Java version
  java_version=$(java -version 2>&1 | tail -n 1)
  if [[ "$java_version" != *"GraalVM"* ]]; then
    echo "Error: GraalVM Java is not installed or is not the default Java in your PATH."
    exit 1
  fi

  echo "GraalVM Java is available: $java_version"
}

# Call GraalVM check function
check_graalvm
echo "GraalVM check passed."
echo ""

# Count the number of operations set
OPERATION_COUNT=0
[ "$GENERATE_METADATA" == true ] && ((OPERATION_COUNT++))
[ "$CREATE_NATIVE" == true ] && ((OPERATION_COUNT++))
[ "$RUN_NATIVE_IMAGE" == true ] && ((OPERATION_COUNT++))
[ "$CLEAN_METADATA" == true ] && ((OPERATION_COUNT++))
[ "$DOCKER_IMAGE" == true ] && ((OPERATION_COUNT++))

# Check if more than one operation is selected
if [ "$OPERATION_COUNT" -gt 1 ]; then
  echo "Error: Only one operation can be selected. You cannot specify both -m, -c, -n, -d, and -r together."
  exit 1
fi

# Validate mandatory options based on the selected operation
if [ "$GENERATE_METADATA" == true ]; then
  echo "Generating metadata..."
  ./scripts/gen-metadata.sh -s "$BE_HOME" -a "$APP_HOME" -u "$PU" -e "$EXTERNAL_JARS_PATH"

elif [ "$CREATE_NATIVE" == true ]; then
  echo "Creating native image..."
  ./scripts/create-native.sh -s "$BE_HOME" -a "$APP_HOME" -e "$EXTERNAL_JARS_PATH"

elif [ "$RUN_NATIVE_IMAGE" == true ]; then
  echo "Running the native image..."
  ./scripts/run-native-app.sh -s "$BE_HOME" -a "$APP_HOME" -u "$PU"
elif [ "$DOCKER_IMAGE" == true ]; then
  echo "Creating the docker image from native binary..."
  ./scripts/build-image.sh -s "$BE_HOME" -a "$APP_HOME" -t "$IMAGE_NAME"
elif [ "$CLEAN_METADATA" == true ]; then
  echo "Cleaning the metdata folders..."
  if [ -z "$APP_HOME" ]; then
    echo "Error: APP_HOME is required."
    usage
  fi

  # Validate if application home exists
  if [ ! -d "$APP_HOME" ]; then
    echo "Error: Application home directory '$APP_HOME' does not exist."
    exit 1
  fi

  rm -rf "$APP_HOME/.graal/META-INF*"
else
  echo "Error: No operation specified. Please use -g, -c, or -r."
  usage
  exit 1
fi

echo "Process completed."
