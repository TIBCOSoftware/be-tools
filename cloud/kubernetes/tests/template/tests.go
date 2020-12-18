//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package template

import (
	"strings"
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
)

// appAndJmxServices contains common be app and jmx service related tests
func appAndJmxServices(t *testing.T, options *helm.Options, HelmChartPath string) {
	// be app service test
	beServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beappservice})
	appServiceTest(beServiceOutput, t)

	// jmx service test
	jmxServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Bejmx})
	jmxServiceTest(jmxServiceOutput, t)
}

// appServiceTest testing be service content
func appServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be service port check
	require.NotNil(t, service.Spec.Ports)

	// beservice name check
	require.Equal(t, common.BeserviceName, service.ObjectMeta.Name)

	// beservice selector name check
	require.Equal(t, map[string]string{"name": common.InferenceSelectorName}, service.Spec.Selector)

	// be service port check
	require.Equal(t, common.BeServicePort, service.Spec.Ports[0].Port)

	// be service port type check
	require.Equal(t, v1.ServiceType(common.InfServicePortType), service.Spec.Type)
}

// aS2CacheServiceTest testing be cache service content
func aS2CacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be cache service port check
	require.NotNil(t, service.Spec.Ports)
	require.Equal(t, common.BeAS2CacheServicePort, service.Spec.Ports[0].Port)
}

// igniteCacheServiceTest testing be cache service content
func igniteCacheServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// be cache service port check
	require.NotNil(t, service.Spec.Ports)
	require.Equal(t, common.BeIgniteCacheServicePort, service.Spec.Ports[0].Port)
}

// jmxServiceTest testing be jmx service content
func jmxServiceTest(data string, t *testing.T) {

	var service v1.Service
	helm.UnmarshalK8SYaml(t, data, &service)

	// jmx service port check
	require.NotNil(t, service.Spec.Ports)

	// jmx service metadataname check
	require.Equal(t, common.JMXserviceName, service.ObjectMeta.Name)

	// jmx selector name check
	require.Equal(t, map[string]string{"name": common.InferenceSelectorName}, service.Spec.Selector)

	// jmx service port check
	require.Equal(t, common.BeJmxServicePort, service.Spec.Ports[0].Port)

	// jmx service port type check
	require.Equal(t, v1.ServiceType(common.JmxServicePortType), service.Spec.Type)
}

// configMapNameTest check for configmap metadata name and labels name
func configMapNameTest(configMap v1.ConfigMap, t *testing.T) {

	// configmap metadata name check
	require.Equal(t, common.ConfigmapName, configMap.ObjectMeta.Name)

	// metadata labels name check
	require.Equal(t, map[string]string{"name": common.ConfigmapName}, configMap.ObjectMeta.Labels)
}

// configMapAS4Test tests config map content
func configMapAS4Test(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	configMapNameTest(configMap, t)

	// as4 configmap data check
	require.NotEmpty(t, configMap.Data)
	require.Equal(t, common.As4GridNameVal, configMap.Data[common.As4GridNameKey])
	require.Equal(t, common.As4ReamURLVal, configMap.Data[common.As4ReamURLKey])
	require.Equal(t, common.As4SecReamURLVal, configMap.Data[common.As4SecReamURLKey])
}

// configMapCassandraTest tests config map content
func configMapCassandraTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	configMapNameTest(configMap, t)

	// cassandra configmap data check
	require.NotEmpty(t, configMap.Data)
	require.Equal(t, common.CassandraSerHostNameVal, configMap.Data[common.CassandraSerHostNameKey])
	require.Equal(t, common.CassandraKeyspaceNameVal, configMap.Data[common.CassandraKeyspaceNameKey])
	require.Equal(t, common.CassandraUserNameVal, configMap.Data[common.CassandraUserNameKey])
	require.Equal(t, common.CassandraPasswVal, configMap.Data[common.CassandraPasswKey])
}

func secret(data string, t *testing.T) {
	var secret v1.Secret
	helm.UnmarshalK8SYaml(t, data, &secret)

	require.Equal(t, common.SecretName, secret.ObjectMeta.Name)
	require.Equal(t, v1.SecretType(common.SecretType), secret.Type)
}

// configMapMysqlTest tests config map content
func configMapMysqlTest(data string, t *testing.T) {
	var configMap v1.ConfigMap
	helm.UnmarshalK8SYaml(t, data, &configMap)

	configMapNameTest(configMap, t)

	// RDBMS configmap data check
	require.NotEmpty(t, configMap.Data)
	require.Equal(t, common.RdbmsDriverVal, configMap.Data[common.RdbmsDriverKey])
	require.Equal(t, common.RdbmsDbUsernameVal, configMap.Data[common.RdbmsDbUsernameKey])
	require.Equal(t, common.RdbmsDbPswdVal, configMap.Data[common.RdbmsDbPswdKey])
}

func registryPullSecret(sSet appsv1.StatefulSet, t *testing.T) {

	// imagePullSecret value defined in values.yaml
	require.Equal(t, []v1.LocalObjectReference([]v1.LocalObjectReference{v1.LocalObjectReference{Name: common.SecretName}}), sSet.Spec.Template.Spec.ImagePullSecrets)
}

func pullSecret(sSet appsv1.StatefulSet, t *testing.T) {

	// imagePullSecret value defined in values.yaml
	require.Equal(t, []v1.LocalObjectReference([]v1.LocalObjectReference{v1.LocalObjectReference{Name: common.ImgPullSecret}}), sSet.Spec.Template.Spec.ImagePullSecrets)
}
func checkVolumeClaims(sSet appsv1.StatefulSet, t *testing.T) {

	// volume mount path test
	require.Equal(t, common.Snpath, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].MountPath)

	//  mount volume path name check
	require.Equal(t, common.SnmountVolume, sSet.Spec.Template.Spec.Containers[0].VolumeMounts[0].Name)

	// volume claim temlate testing annotation volume.beta.kubernetes.io/storage-class as standard
	require.Equal(t, common.StorageClass, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Annotations["volume.beta.kubernetes.io/storage-class"])

	//  claim template mount volume name check
	require.Equal(t, common.SnmountVolume, sSet.Spec.VolumeClaimTemplates[0].ObjectMeta.Name)

	//  volume claim access modes
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{common.AccessMode}), sSet.Spec.VolumeClaimTemplates[0].Spec.AccessModes)
}

func agentTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.NotEmpty(t, sSet.Spec.Template.Spec.Containers)
	// image name check
	require.Equal(t, common.ImageName, sSet.Spec.Template.Spec.Containers[0].Image)

	// imagepull policy check
	require.Equal(t, v1.PullPolicy(common.ImagePullPolicy), sSet.Spec.Template.Spec.Containers[0].ImagePullPolicy)

}

func inferenceTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	var inferenceName = map[string]string{"name": common.InferenceSelectorName}

	// selector matchlabels name check
	require.Equal(t, inferenceName, *&sSet.Spec.Selector.MatchLabels)

	// template metadata name check
	require.Equal(t, inferenceName, *&sSet.Spec.Template.ObjectMeta.Labels)

	// service name check
	require.Equal(t, common.BeserviceName, *&sSet.Spec.ServiceName)

	// replica count check
	require.Equal(t, common.InfReplicas, *sSet.Spec.Replicas)

	// PU value check
	require.Equal(t, common.DefaultPU, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"))
}

func cacheTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	var cacheName = map[string]string{"name": common.CacheSelectorName}

	// selector matchlabels name check
	require.Equal(t, cacheName, *&sSet.Spec.Selector.MatchLabels)

	// template metadata name check
	require.Equal(t, cacheName, *&sSet.Spec.Template.ObjectMeta.Labels)

	// service name check
	require.Equal(t, common.CacheserviceName, *&sSet.Spec.ServiceName)

	// replica count check
	require.Equal(t, common.CacheReplicas, *sSet.Spec.Replicas)

	// PU value check
	require.Equal(t, common.CachePU, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "PU"))
}

func ftlTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	// ftl url check
	require.Equal(t, common.FtlServerURLVal, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.FtlServerURLKey))

	// ftl cluster name check
	require.Equal(t, common.FtlClusterNameVal, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.FtlClusterNameKey))
}

func asDiscoveryTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	// as discovery url check
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.AsURL))
}

func IGNITEDiscoveryTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	// ignite discovery url check
	require.Equal(t, common.IgniteListenPortVal, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.IgniteListenPortKey))
	require.Equal(t, common.IgniteCommPortVal, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.IgniteCommPortKey))
}

func configMapEnvAS4Testcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, common.As4GridNameKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.As4GridNameKey)))
	require.Equal(t, common.As4ReamURLKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.As4ReamURLKey)))
	require.Equal(t, common.As4SecReamURLKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.As4SecReamURLKey)))
}

func configMapEnvCassandraTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, common.CassandraKeyspaceNameKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.CassandraKeyspaceNameKey)))
	require.Equal(t, common.CassandraPasswKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.CassandraPasswKey)))
	require.Equal(t, common.CassandraSerHostNameKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.CassandraSerHostNameKey)))
	require.Equal(t, common.CassandraUserNameKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, strings.ToUpper(common.CassandraUserNameKey)))
}

func configMapEnvRDBMSTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, common.RdbmsDriverKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_DRIVER"))
	require.Equal(t, common.RdbmsDbUsernameKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_USERNAME"))
	require.Equal(t, common.RdbmsDbPswdKey, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_PASSWORD"))
}

func configMapEnvInfluxTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, common.InfluxDbURL, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "INFLUXDB_URL"))
	require.Equal(t, common.InfluxBucket, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "INFLUXBUCKET"))
	require.Equal(t, common.InfluxDBToken, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "INFLUXTOKEN"))
	require.Equal(t, common.InfluxOrg, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "INFLUXORG"))
}

func configMapEnvLiveViewTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.Equal(t, common.LdmDbURL, configMapKeyFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, "LDM_URL"))
}

func metricscustomTestcases(sSet appsv1.StatefulSet, t *testing.T) {
	require.NotEmpty(t, valueFromEnv(sSet.Spec.Template.Spec.Containers[0].Env, common.CustomMetricsURL))
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
