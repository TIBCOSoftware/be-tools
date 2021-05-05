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
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceAS2SNTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheAS2SNTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	aS2CacheServiceTest(beCacheServiceOutput, t)

	// be inference hpa test
	inferenceHPAOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferencehpa})
	inferenceAutoScalerAS2SNTest(inferenceHPAOutput, t)

	// be cache hpa test
	cacheHPAOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becachehpa})
	cacheAutoScalerAS2SNTest(cacheHPAOutput, t)

	delete(common.Values, "inferencenode.hpa.memory.enabled")
	delete(common.Values, "inferencenode.hpa.cpu.enabled")
	delete(common.Values, "cachenode.hpa.memory.enabled")
	delete(common.Values, "cachenode.hpa.cpu.enabled")
	delete(common.Values, "podAntiAffinity")
	delete(common.Values, "mountLogs")
}

func TestFTLCacheSN(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheSNValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLSNTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheFTLSNTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)
}
