//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package template

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	appsv1 "k8s.io/api/apps/v1"
)

// inferenceTest testing inference content
func inferenceTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
}

// inferenceFTLStoreAS4Test testing inference content for ftl cluster and cache type as store as4
func inferenceFTLStoreAS4Test(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// inferenceFTLStoreCassTest testing inference content for ftl cluster and cache type as store cassandra
func inferenceFTLStoreCassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}

// inferenceFTLNoneTest testing inference content for FTL cluster backing store none
func inferenceFTLNoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
}

// inferenceFTLSNTest testing inference content for FTL cluster backing store shared nothing
func inferenceFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// inferenceAS2NoneTest testing inference content for AS2 cluster backing store none
func inferenceAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
}

// inferenceAS2SNTest testing inference content for AS2 cluster shared nothing
func inferenceAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// inferenceAS2MysqlTest testing inference content for AS2 cluster backing store mysql
func inferenceAS2MysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
	pullSecret(sSet, t)
}

// inferenceFTLMysqlTest testing inference content for FTL cluster backing store none
func inferenceFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// inferenceFTLAS4Test testing inference content for FTL cluster backing store as4
func inferenceFTLAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
	registryPullSecret(sSet, t)
}

// inferenceFTLCassTest testing inference content for FTL cluster backing store cassandra
func inferenceFTLCassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}

// inferenceMetricsFTLMysqlTest testing inference content for FTL cluster backing store none
func inferenceMetricsFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
	configMapEnvInfluxTestcases(sSet, t)
}

// inferenceMetricsFTLCassTest testing inference content for FTL cluster backing store cassandra
func inferenceMetricsFTLCassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
	configMapEnvLiveViewTestcases(sSet, t)
}

// inferenceMetricsCustomTest testing inference content
func inferenceMetricsCustomTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	metricscustomTestcases(sSet, t)
}

// inferenceIGNITENoneTest testing inference content for IGNITE cluster backing store none
func inferenceIGNITENoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
}

// inferenceIGNITESNTest testing inference content for IGNITE cluster shared nothing
func inferenceIGNITESNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// inferenceIGNITEMysqlTest testing inference content for IGNITE cluster backing store mysql
func inferenceIGNITEMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// inferenceIGNITEAS4Test testing inference content for IGNITE cluster backing store as4
func inferenceIGNITEAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// inferenceIGNITECassTest testing inference content for IGNITE cluster backing store cassandra
func inferenceIGNITECassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	IGNITEDiscoveryTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}
