package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/helm/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestFTLStoreAS4(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: common.FTLAS4StoreValues(),
	}

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceFTLTest(output, t)

	// be service test
	beServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "beservice", []string{"templates/beservice.yaml"})
	common.AppServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "bejmx", []string{"templates/bejmx-service.yaml"})
	common.JmxServiceTest(jmxServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, helmChartPath, "configmap", []string{"templates/configmap.yaml"})
	common.ConfigMapAS4Test(configOutPut, t)

}

func TestFTLStoreCassandra(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: common.InmemoryCassandraStoreValues(),
	}

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceFTLTest(output, t)

	// be service test
	beServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "beservice", []string{"templates/beservice.yaml"})
	common.AppServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "bejmx", []string{"templates/bejmx-service.yaml"})
	common.JmxServiceTest(jmxServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, helmChartPath, "configmap", []string{"templates/configmap.yaml"})
	common.ConfigMapCassandraTest(configOutPut, t)

}
