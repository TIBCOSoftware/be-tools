#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

CONFIGPROVIDER=$1

if [ "$CONFIGPROVIDER" = "na" -o -z "${CONFIGPROVIDER// }" ]; then
	echo "INFO: Skipping Config Providers setup"
  exit 0
fi

echo "INFO: Setting up Config Providers[${CONFIGPROVIDER}]..."

if [ -f /usr/bin/apt-get ]; then
  ln -s /usr/bin/apt-get /usr/bin/package-manager
elif [ -f /usr/bin/yum ]; then
  ln -s /usr/bin/yum /usr/bin/package-manager
fi

# install tools common for all Config Providers
cd /home/tibco/be/configproviders
package-manager update -y && package-manager install -y wget

# Download jq.
wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
wget "https://raw.githubusercontent.com/stedolan/jq/master/COPYING"
mv jq-linux64 jq
mv COPYING JQLICENSE
chmod +x jq

oIFS="$IFS"; IFS=','; declare -a CPs=($CONFIGPROVIDER); IFS="$oIFS"; unset oIFS

# invoke provider specific setups
for CP in "${CPs[@]}"
do
  echo "INFO: setting up the Config Provider[${CP}]..."
  chmod +x /home/tibco/be/configproviders/${CP}/*.sh
  # set javabin path in path variables to check existance of keytool utility
  if [[ $CP = cm* ]] || [[ $CP = custom/cm* ]] ; then
    TRA_FILE="bin/be-engine.tra"
    TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//')
    echo "INFO: Setting java bin path"
    export PATH=$PATH:$TIB_JAVA_HOME/bin
  fi
  if [ -f /home/tibco/be/configproviders/${CP}/setup.sh ]; then /home/tibco/be/configproviders/${CP}/setup.sh; fi

  if [ "$?" != 0 ]; then
    echo "ERROR: Config Provider[${CP}] setup failed."
    exit 1
  fi
  echo "INFO: Config Provider[${CP}] setup done."
done

# update run.sh with selected Config Provider
cd /home/tibco/be/configproviders
ESCAPED_CONFIGPROVIDER=$(printf '%s\n' "$CONFIGPROVIDER" | sed -e 's/[\/]/\\&/g')
sed -i "s/CONFIGPROVIDER=na/CONFIGPROVIDER=$ESCAPED_CONFIGPROVIDER/g" run.sh

# clean up
package-manager remove -y wget
package-manager autoremove -y