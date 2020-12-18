ARG_ADDONS="na"
BE_PROCESS_ADDON_REGEX="${BE_PRODUCT}-process_${ARG_BE_VERSION}${INSTALLER_PLATFORM}"
BE_VIEWS_ADDON_REGEX="${BE_PRODUCT}-views_${ARG_BE_VERSION}${INSTALLER_PLATFORM}"

#Add process addon if present
processAddon=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "$BE_PROCESS_ADDON_REGEX"  )
processAddonCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "$BE_PROCESS_ADDON_REGEX"  | wc -l)

if [ $processAddonCnt -eq 1 ]; then
	ARG_ADDONS="process"
	BE_ADDON_PROCESS_PACKAGE="${processAddon[0]##*/}"
	#add be process addon to file list and increment index
	FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BE_ADDON_PROCESS_PACKAGE"
	FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
elif [ $processAddonCnt -gt 1 ]; then
	printf "\nERROR: More than one TIBCO BusinessEvents process addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi

#Add view addon if present
viewsAddon=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "$BE_VIEWS_ADDON_REGEX"  )
viewsAddonCnt=$(find $ARG_INSTALLER_LOCATION -maxdepth 1 -name "$BE_VIEWS_ADDON_REGEX"  | wc -l)

if [ $viewsAddonCnt -eq 1 ]; then
	ARG_ADDONS="$ARG_ADDONS,views"
	BE_ADDON_VIEWS_PACKAGE="${viewsAddon[0]##*/}"
	#add be views addon to file list and increment index
	FILE_LIST[$FILE_LIST_INDEX]="$ARG_INSTALLER_LOCATION/$BE_ADDON_VIEWS_PACKAGE"
	FILE_LIST_INDEX=`expr $FILE_LIST_INDEX + 1`
elif [ $viewsAddonCnt -gt 1 ]; then
	printf "\nERROR: More than one TIBCO BusinessEvents views addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi
