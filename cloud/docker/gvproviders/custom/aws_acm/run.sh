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
  echo "ERROR: Cannot read GVs from AWS certificate Manager.."
  echo "ERROR: Specify env variable AWS_ACCESS_KEY_ID"
  exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "ERROR: Cannot read GVs from AWS certificate Manager.."
  echo "ERROR: Specify env variable AWS_SECRET_ACCESS_KEY"
  exit 1
fi

if [[ -z "$AWS_SESSION_TOKEN" ]]; then
  echo "ERROR: Cannot read GVs from AWS certificate Manager.."
  echo "ERROR: Specify env variable AWS_SESSION_TOKEN"
  exit 1
fi

if [[ -z "$AWS_ACM_CLIENT_CERT_ARN" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CLIENT_CERT_ARN is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_SERVER_CERT_ARN" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CLIENT_CERT_ARN is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_CERT_AUTHORITY_ARN" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CERT_AUTHORITY_ARN is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_CLIENT_PASSPHRASE" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CLIENT_PASSPHRASE is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_SERVER_PASSPHRASE" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_SERVER_PASSPHRASE is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS certificate Manager."
  exit 0
fi

# configure aws cli
# PROFILE_NAME="beuser"
# printf "%s\n%s\n%s\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_DEFAULT_REGION" | aws configure 
# if [ ! -z "$AWS_ROLE_ARN" ]; then
#   aws configure set role_arn $AWS_ROLE_ARN 
#   aws configure set source_profile $PROFILE_NAME 
# fi

export AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY"
export AWS_SESSION_TOKEN="$AWS_SESSION_TOKEN"

if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    aws configure set aws_session_token $AWS_SESSION_TOKEN 
fi


passphraseFile=password.txt
serverpassphraseFile=serverpassword.txt
CERTS_PATH=/opt/tibco/be/certstore
mkdir -p $CERTS_PATH
cd $CERTS_PATH

# Set cert file names
SERVER_PUBLIC_CERT=serverpub.pem
CLIENT_PUBLIC_CERT=certificate.pem
CLIENT_FULL_CERT=fullcertificate.pem
CACERTIFICATE=CACertificate.pem
CLIENTP12=client.p12
CLIENT_KEYSTORE=client.keystore.jks
CLIENT_TRUSTSTORE=client.truststore.jks
SERVER_TRUSTSTORE=server.truststore.jks

# write passphrase to a file
printf "$AWS_ACM_CLIENT_PASSPHRASE" > $passphraseFile
printf "$AWS_ACM_SERVER_PASSPHRASE" > $serverpassphraseFile

# Download aws private ceritificate authority CA certificate
aws acm-pca get-certificate-authority-certificate --certificate-authority-arn $AWS_ACM_CERT_AUTHORITY_ARN  --output text > $CACERTIFICATE

#Download aws acm client certificate body and ceritifate chain
aws acm export-certificate --certificate-arn $AWS_ACM_CLIENT_CERT_ARN --passphrase fileb://$passphraseFile  | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)"' > $CLIENT_PUBLIC_CERT

#Download aws acm client private cert, certificate body and ceritifate chain
aws acm export-certificate --certificate-arn $AWS_ACM_CLIENT_CERT_ARN --passphrase fileb://$passphraseFile  | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)\(.PrivateKey)"' > $CLIENT_FULL_CERT

#Download aws acm server certificate body and ceritifate chain
aws acm export-certificate --certificate-arn $AWS_ACM_SERVER_CERT_ARN --passphrase fileb://$serverpassphraseFile  | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)"' > $SERVER_PUBLIC_CERT

#set JAVA bin path for keytool utility
TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
KEYTOOL_LOCATION=$TIB_JAVA_HOME/bin/keytool

# Convert downloaded acm certs to p12 and jks, generate client jks keystore using CAcert and acm certs
openssl pkcs12 -in $CLIENT_FULL_CERT -export -out $CLIENTP12 -name localhost -passin pass:$AWS_ACM_CLIENT_PASSPHRASE -passout pass:$AWS_ACM_CLIENT_PASSPHRASE -password  pass:$AWS_ACM_CLIENT_PASSPHRASE
$KEYTOOL_LOCATION -importkeystore -srckeystore $CLIENTP12 -srcstoretype PKCS12 -destkeystore $CLIENT_KEYSTORE -deststoretype PKCS12 -srcstorepass $AWS_ACM_CLIENT_PASSPHRASE -deststorepass $AWS_ACM_CLIENT_PASSPHRASE -srcalias localhost -destalias localhost -srckeypass $AWS_ACM_CLIENT_PASSPHRASE -destkeypass $AWS_ACM_CLIENT_PASSPHRASE -noprompt
$KEYTOOL_LOCATION -keystore $CLIENT_KEYSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_CLIENT_PASSPHRASE -keypass $AWS_ACM_CLIENT_PASSPHRASE -noprompt

#  generate client jks truststore using CAcert and acm certs
$KEYTOOL_LOCATION -keystore $CLIENT_TRUSTSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_CLIENT_PASSPHRASE -keypass $AWS_ACM_CLIENT_PASSPHRASE -noprompt
$KEYTOOL_LOCATION -keystore $CLIENT_TRUSTSTORE -alias localhost -import -file $CLIENT_PUBLIC_CERT -storepass $AWS_ACM_CLIENT_PASSPHRASE -keypass $AWS_ACM_CLIENT_PASSPHRASE -noprompt

##  generate server jks truststore using CAcert and acm certs
$KEYTOOL_LOCATION -keystore $SERVER_TRUSTSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_CLIENT_PASSPHRASE -keypass $AWS_ACM_CLIENT_PASSPHRASE -noprompt
$KEYTOOL_LOCATION -keystore $SERVER_TRUSTSTORE -alias localhost -import -file $SERVER_PUBLIC_CERT -storepass $AWS_ACM_SERVER_PASSPHRASE -keypass $AWS_ACM_SERVER_PASSPHRASE -noprompt

# Delete download private and public certs except CAroot cert
rm -rf $CLIENT_PUBLIC_CERT $SERVER_PUBLIC_CERT $CLIENT_FULL_CERT $passphraseFile $serverpassphraseFile $CLIENTP12