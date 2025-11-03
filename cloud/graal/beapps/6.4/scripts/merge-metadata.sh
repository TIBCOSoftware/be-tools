#!/bin/bash

# Hardcoded list of folders, first is ./META-INF
folders=( "../fd" "../fdcache" )

# Join folders into a space-separated string for find
dirs="${folders[*]}"
echo  "dirs : $dirs"

# Find directories named native* inside these folders
INPUTS=$(find $dirs -type d -name "META-INF*" | sed 's/^/--input-dir=/' | tr '\n' ' ')

echo "INPUTS=$INPUTS"

# Run the native-image-configure generate command
native-image-configure generate $INPUTS --output-dir=META-INF
