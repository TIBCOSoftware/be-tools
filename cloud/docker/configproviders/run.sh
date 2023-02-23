#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Its value gets updated during image build time
CONFIGPROVIDER=na

if [ $CONFIGPROVIDER = na ]
then
  # Config Provider is not configured.
  exit 0
fi

oIFS="$IFS"; IFS=','; declare -a CPs=($CONFIGPROVIDER); IFS="$oIFS"; unset oIFS

# invoke provider specific runs
for CP in "${CPs[@]}"
do
  if [[ $CP = gv* ]] || [[ $CP = custom/gv* ]] ; then

    echo "INFO: Reading GV values from [${CP}]"

    ./configproviders/${CP}/run.sh

    BE_PROPS_FILE=/home/tibco/be/beprops_all.props
    JSON_FILE=/home/tibco/be/configproviders/output.json

    if [ -f $JSON_FILE ]; then
      prop_keys="$(/home/tibco/be/configproviders/jq -r keys[] $JSON_FILE)"
      if [ -z "$prop_keys" ]; then
        echo "WARN: 0[zero] GV values fetched from the Config Provider[$CP]"
      else
        echo "# GV values from $CP">>$BE_PROPS_FILE
        for prop in $prop_keys
        do
          echo "Prop: $prop"
          echo tibco.clientVar.${prop}=$(/home/tibco/be/configproviders/jq -r .\"$prop\" $JSON_FILE)>>$BE_PROPS_FILE
        done
      fi
    else
      echo "WARN: 0[zero] GV values fetched from the Config Provider[$CP]"
    fi

    # cleanup
    rm -f "${JSON_FILE}"
  else
    echo "INFO: Running Config Provider [${CP}]"
    ./configproviders/${CP}/run.sh
  fi

done
