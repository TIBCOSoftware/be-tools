#!/bin/bash
  if [[ "$9" == "aws" ]]; then
	nohup python be_docker_container_discovery_aws.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -s $8 > discovery.logs 2>&1 &
  elif [[ "$9" == "k8s" ]]; then
	nohup python be_docker_container_discovery_k8s.py  -t $3 -u $4 -p $5 -py $6 -pi $7 -ta $8 > discovery.logs 2>&1 &
  fi

$1/teagent/bin/be-teagent --propFile $2




