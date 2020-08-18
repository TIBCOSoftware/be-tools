#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#


echo "INFO: Reading GV values.."

BE_PROPS_FILE=/home/tibco/be/beprops_all.props
touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

if [[ -z "$HTTP_SERVER_URL" ]]; then
  echo "ERROR: Cannot read GVs from HTTP server.."
  echo "ERROR: Specify env variable HTTP_SERVER_URL"
  exit 1;
fi

echo "INFO: HTTP_SERVER_URL = $HTTP_SERVER_URL"

if [[ -z "$HEADER_VALUES" ]]; then
  echo "ERROR: Cannot read GVs from HTTP server.."
  echo "ERROR: Specify env variable HEADER_VALUES"
  exit 1;
fi


echo "INFO: HEADER_VALUES = $HEADER_VALUES"

echo "# GV values from HTTP server">>$BE_PROPS_FILE

declare -a HEADER_VALUE
IFS=","
for header in $HEADER_VALUES
do
  echo "Header: $header"
  HEADER_VALUE=("${HEADER_VALUE[@]}" -H)
  HEADER_VALUE=("${HEADER_VALUE[@]}" "${header//\"}")
done

unset IFS

curl -X GET "${HEADER_VALUE[@]}" $HTTP_SERVER_URL -o $JSON_FILE
