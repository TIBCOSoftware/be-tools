#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#
 
if [[ "$9" == "aws"  || "$9" == "fargate" ]]; then
  aws configure set aws_access_key_id ${10} \
  && aws configure set aws_secret_access_key ${11} \
  && aws configure set default.region ${12} \
  && aws configure set default.output ${13}
fi

if [[ "$9" == "aws" ]]; then
  AWS_CONFIG_FILE="/root/.aws/config"
  echo "role_arn = ${14}" >> $AWS_CONFIG_FILE
  echo "source_profile=default" >>$AWS_CONFIG_FILE

  nohup python3 be_docker_container_discovery_aws.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -s $8 > discovery.logs 2>&1 &
elif [[ "$9" == "fargate" ]]; then
  nohup python3 be_docker_container_discovery_fargate.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -c $8 > discovery.logs 2>&1 &
elif [[ "$9" == "k8s" ]]; then
  nohup python3 be_docker_container_discovery_k8s.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -ta $8 > discovery.logs 2>&1 &
fi

$1/teagent/bin/be-teagent --propFile $2
