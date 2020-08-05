package common

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	appsv1 "k8s.io/api/apps/v1"
)

// CacheAS2NoneTest testing cache content for AS2 cluster backing store none
func CacheAS2NoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
}

// CacheAS2SNTest testing cache content for AS2 cluster backing store shared nothing
func CacheAS2SNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// CacheFTLNoneTest testing cache content for FTL cluster backing store none
func CacheFTLNoneTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
}

// CacheFTLSNTest testing cache content for FTL cluster backing store shared nothing
func CacheFTLSNTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	checkVolumeClaims(sSet, t)
}

// CacheAS2MysqlTest testing cache content for AS2 cluster backing store none
func CacheAS2MysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	asDiscoveryTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// CacheFTLMysqlTest testing cache content for FTL cluster backing store none
func CacheFTLMysqlTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvRDBMSTestcases(sSet, t)
}

// CacheFTLAS4Test testing cache content for FTL cluster backing store none
func CacheFTLAS4Test(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvAS4Testcases(sSet, t)
}

// CacheFTLCassTest testing cache content for FTL cluster backing store none
func CacheFTLCassTest(data string, t *testing.T) {

	var sSet appsv1.StatefulSet
	helm.UnmarshalK8SYaml(t, data, &sSet)

	cacheTestcases(sSet, t)
	ftlIgniteTestcases(sSet, t)
	configMapEnvCassandraTestcases(sSet, t)
}
