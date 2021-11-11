#!/bin/bash
#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

if [[ "$9" == "AWS_ECS_FARGATE"  || "$9" == "AWS_ECS_EC2" ]]; then

  aws configure set default.region ${10} \
  && aws configure set default.output ${11}\

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