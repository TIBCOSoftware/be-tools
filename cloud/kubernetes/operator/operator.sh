#!/bin/bash

mkdir operator
cd operator
operator-sdk init --plugins=helm --domain be.tibco.com
operator-sdk create api       --helm-chart=../helm     --helm-chart-version=1.0.0 --verbose

make install
export IMG=<reponame>/ops:0.1
make docker-build docker-push IMG=$IMG
make deploy IMG=$IMG
kubectl get deployments -n operator-system