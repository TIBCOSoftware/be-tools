#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$GCP_SERVICEACCOUNT_ID" ]]; then
  echo "ERROR: Cannot read GVs from GCP Certificate authority service.. Specify env variable GCP_SERVICEACCOUNT_ID"
  exit 1
fi

if [[ -z "$GCP_SERVICEACCOUNT_KEYFILE_PATH" ]]; then
  echo "ERROR: Cannot read GVs from GCP Certificate authority service.. Specify env variable GCP_SERVICEACCOUNT_KEYFILE_PATH"
  exit 1
fi

if [[ -z "$GCP_PROJECT_ID" ]]; then
  echo "ERROR: Cannot read GVs from GCP Certificate authority service.. Specify env variable GCP_PROJECT_ID"
  exit 1
fi

if [[ -z "$GCP_LOCATION" ]]; then
  echo "ERROR: Cannot read GVs from GCP Certificate authority service.. Specify env variable GCP_LOCATION"
  exit 1
fi


# GCLOUD_CLI_PATH=gcloud
GCLOUD_CLI_PATH=/home/tibco/be/gvproviders/custom/gcp-cas/google-cloud-sdk/bin/gcloud

# Authenticate gcloud account and configure project
$GCLOUD_CLI_PATH auth activate-service-account $GCP_SERVICEACCOUNT_ID --key-file=$GCP_SERVICEACCOUNT_KEYFILE_PATH
$GCLOUD_CLI_PATH config set project $GCP_PROJECT_ID

# CERTS_PATH=certs
CERTS_PATH=/opt/tibco/be/certstore
TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//')
KEYTOOL_LOCATION=$TIB_JAVA_HOME/bin/keytool
CERT_TRUSTSTORE=truststore.jks
CERT_KEYSTORE=keystore.jks
KEYSTORE_PASSPHRASE=password
TRUSTSTORE_PASSPHRASE=password
CAROOT=prod-root.pem
mkdir -p $CERTS_PATH && cd $CERTS_PATH

trust_store_certs_generation() {

  oIFS="$IFS"
  IFS=','
  declare -a GCP_CAS_CERTIFICATESs=($GCP_CAS_CERTIFICATES)
  IFS="$oIFS"
  unset oIFS

  #Remove duplicate certs list
  TRUSTSTORE_CERT_IDS=($(for i in ${GCP_CAS_CERTIFICATESs[@]}; do echo $i; done | sort -u))

  for ((i = 0; i < "${#TRUSTSTORE_CERT_IDS[@]}"; i++)); do
    PUBLIC_CERT=${TRUSTSTORE_CERT_IDS[$i]}-pub.pem
    P12CERT=${TRUSTSTORE_CERT_IDS[$i]}.p12
    echo "Downloading cert for : ${TRUSTSTORE_CERT_IDS[$i]}"
    $GCLOUD_CLI_PATH privateca certificates export ${TRUSTSTORE_CERT_IDS[$i]} --issuer-pool=$GCP_CAS_CERTIFICATE_POOL --issuer-location=$GCP_LOCATION --include-chain --output-file=$PUBLIC_CERT

    # # Convert downloaded gcp certs to p12 and jks, generate client jks keystore using CAcert and gcp certs
    $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias localhost-$i -import -file $PUBLIC_CERT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt

    if [[ -z "$GCP_PVT_CERTIFICATE_PATH" ]]; then
      echo "Warn: Private certs path not specified.., Specify env variable GCP_PVT_CERTIFICATE_PATH"
    else
      PRIVATE_CERT=$GCP_PVT_CERTIFICATE_PATH/${TRUSTSTORE_CERT_IDS[$i]}.private.pem
      if [ -f "$PRIVATE_CERT" ] && [ -f "$PUBLIC_CERT" ]; then
        echo "converting keystore certs"
        openssl pkcs12 -inkey $PRIVATE_CERT -in $PUBLIC_CERT -export -out $P12CERT -name localhost-$i -passin pass:$KEYSTORE_PASSPHRASE -passout pass:$KEYSTORE_PASSPHRASE -password pass:$KEYSTORE_PASSPHRASE
        $KEYTOOL_LOCATION -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSPHRASE -deststorepass $KEYSTORE_PASSPHRASE -srcalias localhost-$i -destalias localhost-$i -srckeypass $KEYSTORE_PASSPHRASE -destkeypass $KEYSTORE_PASSPHRASE -noprompt
      fi
    fi
  done

  if [[ -z "$GCP_CAS_ROOT_CERTIFICATE" ]]; then
    echo "WARN: env variable GCP_CAS_ROOT_CERTIFICATE not specified for gv-provider:gcp-cas.. Specify env variable GCP_CAS_ROOT_CERTIFICATE"
  else
    $GCLOUD_CLI_PATH privateca roots describe $GCP_CAS_ROOT_CERTIFICATE --location=$GCP_LOCATION --pool=$GCP_CAS_CERTIFICATE_POOL --format="value(pemCaCertificates)" >$CAROOT
    echo "Adding CARoot to truststore.jks"
    $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias CARoot -import -file $CAROOT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt

    if [ -f $CERT_KEYSTORE ]; then
      echo "Adding CARoot to keystore.jks"
      $KEYTOOL_LOCATION -keystore $CERT_KEYSTORE -alias CARoot -import -file $CAROOT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    fi
  fi
}

if [[ -z "$GCP_CAS_CERTIFICATES" ]] & [[ -z "$GCP_CAS_CERTIFICATE_POOL" ]]; then
  echo "WARN: env variable any of GCP_CAS_CERTIFICATES or GCP_CAS_CERTIFICATE_POOL not specified for gv-provider:gcp-cas... Specify both env variables GCP_CAS_CERTIFICATES and GCP_CAS_CERTIFICATE_POOL"
else
  echo "-----download pem certs and converting to truststore jks certificcates-----"
  trust_store_certs_generation
fi

rm -rf *-pub.pem *.p12
