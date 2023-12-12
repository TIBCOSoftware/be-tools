#supported TEA versions for be version
TEA_VERSION_MAP_MIN=( "6.3.0:2.4.1" "6.3.1:2.4.1" )
TEA_VERSION_MAP_MAX=( "6.3.0:2.4.1" "6.3.1:2.4.1" )

# Validate and get TIBCO TEA base and hf versions
teaPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_tea_[0-9]\.[0-9]\.[0-9]_linux26gl23_x86_64.zip"  )
teaPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_tea_[0-9]\.[0-9]\.[0-9]_linux26gl23_x86_64.zip"  |  wc -l)
teaHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_tea_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9].zip"  )
teaHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_tea_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9].zip"  |  wc -l)

if [ $teaPckgsCnt -gt 0 ]; then
	if [ $teaPckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR: More than one TIBCO TEA base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $teaHfPckgsCnt -gt 1 ]; then
		printf "\nERROR: More than one TIBCO TEA HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $teaPckgsCnt -eq 1 ]; then
		TEA_PACKAGE="$(basename ${teaPckgs[0]} )"
		ARG_TEA_VERSION=$(echo $TEA_PACKAGE | cut -d'_' -f 3)

		# validate tea version
		if [[ $ARG_TEA_VERSION =~ $VERSION_REGEX ]]; then
			ARG_TEA_SHORT_VERSION=${BASH_REMATCH[1]};
		else
			printf "ERROR: Improper TEA version: [$ARG_TEA_VERSION]. It should be in (x.x.x) format Ex: (2.4.1).\n"
			exit 1
		fi

		# validate tea version with be base version
		DOT="\."
		teaMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${TEA_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
		teaVersion=$(echo "${ARG_TEA_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		teaMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${TEA_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

		if ! [[ (( $teaMinVersion -le $teaVersion )) && (( $teaVersion -le $teaMaxVersion )) ]]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with TEA version: [$ARG_TEA_VERSION].\n";
			exit 1
		fi

        #add tea package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$TEA_PACKAGE"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $teaHfPckgsCnt -eq 1 ]; then
			TEA_HF_PACKAGE="$(basename ${teaHfPckgs[0]})"
			teaHfBaseVersion=$(echo $TEA_HF_PACKAGE | cut -d'_' -f 3)
			if [ "$ARG_TEA_VERSION" = "$teaHfBaseVersion" ]; then
				ARG_TEA_HOTFIX=$(echo $TEA_HF_PACKAGE | cut -d'_' -f 4 | cut -d'-' -f 2 | cut -d'.' -f 1)
                #validate hf version
				if ! [[ $ARG_TEA_HOTFIX =~ $HF_VERSION_REGEX ]]; then
					printf "ERROR: Improper tea hf version: [$ARG_TEA_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
					exit 1
				fi
				
                #add tea hf package to file list and increment index
                FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$TEA_HF_PACKAGE"
                FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
			else
				printf "\nERROR: TIBCO TEA version: [$teaHfBaseVersion] in HF installer and TIBCO TEA Base version: [$ARG_TEA_VERSION] is not matching.\n"
				exit 1;
			fi
		fi
	fi
fi
