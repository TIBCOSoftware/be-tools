#!/bin/bash

#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# Setup the gv providers
if [[ $1 == *"consul"* ]]; then
  chmod +x /home/tibco/be/gvproviders/consul/*.sh
  /home/tibco/be/gvproviders/consul/setup.sh
fi