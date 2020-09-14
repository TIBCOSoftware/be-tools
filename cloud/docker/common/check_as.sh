#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

#supported As versions for be version
declare -A AS_VERSION_MAP_MIN=(["6.0.0"]="4.2.0" )
declare -A AS_VERSION_MAP_MAX=(["6.0.0"]="4.x.x" )

# Validate and get TIBCO As base and hf versions
asPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip")
asPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_linux_x86_64.zip" |  wc -l)
asHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip")
asHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_as_*_HF-*_linux_x86_64.zip" |  wc -l)

if [ $asPckgsCnt -gt 0 ]; then
	asBasePckgsCnt=$(expr ${asPckgsCnt} - ${asHfPckgsCnt})
	if [ $asBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR :More than one TIBCO As base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $asHfPckgsCnt -gt 1 ]; then
		printf "\nERROR :More than one TIBCO As HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $asBasePckgsCnt -le 0 ]; then
		printf "\nERROR :TIBCO As HF is present but TIBCO As Base version is not present in the target directory.\n"
		exit 1;	
	elif [ $asBasePckgsCnt -eq 1 ]; then
		if [ $asHfPckgsCnt -eq 0 ]; then
			AS_PACKAGE="$(basename ${asPckgs[0]} )"
		else
			AS_PACKAGE="$(basename $( echo "${asPckgs[0]}" | sed -e "s~${asHfPckgs[0]}~~g") )"
		fi
		ARG_AS_VERSION=$(echo $AS_PACKAGE | cut -d'_' -f 3)

		# validate as version
		if [[ $ARG_AS_VERSION =~ $VERSION_REGEX ]]; then
			ARG_AS_SHORT_VERSION=${BASH_REMATCH[1]};
		else
			printf "ERROR: Improper As version: [$ARG_AS_VERSION]. It should be in (x.x.x) format Ex: (4.2.0).\n"
			exit 1
		fi

		# validate as version with be base version
		DOT="\."
		asMinVersion=$(echo "${AS_VERSION_MAP_MIN[$ARG_BE_VERSION]}" | sed -e "s/${DOT}/${BLANK}/g" )
		asVersion=$(echo "${ARG_AS_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		asMaxVersion=$(echo "${AS_VERSION_MAP_MAX[$ARG_BE_VERSION]}" | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

		if ! [ $asMinVersion -le $asVersion -a $asVersion -le $asMaxVersion ]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with As version: [$ARG_AS_VERSION].\n";
			exit 1
		fi

        #add as package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$AS_PACKAGE"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $asHfPckgsCnt -eq 1 ]; then
			AS_HF_PACKAGE="${asHfPckgs[0]##*/}"
			asHfBaseVersion=$(echo $AS_HF_PACKAGE | cut -d'_' -f 3)
			if [ "$ARG_AS_VERSION" = "$asHfBaseVersion" ]; then
				ARG_AS_HOTFIX=$(echo $AS_HF_PACKAGE | cut -d'_' -f 4 | cut -d'-' -f 2)
                #validate hf version
				if ! [[ $ARG_AS_HOTFIX =~ $HF_VERSION_REGEX ]]; then
					printf "ERROR: Improper As hf version: [$ARG_AS_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
					exit 1
				fi
                #add as hf package to file list and increment index
                FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$AS_HF_PACKAGE"
                FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
			else
				printf "\nERROR: TIBCO As version: [$asHfBaseVersion] in HF installer and TIBCO As Base version: [$ARG_AS_VERSION] is not matching.\n"
				exit 1;
			fi
		fi
	fi
fi