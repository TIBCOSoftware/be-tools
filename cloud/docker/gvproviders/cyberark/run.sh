#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

echo "Configuring Conjur"

if [ -z "$CONJUR_SERVER_URL" ]; then
  echo "WARN: GV provider[conjur] is configured but env variable CONJUR_SERVER_URL is empty OR not supplied."
  echo "WARN: Skip fetching GV values from Conjur."
  exit 0
fi

if [ -z "$CONJUR_ACCOUNT" ]; then
  echo "WARN: GV provider[conjur] is configured but env variable CONJUR_ACCOUNT is empty OR not supplied."
  echo "WARN: Skip fetching GV values from Conjur."
  exit 0
fi

if [ -z "$CONJUR_LOGINNAME" ]; then
  echo "WARN: GV provider[conjur] is configured but env variable CONJUR_LOGINNAME is empty OR not supplied."
  echo "WARN: Skip fetching GV values from Conjur."
  exit 0
fi

if [ -z "$CONJUR_APIKEY" ]; then
  echo "WARN: GV provider[conjur] is configured but env variable CONJUR_APIKEY is empty OR not supplied."
  echo "WARN: Skip fetching GV values from Conjur."
  exit 0
fi

touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

cnjrcmd=conjur
if [ $CONJUR_SECURE ]
then
    #Initialize the conjur cli
    conjur init -a $CONJUR_ACCOUNT -u $CONJUR_SERVER_URL -c /opt/tibco/be/ext/*
else
    #Initialize the conjur cli
    conjur --insecure init -a $CONJUR_ACCOUNT -u $CONJUR_SERVER_URL          
    cnjrcmd+=" --insecure "
fi

#Authenticate to conjur
$cnjrcmd login -i $CONJUR_LOGINNAME -p $CONJUR_APIKEY

#Fetch variable list
variablelist=$($cnjrcmd list --kind variable)
command="$cnjrcmd variable get -i " 

for variable in $(echo $variablelist | sed 's/[][]//g' | sed 's/,//g')
do
  variable=$(echo $variable | sed -r 's/.*variable:(.*)\"/\1/g' );
  command+="$variable ";
done

$command > $JSON_FILE

conjur logout
