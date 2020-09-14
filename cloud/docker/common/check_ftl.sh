#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

#supported FTL versions for be version
declare -A FTL_VERSION_MAP_MIN=(["6.0.0"]="6.2.0" )
declare -A FTL_VERSION_MAP_MAX=(["6.0.0"]="6.x.x" )

# Validate and get TIBCO FTL base and hf versions
ftlPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip")
ftlPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_linux_x86_64.zip" |  wc -l)
ftlHfPckgs=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip")
ftlHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -name "TIB_ftl_*_HF-*_linux_x86_64.zip" |  wc -l)

if [ $ftlPckgsCnt -gt 0 ]; then
	ftlBasePckgsCnt=$(expr ${ftlPckgsCnt} - ${ftlHfPckgsCnt})
	if [ $ftlBasePckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR :More than one TIBCO FTL base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $ftlHfPckgsCnt -gt 1 ]; then
		printf "\nERROR :More than one TIBCO FTL HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $ftlBasePckgsCnt -le 0 ]; then
		printf "\nERROR :TIBCO FTL HF is present but TIBCO FTL Base version is not present in the target directory.\n"
		exit 1;	
	elif [ $ftlBasePckgsCnt -eq 1 ]; then
		if [ $ftlHfPckgsCnt -eq 0 ]; then
			FTL_PACKAGE="$(basename ${ftlPckgs[0]} )"
		else
			FTL_PACKAGE="$(basename $( echo "${ftlPckgs[0]}" | sed -e "s~${ftlHfPckgs[0]}~~g") )"
		fi
		ARG_FTL_VERSION=$(echo $FTL_PACKAGE | cut -d'_' -f 3)

		# validate ftl version
		if [[ $ARG_FTL_VERSION =~ $VERSION_REGEX ]]; then
			ARG_FTL_SHORT_VERSION=${BASH_REMATCH[1]};
		else
			printf "ERROR: Improper FTL version: [$ARG_FTL_VERSION]. It should be in (x.x.x) format Ex: (6.2.0).\n"
			exit 1
		fi

		# validate ftl version with be base version
		DOT="\."
		ftlMinVersion=$(echo "${FTL_VERSION_MAP_MIN[$ARG_BE_VERSION]}" | sed -e "s/${DOT}/${BLANK}/g" )
		ftlVersion=$(echo "${ARG_FTL_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		ftlMaxVersion=$(echo "${FTL_VERSION_MAP_MAX[$ARG_BE_VERSION]}" | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

		if ! [ $ftlMinVersion -le $ftlVersion -a $ftlVersion -le $ftlMaxVersion ]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with FTL version: [$ARG_FTL_VERSION].\n";
			exit 1
		fi

        #add ftl package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$FTL_PACKAGE"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $ftlHfPckgsCnt -eq 1 ]; then
			FTL_HF_PACKAGE="${ftlHfPckgs[0]##*/}"
			ftlHfBaseVersion=$(echo $FTL_HF_PACKAGE | cut -d'_' -f 3)
			if [ "$ARG_FTL_VERSION" = "$ftlHfBaseVersion" ]; then
				ARG_FTL_HOTFIX=$(echo $FTL_HF_PACKAGE | cut -d'_' -f 4 | cut -d'-' -f 2)
                #validate hf version
				if ! [[ $ARG_FTL_HOTFIX =~ $HF_VERSION_REGEX ]]; then
					printf "ERROR: Improper ftl hf version: [$ARG_FTL_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
					exit 1
				fi
                #add ftl hf package to file list and increment index
                FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$FTL_HF_PACKAGE"
                FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
			else
				printf "\nERROR: TIBCO FTL version: [$ftlHfBaseVersion] in HF installer and TIBCO FTL Base version: [$ARG_FTL_VERSION] is not matching.\n"
				exit 1;
			fi
		fi
	fi
fi