//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestAS2CacheSN(t *testing.T) {
	options := &helm.Options{
		SetValues: common.AS2CacheSNValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceAS2SNTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheAS2SNTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.AS2CacheServiceTest(beCacheServiceOutput, t)
}

func TestFTLCacheSN(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheSNValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceFTLSNTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheFTLSNTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)
}
