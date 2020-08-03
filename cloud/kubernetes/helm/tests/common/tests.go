package common

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
)

// InferenceTest testing inference content
func InferenceTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)
}

// InferenceFTLTest testing inference content
func InferenceFTLTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

}

// CacheAS2NoneTest testing inference content
func CacheAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))

}

// AppServiceTest testing be service content
func AppServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be service port check
	require.Equal(t, service.Spec.Ports[0].Port, beServicePort)
}

// CacheServiceTest testing be service content
func CacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be service port check
	require.Equal(t, service.Spec.Ports[0].Port, beCacheServicePort)
}

// JmxServiceTest testing be jmx service content
func JmxServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// jmx service port check
	require.Equal(t, service.Spec.Ports[0].Port, beJmxServicePort)
}

// ConfigMapAS4Test tests config map content
func ConfigMapAS4Test(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	// as4 gridname check
	require.Equal(t, configMap.Data[as4GridNameKey], as4GridNameVal)
}

// ConfigMapCassandraTest tests config map content
func ConfigMapCassandraTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	// cassandra  keyspace name check
	require.Equal(t, configMap.Data[cassandraKeyspaceNameKey], cassandraKeyspaceNameVal)
}

func valueFromEnv(data []v1.EnvVar, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.Value
		}
	}
	return ""
}
