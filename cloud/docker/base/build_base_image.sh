#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

ARG_INSTALLER_LOCATION="na"

for arg in "$@"
do
    if [ "$arg" == "--installers-location" ] || [ "$arg" == "-l" ]
    then
        shift # past the key and to the value
        ARG_INSTALLER_LOCATION="$1"
	shift
    fi
done

echo $ARG_INSTALLER_LOCATION

result=$(find "$ARG_INSTALLER_LOCATION" -type f -iname 'post-install.properties') 
if [ -z "$result" ]
	then
     		source ../base/build_base_frominstaller.sh $@ "-l="$ARG_INSTALLER_LOCATION
	else
      		source ../base/build_base_frominstall.sh $@ "-l="$ARG_INSTALLER_LOCATION
	fi	
