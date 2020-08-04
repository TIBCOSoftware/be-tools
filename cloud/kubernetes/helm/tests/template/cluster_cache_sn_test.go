package template

import (
	"testing"

	"github.com/TIBCOSoftware/be-tools/cloud/kubernetes/helm/tests/common"
	"github.com/gruntwork-io/terratest/modules/helm"
)

func TestAS2CacheSN(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: common.AS2CacheSNValues(),
	}

	appAndJmxServices(t, options, helmChartPath)
	cacheAndInferenceSN(t, options, helmChartPath)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheservice", []string{"templates/becache-service.yaml"})
	common.AS2CacheServiceTest(beCacheServiceOutput, t)
}

func TestFTLCacheSN(t *testing.T) {
	helmChartPath := "../../"
	options := &helm.Options{
		SetValues: common.FTLCacheSNValues(),
	}

	appAndJmxServices(t, options, helmChartPath)
	cacheAndInferenceSN(t, options, helmChartPath)

	// be cache service test
	beCacheServiceOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheservice", []string{"templates/becache-service.yaml"})
	common.IgniteCacheServiceTest(beCacheServiceOutput, t)
}

func cacheAndInferenceSN(t *testing.T, options *helm.Options, helmChartPath string) {
	// inference agent test
	inferenceOutput := helm.RenderTemplate(t, options, helmChartPath, "beinferenceagent", []string{"templates/beinferenceagent.yaml"})
	common.InferenceFTLSNTest(inferenceOutput, t)

	// cache agent test
	cacheAppOutput := helm.RenderTemplate(t, options, helmChartPath, "becacheagent", []string{"templates/becacheagent.yaml"})
	common.CacheFTLSNTest(cacheAppOutput, t)
}
