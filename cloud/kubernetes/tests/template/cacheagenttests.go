//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	appsv1 "k8s.io/api/apps/v1"
	"k8s.io/api/autoscaling/v2beta2"
)

// cacheAS2NoneTest testing cache content for AS2 cluster backing store none
func cacheAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
}

// cacheAS2SNTest testing cache content for AS2 cluster backing store shared nothing
func cacheAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	cachePodAntiAffinityTestcases(sSet, t)
	checkSNandLogVolumeClaims(sSet, t)
	asDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// cacheIGNITEMysqlTest testing cache content for IGNITE cluster backing store none
func cacheAutoScalerAS2SNTest(data string, t *testing.T) {

	var cachescale v2beta2.HorizontalPodAutoscaler
	helm.UnmarshalK8SYaml(t, data, &cachescale)

	cacheAutoScalerTestcases(cachescale, t)
	cacheAutoScalerCPUNMemoryMetricsTestcases(cachescale, t)
}

// cacheFTLNoneTestt testing cache content for FTL cluster backing store none
func cacheFTLNoneTestt(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
}

// cacheFTLSNTest testing cache content for FTL cluster backing store shared nothing
func cacheFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// cacheAS2MysqlTest testing cache content for AS2 cluster backing store none
func cacheAS2MysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
	pullSecret(sSet, t)
}

// cacheFTLMysqlTest testing cache content for FTL cluster backing store none
func cacheFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// cacheFTLAS4Test testing cache content for FTL cluster backing store none
func cacheFTLAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
	registryPullSecret(sSet, t)
}

// cacheFTLCassTest testing cache content for FTL cluster backing store none
func cacheFTLCassTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}

// cacheMetricsFTLMysqlTest testing cache content for FTL cluster backing store none
func cacheMetricsFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
	configMapEnvInfluxTestcases(sSet, t)
}

// cacheMetricsFTLCassTest testing cache content for FTL cluster backing store none
func cacheMetricsFTLCassTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
	configMapEnvLiveViewTestcases(sSet, t)
}

// cacheIGNITENoneTest testing cache content for IGNITE cluster backing store none
func cacheIGNITENoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
}

// cacheIGNITESNTest testing cache content for IGNITE cluster backing store shared nothing
func cacheIGNITESNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// cacheIGNITEMysqlTest testing cache content for IGNITE cluster backing store none
func cacheIGNITEMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	checkLogVolumeClaims(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
	cacheResourceTestcases(sSet, t)
	healtCheck(sSet, t)
}

// cacheIGNITEMysqlTest testing cache content for IGNITE cluster backing store none
func cacheAutoScalerIGNITEMysqlTest(data string, t *testing.T) {

	var cachescale v2beta2.HorizontalPodAutoscaler
	helm.UnmarshalK8SYaml(t, data, &cachescale)

	cacheAutoScalerTestcases(cachescale, t)
	cacheAutoScalerMemoryMetricsTestcases(cachescale, t)
}

// cacheAutoScalerFTLCassTest testing cache content for IGNITE cluster backing store none
func cacheAutoScalerFTLCassTest(data string, t *testing.T) {

	var cachescale v2beta2.HorizontalPodAutoscaler
	helm.UnmarshalK8SYaml(t, data, &cachescale)

	cacheAutoScalerTestcases(cachescale, t)
	cacheAutoScalerCPUMetricsTestcases(cachescale, t)
}

// cacheIGNITEAS4Test testing cache content for IGNITE cluster backing store none
func cacheIGNITEAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// cacheIGNITECassTest testing cache content for IGNITE cluster backing store none
func cacheIGNITECassTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	cacheTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}

func cachePodAntiAffinityTestcases(sset appsv1.StatefulSet, t *testing.T) {

	require.Equal(t, common.CachePodAntiAffinityWeight, *&sset.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].Weight)
	require.Equal(t, []string([]string{common.CacheSelectorName}), sset.Spec.Template.Spec.Affinity.PodAntiAffinity.PreferredDuringSchedulingIgnoredDuringExecution[0].PodAffinityTerm.LabelSelector.MatchExpressions[0].Values)
}
