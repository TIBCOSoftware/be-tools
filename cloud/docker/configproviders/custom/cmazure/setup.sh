#!/bin/bash

#
# Copyright (c) 2023. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/configproviders/cputils.sh


# fill this variable with required packages to be installed. Multiple packages can be represented in a space separated format ex: "curl unzip".
REQUIRED_PKGS="curl"

# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
# BUILD_PKGS="unzip"

echo "INFO: Check for openssl and keytool utilites"

if  ! [ -x $(command -v openssl) ] ; then
    REQUIRED_PKGS="$REQUIRED_PKGS openssl"    
fi

if ! [ -x $(command -v keytool) ] ; then
    echo "ERROR: keytool utility is required and it doesnot exists, exiting the build"
    exit 1;
fi

INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILD_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    package-manager install -y $INSTALL_PKGS_LIST
fi      

# install az cli
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

az version

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi

