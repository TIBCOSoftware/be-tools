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
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceAS2NoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheAS2NoneTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	aS2CacheServiceTest(beCacheServiceOutput, t)
}

func TestFTLCacheNone(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheNoneValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLNoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheFTLNoneTestt(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)
}
