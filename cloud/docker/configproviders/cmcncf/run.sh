#!/bin/bash

#
# Copyright (c) 2023. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

SECRETS_PATH=/opt/tibco/certs

if ! [ -d $CERTS_PATH ]; then
  echo "INFO: Creating trustfolder directory: $CERTS_PATH"
  mkdir -p $CERTS_PATH 
fi

key_store_certs_generation()
{

  oIFS="$IFS"; IFS=','; declare -a CNCF_SERVER_CERTs=($CNCF_SERVER_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate k8s secret names list
  CNCF_SRVR_CERT=( `for i in ${CNCF_SERVER_CERTs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#CNCF_SRVR_CERT[@]}"; i++ ));
  do    
    echo "INFO: Adding "${CNCF_SRVR_CERT[$i]}" Private keypair to keystore.jks"
    P12CERT=$SECRETS_PATH/${CNCF_SRVR_CERT[$i]}.p12
    
    # Convert the crt files to p12 and add it to cert_keystore
    openssl pkcs12 -inkey $SECRETS_PATH/${CNCF_SRVR_CERT[$i]}/tls.key -in $SECRETS_PATH/${CNCF_SRVR_CERT[$i]}/tls.crt -export -out $P12CERT -name ${CNCF_SRVR_CERT[$i]} -passin pass:$KEYSTORE_PASSPHRASE -passout pass:$KEYSTORE_PASSPHRASE -password pass:$KEYSTORE_PASSPHRASE
    keytool -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $KEYSTORE_PASSPHRASE -deststorepass $KEYSTORE_PASSPHRASE -srcalias ${CNCF_SRVR_CERT[$i]} -destalias ${CNCF_SRVR_CERT[$i]} -srckeypass $KEYSTORE_PASSPHRASE -destkeypass $KEYSTORE_PASSPHRASE -noprompt
    
    # Add ca root certificate to cert_keystore 
    keytool -keystore $CERT_KEYSTORE -alias CA-${CNCF_SRVR_CERT[$i]} -import -file $SECRETS_PATH/${CNCF_SRVR_CERT[$i]}/ca.crt -storepass $KEYSTORE_PASSPHRASE -keypass $KEYSTORE_PASSPHRASE -noprompt
    
    # Copy ca.crt file to certs_path
    cp $SECRETS_PATH/${CNCF_SRVR_CERT[$i]}/ca.crt $CERTS_PATH/ca-cncf-server-$i.crt
    
    # Delete download private and public certs
    rm -rf $P12CERT
  done
}

trust_store_certs_generation()
{

  oIFS="$IFS"; IFS=','; declare -a CNCF_CLIENT_CERTs=($CNCF_CLIENT_CERT); IFS="$oIFS"; unset oIFS

  #Remove duplicate k8s secret names list
  CNCF_CLNT_CERT=( `for i in ${CNCF_CLIENT_CERTs[@]}; do echo $i; done | sort -u` )

  for (( i=0; i < "${#CNCF_CLNT_CERT[@]}"; i++ ));
  do    
    echo "INFO: Adding "${CNCF_CLNT_CERT[$i]}" to truststore.jks"
    #Convert convert certs to p12 and jks, generate truststore jks 
    keytool -keystore $CERT_TRUSTSTORE -alias localhost-$i -import -file $SECRETS_PATH/${CNCF_CLNT_CERT[$i]}/tls.crt -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    
    # Add ca.crt to truststore jks
    keytool -keystore $CERT_TRUSTSTORE -alias CARoot-$i -import -file $SECRETS_PATH/${CNCF_CLNT_CERT[$i]}/ca.crt -storepass $TRUSTSTORE_PASSPHRASE -keypass $TRUSTSTORE_PASSPHRASE -noprompt
    # Copy ca.crt file to certs_path
    cp $SECRETS_PATH/${CNCF_CLIENT_CERT[$i]}/ca.crt $CERTS_PATH/ca-cncf-client-$i.crt
  done  
}

if [[ -z "$CNCF_SERVER_CERT" ]]; then
  echo "WARN: Config Provider[cmcnf] is configured but env variable CNCF_SERVER_CERT is empty OR not supplied."
  echo "WARN: Skip converting certificates to JKS"
else
  key_store_certs_generation
fi

if [[ -z "$CNCF_CLIENT_CERT" ]]; then
  echo "WARN: Config Provider[cmcnf] is configured but env variable CNCF_CLIENT_CERT is empty OR not supplied."
  echo "WARN: Skip converting certificates to JKS"
else
  trust_store_certs_generation
fi

