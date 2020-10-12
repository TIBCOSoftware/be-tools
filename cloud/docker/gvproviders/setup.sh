#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

GVPROVIDER=$1
SUPPORTED_GV_PROVIDERS=(consul http custom)

if [ "$GVPROVIDER" = "na" -o -z "${GVPROVIDER// }" ]; then
	echo "Skipping gv provider setup"
  rm -rf /home/tibco/be/gvproviders/*
  exit 0
fi

# check whether the gvprovider is supported or not
if [[ ${SUPPORTED_GV_PROVIDERS[@]} =~ $GVPROVIDER ]]
then
  echo "Setting up '$GVPROVIDER' gv provider..."
else
  echo "gv provider '$GVPROVIDER' is not supported"
  exit 1
fi

# install tools common for all gv providers
cd /home/tibco/be/gvproviders
apt-get update -y && apt-get install -y wget

# Download jq.
wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
mv jq-linux64 jq
chmod +x jq

# invoke provider specific setup
chmod +x /home/tibco/be/gvproviders/${GVPROVIDERS}/*.sh
if [ -f /home/tibco/be/gvproviders/${GVPROVIDERS}/setup.sh ]; then /home/tibco/be/gvproviders/${GVPROVIDERS}/setup.sh; fi

# update run.sh with selected gvprovider
cd /home/tibco/be/gvproviders
sed -i "s/GVPROVIDER=na/GVPROVIDER=$GVPROVIDER/g" run.sh

# clean up i.e. remove other gv provider artefacts
for gv in "${SUPPORTED_GV_PROVIDERS[@]}"
do
  if [ $gv != $GVPROVIDER ]
  then
    rm -rf $gv;
  fi
done

apt-get remove -y wget
apt-get autoremove -y