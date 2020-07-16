#!/bin/bash

#
# Copyright (c) 2019. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

## create temp dir
mkdir ${TEMP_FOLDER}

## gen be testcases from be template
if [ $ARG_BE_VERSION != na ]; then
    sed "s/ARG_BE_VERSION/${ARG_BE_VERSION}/g" ${PWD}/testcases/betestcases.yaml > ${PWD}/${TEMP_FOLDER}/be-${ARG_BE_VERSION}-testcases.yaml
fi

## gen as legacy testcases from as legacy template
if [ $ARG_AS_LEG_VERSION != na ]; then
    sed -e "s/ARG_BE_VERSION/${ARG_BE_VERSION}/g" -e "s/ARG_AS_LEG_VERSION/${ARG_AS_LEG_VERSION}/g" ${PWD}/testcases/aslegacytestcases.yaml > ${PWD}/${TEMP_FOLDER}/as-${ARG_AS_LEG_VERSION}-${ARG_BE_VERSION}-testcases.yaml
fi

## gen as testcases from as template
if [ $ARG_AS_VERSION != na ]; then
    sed -e "s/ARG_BE_VERSION/${ARG_BE_VERSION}/g" -e "s/ARG_AS_VERSION/${ARG_AS_VERSION}/g" ${PWD}/testcases/astestcases.yaml > ${PWD}/${TEMP_FOLDER}/as-${ARG_AS_VERSION}-${ARG_BE_VERSION}-testcases.yaml
fi

## gen ftl testcases from ftl template
if [ $ARG_FTL_VERSION != na ]; then
    sed -e "s/ARG_BE_VERSION/${ARG_BE_VERSION}/g" -e "s/ARG_FTL_VERSION/${ARG_FTL_VERSION}/g" ${PWD}/testcases/ftltestcases.yaml > ${PWD}/${TEMP_FOLDER}/ftl-${ARG_FTL_VERSION}-${ARG_BE_VERSION}-testcases.yaml
fi