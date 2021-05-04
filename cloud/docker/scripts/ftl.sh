#supported FTL versions for be version
FTL_VERSION_MAP_MIN=( "6.0.0:6.4.0" "6.1.0:6.5.0" "6.1.1:6.5.0" )
FTL_VERSION_MAP_MAX=( "6.0.0:6.4.x" "6.1.0:6.5.0" "6.1.1:6.6.1" )

# Validate and get TIBCO FTL base and hf versions
ftlPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_ftl_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  )
ftlPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_ftl_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  |  wc -l)
ftlHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_ftl_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  )
ftlHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_ftl_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  |  wc -l)

if [ $ftlPckgsCnt -gt 0 ]; then
	if [ $ftlPckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR: More than one TIBCO FTL base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $ftlHfPckgsCnt -gt 1 ]; then
		printf "\nERROR: More than one TIBCO FTL HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $ftlPckgsCnt -eq 1 ]; then
		FTL_PACKAGE="$(basename ${ftlPckgs[0]} )"
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
		ftlMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${FTL_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
		ftlVersion=$(echo "${ARG_FTL_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		ftlMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${FTL_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

		if ! [[ (( $ftlMinVersion -le $ftlVersion )) && (( $ftlVersion -le $ftlMaxVersion )) ]]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with FTL version: [$ARG_FTL_VERSION].\n";
			exit 1
		fi

        #add ftl package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$FTL_PACKAGE"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $ftlHfPckgsCnt -eq 1 ]; then
			FTL_HF_PACKAGE="$(basename ${ftlHfPckgs[0]})"
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
