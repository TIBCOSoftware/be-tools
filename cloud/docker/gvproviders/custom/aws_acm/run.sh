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


if [[ -z "$AWS_ACM_CERT_ARN" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CERT_ARN is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS Secrets Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_CERT_AUTHORITY_ARN" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_CERT_ARN is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS Secrets Manager."
  exit 0
fi

if [[ -z "$AWS_ACM_PASSPHRASE" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_ACM_PASSPHRASE is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS Secrets Manager."
  exit 0
fi


if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_ACCESS_KEY_ID"
  exit 1
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_SECRET_ACCESS_KEY"
  exit 1
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_DEFAULT_REGION"
  exit 1
fi

# configure aws cli
PROFILE_NAME="default"
printf "%s\n%s\n%s\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_DEFAULT_REGION" | aws configure --profile $PROFILE_NAME
if [ ! -z "$AWS_ROLE_ARN" ]; then
  aws configure set role_arn $AWS_ROLE_ARN --profile $PROFILE_NAME
  aws configure set source_profile $PROFILE_NAME --profile $PROFILE_NAME
fi

if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $PROFILE_NAME
fi


passphraseFile=password.txt
printf "$AWS_ACM_PASSPHRASE" > $passphraseFile
echo --$(cat $passphraseFile)--

# Set cert file names
PUBLIC_CERT=certificate.pem
FULL_CERT=fullcertificate.pem
CACERTIFICATE=CACertificate.pem
CLIENTP12=client.p12
CLIENT_KEYSTORE=client.keystore.jks
CLIENT_TRUSTSTORE=client.truststore.jks


# Download aws private ceritificate authority CA certificate
aws acm-pca get-certificate-authority-certificate --certificate-authority-arn $AWS_ACM_CERT_AUTHORITY_ARN --profile $PROFILE_NAME --output text > $CACERTIFICATE

#Download aws acm certificate body and ceritifate chain
aws acm export-certificate --certificate-arn $AWS_ACM_CERT_ARN --passphrase fileb://$passphraseFile --profile $PROFILE_NAME | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)"' > $PUBLIC_CERT

#Download aws acm private cert, certificate body and ceritifate chain
aws acm export-certificate --certificate-arn $AWS_ACM_CERT_ARN --passphrase fileb://$passphraseFile --profile $PROFILE_NAME | /home/tibco/be/gvproviders/jq -r '"\(.Certificate)\(.CertificateChain)\(.PrivateKey)"' > $FULL_CERT

#set JAVA bin path for keytool utility
TRA_FILE="bin/be-engine.tra"
TIB_JAVA_HOME=$(cat $BE_HOME/$TRA_FILE | grep ^tibco.env.TIB_JAVA_HOME | cut -d'=' -f 2 | sed -e 's/\r$//' )
TIB_JAVA_BIN=$TIB_JAVA_HOME/bin
echo $TIB_JAVA_BIN

# Convert downloaded acm certs to p12 and jks, generate jks keystore using CAcert and acm certs
openssl pkcs12 -in $FULL_CERT -export -out $CLIENTP12 -name localhost -passin pass:$AWS_ACM_PASSPHRASE -passout pass:$AWS_ACM_PASSPHRASE -password  pass:$AWS_ACM_PASSPHRASE
$TIB_JAVA_BIN/keytool -importkeystore -srckeystore $CLIENTP12 -srcstoretype PKCS12 -destkeystore $CLIENT_KEYSTORE -deststoretype PKCS12 -srcstorepass $AWS_ACM_PASSPHRASE -deststorepass $AWS_ACM_PASSPHRASE -srcalias localhost -destalias localhost -srckeypass $AWS_ACM_PASSPHRASE -destkeypass $AWS_ACM_PASSPHRASE -noprompt
$TIB_JAVA_BIN/keytool -keystore $CLIENT_KEYSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_PASSPHRASE -keypass $AWS_ACM_PASSPHRASE -noprompt


#  generate jks truststore using CAcert and acm certs
$TIB_JAVA_BIN/keytool -keystore $CLIENT_TRUSTSTORE -alias CARoot -import -file $CACERTIFICATE -storepass $AWS_ACM_PASSPHRASE -keypass $AWS_ACM_PASSPHRASE -noprompt
$TIB_JAVA_BIN/keytool -keystore $CLIENT_TRUSTSTORE -alias localhost -import -file $PUBLIC_CERT -storepass $AWS_ACM_PASSPHRASE -keypass $AWS_ACM_PASSPHRASE -noprompt


