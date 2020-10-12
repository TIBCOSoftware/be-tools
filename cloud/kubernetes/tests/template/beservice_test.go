package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

// TestBeservice validates templates/beservice.yaml
func TestBeservice(t *testing.T) {

	// negation test case: service should not render when unsupported value supplied for cmType
	values := map[string]string{
		"cmType": "XYZ",
	}
	options := &helm.Options{
		SetValues: values,
	}
	releaseName := "TestBeservice-cmType=XYZ"
	output, err := helm.RenderTemplateE(t, options, common.HelmChartPath, releaseName, []string{common.Beappservice})
	require.NoError(t, err)
	var service v1.Service
	helm.UnmarshalK8SYaml(t, output, &service)
	require.Equal(t, "", service.Name)
	require.Equal(t, []v1.ServicePort(nil), service.Spec.Ports)
	require.Equal(t, v1.ServiceType(""), service.Spec.Type)
	require.Equal(t, map[string]string(nil), service.Spec.Selector)
}
