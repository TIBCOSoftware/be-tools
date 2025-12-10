#!/bin/bash

# Function to print usage
usage() {
  echo "Usage: $0 -a <APP_HOME>"
  echo "  -a  Application home directory (required)"
  exit 1
}

# Parse command line arguments
while getopts "a:" opt; do
  case $opt in
    a) APP_HOME="$OPTARG" ;;
    *) usage ;;
  esac
done

# Output directory set to "$APP_HOME/.graal/META-INF"
OUTPUT_DIR="$APP_HOME/.graal/META-INF"

# Validate if output directory exists, create it if not
if [ ! -d "$OUTPUT_DIR" ]; then
  echo "Output directory '$OUTPUT_DIR' does not exist. Creating it now."
  mkdir -p "$OUTPUT_DIR"
fi

# Find directories named META-INF* inside the application home directory
INPUTS=$(find "$APP_HOME/.graal" -type d -name "META-INF-*" | sed 's/^/--input-dir=/' | tr '\n' ' ')

# If no META-INF* directories found, exit with an error
if [ -z "$INPUTS" ]; then
  echo "Error: No directories matching 'META-INF*' found in $APP_HOME."
  exit 1
fi

echo "Found directories: $INPUTS"
echo ""

# Run the native-image-configure generate command with the found directories as input
echo "Running native-image-configure generate with the following inputs:"
echo ""

native-image-configure generate $INPUTS --output-dir="$OUTPUT_DIR"

# Check if the native-image-configure command was successful
if [ $? -eq 0 ]; then
  echo "Native image configuration generated successfully in $OUTPUT_DIR."
else
  echo "Error: native-image-configure failed."
  exit 1
fi
