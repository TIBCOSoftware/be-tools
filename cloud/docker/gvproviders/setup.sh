#!/bin/bash

# Setup the gv providers
if [[ $1 == *"consul"* ]]; then
  /home/tibco/be/gvproviders/consul/setup.sh
fi
 