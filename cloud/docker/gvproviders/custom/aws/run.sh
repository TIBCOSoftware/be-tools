#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$AWS_SM_SECRET_ID" ]]; then
  echo "WARN: GV provider[custom/aws] is configured but env variable AWS_SM_SECRET_ID is empty OR not supplied."
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

touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

# configure aws cli
PROFILE_NAME="beuser"
printf "%s\n%s\n%s\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_DEFAULT_REGION" | aws configure --profile $PROFILE_NAME
if [ ! -z "$AWS_ROLE_ARN" ]; then
  aws configure set role_arn $AWS_ROLE_ARN --profile $PROFILE_NAME
  aws configure set source_profile $PROFILE_NAME --profile $PROFILE_NAME
fi

# Read GV values from AWS Secrets Manager into JSON_FILE
echo ""
echo "INFO: Reading GV values from AWS Secrets Manager.."
aws secretsmanager get-secret-value --secret-id $AWS_SM_SECRET_ID --output text --query 'SecretString' --profile $PROFILE_NAME >> $JSON_FILE

# Read GV values from AWS S3 into JSON_FILE
# echo ""
# echo "INFO: Reading GV values from AWS S3.."
# aws s3 cp $AWS_S3_FILE_URI $JSON_FILE --profile $PROFILE_NAME
