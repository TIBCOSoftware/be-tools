#!/bin/bash

#
# Copyright (c) 2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

# install aws cli
package-manager install -y curl unzip less groff python3.8 python3-pip
pip install --upgrade boto beautifulsoup4 requests

cd /home/tibco/be/gvproviders/custom/samlaws
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version

chmod +x ./samlapi.py

# clean up
rm -f awscliv2.zip
rm -rf aws
package-manager remove -y curl unzip