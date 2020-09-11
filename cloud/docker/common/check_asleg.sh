#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

ARG_AS_LEG_VERSION="na"
AS_LEG_SHORT_VERSION="na"
ARG_AS_LEG_HOTFIX="na"

# Validate and get TIBCO Activespaces base and hf versions
asPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_linux_x86_64.zip")
asPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_linux_x86_64.zip" |  wc -l)
asHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_HF-*_linux_x86_64.zip")
asHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_activespaces_*_HF-*_linux_x86_64.zip" |  wc -l)

if [ $asPckgsCnt -gt 0 ]; then
	asBasePckgsCnt=$(expr ${asPckgsCnt} - ${asHfPckgsCnt})
	if [ $asBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR :More than one TIBCO Activespaces base versions are present in the target directory..\n"
		exit 1;
	elif [ $asHfPckgsCnt -gt 1 ]; then
		printf "\nERROR :More than one TIBCO Activespaces HF are present in the target directory.There should be only one.\n"
		exit 1;
	elif [ $asBasePckgsCnt -le 0 ]; then
		printf "\nERROR :TIBCO Activespaces HF is present but TIBCO Activespaces Base version is not present in the target directory.\n"
		exit 1;	
	elif [ $asBasePckgsCnt -eq 1 ]; then
		AS_LEG_BASE_PACKAGE="${asPckgs[0]}"
        ARG_AS_LEG_VERSION=$(echo "${AS_LEG_BASE_PACKAGE##*/}" | sed -e "s/_linux_x86_64.zip/${BLANK}/g" |  sed -e "s/TIB_activespaces_/${BLANK}/g")
		if [ $asHfPckgsCnt -eq 1 ]; then
			asHf=$(echo "${asHfPckgs[0]}" | sed -e "s/"_linux_x86_64.zip"/${BLANK}/g")
			ARG_AS_LEG_HOTFIX=$(echo $asHf| cut -d'-' -f 2)
		elif [ $asHfPckgsCnt -eq 0 ]; then
			ARG_AS_LEG_HOTFIX="na"
		fi	
	else 
		ARG_AS_LEG_HOTFIX="na"	
	fi
fi