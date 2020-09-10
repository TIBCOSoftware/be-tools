#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

addons="na"
BE_PROCESS_ADDON_REGEX="${BE_PRODUCT}-process_${ARG_VERSION}${INSTALLER_PLATFORM}"
BE_VIEWS_ADDON_REGEX="${BE_PRODUCT}-views_${ARG_VERSION}${INSTALLER_PLATFORM}"

#Add process addon if present --------------------------------------
processAddon=$(find $ARG_INSTALLER_LOCATION -name "$BE_PROCESS_ADDON_REGEX")
processAddonCnt=$(find $ARG_INSTALLER_LOCATION -name "$BE_PROCESS_ADDON_REGEX" | wc -l)

if [ $processAddonCnt -eq 1 ]; then
	addons="process,"
elif [ $processAddonCnt -gt 1 ]; then
	printf "\nERROR :More than one TIBCO BusinessEvents process addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi


#Add view addon if present  --------------------------------------
viewsAddon=$(find $ARG_INSTALLER_LOCATION -name "$BE_VIEWS_ADDON_REGEX")
viewsAddonCnt=$(find $ARG_INSTALLER_LOCATION -name "$BE_VIEWS_ADDON_REGEX" | wc -l)

if [ $viewsAddonCnt -eq 1 ]; then
	view="views"
	addons="$addons$view"
elif [ $viewsAddonCnt -gt 1 ]; then
	printf "\nERROR :More than one TIBCO BusinessEvents views addon are present in the target directory.There should be none or only one.\n"
	exit 1;
fi

if [ addons = "na" ]; then
	ARG_ADDONS="na"
else
	ARG_ADDONS=$addons
fi