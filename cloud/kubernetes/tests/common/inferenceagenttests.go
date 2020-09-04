//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package common

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	appsv1 "k8s.io/api/apps/v1"
)

// InferenceTest testing inference content
func InferenceTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)

}

// InferenceFTLStoreAS4Test testing inference content for ftl cluster and cache type as store as4
func InferenceFTLStoreAS4Test(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// InferenceFTLStoreCassTest testing inference content for ftl cluster and cache type as store cassandra
func InferenceFTLStoreCassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}

// InferenceFTLNoneTest testing inference content for FTL cluster backing store none
func InferenceFTLNoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
}

// InferenceFTLSNTest testing inference content for FTL cluster backing store shared nothing
func InferenceFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// InferenceAS2NoneTest testing inference content for AS2 cluster backing store none
func InferenceAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
}

// InferenceAS2SNTest testing inference content for AS2 cluster shared nothing
func InferenceAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// InferenceAS2MysqlTest testing inference content for AS2 cluster backing store mysql
func InferenceAS2MysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// InferenceFTLMysqlTest testing inference content for FTL cluster backing store none
func InferenceFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// InferenceFTLAS4Test testing inference content for FTL cluster backing store as4
func InferenceFTLAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// InferenceFTLCassTest testing inference content for FTL cluster backing store cassandra
func InferenceFTLCassTest(data string, t *testing.T) {
	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	agentTestcases(sSet, t)
	inferenceTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}
