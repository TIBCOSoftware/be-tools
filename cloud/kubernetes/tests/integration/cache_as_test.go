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
	"github.com/gruntwork-io/terratest/modules/random"
)

// TestAS2NoneDeploy as2 cache application deployment
func TestAS2NoneDeploy(t *testing.T) {
	values := common.AS2CacheNoneValues()
	values["image"] = common.AS2none
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "cachenone-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, helmOptions, releaseName, true)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestAS2SNDeploy AS2 sharedNothing application deployment
func TestAS2SNDeploy(t *testing.T) {
	values := common.AS2CacheSNValues()
	values["image"] = common.AS2SN
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "cachesn-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, helmOptions, releaseName, true)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}

// TestAS2mysqlDeploy AS2mysql application deployment
func TestAS2mysqlDeploy(t *testing.T) {
	values := common.AS2CacheRDBMSStoreValues()
	values["image"] = common.AS2mysql
	helmOptions := &helm.Options{
		SetValues: values,
	}
	releaseName := fmt.Sprintf("beapp-%s", "cachesql-"+strings.ToLower(random.UniqueId()))
	// Deploy the chart using `helm install`.
	defer helm.Delete(t, helmOptions, releaseName, true)
	helm.Install(t, helmOptions, common.HelmChartPath, releaseName)
	mysqlService(t, releaseName)
	time.Sleep(50 * time.Second)
	command("/bin/sh", "run.sh", "mysql")
	time.Sleep(50 * time.Second)
	inferenceDeploy(t, releaseName)
	cacheDeploy(t, releaseName)
}
