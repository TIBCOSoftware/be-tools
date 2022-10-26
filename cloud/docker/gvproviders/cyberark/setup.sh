#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/gvproviders/gvutils.sh

# fill this variable with required packages to be installed. Multiple packages can be represented in a space separated format ex: "curl unzip".
REQUIRED_PKGS=""

# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
BUILD_PKGS=""

INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILD_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    echo $INSTALL_PKGS_LIST
    package-manager update -y && package-manager install -y $INSTALL_PKGS_LIST
fi      

apt update && apt upgrade -y
export DEBIAN_FRONTEND=noninteractive
apt install software-properties-common -y
add-apt-repository ppa:deadsnakes/ppa -y
apt install python3.10 -y
apt install curl -y
curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
pip3.10 install conjur==7.1.0

# install conjur cli
conjur --version

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi
