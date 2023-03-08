#!/bin/bash

#
# Copyright (c) 2023. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/configproviders/cputils.sh

echo "Check for openssl and keytool utilites"

if [ -x $(command -v openssl) ] ; then
    echo "openssl exists"
else
    REQUIRED_PKGS="openssl"    
fi

if ! [ -x $(command -v keytool) ] ; then
    echo "keytool doesnot exists"
    exit 1;
fi

# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILD_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    package-manager install -y $INSTALL_PKGS_LIST
fi  
