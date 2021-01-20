#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

GVPROVIDER=$1

if [ "$GVPROVIDER" = "na" -o -z "${GVPROVIDER// }" ]; then
	echo "INFO: Skipping gv provider setup"
  exit 0
fi

echo "INFO: Setting up '$GVPROVIDER' gv provider..."

if [ -f /usr/bin/apt-get ]; then
  ln -s /usr/bin/apt-get /usr/bin/package-manager
elif [ -f /usr/bin/yum ]; then
  ln -s /usr/bin/yum /usr/bin/package-manager
fi

# install tools common for all gv providers
cd /home/tibco/be/gvproviders
package-manager update -y && package-manager install -y wget

# Download jq.
wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
wget "https://raw.githubusercontent.com/stedolan/jq/master/COPYING"
mv jq-linux64 jq
mv COPYING JQLICENSE
chmod +x jq

# invoke provider specific setup
chmod +x /home/tibco/be/gvproviders/${GVPROVIDER}/*.sh
if [ -f /home/tibco/be/gvproviders/${GVPROVIDER}/setup.sh ]; then /home/tibco/be/gvproviders/${GVPROVIDER}/setup.sh; fi

if [ "$?" != 0 ]; then
    echo "ERROR: ${GVPROVIDER} gvprovider setup failed."
    exit 1
fi

# update run.sh with selected gvprovider
cd /home/tibco/be/gvproviders
ESCAPED_GVPROVIDER=$(printf '%s\n' "$GVPROVIDER" | sed -e 's/[\/]/\\&/g')
sed -i "s/GVPROVIDER=na/GVPROVIDER=$ESCAPED_GVPROVIDER/g" run.sh

# clean up
package-manager remove -y wget
package-manager autoremove -y