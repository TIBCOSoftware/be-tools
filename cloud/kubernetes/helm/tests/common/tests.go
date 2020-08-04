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

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")
}

// InferenceFTLTest testing inference content for ftl cluster and cache type as store
func InferenceFTLTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

}

// CacheAS2NoneTest testing cache content for AS2 cluster backing store none
func CacheAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "cache")

	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))

}

// CacheAS2SNTest testing cache content for AS2 cluster backing store shared nothing
func CacheAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "cache")

	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))

	// volume mount path test
	require.NotEmpty(t, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, "/mnt/tibco/be/data-store")

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.NotEmpty(t, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"], "standard")

}

// CacheFTLNoneTest testing cache content for FTL cluster backing store none
func CacheFTLNoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "cache")

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

	// ignite url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "IGNITE_DISCOVER_URL"))

}

// CacheFTLSNTest testing cache content for FTL cluster backing store shared nothing
func CacheFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "cache")

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

	// ignite url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "IGNITE_DISCOVER_URL"))

	// volume mount path test
	require.NotEmpty(t, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, "/mnt/tibco/be/data-store")

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.NotEmpty(t, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"], "standard")

}

// InferenceFTLNoneTest testing inference content for FTL cluster backing store none
func InferenceFTLNoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

	// ignite url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "IGNITE_DISCOVER_URL"))

}

// InferenceFTLSNTest testing inference content for FTL cluster backing store shared nothing
func InferenceFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")

	// ftl url check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, ftlServerURLKey), ftlServerURLVal)

	// ignite url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "IGNITE_DISCOVER_URL"))

	// volume mount path test
	require.NotEmpty(t, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, "/mnt/tibco/be/data-store")

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.NotEmpty(t, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"], "standard")

}

// InferenceAS2NoneTest testing inference content for AS2 cluster backing store none
func InferenceAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")

	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))

}

// InferenceAS2SNTest testing inference content for AS2 cluster shared nothing
func InferenceAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	// image name check
	require.Equal(t, sSet.Spec.Template.Spec.Containers[0].Image, imageName)

	// PU value check
	require.Equal(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"), "default")

	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "AS_DISCOVER_URL"))

	// volume mount path test
	require.NotEmpty(t, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath, "/mnt/tibco/be/data-store")

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.NotEmpty(t, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"], "standard")

}

// AppServiceTest testing be service content
func AppServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be service port check
	require.Equal(t, service.Spec.Ports[0].Port, beServicePort)
}

// AS2CacheServiceTest testing be service content
func AS2CacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be cache service port check
	require.Equal(t, service.Spec.Ports[0].Port, beAS2CacheServicePort)
}

// IgniteCacheServiceTest testing be service content
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

// ConfigMapMysqlTest tests config map content
func ConfigMapMysqlTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	// dbdriver check
	require.Equal(t, configMap.Data["dbdriver"], "com.mysql.jdbc.Driver")
}

func valueFromEnv(data []v1.EnvVar, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.Value
		}
	}
	return ""
}
