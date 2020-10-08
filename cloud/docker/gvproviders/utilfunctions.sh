#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Its value gets updated during image build time
GVPROVIDER=na

if [ $GVPROVIDER == na ]
then
  # gv provider is not configured. exit with 0.
  exit 0;
fi

chmod +x ./gvproviders/${GVPROVIDER}/run.sh
source ./gvproviders/${GVPROVIDER}/run.sh

prop_keys="$(/home/tibco/be/gvproviders/jq -r keys[] $JSON_FILE)"


if [ -f /home/tibco/be/gvproviders/output.json ]; then
for prop in $prop_keys
do
  echo "Prop: $prop"
  echo tibco.clientVar.${prop}=$(/home/tibco/be/gvproviders/jq -r .$prop $JSON_FILE)>>$BE_PROPS_FILE
done
fi
