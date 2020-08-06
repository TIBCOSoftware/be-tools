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

func TestInmemoryStoreAS4(t *testing.T) {
	helmChartPath := "../../helm"
	options := &helm.Options{
		SetValues: common.InmemoryAS4StoreValues(),
	}

	appAndJmxServices(t, options, helmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceTest(output, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, helmChartPath, "configmap", []string{"templates/configmap.yaml"})
	common.ConfigMapAS4Test(configOutPut, t)
}

func TestInmemoryStoreCassandra(t *testing.T) {
	helmChartPath := "../../helm"
	options := &helm.Options{
		SetValues: common.InmemoryCassandraStoreValues(),
	}

	appAndJmxServices(t, options, helmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceTest(output, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, helmChartPath, "configmap", []string{"templates/configmap.yaml"})
	common.ConfigMapCassandraTest(configOutPut, t)
}
