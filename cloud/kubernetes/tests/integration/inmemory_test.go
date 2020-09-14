//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package integration

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"testing"
	"time"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

func inferenceDeploy(t *testing.T, releaseName string) {
	// inference pod
	podName := fmt.Sprintf("%s-beinferenceagent-0", releaseName)
	retries := 15
	sleep := 5 * time.Second
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, retries, sleep)

	// be service
	serviceName := fmt.Sprintf("%s-beservice", releaseName)
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, serviceName, retries, sleep)
	beService := k8s.GetService(t, kubectlOptions, serviceName)
	if beService.Spec.Type != "NodePort" {
		t.Logf("BE service type (%s) is not expected (%s)", beService.Spec.Type, "NodePort")
		t.Fail()
	}

	// jmx-service
	jmxServiceName := fmt.Sprintf("%s-jmx-service", releaseName)
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, jmxServiceName, retries, sleep)
}

func cacheDeploy(t *testing.T, releaseName string) {

	// cache pod
	podName := fmt.Sprintf("%s-becacheagent-0", releaseName)
	retries := 15
	sleep := 5 * time.Second
	k8s.WaitUntilPodAvailable(t, kubectlOptions, podName, retries, sleep)

	// cache service
	serviceName := fmt.Sprintf("%s-becache-service", releaseName)
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, serviceName, retries, sleep)
}
func cassandraDeploy(t *testing.T, releaseName string) {

	// cassandra pod
	retries := 15
	sleep := 5 * time.Second
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "release-cassandra-0", retries, sleep)

	// cassandra service
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, "release-cassandra", retries, sleep)
}
func mysqlService(t *testing.T, releaseName string) {

	// mysql service
	retries := 15
	sleep := 5 * time.Second
	serviceName := fmt.Sprintf("%s-mysql", releaseName)
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, serviceName, retries, sleep)
}

func FTLDeploy(t *testing.T, releaseName string) {

	// ftl pod
	retries := 15
	sleep := 5 * time.Second
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "ftlserver4be-0", retries, sleep)

	// ftl service
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, "ftlservers4be", retries, sleep)
}

func AS4Deploy(t *testing.T, releaseName string) {

	// as4 pod
	retries := 15
	sleep := 5 * time.Second
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "admind-0", retries, sleep)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "cs-01-node-0", retries, sleep)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "ftlserver-0", retries, sleep)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "keeper-0", retries, sleep)
	k8s.WaitUntilPodAvailable(t, kubectlOptions, "proxy-0", retries, sleep)

	// as4 service
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, "tibdgadmind", retries, sleep)

	// ftl service
	k8s.WaitUntilServiceAvailable(t, kubectlOptions, "ftlservers", retries, sleep)
}

// command to run in terminal
func command(name string, arg ...string) {
	fmt.Printf("%s %v\n", name, arg)
	output, err := exec.Command(name, arg...).CombinedOutput()
	if err != nil {
		os.Stderr.WriteString(err.Error())
	}
	if len(output) > 0 {
		fmt.Printf("%s", string(output))
	}
}

// TestInMemoryDeploy inmemory application deployment
func TestInMemoryDeploy(t *testing.T) {
	values := common.InmemoryValues()
	values["image"] = common.UnclInmemory
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "inmem-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, helmOptions, releaseName, true)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	inferenceDeploy(t, releaseName)
}

// TestUnclCassandra unclustered cassandra application deployment
func TestUnclCassandra(t *testing.T) {
	values := common.InmemoryCassandraStoreValues()
	values["image"] = common.Unclcass
	values["cassconfigmap.cass_server"] = common.Casshost
	values["cassconfigmap.cass_username"] = common.Cassandraun
	values["cassconfigmap.cass_password"] = common.Cassandrapwd
	helmOptions := &helm.Options{
		SetValues: values,
	}
	options := &helm.Options{
		SetValues: common.CassChartValues,
	}
	releaseName := fmt.Sprintf("beapp-%s", "unclustercass-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, options, common.CassandraRelease, true)
	defer helm.Delete(t, helmOptions, releaseName, true)
	command("helm", "repo", "add", " bitnami", "https://charts.bitnami.com/bitnami")
	helm.Install(t, options, common.CassandraChart, common.CassandraRelease)
	cassandraDeploy(t, releaseName)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(50 * time.Second)
	command("/bin/bash", "./run.sh", "cassandra")
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
}

func TestUnclAS4(t *testing.T) {
	values := common.InmemoryAS4StoreValues()
	values["image"] = common.Unclas4
	values["as4configmap.realm_url"] = common.AS4realm
	values["as4configmap.grid_name"] = common.AS4grid
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "unclustercass-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer k8s.KubectlDelete(t, kubectlOptions, common.AS4PATH)
	defer helm.Delete(t, helmOptions, releaseName, true)
	k8s.KubectlApply(t, kubectlOptions, common.AS4PATH)
	AS4Deploy(t, releaseName)
	time.Sleep(20 * time.Second)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
}
