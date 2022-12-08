#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

source /home/tibco/be/gvproviders/gvutils.sh



# fill this variable with required packages to be installed. Multiple packages can be represented in a space separated format ex: "curl unzip".
REQUIRED_PKGS="curl tar less groff"

# fill this variable with packages used only during build time. Multiple packages can be represented in a space separated format ex: "curl unzip".
BUILD_PKGS="tar"

INSTALL_PKGS_LIST=$( getInstallPkgs "$REQUIRED_PKGS" )
CLEANUP_PKGS_LIST=$( getCleanupPkgs "$BUILD_PKGS" "$INSTALL_PKGS_LIST" )

# installing required packages
if [ "$INSTALL_PKGS_LIST" != "" ]; then
    package-manager install -y $INSTALL_PKGS_LIST
fi      

# install aws cli
cd /home/tibco/be/gvproviders/custom/gcp-cas
curl "https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-cli-411.0.0-linux-x86_64.tar.gz" -o "google-cloud-cli.tar.gz"
tar -xf google-cloud-cli.tar.gz
./google-cloud-sdk/install.sh
./google-cloud-sdk/bin/gcloud --version

# clean up
rm -f google-cloud-cli.tar.gz
# rm -rf aws

if [ "$CLEANUP_PKGS_LIST" != "" ]; then
    package-manager remove -y $CLEANUP_PKGS_LIST
fi
