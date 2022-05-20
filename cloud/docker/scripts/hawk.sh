#supported HAWK versions for be version
HAWK_VERSION_MAP_MIN=( "6.2.1:6.2.1" "6.2.2:6.2.1" )
HAWK_VERSION_MAP_MAX=( "6.2.1:7.1.0" "6.2.2:7.1.0" )

# Validate and get TIBCO HAWK base and hf versions
hawkPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_hawk_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  )
hawkPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_hawk_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  |  wc -l)
hawkHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_hawk_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  )
hawkHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_hawk_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  |  wc -l)

if [ $hawkPckgsCnt -gt 0 ]; then
	if [ $hawkPckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR: More than one TIBCO HAWK base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $hawkHfPckgsCnt -gt 1 ]; then
		printf "\nERROR: More than one TIBCO HAWK HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $hawkPckgsCnt -eq 1 ]; then
		HAWK_PACKAGE="$(basename ${hawkPckgs[0]} )"
		ARG_HAWK_VERSION=$(echo $HAWK_PACKAGE | cut -d'_' -f 3)

		# validate hawk version
		if [[ $ARG_HAWK_VERSION =~ $VERSION_REGEX ]]; then
			ARG_HAWK_SHORT_VERSION=${BASH_REMATCH[1]};
		else
			printf "ERROR: Improper HAWK version: [$ARG_HAWK_VERSION]. It should be in (x.x.x) format Ex: (6.2.0).\n"
			exit 1
		fi

		# validate hawk version with be base version
		DOT="\."
		hawkMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${HAWK_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
		hawkVersion=$(echo "${ARG_HAWK_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		hawkMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${HAWK_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" | sed -e "s/x/9/g" )

		if ! [[ (( $hawkMinVersion -le $hawkVersion )) && (( $hawkVersion -le $hawkMaxVersion )) ]]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with HAWK version: [$ARG_HAWK_VERSION].\n";
			exit 1
		fi

        #add hawk package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$HAWK_PACKAGE"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $hawkHfPckgsCnt -eq 1 ]; then
			HAWK_HF_PACKAGE="$(basename ${hawkHfPckgs[0]})"
			hawkHfBaseVersion=$(echo $HAWK_HF_PACKAGE | cut -d'_' -f 3)
			if [ "$ARG_HAWK_VERSION" = "$hawkHfBaseVersion" ]; then
				ARG_HAWK_HOTFIX=$(echo $HAWK_HF_PACKAGE | cut -d'_' -f 4 | cut -d'-' -f 2)
                #validate hf version
				if ! [[ $ARG_HAWK_HOTFIX =~ $HF_VERSION_REGEX ]]; then
					printf "ERROR: Improper hawk hf version: [$ARG_HAWK_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
					exit 1
				fi
				
                #add hawk hf package to file list and increment index
                FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$HAWK_HF_PACKAGE"
                FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
			else
				printf "\nERROR: TIBCO HAWK version: [$hawkHfBaseVersion] in HF installer and TIBCO HAWK Base version: [$ARG_HAWK_VERSION] is not matching.\n"
				exit 1;
			fi
		fi
	fi
fi
