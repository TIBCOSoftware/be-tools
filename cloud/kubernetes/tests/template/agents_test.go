package template

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	v1 "k8s.io/api/core/v1"
)

// Temolate test for rms aws static provisioning
func TestAgents(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestAgents"
	require.NoError(t, err)

	values := map[string]string{
		"cpType":                              "aws",
		"cmType":                              "as2",
		"bsType":                              "sharednothing",
		"rmsDeployment":                       "true",
		"persistence.logs":                    "true",
		"persistence.rmsWebstudio":            "true",
		"persistence.storageClass":            "-",
		"persistence.scSupportsReadWriteMany": "false",
	}
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
	require.Equal(t, "default", valueFromEnv(actualAgents[0].Spec.Template.Spec.Containers[0].Env, "PU"))
	require.Equal(t, "/mnt/tibco/be/data-store", valueFromVolumeMount(actualAgents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "data-store"))
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(actualAgents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/shared", valueFromVolumeMount(actualAgents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-shared"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/config/security", valueFromVolumeMount(actualAgents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-security"))
	require.Equal(t, "/opt/tibco/be/6.1/examples/standard/WebStudio", valueFromVolumeMount(actualAgents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-webstudio"))
	require.Equal(t, "data-store", actualAgents[0].Spec.VolumeClaimTemplates[0].ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteOnce"}), actualAgents[0].Spec.VolumeClaimTemplates[0].Spec.AccessModes)
	require.Equal(t, "", *actualAgents[0].Spec.VolumeClaimTemplates[0].Spec.StorageClassName)
	require.Equal(t, "logs", actualAgents[0].Spec.VolumeClaimTemplates[1].ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteOnce"}), actualAgents[0].Spec.VolumeClaimTemplates[1].Spec.AccessModes)
	require.Equal(t, "", *actualAgents[0].Spec.VolumeClaimTemplates[1].Spec.StorageClassName)
	require.Equal(t, "rms-shared", actualAgents[0].Spec.VolumeClaimTemplates[2].ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteOnce"}), actualAgents[0].Spec.VolumeClaimTemplates[2].Spec.AccessModes)
	require.Equal(t, "", *actualAgents[0].Spec.VolumeClaimTemplates[2].Spec.StorageClassName)
	require.Equal(t, "rms-security", actualAgents[0].Spec.VolumeClaimTemplates[3].ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteOnce"}), actualAgents[0].Spec.VolumeClaimTemplates[3].Spec.AccessModes)
	require.Equal(t, "", *actualAgents[0].Spec.VolumeClaimTemplates[3].Spec.StorageClassName)
	require.Equal(t, "rms-webstudio", actualAgents[0].Spec.VolumeClaimTemplates[4].ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteOnce"}), actualAgents[0].Spec.VolumeClaimTemplates[4].Spec.AccessModes)
	require.Equal(t, "", *actualAgents[0].Spec.VolumeClaimTemplates[4].Spec.StorageClassName)

}

// Template Test for cmType=as2, with persistence type none, helathcheck=true, enable logs, enableRMS true, podAntiAffinity true, mysql and influx enabled
func TestAgentsNone(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "persistencenone"

	require.NoError(t, err)

	values := map[string]string{
		"cmType":                                                  "as2",
		"bsType":                                                  "none",
		"healthcheck.enabled":                                     "true",
		"podAntiAffinity":                                         "true",
		"enableRMS":                                               "true",
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
		"agents[0].hpa.cpuMetric.enable":                          "false",
		"agents[0].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[0].hpa.memoryMetric.enable":                       "false",
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
		"agents[1].hpa.cpuMetric.enable":                          "false",
		"agents[1].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[1].hpa.memoryMetric.enable":                       "false",
		"agents[1].hpa.memoryMetric.averageUtilizationPercentage": "90",
		"persistence.logs":                                        "true",
		"mysql.enabled":                                           "true",
		"configs.BACKINGSTORE_JDBC_URL":                           "jdbc:mysql://mysql-0.mysql.default.svc.cluster.local:3306/BE_DATABASE",
		"mysql.backingstoreUrlGV":                                 "BACKINGSTORE_JDBC_URL",
		"mysql.auth.database":                                     "BE_DATABASE",
		"influxdb.enabled":                                        "true",
		"configs.INFLUXDB_URL":                                    "http://influxDB:8086",
		"influxdb.influxdbUrlGV":                                  "INFLUXDB_URL",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/agents.yaml"})
	require.NoError(t, err)
	rawAgents := strings.Split(output, "---")
	var agents []appsv1.StatefulSet

	for _, rawAgent := range rawAgents {
		if strings.Trim(rawAgent, "") == "" {
			continue
		}
		var agent appsv1.StatefulSet
		helm.UnmarshalK8SYaml(t, rawAgent, &agent)
		agents = append(agents, agent)
	}

	// fmt.Println("------------", agents, "------------------------------")

	// agent 0
	expectedReleaseName := fmt.Sprintf("%s-inferenceagent", releaseName)
	expectedSVCName := fmt.Sprintf("%s-discovery-service", releaseName)
	// val := "tcp://persistencenone-inferenceagent-0.persistencenone-discovery-service:50000;persistencenone-cacheagent-0.persistencenone-discovery-service:50000;"
	require.Equal(t, "StatefulSet", agents[0].Kind)
	require.Equal(t, "apps/v1", agents[0].APIVersion)
	require.Equal(t, int32(1), *agents[0].Spec.Replicas)
	require.Equal(t, expectedSVCName, agents[0].Spec.ServiceName)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Template.Labels["name"])
	require.Equal(t, expectedReleaseName, agents[0].Name)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Selector.MatchLabels["name"])
	require.Equal(t, int32(100), agents[0].Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].Weight)
	require.Equal(t, []string([]string{"persistencenone-inferenceagent"}), agents[0].Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.LabelSelector.MatchExpressions[0].Values)
	require.Equal(t, "inferenceagent-container", agents[0].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", agents[0].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, v1.PullIfNotPresent, agents[0].Spec.Template.Spec.Containers[0].ImagePullPolicy)
	require.Equal(t, "persistencenone-configmap", agents[0].Spec.Template.Spec.Containers[0].EnvFrom[0].ConfigMapRef.Name)
	require.Equal(t, "default", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "PU"))
	require.Equal(t, "jdbc:mysql://persistencenone-mysql:3306/BE_DATABASE", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_URL"))
	require.Equal(t, "http://persistencenone-influxdb:8086", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "INFLUXDB_URL"))
	// require.Equal(t, 5555, agents[0].Spec.Template.Spec.Containers[0].LivenessProbe.TCPSocket.Port)
	require.Equal(t, int32(5), agents[0].Spec.Template.Spec.Containers[0].LivenessProbe.InitialDelaySeconds)
	require.Equal(t, int32(5), agents[0].Spec.Template.Spec.Containers[0].LivenessProbe.PeriodSeconds)
	// require.Equal(t, 5555, agents[0].Spec.Template.Spec.Containers[0].ReadinessProbe.TCPSocket.Port)
	require.Equal(t, int32(5), agents[0].Spec.Template.Spec.Containers[0].ReadinessProbe.InitialDelaySeconds)
	require.Equal(t, int32(5), agents[0].Spec.Template.Spec.Containers[0].ReadinessProbe.PeriodSeconds)
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/shared", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-shared"))
	require.Equal(t, "persistencenone-logs", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "logs"))
	require.Equal(t, "RMSDEPLOYMENTNAME-rms-shared", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "rms-shared"))

	// agent 1
	expectedCacheReleaseName := fmt.Sprintf("%s-cacheagent", releaseName)
	require.Equal(t, "StatefulSet", agents[1].Kind)
	require.Equal(t, "apps/v1", agents[1].APIVersion)
	require.Equal(t, int32(1), *agents[1].Spec.Replicas)
	require.Equal(t, expectedSVCName, agents[1].Spec.ServiceName)
	require.Equal(t, expectedCacheReleaseName, agents[1].Spec.Template.Labels["name"])
	require.Equal(t, "yes", agents[1].Spec.Template.Labels["cacheagent"])
	require.Equal(t, expectedCacheReleaseName, agents[1].Name)
	require.Equal(t, expectedCacheReleaseName, agents[1].Spec.Selector.MatchLabels["name"])
	require.Equal(t, int32(100), agents[0].Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].Weight)
	require.Equal(t, []string([]string{"persistencenone-cacheagent"}), agents[1].Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.LabelSelector.MatchExpressions[0].Values)
	require.Equal(t, "cacheagent-container", agents[1].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", agents[1].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, v1.PullIfNotPresent, agents[1].Spec.Template.Spec.Containers[0].ImagePullPolicy)
	require.Equal(t, "cache", valueFromEnv(agents[1].Spec.Template.Spec.Containers[0].Env, "PU"))
	require.Equal(t, "jdbc:mysql://persistencenone-mysql:3306/BE_DATABASE", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "BACKINGSTORE_JDBC_URL"))
	require.Equal(t, "http://persistencenone-influxdb:8086", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "INFLUXDB_URL"))
	// require.Equal(t, 5555, agents[1].Spec.Template.Spec.Containers[0].LivenessProbe.TCPSocket.Port)
	require.Equal(t, int32(5), agents[1].Spec.Template.Spec.Containers[0].LivenessProbe.InitialDelaySeconds)
	require.Equal(t, int32(5), agents[1].Spec.Template.Spec.Containers[0].LivenessProbe.PeriodSeconds)
	// require.Equal(t, 5555, agents[1].Spec.Template.Spec.Containers[0].ReadinessProbe.TCPSocket.Port)
	require.Equal(t, int32(5), agents[1].Spec.Template.Spec.Containers[0].ReadinessProbe.InitialDelaySeconds)
	require.Equal(t, int32(5), agents[1].Spec.Template.Spec.Containers[0].ReadinessProbe.PeriodSeconds)
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(agents[1].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/shared", valueFromVolumeMount(agents[1].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-shared"))
	require.Equal(t, "persistencenone-logs", valueFromVolumes(agents[1].Spec.Template.Spec.Volumes, "logs"))
	require.Equal(t, "RMSDEPLOYMENTNAME-rms-shared", valueFromVolumes(agents[1].Spec.Template.Spec.Volumes, "rms-shared"))
}

// Template Test for cmType=ftl, persistence type sharednothing, envVars for ftl, enable logs, envVarsFromSecrets,envVarsFromConfigMaps,configs
func TestAgentsSharedNothing(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "persistencenone"

	require.NoError(t, err)

	values := map[string]string{
		"cmType":                                                  "ftl",
		"bsType":                                                  "sharednothing",
		"imagepullsecret":                                         "besecret",
		"envVars.FTL_REALM_SERVER":                                "http://ftlserver:8585",
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
		"agents[0].hpa.cpuMetric.enable":                          "false",
		"agents[0].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[0].hpa.memoryMetric.enable":                       "false",
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
		"agents[1].hpa.cpuMetric.enable":                          "false",
		"agents[1].hpa.cpuMetric.averageUtilizationPercentage":    "90",
		"agents[1].hpa.memoryMetric.enable":                       "false",
		"agents[1].hpa.memoryMetric.averageUtilizationPercentage": "90",
		"persistence.logs":                                        "true",
		"configs.AS4_REALM":                                       "https://ftlserver:8585",
		"envVarsFromConfigMaps[0]":                                "myconfigmap",
		"envVarsFromSecrets[0]":                                   "mysecret",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/agents.yaml"})
	require.NoError(t, err)
	rawAgents := strings.Split(output, "---")
	var agents []appsv1.StatefulSet

	for _, rawAgent := range rawAgents {
		if strings.Trim(rawAgent, "") == "" {
			continue
		}
		var agent appsv1.StatefulSet
		helm.UnmarshalK8SYaml(t, rawAgent, &agent)
		agents = append(agents, agent)
	}

	// fmt.Println("------------", agents, "------------------------------")

	// agent 0
	expectedReleaseName := fmt.Sprintf("%s-inferenceagent", releaseName)
	expectedSVCName := fmt.Sprintf("%s-discovery-service", releaseName)
	// val := "tcp://persistencenone-inferenceagent-0.persistencenone-discovery-service:50000;persistencenone-cacheagent-0.persistencenone-discovery-service:50000;"
	require.Equal(t, "StatefulSet", agents[0].Kind)
	require.Equal(t, "apps/v1", agents[0].APIVersion)
	require.Equal(t, int32(1), *agents[0].Spec.Replicas)
	require.Equal(t, expectedSVCName, agents[0].Spec.ServiceName)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Template.Labels["name"])
	require.Equal(t, expectedReleaseName, agents[0].Name)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Selector.MatchLabels["name"])
	require.Equal(t, "inferenceagent-container", agents[0].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", agents[0].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, "besecret", agents[1].Spec.Template.Spec.ImagePullSecrets[0].Name)
	require.Equal(t, v1.PullIfNotPresent, agents[0].Spec.Template.Spec.Containers[0].ImagePullPolicy)
	require.Equal(t, "persistencenone-configmap", agents[0].Spec.Template.Spec.Containers[0].EnvFrom[0].ConfigMapRef.Name)
	require.Equal(t, "myconfigmap", agents[0].Spec.Template.Spec.Containers[0].EnvFrom[1].ConfigMapRef.Name)
	require.Equal(t, "mysecret", agents[0].Spec.Template.Spec.Containers[0].EnvFrom[2].SecretRef.Name)
	require.Equal(t, "default", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "PU"))
	require.Equal(t, "http://ftlserver:8585", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "FTL_REALM_SERVER"))
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "/mnt/tibco/be/data-store", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "data-store"))
	require.Equal(t, "persistencenone-logs", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "logs"))
	require.Equal(t, "persistencenone-data-store", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "data-store"))

	// agent 1
	expectedCacheReleaseName := fmt.Sprintf("%s-cacheagent", releaseName)
	require.Equal(t, "StatefulSet", agents[1].Kind)
	require.Equal(t, "apps/v1", agents[1].APIVersion)
	require.Equal(t, int32(1), *agents[1].Spec.Replicas)
	require.Equal(t, expectedSVCName, agents[1].Spec.ServiceName)
	require.Equal(t, expectedCacheReleaseName, agents[1].Spec.Template.Labels["name"])
	require.Equal(t, expectedCacheReleaseName, agents[1].Name)
	require.Equal(t, expectedCacheReleaseName, agents[1].Spec.Selector.MatchLabels["name"])
	require.Equal(t, "cacheagent-container", agents[1].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", agents[1].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, "besecret", agents[1].Spec.Template.Spec.ImagePullSecrets[0].Name)
	require.Equal(t, v1.PullIfNotPresent, agents[1].Spec.Template.Spec.Containers[0].ImagePullPolicy)
	require.Equal(t, "persistencenone-configmap", agents[0].Spec.Template.Spec.Containers[0].EnvFrom[0].ConfigMapRef.Name)
	require.Equal(t, "myconfigmap", agents[1].Spec.Template.Spec.Containers[0].EnvFrom[1].ConfigMapRef.Name)
	require.Equal(t, "mysecret", agents[1].Spec.Template.Spec.Containers[0].EnvFrom[2].SecretRef.Name)
	require.Equal(t, "cache", valueFromEnv(agents[1].Spec.Template.Spec.Containers[0].Env, "PU"))
	require.Equal(t, "http://ftlserver:8585", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "FTL_REALM_SERVER"))
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(agents[1].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "/mnt/tibco/be/data-store", valueFromVolumeMount(agents[1].Spec.Template.Spec.Containers[0].VolumeMounts, "data-store"))
	require.Equal(t, "persistencenone-logs", valueFromVolumes(agents[1].Spec.Template.Spec.Volumes, "logs"))
	require.Equal(t, "persistencenone-data-store", valueFromVolumes(agents[1].Spec.Template.Spec.Volumes, "data-store"))
}

//  Template test for rms deployment with ignite cassandra
func TestAgentsRNSIgniteCassandra(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "persistencenone"

	require.NoError(t, err)

	values := map[string]string{
		"cmType":                     "ignite",
		"bsType":                     "none",
		"imagepullsecret":            "besecret",
		"rmsDeployment":              "true",
		"envVars.CASS_SERVER":        "localhost:9042",
		"envVars.CASS_KEYSPACE_NAME": "testdb",
		"persistence.logs":           "true",
		"persistence.rmsWebstudio":   "true",
		"persistence.rmsSharedPVC":   "persistencenone-rms-shared",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/agents.yaml"})
	require.NoError(t, err)
	rawAgents := strings.Split(output, "---")
	var agents []appsv1.StatefulSet

	for _, rawAgent := range rawAgents {
		if strings.Trim(rawAgent, "") == "" {
			continue
		}
		var agent appsv1.StatefulSet
		helm.UnmarshalK8SYaml(t, rawAgent, &agent)
		agents = append(agents, agent)
	}

	// fmt.Println("------------", agents, "------------------------------")

	// agent 0
	expectedReleaseName := fmt.Sprintf("%s-inferenceagent", releaseName)
	expectedSVCName := fmt.Sprintf("%s-discovery-service", releaseName)
	expectedServiceAccName := fmt.Sprintf("%s-ignite", releaseName)
	require.Equal(t, "StatefulSet", agents[0].Kind)
	require.Equal(t, "apps/v1", agents[0].APIVersion)
	require.Equal(t, int32(1), *agents[0].Spec.Replicas)
	require.Equal(t, expectedSVCName, agents[0].Spec.ServiceName)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Template.Labels["name"])
	require.Equal(t, expectedReleaseName, agents[0].Name)
	require.Equal(t, expectedReleaseName, agents[0].Spec.Selector.MatchLabels["name"])
	require.Equal(t, expectedServiceAccName, agents[0].Spec.Template.Spec.DeprecatedServiceAccount)
	require.Equal(t, "inferenceagent-container", agents[0].Spec.Template.Spec.Containers[0].Name)
	require.Equal(t, "befdapp:01", agents[0].Spec.Template.Spec.Containers[0].Image)
	require.Equal(t, v1.PullIfNotPresent, agents[0].Spec.Template.Spec.Containers[0].ImagePullPolicy)
	require.Equal(t, "default", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "PU"))
	// require.Equal(t, "123", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "ENGINE_NAME"))
	require.Equal(t, "testdb", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "CASS_KEYSPACE_NAME"))
	require.Equal(t, "localhost:9042", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "CASS_SERVER"))
	require.Equal(t, "persistencenone-discovery-service", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "tra.be.ignite.k8s.service.name"))
	require.Equal(t, "k8s", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "tra.be.ignite.discovery.type"))
	require.Equal(t, "default", valueFromEnv(agents[0].Spec.Template.Spec.Containers[0].Env, "tra.be.ignite.k8s.namespace"))
	require.Equal(t, "/mnt/tibco/be/logs", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "logs"))
	require.Equal(t, "persistencenone-logs", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "logs"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/shared", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-shared"))
	require.Equal(t, "persistencenone-rms-shared", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "rms-shared"))
	require.Equal(t, "/opt/tibco/be/6.1/rms/config/security", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-security"))
	require.Equal(t, "persistencenone-rms-security", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "rms-security"))
	require.Equal(t, "/opt/tibco/be/6.1/examples/standard/WebStudio", valueFromVolumeMount(agents[0].Spec.Template.Spec.Containers[0].VolumeMounts, "rms-webstudio"))
	require.Equal(t, "persistencenone-rms-webstudio", valueFromVolumes(agents[0].Spec.Template.Spec.Volumes, "rms-webstudio"))

}

func valueFromEnv(data []v1.EnvVar, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.Value
		}
	}
	return ""
}

func valueFromVolumeMount(data []v1.VolumeMount, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.MountPath
		}
	}
	return ""
}

func valueFromVolumes(data []v1.Volume, key string) string {
	for _, d1 := range data {
		if d1.Name == key {
			return d1.PersistentVolumeClaim.ClaimName
		}
	}
	return ""
}
