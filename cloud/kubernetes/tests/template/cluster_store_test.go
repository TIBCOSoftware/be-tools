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

func TestFTLStoreAS4(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLAS4StoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLStoreAS4Test(output, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapAS4Test(configOutPut, t)
}

func TestFTLStoreCassandra(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCassandraStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLStoreCassTest(output, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapCassandraTest(configOutPut, t)
}
