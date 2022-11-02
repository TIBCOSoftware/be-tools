#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/gvproviders/gvutils.sh

OS=$(cat /etc/os-release | grep ^ID= | sed -r 's/^ID=?(.*)?$/\1/g;s/"//g')

if [ "$OS" = "ubuntu" ]
then
    # fill this variable with required packages to be installed. Multiple packages can be represented in a space separated format ex: "curl unzip".
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
    wget -nv https://bootstrap.pypa.io/get-pip.py 
    python3 get-pip.py
    pip3 install conjur==7.0.1
    #Initialize the conjur cli
elif [ "$OS" = "rhel" ]
then
    wget https://github.com/cyberark/cyberark-conjur-cli/releases/download/v7.1.0/conjur-cli-rhel-8.tar.gz
    tar -xvf conjur-cli-rhel-8.tar.gz
    chmod +x conjur
    mv conjur /usr/local/bin
else
    echo "Conjur cli not supported in current OS"
    exit 0 
fi

# install conjur cli
conjur --version

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi
