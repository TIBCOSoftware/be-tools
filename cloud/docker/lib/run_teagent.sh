#!/bin/bash
#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ "$9" == "AWS_ECS_FARGATE"  || "$9" == "AWS_ECS_EC2" ]]; then
  if [[ ! -z "$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI" ]]; then
    json=$(curl 169.254.170.2$AWS_CONTAINER_CREDENTIALS_RELATIVE_URI)
    AWS_ACCESS_KEY_ID=$(echo "$json" | jq -r '.AccessKeyId')
    AWS_SECRET_ACCESS_KEY=$(echo "$json" | jq -r '.SecretAccessKey')
    AWS_SESSION_TOKEN=$(echo "$json" | jq -r '.Token')
  
    if [[ -z "$AWS_ACCESS_KEY_ID" ]] || [[ -z "$AWS_SECRET_ACCESS_KEY" ]] || [[ -z "$AWS_SESSION_TOKEN" ]]; then
      echo "ERROR Failed to load AWS environment variables. Make sure that ECS task configured correctly"
      exit 1
    fi
  fi

  aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID" \
  && aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY" \
  && aws configure set default.region ${10} \
  && aws configure set default.output ${11}
  aws configure set aws_session_token $AWS_SESSION_TOKEN

  if [[ "$9" == "AWS_ECS_FARGATE" ]]; then
      launchType="FARGATE"
  elif [[ "$9" == "AWS_ECS_EC2" ]]; then
      launchType="EC2"
  fi    

  nohup python3 be_docker_container_discovery_aws_ecs.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -c $8 -lt $launchType > discovery.logs 2>&1 &
elif [[ "$9" == "k8s" ]]; then
  nohup python3 be_docker_container_discovery_k8s.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -ta $8 > discovery.logs 2>&1 &
fi
$1/teagent/bin/be-teagent --propFile $2