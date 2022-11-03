#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/gvproviders/gvutils.sh

CONJUR_VERSION=7.0.1
PYTHON_VERSION=3.6

REQUIRED_PKGS="python3-setuptools python3 "
    
# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
BUILD_PKGS=""

INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILD_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    echo $INSTALL_PKGS_LIST
    package-manager update -y && package-manager install -y $INSTALL_PKGS_LIST
fi

wget -nv https://bootstrap.pypa.io/pip/$PYTHON_VERSION/get-pip.py
python3 get-pip.py
pip3 install conjur==$CONJUR_VERSION

# install conjur cli
conjur --version

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi
