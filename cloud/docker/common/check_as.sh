#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Validate and get ACTIVESPACES version
activespacesPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip")
activespacesPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip" |  wc -l)
activespacesHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip")
activespacesHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip" |  wc -l)
if [ $activespacesPckgsCnt -gt 0 ]; then
    activespacesBasePckgsCnt=$(expr ${activespacesPckgsCnt} - ${activespacesHfPckgsCnt})
    
    if [ $activespacesBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
        printf "\nERROR :More than one TIBCO AS base versions are present in the target directory..\n"
        exit 1;
    elif [ $activespacesHfPckgsCnt -gt 1 ]; then
        printf "\nERROR :More than one TIBCO AS HF are present in the target directory.There should be only one.\n"
        exit 1;
    elif [ $activespacesBasePckgsCnt -le 0 ]; then
        printf "\nERROR :TIBCO AS HF is present but TIBCO AS Base version is not present in the target directory.\n"
        exit 1;
    elif [ $activespacesBasePckgsCnt -eq 1 ]; then
        AS_BASE_PACKAGE="${activespacesPckgs[0]}"
        ARG_AS_VERSION=$(echo "${AS_BASE_PACKAGE##*/}" | sed -e "s/_linux_x86_64.zip/${BLANK}/g" |  sed -e "s/TIB_as_/${BLANK}/g")
        if [ "$ARG_AS_VERSION" = "" ]; then
            ARG_AS_VERSION="na"
        fi
        if [ $activespacesHfPckgsCnt -eq 1 ]; then
            activespacesHf=$(echo "${activespacesPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
            ARG_AS_HOTFIX=$(echo $activespacesHf| cut -d'-' -f 2| cut -d' ' -f 1)
            if [[ "$ARG_AS_VERSION" != "na" ]]; then
                ARG_AS_VERSION=$(echo $ARG_AS_VERSION | cut -d'_' -f 1)
            fi
        fi
    fi
fi

VERSION_REGEX=([0-9]\.[0-9]).*
if [[ $ARG_AS_VERSION =~ $VERSION_REGEX ]]
then
	ARG_AS_SHORT_VERSION=${BASH_REMATCH[1]};
else
	echo "ERROR: Improper As version. Aborting."
	exit 1
fi