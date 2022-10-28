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

if [ -z "$CONJUR_LOGIN" ]; then
  echo "WARN: GV provider[conjur] is configured but env variable CONJUR_LOGIN is empty OR not supplied."
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

echo "{" >> $JSON_FILE

if [ $CONJUR_SECURE ]
then
    #Initialize the conjur cli
    conjur init -a $CONJUR_ACCOUNT -u $CONJUR_SERVER_URL -c /opt/tibco/be/ext/*
    
    #Authenticate to conjur
    conjur login -i $CONJUR_LOGIN -p $CONJUR_APIKEY
    
    #Fetch variable list
    variablelist=$(conjur list --kind variable)
    
    for variable in $(echo $variablelist | sed 's/[][]//g')
    do
        variable="${variable//\"}"         ##Remove "" myConjurAccount:variable:BotApp/secretVar,
        variable="${variable//,}"          ##Remove ,  myConjurAccount:variable:BotApp/IGNITE/DISCOVERY_URL
        variable=${variable##*:}           ##Get variable  BotApp/IGNITE/DISCOVERY_URL
        value=$(conjur variable get -i $variable)
        echo -e "  \"${variable#*/}\": \"$value\"," >> $JSON_FILE  #IGNITE/DISCOVERY_URL
    done
else
    #Initialize the conjur cli
    conjur --insecure init -a $CONJUR_ACCOUNT -u $CONJUR_SERVER_URL
    
    #Authenticate to conjur
    conjur --insecure login -i $CONJUR_LOGIN -p $CONJUR_APIKEY
    
    #Fetch variable list
    variablelist=$(conjur --insecure list --kind variable)
    
    for variable in $(echo $variablelist | sed 's/[][]//g')
    do
        variable="${variable//\"}"         ##Remove "" myConjurAccount:variable:BotApp/secretVar,
        variable="${variable//,}"          ##Remove ,  myConjurAccount:variable:BotApp/IGNITE/DISCOVERY_URL
        variable=${variable##*:}           ##Get variable  BotApp/IGNITE/DISCOVERY_URL
        value=$(conjur --insecure variable get -i $variable)
        echo -e "  \"${variable#*/}\": \"$value\"," >> $JSON_FILE  #IGNITE/DISCOVERY_URL
    done
fi

conjur logout

sed -i '$ s/.$//' $JSON_FILE
echo "}" >> $JSON_FILE
