#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#


echo "Setting up consul gv provider.."

cd /home/tibco/be/gvproviders/consul

apt-get install -y wget

# Download jq.
wget "https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64"
mv jq-linux64 jq
chmod +x jq

# Download consul cli and extract it.
wget "https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip"
unzip consul_1.6.1_linux_amd64.zip
rm consul_1.6.1_linux_amd64.zip
 
