#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

echo "INFO: Reading GV values from Consul.."

BE_PROPS_FILE=/home/tibco/be/beprops_all.props
if [[ -z "$APP_CONFIG_PROFILE" ]]; then
  APP_CONFIG_PROFILE=default
fi

if [[ -z "$BE_APP_NAME" ]]; then
  echo "ERROR: Cannot read GVs from Consul.."
  echo "ERROR: Specify env variable BE_APP_NAME, when specifying CONSUL_SERVER_URL."
  exit 1;
fi

echo "INFO: CONSUL_SERVER_URL = $CONSUL_SERVER_URL"
echo "INFO: BE_APP_NAME = $BE_APP_NAME"
echo "INFO: APP_CONFIG_PROFILE = $APP_CONFIG_PROFILE"

# skip prefix ($BE_APP_NAME/$APP_CONFIG_PROFILE/) from key
prefix_len=${#BE_APP_NAME}
prefix_len=$((prefix_len + 1))
prefix_len=$((prefix_len + ${#APP_CONFIG_PROFILE}))
prefix_len=$((prefix_len + 1))

echo "INFO: Reading GV values from Consul.. ($BE_APP_NAME/$APP_CONFIG_PROFILE/)"
echo "# GV values from Consul">>$BE_PROPS_FILE
prop_keys="$(/home/tibco/be/gvproviders/consul/consul kv export -http-addr=$CONSUL_SERVER_URL $BE_APP_NAME/$APP_CONFIG_PROFILE | /home/tibco/be/gvproviders/consul/jq -r '.[] | .key')";
for prop in $prop_keys
do
  echo tibco.clientVar.${prop:prefix_len}=$(/home/tibco/be/gvproviders/consul/consul kv get -http-addr=$CONSUL_SERVER_URL $prop)>>$BE_PROPS_FILE
done
echo ""
 
