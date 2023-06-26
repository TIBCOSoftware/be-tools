#!/bin/bash

#
# Copyright (c) 2023. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$AZ_CLIENT_ID" ]]; then
  echo "ERROR: Cannot read certificates from Azure Key Vault."
  echo "ERROR: Specify env variable AZ_CLIENT_ID"
  exit 1
fi

if [[ -z "$AZ_CLIENT_PASSWORD" ]]; then
  echo "ERROR: Cannot read certificates from Azure Key Vault."
  echo "ERROR: Specify env variable AZ_CLIENT_PASSWORD"
  exit 1
fi

if [[ -z "$AZ_TENANT_ID" ]]; then
  echo "ERROR: Cannot read certificates from Azure Key Vault."
  echo "ERROR: Specify env variable AZ_TENANT_ID"
  exit 1
fi

if [[ -z "$AZ_KV_NAME" ]]; then
  echo "ERROR: Cannot read certificates from Azure Key Vault."
  echo "ERROR: Specify env variable AZ_KV_NAME"
  exit 1
fi

#Login to Azure using service principal
az login --service-principal -u $AZ_CLIENT_ID -p $AZ_CLIENT_PASSWORD --tenant $AZ_TENANT_ID

if ! [ -d $CERTS_PATH ]; then
  echo "INFO: Creating $CERTS_PATH directory"
  mkdir -p $CERTS_PATH 
fi

generate_key_store_certs(){

  oIFS="$IFS"; IFS=','; declare -a AZ_KV_KEYSTORE_CERTs=($AZ_KV_KEYSTORE_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate cert names's
  KEYSTORE_CERT=( `for i in ${AZ_KV_KEYSTORE_CERTs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#KEYSTORE_CERT[@]}"; i++ ));
  do
    FULL_CERT=$SECRETS_PATH/fullcertificate-$i.pfx
    P12CERT=$SECRETS_PATH/client-$i.p12

    #Download azure client private cert, certificate body and ceritifate chain
    echo "INFO: Downloading certs : ${KEYSTORE_CERT[$i]}"
    az keyvault secret download --file $FULL_CERT --name ${KEYSTORE_CERT[$i]} --vault-name $AZ_KV_NAME

    # Convert downloaded azure certs to p12 and jks, generate client jks keystore using CAcert and azure certs
    openssl pkcs12 -in $FULL_CERT -export -out $P12CERT -name azure-$i -passin pass:$KEYSTORE_PASSPHRASE -passout pass:$KEYSTORE_PASSPHRASE -password  pass:$KEYSTORE_PASSPHRASE
    keytool -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSPHRASE -deststorepass $KEYSTORE_PASSPHRASE -srcalias azure-$i -destalias azure-$i -srckeypass $KEYSTORE_PASSPHRASE -destkeypass $KEYSTORE_PASSPHRASE -noprompt
    
    # # Delete download private and public certs except CAroot cert
    rm -rf $P12CERT $FULL_CERT
  done

}

generate_trust_store_certs(){

  oIFS="$IFS"; IFS=','; declare -a AZ_KV_TRUSTSTORE_CERTs=($AZ_KV_TRUSTSTORE_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate cert names's
  TRUSTSTORE_CERT=( `for i in ${AZ_KV_TRUSTSTORE_CERTs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#TRUSTSTORE_CERT[@]}"; i++ ));
  do
    PUBLIC_CERT=$SECRETS_PATH/certificate-$i.pem
    
    #Download  azure client private cert, certificate body and ceritifate chain
    echo "INFO: Downloading certs : ${TRUSTSTORE_CERT[$i]}"
    az keyvault certificate download --file $PUBLIC_CERT --name ${TRUSTSTORE_CERT[$i]} --vault-name $AZ_KV_NAME

    # Convert downloaded azure certs to p12 and jks, generate client jks keystore using CAcert and azure certs
    keytool -keystore $CERT_TRUSTSTORE -alias azure-$i -import -file $PUBLIC_CERT -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    cp $PUBLIC_CERT $CERTS_PATH/ca-certificate-$i.pem
    
    # Delete download private and public certs except CAroot cert
    rm -rf $PUBLIC_CERT
  done

}

if [[ -z "$AZ_KV_KEYSTORE_CERT" ]]; then
  echo "WARN: Config Provider[custom/cmazure] is configured but env variable AZ_KV_KEYSTORE_CERT is empty OR not supplied."
  echo "WARN: Skip fetching certificates from Azure Key Vault."
else
  generate_key_store_certs
fi

if [[ -z "$AZ_KV_TRUSTSTORE_CERT" ]]; then
  echo "WARN: Config Provider[custom/cmazure] is configured but env variable AZ_KV_TRUSTSTORE_CERT is empty OR not supplied."
  echo "WARN: Skip fetching certificates from Azure Key Vault."
else
  generate_trust_store_certs
fi

# Safe to logout
az logout

