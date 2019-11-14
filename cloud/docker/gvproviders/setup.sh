#!/bin/bash

# Setup the gv providers
if [[ $1 == *"consul"* ]]; then
  chmod +x /home/tibco/be/gvproviders/consul/*.sh
  /home/tibco/be/gvproviders/consul/setup.sh
fi
 