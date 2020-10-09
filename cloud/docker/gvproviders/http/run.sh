#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$GVP_HTTP_SERVER_URL" ]]; then
  return 0;
fi

echo "INFO: Reading GV values from HTTP server.."

BE_PROPS_FILE=/home/tibco/be/beprops_all.props
touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

# if [[ -z "$GVP_HTTP_SERVER_URL" ]]; then
#   echo "ERROR: Cannot read GVs from HTTP server.."
#   echo "ERROR: Specify env variable GVP_HTTP_SERVER_URL"
#   exit 1;
# fi

echo "INFO: GVP_HTTP_SERVER_URL = $GVP_HTTP_SERVER_URL"

if [[ -z "$GVP_HTTP_HEADERS" ]]; then
  echo "ERROR: Cannot read GVs from HTTP server.."
  echo "ERROR: Specify env variable GVP_HTTP_HEADERS"
  exit 1;
fi


echo "INFO: GVP_HTTP_HEADERS = $GVP_HTTP_HEADERS"

echo "# GV values from HTTP server">>$BE_PROPS_FILE

declare -a HEADER_VALUE
IFS=","
for header in $GVP_HTTP_HEADERS
do
  echo "Header: $header"
  HEADER_VALUE=("${HEADER_VALUE[@]}" -H)
  HEADER_VALUE=("${HEADER_VALUE[@]}" "${header//\"}")
done

unset IFS

curl -X GET "${HEADER_VALUE[@]}" $GVP_HTTP_SERVER_URL -o $JSON_FILE
