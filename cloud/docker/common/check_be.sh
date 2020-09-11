#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

ARG_EDITION="enterprise"
ARG_VERSION="na"
ARG_BE_HOTFIX="na"

BLANK=""
BE_PRODUCT="TIB_businessevents"
INSTALLER_PLATFORM="_linux26gl25_x86_64.zip"

BE_BASE_VERSION_REGEX="${BE_PRODUCT}-${ARG_EDITION}_*${INSTALLER_PLATFORM}"
BE_HF_REGEX="${BE_PRODUCT}-hf_*_HF"

#Check for BE Installer  --------------------------------------
result=$(find $ARG_INSTALLER_LOCATION -name "$BE_BASE_VERSION_REGEX")
len=$(echo ${result} | wc -l)

if [ $len -eq 0 ]; then
	printf "\nERROR: TIBCO BusinessEvents Installer is not present in the target directory.\n"
	exit 1;
fi

# Get all packages(base and hf)  --------------------------------------
bePckgs=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_*$INSTALLER_PLATFORM")
bePckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "${BE_PRODUCT}-${ARG_EDITION}_*$INSTALLER_PLATFORM" | wc -l)


#Get All HF for BE --------------------------------------
beHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "$BE_HF_REGEX*$INSTALLER_PLATFORM")
beHfCnt=$(find $ARG_INSTALLER_LOCATION -name  "$BE_HF_REGEX*$INSTALLER_PLATFORM" | wc -l)

beBasePckgsCnt=$(expr ${bePckgsCnt} - ${beHfCnt})
if [ $bePckgsCnt -gt 1 ]; then # If more than one base versions are present
	printf "\nERROR :More than one TIBCO BusinessEvents base versions are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beHfCnt -gt 1 ]; then # If more than one hf versions are present
	printf "\nERROR :More than one TIBCO BusinessEvents HF are present in the target directory.There should be only one.\n"
	exit 1;
elif [ $beBasePckgsCnt -lt 0 ]; then # If HF is present but base version is not present
	printf "\nERROR :TIBCO BusinessEvents HF is present but TIBCO BusinessEvents Base version is not present in the target directory.\n"
	exit 1;	
elif [ $bePckgsCnt -eq 1 ]; then
	#Find BE Version from installer
	BASE_PACKAGE="${bePckgs[0]}"
	ARG_VERSION=$(echo "${BASE_PACKAGE##*/}" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g" |  sed -e "s/${BE_PRODUCT}-${ARG_EDITION}"_"/${BLANK}/g")  
	#Find JER Version for given BE Version
	length=${#BE_VERSION_AND_JRE_MAP[@]}
	for (( i = 0; i < length; i++ )); do
		if [ "$ARG_VERSION" = "${BE_VERSION_AND_JRE_MAP[i]}" ];then
			ARG_JRE_VERSION=${BE_VERSION_AND_JRE_MAP[i+1]};
			break;	
		fi
	done
	
	if [ $beHfCnt -eq 1 ]; then # If Only one HF is present then parse the HF version

		VERSION_PACKAGE="${beHfPckgs[0]}"
		hfbepackage=$(echo "${VERSION_PACKAGE##*/}" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g")
		hfbeversion=$(echo "$hfbepackage"| cut -d'_' -f 3)
    	if [ $ARG_VERSION == $hfbeversion ];then
      		ARG_BE_HOTFIX=$(echo "${hfbepackage}"| cut -d'_' -f 4 | sed -e "s/HF-/${BLANK}/g")
		else
			printf "\nERROR: TIBCO BusinessEvents version in HF installer and TIBCO BusinessEvents Base version is not matching.\n"
			exit 1;
		fi 
		
	elif [ $beHfCnt -eq 0 ]; then
		ARG_BE_HOTFIX="na"
	fi
else
	ARG_BE_HOTFIX="na"
fi