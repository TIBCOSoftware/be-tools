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

func TestInmemory(t *testing.T) {

	options := &helm.Options{
		SetValues: common.InmemoryValues(),
	}

	appAndJmxServices(t, options, common.HelmChartPath)

	// inference agent test
	output := helm.RenderTemplate(t, options, common.HelmChartPath, common.ReleaseName, []string{common.Beinferenceagent})
	inferenceTest(output, t)
}
