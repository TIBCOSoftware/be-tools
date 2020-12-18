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
	asDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
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
	configMapEnvRDBMSTestcases(sSet, t)
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
