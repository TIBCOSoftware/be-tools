package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestAS2CacheNone(t *testing.T) {
	helmChartPath := "../../helm"
	options := &helm.Options{
		SetValues: common.AS2CacheNoneValues(),
	}

	appAndJmxServices(t, options, helmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceAS2NoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheagent", []string{"templates/becacheagent.yaml"})
	common.CacheAS2NoneTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheservice", []string{"templates/becache-service.yaml"})
	common.AS2CacheServiceTest(beCacheServiceOutput, t)
}

func TestFTLCacheNone(t *testing.T) {
	helmChartPath := "../../helm"
	options := &helm.Options{
		SetValues: common.FTLCacheNoneValues(),
	}

	appAndJmxServices(t, options, helmChartPath)

	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceFTLNoneTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheagent", []string{"templates/becacheagent.yaml"})
	common.CacheFTLNoneTest(cacheAppOutput, t)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheservice", []string{"templates/becache-service.yaml"})
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)
}
