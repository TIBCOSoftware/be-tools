#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Its value gets updated during image build time
GVPROVIDER=na

if [ $GVPROVIDER = na ]
then
  # gv provider is not configured.
  exit 0
fi

echo "INFO: Reading GV values from [${GVPROVIDER}]"

oIFS="$IFS"; IFS=','; declare -a GVs=($GVPROVIDER); IFS="$oIFS"; unset oIFS

# invoke provider specific runs
for GV in "${GVs[@]}"
do

  ./gvproviders/${GV}/run.sh

  BE_PROPS_FILE=/home/tibco/be/beprops_all.props
  JSON_FILE=/home/tibco/be/gvproviders/output.json

  if [ -f $JSON_FILE ]; then
    prop_keys="$(/home/tibco/be/gvproviders/jq -r keys[] $JSON_FILE)"
    if [ -z "$prop_keys" ]; then
      echo "WARN: 0[zero] GV values fetched from the GV provider[$GV]"
    else
      echo "# GV values from $GV">>$BE_PROPS_FILE
      for prop in $prop_keys
      do
        echo "Prop: $prop"
        echo tibco.clientVar.${prop}=$(/home/tibco/be/gvproviders/jq -r .\"$prop\" $JSON_FILE)>>$BE_PROPS_FILE
      done
    fi
  else
    echo "WARN: 0[zero] GV values fetched from the GV provider[$GV]"
  fi

  # cleanup
  rm -f "${JSON_FILE}"

done

TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//')
KEYTOOL_LOCATION=$TIB_JAVA_HOME/bin/keytool
CERTS_PATH=/opt/tibco/be/certstore
CERT_TRUSTSTORE=$CERTS_PATH/truststore.jks
CERT_KEYSTORE=$CERTS_PATH/keystore.jks
KEYSTORE_PASSPHRASE=password
TRUSTSTORE_PASSPHRASE=password
CAROOT=prod-root.pem
SECRETS_PATH=/opt/tibco/certs
mkdir -p $CERTS_PATH
echo "123"
if [ -d $SECRETS_PATH ]; then

  cd $SECRETS_PATH
  CERT_SECRETS_LIST="$(ls -d */ | tr -d '/')"
  SECRETS_LIST=($CERT_SECRETS_LIST)
  echo ${#SECRETS_LIST[@]}
  for SECRET_LIST in ${SECRETS_LIST[@]}
  do
    CA_AND_PUB_CERT=$CERTS_PATH/ca-tls-${SECRET_LIST}.crt
    if [ -f "${SECRET_LIST}/tls.key" -a -f "${SECRET_LIST}/tls.crt" ]; then
      echo "Adding "${SECRET_LIST}" Private keypair to Keystore.jks"
      P12CERT=${SECRET_LIST}.p12
      cat ${SECRET_LIST}/tls.crt ${SECRET_LIST}/ca.crt > $CA_AND_PUB_CERT
      openssl pkcs12 -inkey ${SECRET_LIST}/tls.key -in $CA_AND_PUB_CERT -export -out $P12CERT -name ${SECRET_LIST} -passin pass:$KEYSTORE_PASSPHRASE -passout pass:$KEYSTORE_PASSPHRASE -password pass:$KEYSTORE_PASSPHRASE
      $KEYTOOL_LOCATION -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSPHRASE -deststorepass $KEYSTORE_PASSPHRASE -srcalias ${SECRET_LIST} -destalias ${SECRET_LIST} -srckeypass $KEYSTORE_PASSPHRASE -destkeypass $KEYSTORE_PASSPHRASE -noprompt
      $KEYTOOL_LOCATION -keystore $CERT_KEYSTORE -alias CA-${SECRET_LIST} -import -file ${SECRET_LIST}/ca.crt -storepass $KEYSTORE_PASSPHRASE -keypass $KEYSTORE_PASSPHRASE -noprompt
    elif [ -f "${SECRET_LIST}/tls.crt" ]; then
      echo "Adding "${SECRET_LIST}" public cert to TrustStore.jks"
      cat ${SECRET_LIST}/tls.crt ${SECRET_LIST}/ca.crt > $CA_AND_PUB_CERT
      $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias ${SECRET_LIST} -import -file $CA_AND_PUB_CERT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
      $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias CA-${SECRET_LIST} -import -file ${SECRET_LIST}/ca.crt -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    fi
      # rm -rf $CA_AND_PUB_CERT  
  done
  # rm -rf *.p12
fi