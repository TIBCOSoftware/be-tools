package template

import (
	"fmt"
	"path/filepath"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

func TestImagePullSecret(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "testrelease"

	require.NoError(t, err)

	values := map[string]string{}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/imagepullsecret.yaml"})
	require.NotNil(t, err)
	require.Equal(t, "Error: could not find template templates/imagepullsecret.yaml in chart", output)

	values = map[string]string{
		"imageCredentials.registry": "docker.io",
		"imageCredentials.username": "test",
		"imageCredentials.password": "test",
		"imageCredentials.email":    "test@test.com",
	}

	options = &helm.Options{
		SetValues: values,
	}

	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/imagepullsecret.yaml"})
	require.NoError(t, err)
	var imagePullSecret v1.Secret
	helm.UnmarshalK8SYaml(t, output, &imagePullSecret)

	expectedRelName := fmt.Sprintf("%s-beimagepullsecret", releaseName)
	require.Equal(t, expectedRelName, imagePullSecret.Name)
	require.NotEmpty(t, imagePullSecret.Data)
	require.Equal(t, v1.SecretType("kubernetes.io/dockerconfigjson"), imagePullSecret.Type)

}
