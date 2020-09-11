#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

ARG_FTL_VERSION="na"
ARG_FTL_HOTFIX="na"
ARG_FTL_SHORT_VERSION="na"

# Validate and get FTL version
ftlPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip")
ftlPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip" |  wc -l)
ftlHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip")
ftlHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip" |  wc -l)
if [ $ftlPckgsCnt -gt 0 ]; then
    ftlBasePckgsCnt=$(expr ${ftlPckgsCnt} - ${ftlHfPckgsCnt})
    
    if [ $ftlBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
        printf "\nERROR :More than one TIBCO FTL base versions are present in the target directory..\n"
        exit 1;
    elif [ $ftlHfPckgsCnt -gt 1 ]; then
        printf "\nERROR :More than one TIBCO FTL HF are present in the target directory.There should be only one.\n"
        exit 1;
    elif [ $ftlBasePckgsCnt -le 0 ]; then
        printf "\nERROR :TIBCO FTL HF is present but TIBCO FTL Base version is not present in the target directory.\n"
        exit 1;
    elif [ $ftlBasePckgsCnt -eq 1 ]; then
        FTL_BASE_PACKAGE="${ftlPckgs[0]}"
        ARG_FTL_VERSION=$(echo "${FTL_BASE_PACKAGE##*/}" | sed -e "s/_linux_x86_64.zip/${BLANK}/g" |  sed -e "s/TIB_ftl_/${BLANK}/g") 
        if [ "$ARG_FTL_VERSION" = "" ]; then
            ARG_FTL_VERSION="na"
        fi
        if [ $ftlHfPckgsCnt -eq 1 ]; then
            ftlHf=$(echo "${ftlPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
            ARG_FTL_HOTFIX=$(echo $ftlHf| cut -d'-' -f 2| cut -d' ' -f 1)
            if [[ "$ARG_FTL_VERSION" != "na" ]]; then
                ARG_FTL_VERSION=$(echo $ARG_FTL_VERSION | cut -d'_' -f 1)
            fi
        fi
    fi
fi