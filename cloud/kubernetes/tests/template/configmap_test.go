package template

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

func TestConfigMap(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "testrelease"

	require.NoError(t, err)

	values := map[string]string{
		"configs.FTL": "https://ftlserver:8585",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/configmap.yaml"})
	require.NoError(t, err)
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, output, &configMap)

	expectedConfigMap := fmt.Sprintf("%s-configmap", releaseName)
	require.Equal(t, expectedConfigMap, configMap.Name)
	require.Equal(t, "ConfigMap", configMap.Kind)
	require.Equal(t, "v1", configMap.APIVersion)
	require.NotEmpty(t, configMap.Data)
	require.Equal(t, "https://ftlserver:8585", configMap.Data["FTL"])
}
