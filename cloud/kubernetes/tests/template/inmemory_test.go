package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestInmemory(t *testing.T) {
	helmChartPath := "../../helm"
	options := &helm.Options{
		SetValues: common.InmemoryValues(),
	}

	appAndJmxServices(t, options, helmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceTest(output, t)
}

// appAndJmxServices contains common be app and jmx service related tests
func appAndJmxServices(t *testing.T, options *helm.Options, helmChartPath string) {
	// be app service test
	beServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "beappservice", []string{"templates/beservice.yaml"})
	common.AppServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "bejmx", []string{"templates/bejmx-service.yaml"})
	common.JmxServiceTest(jmxServiceOutput, t)
}
