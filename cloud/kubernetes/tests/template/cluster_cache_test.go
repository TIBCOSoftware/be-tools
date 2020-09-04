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

func TestAS2CacheNone(t *testing.T) {
	options := &helm.Options{
		SetValues: common.AS2CacheNoneValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceAS2NoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheAS2NoneTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.AS2CacheServiceTest(beCacheServiceOutput, t)
}

func TestFTLCacheNone(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheNoneValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceFTLNoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheFTLNoneTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)
}
