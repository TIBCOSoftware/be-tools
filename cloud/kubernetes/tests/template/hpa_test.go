package template

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	"k8s.io/api/autoscaling/v2beta2"
)

//  Template test for HPA
func TestHPA(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestHPA"

	require.NoError(t, err)

	values := map[string]string{}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/hpa.yaml"})
	require.NotNil(t, err)
	require.Equal(t, "Error: could not find template templates/hpa.yaml in chart", output)

	values = map[string]string{
		"cmType":                                                  "as2",
		"bsType":                                                  "none",
		"namespace":                                               "be-tools",
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

	options = &helm.Options{
		SetValues: values,
	}

	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/hpa.yaml"})
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

	expectedHPAMap := map[string]map[string]interface{}{
		"TestHPA-cacheagent": {
			"releaseName":                      "TestHPA-cacheagent",
			"minreplicas":                      int32(1),
			"maxreplicas":                      int32(5),
			"resourceCPUAverageUtilization":    int32(90),
			"resourceMemoryAverageUtilization": int32(90),
		},
		"TestHPA-inferenceagent": {
			"releaseName":                      "TestHPA-inferenceagent",
			"minreplicas":                      int32(1),
			"maxreplicas":                      int32(5),
			"resourceCPUAverageUtilization":    int32(90),
			"resourceMemoryAverageUtilization": int32(90),
		},
	}

	require.Equal(t, 2, len(actualHPAs))

	for _, actualHPA := range actualHPAs {
		actualHPAName := actualHPA.ObjectMeta.Name
		expectedHPA, found := expectedHPAMap[actualHPAName]
		require.Truef(t, found, fmt.Sprintf("HPA name[%s] is not expected", expectedHPA))
		require.Equal(t, expectedHPA["releaseName"], actualHPA.ObjectMeta.Name)
		require.Equal(t, "be-tools", actualHPA.ObjectMeta.Namespace)

		require.Equal(t, expectedHPA["releaseName"], actualHPA.Spec.ScaleTargetRef.Name)
		require.Equal(t, expectedHPA["minreplicas"], *actualHPA.Spec.MinReplicas)
		require.Equal(t, expectedHPA["maxreplicas"], actualHPA.Spec.MaxReplicas)
		require.Equal(t, expectedHPA["resourceCPUAverageUtilization"], *actualHPA.Spec.Metrics[0].Resource.Target.AverageUtilization)
		require.Equal(t, expectedHPA["resourceMemoryAverageUtilization"], *actualHPA.Spec.Metrics[1].Resource.Target.AverageUtilization)
	}
}
