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

func TestInmemory(t *testing.T) {

	options := &helm.Options{
		SetValues: common.InmemoryValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	output := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceTest(output, t)
}

// appAndJmxServices contains common be app and jmx service related tests
func appAndJmxServices(t *testing.T, options *helm.Options, HelmChartPath string) {
	// be app service test
	beServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beappservice})
	common.AppServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Bejmx})
	common.JmxServiceTest(jmxServiceOutput, t)
}

// template func for beinferenceagent
func beinferenceagent(t *testing.T, options *helm.Options, HelmChartPath string) string {
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	return output
}

// template func for configmap
func beconfmap(t *testing.T, options *helm.Options, HelmChartPath string) string {
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	return output
}

// template func for cacheservice
func cacheservice(t *testing.T, options *helm.Options, HelmChartPath string) string {
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	return output
}

// template func for cache agent
func cacheagent(t *testing.T, options *helm.Options, HelmChartPath string) string {
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	return output
}
