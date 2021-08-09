package template

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"k8s.io/api/autoscaling/v2beta2"
	v1 "k8s.io/api/core/v1"
)

//  Template test for HPA
func TestHPA(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "TestHPA"

	require.NoError(t, err)

	values := map[string]string{
		"cmType":                                                  "as2",
		"bsType":                                                  "none",
		"agents[0].name":                                          "inferenceagent",
		"agents[0].PU":                                            "default",
		"agents[0].cacheStorageEnabled":                           "false",
		"agents[0].replicas":                                      "1",
		"agents[0].discoverableReplicas":                          "1",
		"agents[0].expose[0].name":                                "jmx",
		"agents[0].expose[0].port":                                "5555",
		"agents[0].expose[0].type":                                "ClusterIP",
		"agents[0].expose[1].name":                                "httpchannel",
		"agents[0].expose[1].port":                                "8090",
		"agents[0].expose[1].type":                                "NodePort",
		"agents[0].resources.memoryRequest":                       "1.2Gi",
		"agents[0].resources.memoryLimit":                         "1.5Gi",
		"agents[0].resources.cpuRequest":                          "1",
		"agents[0].resources.cpuLimit":                            "2",
		"agents[0].hpa.maxReplicas":                               "5",
		"agents[0].hpa.cpuMetric.enable":                          "true",
		"agents[0].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[0].hpa.memoryMetric.enable":                       "true",
		"agents[0].hpa.memoryMetric.averageUtilizationPercentage": "90",
		// agent[1]
		"agents[1].name":                                          "cacheagent",
		"agents[1].PU":                                            "cache",
		"agents[1].cacheStorageEnabled":                           "true",
		"agents[1].replicas":                                      "1",
		"agents[1].discoverableReplicas":                          "1",
		"agents[1].expose[0].name":                                "jmx",
		"agents[1].expose[0].port":                                "5555",
		"agents[1].expose[0].type":                                "ClusterIP",
		"agents[1].expose[1].name":                                "one",
		"agents[1].expose[1].port":                                "1111",
		"agents[1].expose[1].type":                                "NodePort",
		"agents[1].expose[2].name":                                "two",
		"agents[1].expose[2].port":                                "2222",
		"agents[1].expose[2].type":                                "LoadBalancer",
		"agents[1].resources.memoryRequest":                       "1.2Gi",
		"agents[1].resources.memoryLimit":                         "1.5Gi",
		"agents[1].resources.cpuRequest":                          "1",
		"agents[1].resources.cpuLimit":                            "2",
		"agents[1].hpa.maxReplicas":                               "5",
		"agents[1].hpa.cpuMetric.enable":                          "true",
		"agents[1].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[1].hpa.memoryMetric.enable":                       "true",
		"agents[1].hpa.memoryMetric.averageUtilizationPercentage": "90",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/hpa.yaml"})
	require.NoError(t, err)
	rawHPAs := strings.Split(output, "---")
	var actualHPAs []v2beta2.HorizontalPodAutoscaler
	for _, rawHPA := range rawHPAs {
		if strings.Trim(rawHPA, "") == "" {
			continue
		}
		var actualHPA v2beta2.HorizontalPodAutoscaler
		helm.UnmarshalK8SYaml(t, rawHPA, &actualHPA)
		actualHPAs = append(actualHPAs, actualHPA)
	}

	require.Equal(t, 2, len(actualHPAs))
	hpaName := [5]string{"inferenceagent", "cacheagent"}
	for i := 0; i < len(actualHPAs); i++ {
		expectedReleaseName := fmt.Sprintf("TestHPA-%s", hpaName[i])
		require.Equal(t, expectedReleaseName, actualHPAs[i].ObjectMeta.Name)
		require.Equal(t, expectedReleaseName, actualHPAs[i].Spec.ScaleTargetRef.Name)
		require.Equal(t, int32(1), *actualHPAs[i].Spec.MinReplicas)
		require.Equal(t, int32(5), actualHPAs[i].Spec.MaxReplicas)
		require.Equal(t, v2beta2.MetricSourceType("Resource"), actualHPAs[i].Spec.Metrics[i].Type)
		resourceName := [2]string{"cpu", "memory"}
		for j := 0; j < len(resourceName); j++ {
			require.Equal(t, v1.ResourceName(resourceName[j]), actualHPAs[i].Spec.Metrics[j].Resource.Name)
			require.Equal(t, v2beta2.MetricTargetType("Utilization"), actualHPAs[i].Spec.Metrics[j].Resource.Target.Type)
			require.Equal(t, int32(90), *actualHPAs[i].Spec.Metrics[j].Resource.Target.AverageUtilization)
		}
	}
}
