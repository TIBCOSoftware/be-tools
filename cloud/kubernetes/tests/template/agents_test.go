package template

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
)

func TestAgents(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestAgents"
	require.NoError(t, err)

	values := map[string]string{}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/agents.yaml"})
	require.NoError(t, err)
	rawAgents := strings.Split(output, "---")
	var actualAgents []appsv1.StatefulSet
	for _, rawAgent := range rawAgents {
		if strings.Trim(rawAgent, "") == "" {
			continue
		}
		var agent appsv1.StatefulSet
		helm.UnmarshalK8SYaml(t, rawAgent, &agent)
		actualAgents = append(actualAgents, agent)
	}

	require.Equal(t, 1, len(actualAgents))
	require.Equal(t, "TestAgents-inferenceagent", actualAgents[0].Name)
	require.Equal(t, int32(1), *actualAgents[0].Spec.Replicas)
	require.Equal(t, "TestAgents-inferenceagent", actualAgents[0].Spec.Selector.MatchLabels["name"])
	require.Equal(t, "TestAgents-discovery-service", actualAgents[0].Spec.ServiceName)
	require.Equal(t, 1, len(actualAgents[0].Spec.Template.Labels))
	require.Equal(t, "TestAgents-inferenceagent", actualAgents[0].Spec.Template.Labels["name"])
	require.Equal(t, "", actualAgents[0].Spec.Template.Labels["cacheagent"])
	require.Equal(t, "inferenceagent-container", actualAgents[0].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", actualAgents[0].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, v1.PullPolicy("IfNotPresent"), actualAgents[0].Spec.Template.Spec.Containers[0].ImagePullPolicy)
}
