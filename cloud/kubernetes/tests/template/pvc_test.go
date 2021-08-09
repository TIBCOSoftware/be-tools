package template

import (
	"fmt"
	"path/filepath"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/helm"
	"github.com/stretchr/testify/require"
	v1 "k8s.io/api/core/v1"
)

// Templates test for rms+logs+sharednothing
func TestPVC(t *testing.T) {
	helmFilePath, err := filepath.Abs("../../helm")
	releaseName := "TestPVC"

	require.NoError(t, err)

	values := map[string]string{
		"persistence.logs":                    "true",
		"persistence.rmsWebstudio":            "true",
		"rmsDeployment":                       "true",
		"persistence.scSupportsReadWriteMany": "true",
		"bsType":                              "sharednothing",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmFilePath, releaseName, []string{"templates/pvc.yaml"})
	require.NoError(t, err)
	rawPVCs := strings.Split(output, "---")
	var actualPVCs []v1.PersistentVolumeClaim
	for _, rawPVC := range rawPVCs {
		if strings.Trim(rawPVC, "") == "" {
			continue
		}
		var actualPVC v1.PersistentVolumeClaim
		helm.UnmarshalK8SYaml(t, rawPVC, &actualPVC)
		actualPVCs = append(actualPVCs, actualPVC)
	}

	vName := [5]string{"data-store", "logs", "rms-shared", "rms-security", "rms-webstudio"}
	for i := 0; i < len(actualPVCs); i++ {
		expectedReleaseName := fmt.Sprintf("TestPVC-%s", vName[i])
		require.Equal(t, expectedReleaseName, actualPVCs[i].ObjectMeta.Name)
		require.Equal(t, "keep", actualPVCs[i].ObjectMeta.Annotations["helm.sh/resource-policy"])
		require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), actualPVCs[i].Spec.AccessModes)
		require.Equal(t, "standard", *actualPVCs[i].Spec.StorageClassName)
	}
}
