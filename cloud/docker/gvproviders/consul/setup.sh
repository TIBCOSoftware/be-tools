#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/gvproviders/gvutils.sh

# fill this variable with required packages to be installed. Multiple packages can be represented in a space separated format ex: "curl unzip".
REQUIRED_PKGS="unzip"

# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
BUILDTIME_PKGS="unzip"

INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILDTIME_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    package-manager install -y $INSTALL_PKGS_LIST
fi

cd /home/tibco/be/gvproviders/consul

# Download consul cli and extract it.
wget "https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip"
unzip consul_1.6.1_linux_amd64.zip

# clean up
rm -f consul_1.6.1_linux_amd64.zip

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi
