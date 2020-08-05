package common

import (
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
)

// AppServiceTest testing be service content
func AppServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be service port check
	require.Equal(t, service.Spec.Ports[0].Port, beServicePort)
}

// AS2CacheServiceTest testing be cache service content
func AS2CacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be cache service port check
	require.Equal(t, service.Spec.Ports[0].Port, beAS2CacheServicePort)
}

// IgniteCacheServiceTest testing be cache service content
func IgniteCacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be cache service port check
	require.Equal(t, service.Spec.Ports[0].Port, beIgniteCacheServicePort)
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

	require.Equal(t, configMap.Data[as4GridNameKey], as4GridNameVal)
	require.Equal(t, configMap.Data[as4ReamURLKey], as4ReamURLVal)
	require.Equal(t, configMap.Data[as4SecReamURLKey], as4SecReamURLVal)
}

// ConfigMapCassandraTest tests config map content
func ConfigMapCassandraTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	require.Equal(t, configMap.Data[cassandraSerHostNameKey], cassandraSerHostNameVal)
	require.Equal(t, configMap.Data[cassandraKeyspaceNameKey], cassandraKeyspaceNameVal)
	require.Equal(t, configMap.Data[cassandraUserNameKey], cassandraUserNameVal)
	require.Equal(t, configMap.Data[cassandraPasswKey], cassandraPasswVal)
}

// ConfigMapMysqlTest tests config map content
func ConfigMapMysqlTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	require.Equal(t, configMap.Data[rdbmsDriverKey], rdbmsDriverVal)
	require.Equal(t, configMap.Data[rdbmsDbUsernameKey], rdbmsDbUsernameVal)
	require.Equal(t, configMap.Data[rdbmsDbPswdKey], rdbmsDbPswdVal)
}

func checkVolumeClaims(sSet appsv1.StatefulSet, t *testing.T) {

	// volume mount path test
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, "/mnt/tibco/be/data-store")

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.Equal(t, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"], "standard")
}

func inferenceTestcases(sSet appsv1.StatefulSet, t *testing.T) {

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")
}

func cacheTestcases(sSet appsv1.StatefulSet, t *testing.T) {

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "cache")
}

func ftlIgniteTestcases(sSet appsv1.StatefulSet, t *testing.T) {

	ftlTestcases(sSet, t)

	// ignite url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "IGNITE_DISCOVER_URL"))
}

func ftlTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

	// ftl cluster name check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlClusterNameKey), ftlClusterNameVal)
}

func asDiscoveryTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))
}

func configMapEnvAS4Testcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(as4GridNameKey)), as4GridNameKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(as4ReamURLKey)), as4ReamURLKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(as4SecReamURLKey)), as4SecReamURLKey)
}

func configMapEnvCassandraTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(cassandraKeyspaceNameKey)), cassandraKeyspaceNameKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(cassandraPasswKey)), cassandraPasswKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(cassandraSerHostNameKey)), cassandraSerHostNameKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(cassandraUserNameKey)), cassandraUserNameKey)
}

func configMapEnvRDBMSTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_DRIVER"), rdbmsDriverKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_USERNAME"), rdbmsDbUsernameKey)
	require.Equal(t, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_PASSWORD"), rdbmsDbPswdKey)
}

func valueFromEnv(data []v1.EnvVar, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.Value
		}
	}
	return ""
}

func configMapKeyFromEnv(data []v1.EnvVar, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.ValueFrom.ConfigMapKeyRef.Key
		}
	}
	return ""
}
