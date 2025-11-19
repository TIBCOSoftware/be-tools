#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> -e <EXTERNAL_JARS_PATH> [-g] [-c] [-r]"
    echo "  -g                       Generate metadata"
    echo "  -c                       Create native image"
    echo "  -r                       Run the native image"
    echo "  -s <BE_HOME>             Path to BE Home"
    echo "  -a <APP_HOME>            Path to Application Home"
    echo "  -u <PU>                  Processing Unit name (default: default)"
    echo "  -e <EXTERNAL_JARS_PATH>  Path to External Jars (default: extjars)"
    echo "  -h                       Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:u:e:gcrh" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        u) PU=$OPTARG ;;
        e) EXTERNAL_JARS_PATH=$OPTARG ;;
        g) GENERATE_METADATA=true ;;
        c) CREATE_NATIVE=true ;;
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

# Check if more than one operation is selected
if [ "$OPERATION_COUNT" -gt 1 ]; then
  echo "Error: Only one operation can be selected. You cannot specify both -g, -c, and -r together."
  exit 1
fi

# Validate mandatory options based on the selected operation
if [ "$GENERATE_METADATA" == true ]; then
  echo "Generating metadata..."
  ./gen-metadata.sh -s "$BE_HOME" -a "$APP_HOME" -u "$PU" -e "$EXTERNAL_JARS_PATH"

elif [ "$CREATE_NATIVE" == true ]; then
  echo "Creating native image..."
  ./create-native.sh -s "$BE_HOME" -a "$APP_HOME" -e "$EXTERNAL_JARS_PATH"

elif [ "$RUN_NATIVE_IMAGE" == true ]; then
  echo "Running the native image..."
  ./run-native-app.sh -s "$BE_HOME" -a "$APP_HOME" -u "$PU"
else
  echo "Error: No operation specified. Please use -g, -c, or -r."
  usage
  exit 1
fi

echo "Process completed."
