#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$GVP_HTTP_SERVER_URL" ]]; then
  echo "WARN: GV provider[http] is configured but env variable GVP_HTTP_SERVER_URL is empty OR not supplied."
  echo "WARN: Skip fetching GV values from http end-store."
  exit 0
fi

touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

echo "INFO: GVP_HTTP_SERVER_URL = $GVP_HTTP_SERVER_URL"

declare -a HEADER_VALUE

if [[ -z "$GVP_HTTP_HEADERS" ]]; then
  echo "ERROR: GVP_HTTP_HEADERS not specified."
else
  echo "INFO: GVP_HTTP_HEADERS = $GVP_HTTP_HEADERS"

  IFS=","
  for header in $GVP_HTTP_HEADERS
  do
    echo "Header: $header"
    HEADER_VALUE=("${HEADER_VALUE[@]}" -H)
    HEADER_VALUE=("${HEADER_VALUE[@]}" "${header//\"}")
  done

  unset IFS
fi

curl -X GET "${HEADER_VALUE[@]}" $GVP_HTTP_SERVER_URL -o $JSON_FILE
