//
//  Copyright (c) 2019-2020. TIBCO Software Inc.
//  This file is subject to the license terms contained in the license file that is distributed with this file.
//
package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestAS2CacheRDBMSMysqlStore(t *testing.T) {
	options := &helm.Options{
		SetValues: common.AS2CacheRDBMSStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceAS2MysqlTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheAS2MysqlTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.AS2CacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := beconfmap(t, options, common.HelmChartPath)
	common.ConfigMapMysqlTest(configOutPut, t)
}

func TestFTLCacheStoreAS4(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheAS4StoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceFTLAS4Test(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheFTLAS4Test(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := beconfmap(t, options, common.HelmChartPath)
	common.ConfigMapAS4Test(configOutPut, t)
}

func TestFTLCacheStoreCassandra(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheCassandraStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceFTLCassTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheFTLCassTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := beconfmap(t, options, common.HelmChartPath)
	common.ConfigMapCassandraTest(configOutPut, t)
}

func TestFTLCacheStoreMysql(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheMysqlStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := beinferenceagent(t, options, common.HelmChartPath)
	common.InferenceFTLMysqlTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := cacheagent(t, options, common.HelmChartPath)
	common.CacheFTLMysqlTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := cacheservice(t, options, common.HelmChartPath)
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := beconfmap(t, options, common.HelmChartPath)
	common.ConfigMapMysqlTest(configOutPut, t)
}
