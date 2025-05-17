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

    /home/tibco/be/configproviders/${CP}/run.sh

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
  elif [[ $CP = cm* ]] || [[ $CP = custom/cm* ]] ; then
    echo "INFO: Running Config Provider [${CP}]"
    TRA_FILE="bin/be-engine.tra"
    TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//')
    export PATH=$PATH:$TIB_JAVA_HOME/bin
    export CERTS_PATH=/opt/tibco/be/certstore
    export CERT_TRUSTSTORE=$CERTS_PATH/truststore.jks
    export CERT_KEYSTORE=$CERTS_PATH/keystore.jks
    export KEYSTORE_PASSPHRASE=password
    export TRUSTSTORE_PASSPHRASE=password
    ./configproviders/${CP}/run.sh
  else
    echo "INFO: Running Config Provider [${CP}]"
    ./configproviders/${CP}/run.sh
  fi

done
