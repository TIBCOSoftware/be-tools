#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

GVPROVIDER=$1

if [ "$GVPROVIDER" = "na" -o -z "${GVPROVIDER// }" ]; then
	echo "Skipping gv provider setup"
  exit 0
fi

echo "Setting up '$GVPROVIDER' gv provider..."

# install tools common for all gv providers
cd /home/tibco/be/gvproviders
apt-get update -y && apt-get install -y wget

# Download jq.
wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
mv jq-linux64 jq
chmod +x jq

# invoke provider specific setup
chmod +x /home/tibco/be/gvproviders/${GVPROVIDER}/*.sh
if [ -f /home/tibco/be/gvproviders/${GVPROVIDER}/setup.sh ]; then /home/tibco/be/gvproviders/${GVPROVIDER}/setup.sh; fi

# update run.sh with selected gvprovider
cd /home/tibco/be/gvproviders
sed -i "s/GVPROVIDER=na/GVPROVIDER=$GVPROVIDER/g" run.sh

# clean up
apt-get remove -y wget
apt-get autoremove -y
