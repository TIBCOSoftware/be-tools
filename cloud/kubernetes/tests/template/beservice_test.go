package template

import (
	"fmt"
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

// TestBeservice validates templates/beservice.yaml
func TestBeservice(t *testing.T) {

	testCases := []struct {
		name                string
		values              map[string]string
		expectedServiceName string
		expectedServicePort int32
		expectedServiceType v1.ServiceType
		expectedSelector    map[string]string
	}{
		{
			name: "cmType=AS2",
			values: map[string]string{
				"cmType": "AS2",
			},
			expectedServiceName: "TestBeservice-cmType=AS2-beservice",
			expectedServicePort: int32(8108),
			expectedServiceType: v1.ServiceType("NodePort"),
			expectedSelector: map[string]string{
				"name": "TestBeservice-cmType=AS2-beinferenceagent",
			},
		},
		{
			name: "cmType=FTL",
			values: map[string]string{
				"cmType": "FTL",
			},
			expectedServiceName: "TestBeservice-cmType=FTL-beservice",
			expectedServicePort: int32(8108),
			expectedServiceType: v1.ServiceType("NodePort"),
			expectedSelector: map[string]string{
				"name": "TestBeservice-cmType=FTL-beinferenceagent",
			},
		},
		{
			name: "cmType=unclustered",
			values: map[string]string{
				"cmType": "unclustered",
			},
			expectedServiceName: "TestBeservice-cmType=unclustered-beservice",
			expectedServicePort: int32(8108),
			expectedServiceType: v1.ServiceType("NodePort"),
			expectedSelector: map[string]string{
				"name": "TestBeservice-cmType=unclustered-beinferenceagent",
			},
		},
		{
			name: "cmType=AS2",
			values: map[string]string{
				"cmType":               "AS2",
				"beservice.name":       "testbeservice",
				"beservice.ports.port": "9999",
				"beservice.type":       "LoadBalancer",
				"inferencenode.name":   "testinferencenode",
			},
			expectedServiceName: "TestBeservice-cmType=AS2-testbeservice",
			expectedServicePort: int32(9999),
			expectedServiceType: v1.ServiceType("LoadBalancer"),
			expectedSelector: map[string]string{
				"name": "TestBeservice-cmType=AS2-testinferencenode",
			},
		},
	}

	for _, tc := range testCases {
		t.Run(tc.name, func(subT *testing.T) {
			options := &helm.Options{
				SetValues: tc.values,
			}
			releaseName := fmt.Sprintf("TestBeservice-%s", tc.name)
			output, err := helm.RenderTemplateE(t, options, common.HelmChartPath, releaseName, []string{common.Beappservice})
			require.NoError(t, err)
			var service v1.Service
			helm.UnmarshalK8SYaml(t, output, &service)
			require.Equal(t, tc.expectedServiceName, service.Name)
			require.Equal(t, tc.expectedServicePort, service.Spec.Ports[0].Port)
			require.Equal(t, tc.expectedServiceType, service.Spec.Type)
			require.Equal(t, tc.expectedSelector, service.Spec.Selector)
		})
	}

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
