#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

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
	printf "\nERROR :More than one TIBCO BusinessEvents base versions are present in the target directory. There should be only one.\n"
	exit 1;
elif [ $beHfCnt -gt 1 ]; then # If more than one hf versions are present
	printf "\nERROR :More than one TIBCO BusinessEvents HF are present in the target directory. There should be only one.\n"
	exit 1;
elif [ $beBasePckgsCnt -lt 0 ]; then # If HF is present but base version is not present
	printf "\nERROR :TIBCO BusinessEvents HF is present but TIBCO BusinessEvents Base version is not present in the target directory.\n"
	exit 1;	
elif [ $bePckgsCnt -eq 1 ]; then
	#Find BE Version from installer
	BE_PACKAGE="${bePckgs[0]##*/}"
	ARG_BE_VERSION=$(echo "$BE_PACKAGE" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g" |  sed -e "s/${BE_PRODUCT}-${ARG_EDITION}"_"/${BLANK}/g")  

	# validate be version
	if [[ $ARG_BE_VERSION =~ $VERSION_REGEX ]]; then
		ARG_BE_SHORT_VERSION=${BASH_REMATCH[1]};
	else
		printf "ERROR: Improper BE version: [$ARG_BE_VERSION]. It should be in (x.x.x) format Ex: (5.6.0).\n"
		exit 1
	fi

	#Find JRE Version for given BE Version
	length=${#BE_VERSION_AND_JRE_MAP[@]}	
	for (( i = 0; i < length; i++ )); do
		if [ "$ARG_BE_VERSION" = "${BE_VERSION_AND_JRE_MAP[i]}" ];then
			ARG_JRE_VERSION=${BE_VERSION_AND_JRE_MAP[i+1]};
			break;	
		fi
	done
	
	#add be package to file list and increment index
	FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BE_PACKAGE"
	FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

	if [ $beHfCnt -eq 1 ]; then # If Only one HF is present then parse the HF version
		BE_HF_PACKAGE="${beHfPckgs[0]##*/}"
		hfbeversion=$(echo "$BE_HF_PACKAGE"| cut -d'_' -f 3)
		if [ $ARG_BE_VERSION == $hfbeversion ]; then
      		ARG_BE_HOTFIX=$(echo "$BE_HF_PACKAGE" | cut -d'_' -f 4 | sed -e "s/HF-/${BLANK}/g")
			#validate hf version
			if ! [[ $ARG_BE_HOTFIX =~ $HF_VERSION_REGEX ]]; then
				printf "ERROR: Improper BE hf version: [$ARG_BE_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
				exit 1
			fi
			#add be hf package to file list and increment index
			FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BE_HF_PACKAGE"
			FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
		else
			printf "\nERROR: TIBCO BusinessEvents version: [$hfbeversion] in HF installer and TIBCO BusinessEvents Base version: [$ARG_BE_VERSION] is not matching.\n"
			exit 1;
		fi
	fi
fi