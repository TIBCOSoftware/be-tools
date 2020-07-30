package template

import (
	"testing"

	appsv1 "k8s.io/api/apps/v1"

	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestInferenceTemplate(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: map[string]string{"image": "fd:01",
			"imagePullPolicy": "IfNotPresent"},
	}

	output := helm.RenderTemplate(t, options, helmChartPath, "inferenceagent", []string{"templates/beinferenceagent.yaml"})

	// test whether beimage renders correctly
	expectedContainerImage := "fd:01"
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, output, &sSet)
	if sSet.Spec.Template.Spec.Containers[0].Image != expectedContainerImage {
		t.Fatalf("Rendered container image (%s) is not expected (%s)", sSet.Spec.Template.Spec.Containers[0].Image, expectedContainerImage)
	}
}
