package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestMetricsFTLCacheStoreCassandra(t *testing.T) {
	options := &helm.Options{
		SetValues: common.MetricsFTLCacheCassandraStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceMetricsFTLCassTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheMetricsFTLCassTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapCassandraTest(configOutPut, t)

	delete(common.Values, "metricsType")
}

func TestMetricsFTLCacheStoreMysql(t *testing.T) {
	options := &helm.Options{
		SetValues: common.MetricsFTLCacheMysqlStoreValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceMetricsFTLMysqlTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheagent})
	cacheMetricsFTLMysqlTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Becacheservice})
	igniteCacheServiceTest(beCacheServiceOutput, t)

	// configmap test
	configOutPut := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Configmap})
	configMapMysqlTest(configOutPut, t)

	delete(common.Values, "metricsType")
}

func TestMetricsCustomInmemory(t *testing.T) {

	options := &helm.Options{
		SetValues: common.MetricsCustomInmemoryValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceMetricsCustomTest(output, t)
}
