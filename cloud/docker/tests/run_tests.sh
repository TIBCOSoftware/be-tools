#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

ARG_IMAGE_VERSION=s2ifd:01

echo "INFO: Running container structure tests on BE application image $ARG_IMAGE_VERSION ..."
docker run -i --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ${PWD}:/test gcr.io/gcp-runtimes/container-structure-test:latest \
    test \
    --image ${ARG_IMAGE_VERSION} \
    --config "/test/be-testcases.yaml" \
    --config "/test/as-testcases.yaml" \
    --config "/test/ftl-testcases.yaml"