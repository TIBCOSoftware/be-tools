package integration

import (
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/helm/tests/common"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

func TestDeploy(t *testing.T) {
	helmChartPath := "../../"
	kubectlOptions := k8s.NewKubectlOptions("", "", "default")
	helmOptions := &helm.Options{
		SetValues: common.InmemoryValues(),
	}
	releaseName := fmt.Sprintf("beapp-%s", strings.ToLower(random.UniqueId()))

	// Deploy the chart using `helm install`.
	defer helm.Delete(t, helmOptions, releaseName, true)
	helm.Install(t, helmOptions, helmChartPath, releaseName)

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
