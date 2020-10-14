#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

cd /home/tibco/be/gvproviders/consul

apt-get install -y unzip

# Download consul cli and extract it.
wget "https://releases.hashicorp.com/consul/1.6.1/consul_1.6.1_linux_amd64.zip"
unzip consul_1.6.1_linux_amd64.zip

# clean up
rm -f consul_1.6.1_linux_amd64.zip
apt-get remove -y unzip