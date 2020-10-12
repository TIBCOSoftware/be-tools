// #
// # Copyright (c) 2019-2020. TIBCO Software Inc.
// # This file is subject to the license terms contained in the license file that is distributed with this file.
// #
package integration

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

// kubectlOptions kubectl options variable
var kubectlOptions = k8s.NewKubectlOptions("", "", "default")

// TestFTLNoneDeploy FTL cache none application deployment
func TestFTLNoneDeploy(t *testing.T) {
	values := common.FTLCacheNoneValues()
	values["image"] = common.Ftlnone
	values["ftl.FTL_gv_REALM_SERVER"] = common.Ftlrealm
	helmOptions := &helm.Options{
		SetValues: values,
	}

	releaseName := fmt.Sprintf("beapp-%s", "ftlnone-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.FTLPATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.FTLPATH)
	FTLDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(20 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestFTLSNDeploy FTL cache sharedNothing application deployment
func TestFTLSNDeploy(t *testing.T) {
	values := common.FTLCacheSNValues()
	values["image"] = common.FtlSN
	values["ftl.FTL_gv_REALM_SERVER"] = common.Ftlrealm
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlsn-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.FTLPATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.FTLPATH)
	FTLDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(20 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestFTLMYSQLDeploy FTL cache mysql application deployment
func TestFTLMYSQLDeploy(t *testing.T) {
	values := common.FTLCacheMysqlStoreValues()
	values["image"] = common.Ftlmysql
	values["ftl.FTL_gv_REALM_SERVER"] = common.Ftlrealm
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlmysql-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.FTLPATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.FTLPATH)
	FTLDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	mysqlService(t, releaseName)
	time.Sleep(50 * time.Second)
	command("/bin/bash", "run.sh", "mysql")
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestFTLcacheCassandraDeploy FTL cache cassandra application deployment
func TestFTLCacheCassandraDeploy(t *testing.T) {
	values := common.FTLCacheCassandraStoreValues()
	values["image"] = common.FTLCacheCass
	values["ftl.FTL_gv_REALM_SERVER"] = common.Ftlrealm
	values["cassconfigmap.cass_server"] = common.Casshost
	values["cassconfigmap.cass_username"] = common.Cassandraun
	values["cassconfigmap.cass_password"] = common.Cassandrapwd
	helmOptions := &helm.Options{
		SetValues: values,
	}
	options := &helm.Options{
		SetValues: common.CassChartValues,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlcachecass-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, options, common.CassandraRelease, true)
	defer k8s.KubectlDelete(t, kubectlOptions, common.FTLPATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	command("helm", "repo", "add", " bitnami", "https://charts.bitnami.com/bitnami")
	helm.Install(t, options, common.CassandraChart, common.CassandraRelease)
	k8s.KubectlApply(t, kubectlOptions, common.FTLPATH)
	cassandraDeploy(t, releaseName)
	FTLDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(50 * time.Second)
	command("/bin/bash", "run.sh", "cassandra")
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestFTLCacheAS4 FTL cache as4 deployment
func TestFTLCacheAS4(t *testing.T) {
	values := common.FTLCacheAS4StoreValues()
	values["image"] = common.FTLCacheAS4
	values["as4configmap.realm_url"] = common.AS4realm
	values["as4configmap.grid_name"] = common.AS4grid
	values["ftl.FTL_gv_REALM_SERVER"] = common.AS4realm
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlcacheas4-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.AS4PATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.AS4PATH)
	AS4Deploy(t, releaseName)
	time.Sleep(20 * time.Second)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestFTLstoreCassandraDeploy FTL Direct store cassandra deployment
func TestFTLStoreCassandraDeploy(t *testing.T) {
	values := common.FTLCassandraStoreValues()
	values["image"] = common.FTLStoreCass
	values["ftl.FTL_gv_REALM_SERVER"] = common.Ftlrealm
	values["cassconfigmap.cass_server"] = common.Casshost
	values["cassconfigmap.cass_username"] = common.Cassandraun
	values["cassconfigmap.cass_password"] = common.Cassandrapwd
	helmOptions := &helm.Options{
		SetValues: values,
	}
	options := &helm.Options{
		SetValues: common.CassChartValues,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlcachecass-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, options, common.CassandraRelease, true)
	defer k8s.KubectlDelete(t, kubectlOptions, common.FTLPATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	command("helm", "repo", "add", " bitnami", "https://charts.bitnami.com/bitnami")
	helm.Install(t, options, common.CassandraChart, common.CassandraRelease)
	k8s.KubectlApply(t, kubectlOptions, common.FTLPATH)
	cassandraDeploy(t, releaseName)
	FTLDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(50 * time.Second)
	command("/bin/bash", "run.sh", "cassandra")
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
}

// TestFTLStoreAS4 FTL direct store as4 deployment
func TestFTLStoreAS4(t *testing.T) {
	values := common.FTLAS4StoreValues()
	values["image"] = common.FTLStoreAs4
	values["as4configmap.realm_url"] = common.AS4realm
	values["as4configmap.grid_name"] = common.AS4grid
	values["ftl.FTL_gv_REALM_SERVER"] = common.AS4realm
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "ftlstoreas4-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.AS4PATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.AS4PATH)
	AS4Deploy(t, releaseName)
	time.Sleep(20 * time.Second)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(60 * time.Second)
	inferenceDeploy(t, releaseName)
}
