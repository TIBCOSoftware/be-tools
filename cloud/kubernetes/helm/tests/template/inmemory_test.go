package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/helm/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestInmemory(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: common.InmemoryValues(),
	}

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceTest(output, t)

	// be service test
	beServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "beservice", []string{"templates/beservice.yaml"})
	common.AppServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "bejmx", []string{"templates/bejmx-service.yaml"})
	common.JmxServiceTest(jmxServiceOutput, t)

}
