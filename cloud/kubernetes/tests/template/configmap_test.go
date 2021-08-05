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
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestConfigMap"

	require.NoError(t, err)

	// test case: dont generate configmap in case of empty configs
	values := map[string]string{}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/configmap.yaml"})
	require.NotNil(t, err)
	require.Equal(t, "Error: could not find template templates/configmap.yaml in chart", output)

	// test case: non empty configmap
	values = map[string]string{
		"configs.FTL":  "https://ftlserver:8585",
		"configs.KEY1": "VALUE1",
		"configs.KEY2": "VALUE2",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/configmap.yaml"})
	require.NoError(t, err)
	var actualConfigMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, output, &actualConfigMap)

	expectedConfigMapName := fmt.Sprintf("%s-configmap", releaseName)
	require.Equal(t, expectedConfigMapName, actualConfigMap.Name)
	require.Equal(t, expectedConfigMapName, actualConfigMap.Labels["name"])
	require.Equal(t, 3, len(actualConfigMap.Data))
	require.Equal(t, "https://ftlserver:8585", actualConfigMap.Data["FTL"])
	require.Equal(t, "VALUE1", actualConfigMap.Data["KEY1"])
}
