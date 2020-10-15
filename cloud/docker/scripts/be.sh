BLANK=""
BE_HF_REGEX="${BE_PRODUCT}-hf_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]${INSTALLER_PLATFORM}"

# Get all be packages
bePckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "${BE_BASE_PKG_REGEX}"  )
bePckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "${BE_BASE_PKG_REGEX}"  | wc -l)

#Get all be hf packages
beHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "${BE_HF_REGEX}"  )
beHfCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name  "${BE_HF_REGEX}"  | wc -l)

if [ $bePckgsCnt -gt 1 ]; then # If more than one base versions are present
	printf "\nERROR: More than one TIBCO BusinessEvents base versions are present in the target directory. There should be only one.\n"
	exit 1;
elif [ $beHfCnt -gt 1 ]; then # If more than one hf versions are present
	printf "\nERROR: More than one TIBCO BusinessEvents HF are present in the target directory. There should be only one.\n"
	exit 1;
elif [ $bePckgsCnt -eq 1 ]; then
	#Find BE Version from installer
	BE_PACKAGE="$(basename ${bePckgs[0]})"
	ARG_BE_VERSION=$(echo "$BE_PACKAGE" | sed -e "s/${INSTALLER_PLATFORM}/${BLANK}/g" |  sed -e "s/${BE_PRODUCT}-${ARG_EDITION}"_"/${BLANK}/g")  

	# validate be version
	if [[ $ARG_BE_VERSION =~ $VERSION_REGEX ]]; then
		ARG_BE_SHORT_VERSION=${BASH_REMATCH[1]};
	else
		printf "ERROR: Improper BE version: [$ARG_BE_VERSION]. It should be in (x.x.x) format Ex: (5.6.0).\n"
		exit 1
	fi
	
	#add be package to file list and increment index
	FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BE_PACKAGE"
	FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

	if [ $beHfCnt -eq 1 ]; then # If Only one HF is present then parse the HF version
		BE_HF_PACKAGE="$(basename ${beHfPckgs[0]})"
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
