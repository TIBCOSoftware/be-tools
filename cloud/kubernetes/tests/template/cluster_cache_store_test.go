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
	common.Values["imagepullsecret"] = common.ImgPullSecret
	options := &helm.Options{
		SetValues: common.AS2CacheRDBMSStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceAS2MysqlTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheAS2MysqlTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	aS2CacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapMysqlTest(configOutPut, t)

	delete(common.Values, "imagepullsecret")
}

func TestFTLCacheStoreAS4(t *testing.T) {
	common.Values["imageCredentials.registry"] = "hub.docker.com"
	common.Values["imageCredentials.username"] = "test1234"
	common.Values["imageCredentials.password"] = "test1234"
	common.Values["imageCredentials.email"] = "test@test1.com"
	options := &helm.Options{
		SetValues: common.FTLCacheAS4StoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLAS4Test(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheFTLAS4Test(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapAS4Test(configOutPut, t)

	// image pull secret test
	secretOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.SecretFile})
	secret(secretOutput, t)

	delete(common.Values, "imageCredentials.registry")
}

func TestFTLCacheStoreCassandra(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheCassandraStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLCassTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheFTLCassTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapCassandraTest(configOutPut, t)
}

func TestFTLCacheStoreMysql(t *testing.T) {
	options := &helm.Options{
		SetValues: common.FTLCacheMysqlStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceFTLMysqlTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheFTLMysqlTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapMysqlTest(configOutPut, t)
}
