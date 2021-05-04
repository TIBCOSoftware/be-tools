#supported Activespaces(legacy) versions for be version
AS_LEG_VERSION_MAP_MIN=( "5.6.0:2.3.0" "5.6.1:2.3.0" "6.0.0:2.4.0" "6.1.0:2.4.0" "6.1.1:2.4.0" )
AS_LEG_VERSION_MAP_MAX=( "5.6.0:2.4.0" "5.6.1:2.4.1" "6.0.0:2.4.1" "6.1.0:2.4.1" "6.1.1:2.4.1" )

# Validate and get TIBCO Activespaces(legacy) base and hf versions
asLegPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_activespaces_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  )
asLegPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_activespaces_[0-9]\.[0-9]\.[0-9]_linux_x86_64.zip"  |  wc -l)
asLegHfPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_activespaces_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  )
asLegHfPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "TIB_activespaces_[0-9]\.[0-9]\.[0-9]_HF-[0-9][0-9][0-9]_linux_x86_64.zip"  |  wc -l)

if [ $asLegPckgsCnt -gt 0 ]; then
	if [ $asLegPckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR: More than one TIBCO Activespaces(legacy) base versions are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $asLegHfPckgsCnt -gt 1 ]; then
		printf "\nERROR: More than one TIBCO Activespaces(legacy) HF are present in the target directory. There should be only one.\n"
		exit 1;
	elif [ $asLegPckgsCnt -eq 1 ]; then
		AS_LEG_PACKAGE="$(basename ${asLegPckgs[0]} )"
		ARG_AS_LEG_VERSION=$(echo $AS_LEG_PACKAGE | cut -d'_' -f 3)

		# validate as legacy version
		if [[ $ARG_AS_LEG_VERSION =~ $VERSION_REGEX ]]; then
			ARG_AS_LEG_SHORT_VERSION=${BASH_REMATCH[1]};
		else
			printf "ERROR: Improper Activespaces(legacy) version: [$ARG_AS_LEG_VERSION]. It should be in (x.x.x) format Ex: (2.4.0).\n"
			exit 1
		fi

		# validate as leg version with be base version
		DOT="\."
		asLegMinVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_LEG_VERSION_MAP_MIN[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )
		asLegVersion=$(echo "${ARG_AS_LEG_VERSION}" | sed -e "s/${DOT}/${BLANK}/g" )
		asLegMaxVersion=$(echo $( getFromArray "$ARG_BE_VERSION" "${AS_LEG_VERSION_MAP_MAX[@]}" ) | sed -e "s/${DOT}/${BLANK}/g" )

		if ! [[ (( $asLegMinVersion -le $asLegVersion ))  && (( $asLegVersion -le $asLegMaxVersion )) ]]; then
			printf "ERROR: BE version: [$ARG_BE_VERSION] not compatible with Activespaces(legacy) version: [$ARG_AS_LEG_VERSION].\n";
			exit 1
		fi

		#add as legacy package to file list and increment index
		FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$AS_LEG_PACKAGE"
		FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`

		if [ $asLegHfPckgsCnt -eq 1 ]; then
			AS_LEG_HF_PACKAGE="$(basename ${asLegHfPckgs[0]})"
			asHfBaseVersion=$(echo $AS_LEG_HF_PACKAGE | cut -d'_' -f 3)
			if [ "$ARG_AS_LEG_VERSION" = "$asHfBaseVersion" ]; then
				ARG_AS_LEG_HOTFIX=$(echo $AS_LEG_HF_PACKAGE | cut -d'_' -f 4 | cut -d'-' -f 2)
				#validate hf version
				if ! [[ $ARG_AS_LEG_HOTFIX =~ $HF_VERSION_REGEX ]]; then
					printf "ERROR: Improper Activespaces(legacy) hf version: [$ARG_AS_LEG_HOTFIX]. It should be in (xxx) format Ex: (002).\n"
					exit 1
				fi

				#add as legacy hf package to file list and increment index
				FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$AS_LEG_HF_PACKAGE"
				FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
			else
				printf "\nERROR: TIBCO Activespaces(legacy) version: [$asHfBaseVersion] in HF installer and TIBCO Activespaces(legacy) Base version: [$ARG_AS_LEG_VERSION] is not matching.\n"
				exit 1;
			fi
		fi
	fi
fi
