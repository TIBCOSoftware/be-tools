#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    echo "INFO Detected ECS environment. Loading AWS environment variables..."
    json=$(curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)
    AWS_ACCESS_KEY_ID=$(echo "$json" | /home/tibco/be/gvproviders/jq -r '.AccessKeyId')
    AWS_SECRET_ACCESS_KEY=$(echo "$json" | /home/tibco/be/gvproviders/jq -r '.SecretAccessKey')
    AWS_SESSION_TOKEN=$(echo "$json" | /home/tibco/be/gvproviders/jq -r '.Token')
    if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]] || [[ -z "$AWS_SESSION_TOKEN" ]]; then
      echo "ERROR Failed to load AWS environment variables. Make sure that ECS task configured correctly"
      exit 1
    fi
fi

if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "ERROR: Cannot read GVs from AWS certificate Manager.. Specify env variable AWS_ACCESS_KEY_ID"
  exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "ERROR: Cannot read GVs from AWS certificate Manager..Specify env variable AWS_SECRET_ACCESS_KEY"
  exit 1
fi

if [[ -z "$AWS_SESSION_TOKEN" ]]; then
  echo "ERROR: Cannot read GVs from AWS certificate Manager..Specify env variable AWS_SESSION_TOKEN"
  exit 1
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager..Specify env variable AWS_DEFAULT_REGION"
  exit 1
fi

if [[ -z "$AWS_ACM_CERT_AUTHORITY_ARN" ]]; then
  echo "Env variable AWS_ACM_CERT_AUTHORITY_ARN is empty OR not supplied.. Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

# Set AWS Credentials using export 
export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"
export AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION"

if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    aws configure set aws_session_token $AWS_SESSION_TOKEN 
fi

# Variables and set JAVA bin path for keytool utility
KEYSTORE_PHRASEFILE=password.txt
TRUSTSTORE_PHRASEFILE=password2.txt
CERTS_PATH=/opt/tibco/be/certstore
CERT_KEYSTORE=keystore.jks
CERT_TRUSTSTORE=truststore.jks
CACERTIFICATE=CACertificate.pem
TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
KEYTOOL_LOCATION=$TIB_JAVA_HOME/bin/keytool
mkdir -p $CERTS_PATH && cd $CERTS_PATH

# Download aws private ceritificate authority CA certificate
aws acm-pca get-certificate-authority-certificate --certificate-authority-arn $AWS_ACM_CERT_AUTHORITY_ARN  --output text > $CACERTIFICATE

key_store_certs_generation()
{
  if [[ -z "$AWS_ACM_KEYSTORE_PASSPHRASE" ]]; then
    echo "WARN: Env variable AWS_ACM_KEYSTORE_PASSPHRASE is empty OR not supplied.. Setting the passphrase 'password123' as default."
    AWS_ACM_KEYSTORE_PASSPHRASE=password
  fi
  printf "$AWS_ACM_KEYSTORE_PASSPHRASE" > $KEYSTORE_PHRASEFILE
  oIFS="$IFS"; IFS=','; declare -a AWS_ACM_KEYSTORE_ARNs=($AWS_ACM_KEYSTORE_ARN); IFS="$oIFS"; unset oIFS

  #Remove duplicate ARN's
  KEYSTORE_ARN=( `for i in ${AWS_ACM_KEYSTORE_ARNs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#KEYSTORE_ARN[@]}"; i++ ));
  do
    FULL_CERT=fullcertificate-$i.pem
    P12CERT=client-$i.p12

    #Download aws acm client private cert, certificate body and ceritifate chain
    echo "Downloading certs for arn : ${KEYSTORE_ARN[$i]}"
    aws acm export-certificate --certificate-arn ${KEYSTORE_ARN[$i]} --passphrase fileb://$KEYSTORE_PHRASEFILE  | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)\(.PrivateKey)"' > $FULL_CERT

    # Convert downloaded acm certs to p12 and jks, generate client jks keystore using CAcert and acm certs
    openssl pkcs12 -in $FULL_CERT -export -out $P12CERT -name localhost-$i -passin pass:$AWS_ACM_KEYSTORE_PASSPHRASE -passout pass:$AWS_ACM_KEYSTORE_PASSPHRASE -password  pass:$AWS_ACM_KEYSTORE_PASSPHRASE
    $KEYTOOL_LOCATION -importkeystore -srckeystore $P12CERT -srcstoretype PKCS12 -destkeystore $CERT_KEYSTORE -deststoretype PKCS12 -srcstorepass $AWS_ACM_KEYSTORE_PASSPHRASE -deststorepass $AWS_ACM_KEYSTORE_PASSPHRASE -srcalias localhost-$i -destalias localhost-$i -srckeypass $AWS_ACM_KEYSTORE_PASSPHRASE -destkeypass $AWS_ACM_KEYSTORE_PASSPHRASE -noprompt
    # # Delete download private and public certs except CAroot cert
    rm -rf $P12CERT $FULL_CERT
  done

  # Add CAroot cert to keystore jks
  $KEYTOOL_LOCATION -keystore $CERT_KEYSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_KEYSTORE_PASSPHRASE -keypass $AWS_ACM_KEYSTORE_PASSPHRASE -noprompt  
}

trust_store_certs_generation()
{
  if [[ -z "$AWS_ACM_TRUSTSTORE_PASSPHRASE" ]]; then
    echo "WARN: Env variable AWS_ACM_TRUSTSTORE_PASSPHRASE is empty OR not supplied.. Setting the passphrase 'password12' as default."
    AWS_ACM_TRUSTSTORE_PASSPHRASE=password
  fi  
  printf "$AWS_ACM_TRUSTSTORE_PASSPHRASE" > $TRUSTSTORE_PHRASEFILE
  oIFS="$IFS"; IFS=','; declare -a AWS_ACM_TRUSTSTORE_ARNs=($AWS_ACM_TRUSTSTORE_ARN); IFS="$oIFS"; unset oIFS

  #Remove duplicate ARN's
  TRUSTSTORE_ARN=( `for i in ${AWS_ACM_TRUSTSTORE_ARNs[@]}; do echo $i; done | sort -u` )
  
  for (( i=0; i < "${#TRUSTSTORE_ARN[@]}"; i++ ));
  do
    PUBLIC_CERT=certificate-$i.pem
    
    #Download aws acm client private cert, certificate body and ceritifate chain
    echo "Downloading certs for arn : ${TRUSTSTORE_ARN[$i]}"
    aws acm export-certificate --certificate-arn ${TRUSTSTORE_ARN[$i]} --passphrase fileb://$TRUSTSTORE_PHRASEFILE  | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)"' > $PUBLIC_CERT

    # Convert downloaded acm certs to p12 and jks, generate client jks keystore using CAcert and acm certs
    $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias localhost-$i -import -file $PUBLIC_CERT -storepass $AWS_ACM_TRUSTSTORE_PASSPHRASE -keypass $AWS_ACM_TRUSTSTORE_PASSPHRASE -noprompt
    
    # # Delete download private and public certs except CAroot cert
    rm -rf $PUBLIC_CERT
  done

  # Add CAroot cert to truststore jks
  $KEYTOOL_LOCATION -keystore $CERT_TRUSTSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_TRUSTSTORE_PASSPHRASE -keypass $AWS_ACM_TRUSTSTORE_PASSPHRASE -noprompt
}

if [[ -z "$AWS_ACM_KEYSTORE_ARN" ]]; then
  echo "WARN: Skip Downloading AWS_ACM_KEYSTORE_ARN server certificates from AWS certificate Manager."
else
  echo "Generate keystore certificates"
  key_store_certs_generation
fi

if [[ -z "$AWS_ACM_TRUSTSTORE_ARN" ]]; then
  echo "WARN: Skip Downloading AWS_ACM_TRUSTSTORE_ARN client certificates from AWS certificate Manager."
else
  echo "Generate truststore certificates"
  trust_store_certs_generation
fi

# remove unsed files
rm -rf $KEYSTORE_PHRASEFILE $TRUSTSTORE_PHRASEFILE
