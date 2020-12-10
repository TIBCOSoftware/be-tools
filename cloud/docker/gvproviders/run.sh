#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Its value gets updated during image build time
GVPROVIDER=na

if [ $GVPROVIDER == na ]
then
  # gv provider is not configured.
  exit 0
fi

echo "INFO: Reading GV values from [${GVPROVIDER}]"

chmod +x ./gvproviders/${GVPROVIDER}/run.sh
./gvproviders/${GVPROVIDER}/run.sh

BE_PROPS_FILE=/home/tibco/be/beprops_all.props
JSON_FILE=/home/tibco/be/gvproviders/output.json

if [ -f $JSON_FILE ]; then
  prop_keys="$(/home/tibco/be/gvproviders/jq -r keys[] $JSON_FILE)"
  if [ -z "$prop_keys" ]; then
    echo "WARN: 0[zero] GV values fetched from the GV provider[$GVPROVIDER]"
  else
    echo "# GV values from $GVPROVIDER">>$BE_PROPS_FILE
    for prop in $prop_keys
    do
      echo "Prop: $prop"
      echo tibco.clientVar.${prop}=$(/home/tibco/be/gvproviders/jq -r .\"$prop\" $JSON_FILE)>>$BE_PROPS_FILE
    done
  fi
else
  echo "WARN: 0[zero] GV values fetched from the GV provider[$GVPROVIDER]"
fi
