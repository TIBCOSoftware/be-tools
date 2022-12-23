#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#


if [[ -z "$AZ_CLIENT_ID" ]]; then
  echo "ERROR: Cannot read GVs from Azure key vault.. Specify env variable AZ_CLIENT_ID"
  exit 1
fi

if [[ -z "$AZ_CLIENT_PASSWORD" ]]; then
  echo "ERROR: Cannot read GVs from Azure key vault..Specify env variable AZ_CLIENT_PASSWORD"
  exit 1
fi

if [[ -z "$AZ_TENANT_ID" ]]; then
  echo "ERROR: Cannot read GVs from Azure key vault..Specify env variable AZ_TENANT_ID"
  exit 1
fi

#Login to Azure using service principal
az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_PASSWORD --tenant $AZ_TENANT_ID


# Variables and set JAVA bin path for keytool utility
# CERTS_PATH=certs
CERTS_PATH=/opt/tibco/be/certstore
KEYSTORE_PASSPHRASE=password
TRUSTSTORE_PASSPHRASE=password
CERT_KEYSTORE=keystore.jks
CERT_TRUSTSTORE=truststore.jks
CACERTIFICATE=CACertificate.pem
TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
KEYTOOL_LOCATION=$TIB_JAVA_HOME/bin/keytool
mkdir -p $CERTS_PATH && cd $CERTS_PATH



# az keyvault secret download --file b.pem --name beapps --vault-name lnhyd
# az keyvault certificate download --file cert-1.pem --name beproject --vault-name lnhyd 

key_store_certs_generation(){

  oIFS="$IFS"; IFS=','; declare -a AZ_KV_SERVER_CERTs=($AZ_KV_SERVER_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate cert names's
  KEYSTORE_CERT=( `for i in ${AZ_KV_SERVER_CERTs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#KEYSTORE_CERT[@]}"; i++ ));
  do
    FULL_CERT=fullcertificate-$i.pfx
    P12CERT=client-$i.p12

    #Download azure client private cert, certificate body and ceritifate chain
    echo "Downloading certs : ${KEYSTORE_CERT[$i]}"
    az keyvault secret download --file $FULL_CERT --name ${KEYSTORE_CERT[$i]} --vault-name $AZ_KV_NAME

    # Convert downloaded azure certs to p12 and jks, generate client jks keystore using CAcert and azure certs
    openssl pkcs12 -in $FULL_CERT -export -out $P12CERT -name localhost-$i -passin pass:$KEYSTORE_PASSPHRASE -passout pass:$KEYSTORE_PASSPHRASE -password  pass:$KEYSTORE_PASSPHRASE
    $KEYTOOL_LOCATION -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSPHRASE -deststorepass $KEYSTORE_PASSPHRASE -srcalias localhost-$i -destalias localhost-$i -srckeypass $KEYSTORE_PASSPHRASE -destkeypass $KEYSTORE_PASSPHRASE -noprompt
    # # Delete download private and public certs except CAroot cert
    rm -rf $P12CERT $FULL_CERT
  done

}

trust_store_certs_generation(){

  oIFS="$IFS"; IFS=','; declare -a AZ_KV_CLIENT_CERTs=($AZ_KV_CLIENT_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate cert names's
  TRUSTSTORE_CERT=( `for i in ${AZ_KV_CLIENT_CERTs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#TRUSTSTORE_CERT[@]}"; i++ ));
  do
    PUBLIC_CERT=certificate-$i.pem
    
    #Download  azure client private cert, certificate body and ceritifate chain
    echo "Downloading certs for cert names : ${TRUSTSTORE_CERT[$i]}"
    az keyvault certificate download --file $PUBLIC_CERT --name ${TRUSTSTORE_CERT[$i]} --vault-name $AZ_KV_NAME

    # Convert downloaded azure certs to p12 and jks, generate client jks keystore using CAcert and azure certs
    $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias localhost-$i -import -file $PUBLIC_CERT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    
    # Delete download private and public certs except CAroot cert
    rm -rf $PUBLIC_CERT
  done

}

if [[ -z "$AZ_KV_SERVER_CERT" ]]; then
  echo "WARN: Skip Downloading AZ_KV_SERVER_CERT server certificates from Azure key vault."
else
  echo "Generate keystore certificates"
  key_store_certs_generation
fi

if [[ -z "$AZ_KV_CLIENT_CERT" ]]; then
  echo "WARN: Skip Downloading AZ_KV_CLIENT_CERT client certificates from Azure key vault."
else
  echo "Generate truststore certificates"
  trust_store_certs_generation
fi

# Safe to logout
az logout







