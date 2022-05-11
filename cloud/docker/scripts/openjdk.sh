# Validate and get TIBCO As base and hf versions
openJdkPckgs=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "openjdk-[0-9][0-9]*linux*.tar.gz"  )
openJdkPckgsCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "openjdk-[0-9][0-9]*linux*.tar.gz"  |  wc -l)

if [ $openJdkPckgsCnt -gt 0 ]; then
    if [ $openJdkPckgsCnt -gt 1 ]; then # If more than one base versions are present
		printf "\nERROR: More than one openjdk installers found. There should be only one.\n"
		exit 1;
	else
        OPEN_JDK_FILENAME="$(basename ${openJdkPckgs[0]} )"
		OPEN_JDK_VERSION=$(echo $OPEN_JDK_FILENAME | cut -d'-' -f 2| cut -d'+' -f 1)

        #add as package to file list and increment index
        FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$OPEN_JDK_FILENAME"
        FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
    fi
else
    printf "\nERROR: Openjdk installer archive not found at the specified location:[$ARG_INSTALLER_LOCATION].\n"
	exit 1;
fi
