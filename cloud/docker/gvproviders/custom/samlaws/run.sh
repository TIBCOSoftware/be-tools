#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ -z "$AWS_SM_SECRET_ID" ]]; then
  echo "WARN: GV provider[custom/samlaws] is configured but env variable AWS_SM_SECRET_ID is empty OR not supplied."
  echo "WARN: Skip fetching GV values from AWS Secrets Manager."
  exit 0
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_DEFAULT_REGION"
  exit 1
fi

if [[ -z "$SAML_IDP_URL" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable SAML_IDP_URL"
  exit 1
fi

if [[ -z "$SAML_USERNAME" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable SAML_USERNAME"
  exit 1
fi

if [[ -z "$SAML_PASSWORD" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable SAML_PASSWORD"
  exit 1
fi

touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

# configure aws cli with minimal credential file - which is required for samlapi.py
printf "%s\n%s\n%s\njson" " " " " "$AWS_DEFAULT_REGION" | aws configure

# programmatically get the SAML assertion and update aws credentials with profile name - "saml"
# reference: https://aws.amazon.com/blogs/security/how-to-implement-a-general-solution-for-federated-apicli-access-using-saml-2-0/
# reference: https://awsiammedia.s3.amazonaws.com/public/sample/SAMLAPICLIADFS/0192721658_1562696775_blogversion_samlapi_formauth_adfsv3mod_python3.py
/home/tibco/be/gvproviders/custom/samlaws/samlapi.py

# Read GV values from AWS Secrets Manager into JSON_FILE
PROFILE_NAME="saml"
echo ""
echo "INFO: Reading GV values from AWS Secrets Manager.."
aws secretsmanager get-secret-value --secret-id $AWS_SM_SECRET_ID --output text --query 'SecretString' --profile $PROFILE_NAME >> $JSON_FILE

# Read GV values from AWS S3 into JSON_FILE
# echo ""
# echo "INFO: Reading GV values from AWS S3.."
# aws s3 cp $AWS_S3_FILE_URI $JSON_FILE --profile $PROFILE_NAME
