package template

import (
	"path/filepath"
	"strings"
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

func TestExternalServices(t *testing.T) {
	helmChartPath, err := filepath.Abs(common.HelmChartPath)
	releaseName := "testext-svc"
	require.NoError(t, err)

	values := map[string]string{
		// agent[0]
		"agents[0].name":                                          "inferenceagent",
		"agents[0].PU":                                            "default",
		"agents[0].cacheStorageEnabled":                           "false",
		"agents[0].replicas":                                      "1",
		"agents[0].discoverableReplicas":                          "0",
		"agents[0].expose[0].name":                                "httpchannel",
		"agents[0].expose[0].port":                                "8090",
		"agents[0].expose[0].type":                                "NodePort",
		"agents[0].resources.memoryRequest":                       "1.2Gi",
		"agents[0].resources.memoryLimit":                         "1.5Gi",
		"agents[0].resources.cpuRequest":                          "1",
		"agents[0].resources.cpuLimit":                            "2",
		"agents[0].hpa.maxReplicas":                               "5",
		"agents[0].hpa.cpuMetric.enable":                          "false",
		"agents[0].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[0].hpa.memoryMetric.enable":                       "false",
		"agents[0].hpa.memoryMetric.averageUtilizationPercentage": "90",
		// agent[1]
		"agents[1].name":                                          "cacheagent",
		"agents[1].PU":                                            "cache",
		"agents[1].cacheStorageEnabled":                           "true",
		"agents[1].replicas":                                      "1",
		"agents[1].discoverableReplicas":                          "0",
		"agents[1].expose[0].name":                                "one",
		"agents[1].expose[0].port":                                "1111",
		"agents[1].expose[0].type":                                "NodePort",
		"agents[1].expose[1].name":                                "two",
		"agents[1].expose[1].port":                                "2222",
		"agents[1].expose[1].type":                                "LoadBalancer",
		"agents[1].resources.memoryRequest":                       "1.2Gi",
		"agents[1].resources.memoryLimit":                         "1.5Gi",
		"agents[1].resources.cpuRequest":                          "1",
		"agents[1].resources.cpuLimit":                            "2",
		"agents[1].hpa.maxReplicas":                               "5",
		"agents[1].hpa.cpuMetric.enable":                          "false",
		"agents[1].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[1].hpa.memoryMetric.enable":                       "false",
		"agents[1].hpa.memoryMetric.averageUtilizationPercentage": "90",
		// agent[2]
		"agents[2].name":                                          "extracacheagent",
		"agents[2].PU":                                            "cache",
		"agents[2].cacheStorageEnabled":                           "true",
		"agents[2].replicas":                                      "1",
		"agents[2].discoverableReplicas":                          "0",
		"agents[2].expose[0].name":                                "one",
		"agents[2].expose[0].port":                                "1111",
		"agents[2].expose[0].type":                                "NodePort",
		"agents[2].expose[1].name":                                "two",
		"agents[2].expose[1].port":                                "2222",
		"agents[2].expose[1].type":                                "LoadBalancer",
		"agents[2].resources.memoryRequest":                       "1.2Gi",
		"agents[2].resources.memoryLimit":                         "1.5Gi",
		"agents[2].resources.cpuRequest":                          "1",
		"agents[2].resources.cpuLimit":                            "2",
		"agents[2].hpa.maxReplicas":                               "5",
		"agents[2].hpa.cpuMetric.enable":                          "false",
		"agents[2].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[2].hpa.memoryMetric.enable":                       "false",
		"agents[2].hpa.memoryMetric.averageUtilizationPercentage": "90",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/external-services.yaml"})
	require.NoError(t, err)
	rawServices := strings.Split(output, "---")
	var actualServices []v1.Service
	for _, rawService := range rawServices {
		if strings.Trim(rawService, "") == "" {
			continue
		}
		var service v1.Service
		helm.UnmarshalK8SYaml(t, rawService, &service)
		actualServices = append(actualServices, service)
	}

	type ExpectedService struct {
		Port         int32
		SelectorName string
		ServiceType  v1.ServiceType
	}
	var expectedServicesMap = map[string]ExpectedService{
		"testext-svc-inferenceagent-httpchannel": ExpectedService{
			Port:         8090,
			SelectorName: "testext-svc-inferenceagent",
			ServiceType:  v1.ServiceType("NodePort"),
		},
		"testext-svc-cacheagent-one": ExpectedService{
			Port:         1111,
			SelectorName: "testext-svc-cacheagent",
			ServiceType:  v1.ServiceType("NodePort"),
		},
		"testext-svc-cacheagent-two": ExpectedService{
			Port:         2222,
			SelectorName: "testext-svc-cacheagent",
			ServiceType:  v1.ServiceType("LoadBalancer"),
		},
		"testext-svc-extracacheagent-one": ExpectedService{
			Port:         1111,
			SelectorName: "testext-svc-extracacheagent",
			ServiceType:  v1.ServiceType("NodePort"),
		},
		"testext-svc-extracacheagent-two": ExpectedService{
			Port:         2222,
			SelectorName: "testext-svc-extracacheagent",
			ServiceType:  v1.ServiceType("LoadBalancer"),
		},
	}

	require.Equal(t, len(expectedServicesMap), len(actualServices))

	for _, actualService := range actualServices {
		expectedService, found := expectedServicesMap[actualService.Name]
		if !found {
			t.Logf("external service name[%s] is not expected", actualService.Name)
			t.FailNow()
		}
		require.Equal(t, expectedService.Port, actualService.Spec.Ports[0].Port)
		require.Equal(t, expectedService.SelectorName, actualService.Spec.Selector["name"])
		require.Equal(t, expectedService.ServiceType, actualService.Spec.Type)
	}
}
