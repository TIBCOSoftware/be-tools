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

	common.AppJmxServiceTemplate(t, options, helmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceTest(output, t)
}
