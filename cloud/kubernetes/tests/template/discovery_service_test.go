package template

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

func TestDiscoveryService(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestDiscoveryService"
	require.NoError(t, err)

	values := map[string]string{
		"cmType": "NotSupported",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/discovery-service.yaml"})
	require.NotNil(t, err)
	require.Equal(t, "Error: could not find template templates/discovery-service.yaml in chart", output)

	// case: cmType = as2
	values = map[string]string{
		"cmType": "as2",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/discovery-service.yaml"})
	require.NoError(t, err)
	var service v1.Service
	helm.UnmarshalK8SYaml(t, output, &service)
	expectedSName := fmt.Sprintf("%s-discovery-service", releaseName)
	require.Equal(t, expectedSName, service.Name)
	require.Equal(t, 1, len(service.Spec.Ports))
	require.Equal(t, int32(50000), service.Spec.Ports[0].Port)
	require.Equal(t, v1.Protocol("TCP"), service.Spec.Ports[0].Protocol)

	// case: cmType = ftl
	values = map[string]string{
		"cmType":         "ftl",
		"ignitePort.aaa": "77777",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/discovery-service.yaml"})
	require.NoError(t, err)
	helm.UnmarshalK8SYaml(t, output, &service)
	require.Equal(t, 12, len(service.Spec.Ports))
	require.Equal(t, int32(77777), service.Spec.Ports[0].Port)
	require.Equal(t, v1.Protocol("TCP"), service.Spec.Ports[0].Protocol)
	require.Equal(t, "aaa", service.Spec.Ports[0].Name)

	// case: cmType = ignite
	values = map[string]string{
		"cmType": "ignite",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/discovery-service.yaml"})
	require.NoError(t, err)
	helm.UnmarshalK8SYaml(t, output, &service)
	require.Equal(t, 11, len(service.Spec.Ports))
	require.Equal(t, int32(47500), service.Spec.Ports[0].Port)
	require.Equal(t, v1.Protocol("TCP"), service.Spec.Ports[0].Protocol)
	require.Equal(t, "dis0", service.Spec.Ports[0].Name)
}
