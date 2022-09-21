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
PROFILE_NAME="beuser"
printf "%s\n%s\n%s\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_DEFAULT_REGION" | aws configure --profile $PROFILE_NAME
if [ ! -z "$AWS_ROLE_ARN" ]; then
  aws configure set role_arn $AWS_ROLE_ARN --profile $PROFILE_NAME
  aws configure set source_profile $PROFILE_NAME --profile $PROFILE_NAME
fi

if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $PROFILE_NAME
fi


# AWS_ACM_CERT_ARN=arn:aws:acm:us-east-1:565268196457:certificate/6998d9be-5a96-4f85-957f-efe57274da09
# AWS_ACM_PASSPHRASE=test1234
passphraseFile=password.txt
echo $AWS_ACM_PASSPHRASE > $passphraseFile
cert_array=("PrivateKey" "CertificateChain" "Certificate")

# Downloading certificates form aws acm 
for (( i=0; i < "${#cert_array[@]}"; i ++ ));
do
  echo "Downloading : ${cert_array[$i]}"
  eval cert_arr='.${cert_array[$i]}' ;
  aws acm export-certificate --certificate-arn $AWS_ACM_CERT_ARN  --passphrase fileb://$passphraseFile --profile $PROFILE_NAME | /home/tibco/be/gvproviders/jq -r ${cert_arr} > ${cert_array[$i]}.txt
done