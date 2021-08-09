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

// Temolate test for rms minikube static provisioning
func TestPVaws(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPV"
	require.NoError(t, err)

	values := map[string]string{
		"cpType":                              "aws",
		"persistence.storageClass":            "-",
		"persistence.logs":                    "true",
		"persistence.rmsWebstudio":            "true",
		"rmsDeployment":                       "true",
		"persistence.scSupportsReadWriteMany": "true",
		"bsType":                              "sharednothing",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NoError(t, err)
	rawPVs := strings.Split(output, "---")
	var actualPVs []v1.PersistentVolume
	for _, rawPV := range rawPVs {
		if strings.Trim(rawPV, "") == "" {
			continue
		}
		var PV v1.PersistentVolume
		helm.UnmarshalK8SYaml(t, rawPV, &PV)
		actualPVs = append(actualPVs, PV)
	}

	vName := [5]string{"data-store", "logs", "rms-shared", "rms-security", "rms-webstudio"}
	for i := 0; i < len(actualPVs); i++ {
		expectedReleaseName := fmt.Sprintf("TestPV-%s", vName[i])
		volumeHandle := fmt.Sprintf("fs-beec7f0a:/volume1/%s", vName[i])
		require.Equal(t, expectedReleaseName, actualPVs[i].ObjectMeta.Name)
		require.Equal(t, "keep", actualPVs[i].ObjectMeta.Annotations["helm.sh/resource-policy"])
		require.Equal(t, v1.PersistentVolumeMode("Filesystem"), *actualPVs[i].Spec.VolumeMode)
		require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), actualPVs[i].Spec.AccessModes)
		require.Equal(t, v1.PersistentVolumeReclaimPolicy("Retain"), actualPVs[i].Spec.PersistentVolumeReclaimPolicy)
		require.Equal(t, "", actualPVs[i].Spec.StorageClassName)
		require.Equal(t, expectedReleaseName, actualPVs[i].Spec.ClaimRef.Name)
		require.Equal(t, "default", actualPVs[i].Spec.ClaimRef.Namespace)
		require.Equal(t, "efs.csi.aws.com", actualPVs[i].Spec.CSI.Driver)
		require.Equal(t, volumeHandle, *&actualPVs[i].Spec.CSI.VolumeHandle)
	}
}

// Template test for RMS minikube
func TestPVminikube(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPV"
	require.NoError(t, err)

	values := map[string]string{
		"cpType":                              "minikube",
		"persistence.storageClass":            "-",
		"persistence.logs":                    "true",
		"persistence.rmsWebstudio":            "true",
		"rmsDeployment":                       "true",
		"persistence.scSupportsReadWriteMany": "true",
		"bsType":                              "sharednothing",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NoError(t, err)
	rawPVs := strings.Split(output, "---")
	var actualPVs []v1.PersistentVolume
	for _, rawPV := range rawPVs {
		if strings.Trim(rawPV, "") == "" {
			continue
		}
		var PV v1.PersistentVolume
		helm.UnmarshalK8SYaml(t, rawPV, &PV)
		actualPVs = append(actualPVs, PV)
	}

	vName := [5]string{"data-store", "logs", "rms-shared", "rms-security", "rms-webstudio"}
	for i := 0; i < len(actualPVs); i++ {
		expectedReleaseName := fmt.Sprintf("TestPV-%s", vName[i])
		path := fmt.Sprintf("/volume1/%s", vName[i])
		require.Equal(t, expectedReleaseName, actualPVs[i].ObjectMeta.Name)
		require.Equal(t, "keep", actualPVs[i].ObjectMeta.Annotations["helm.sh/resource-policy"])
		require.Equal(t, v1.PersistentVolumeMode("Filesystem"), *actualPVs[i].Spec.VolumeMode)
		require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), actualPVs[i].Spec.AccessModes)
		require.Equal(t, v1.PersistentVolumeReclaimPolicy("Retain"), actualPVs[i].Spec.PersistentVolumeReclaimPolicy)
		require.Equal(t, "", actualPVs[i].Spec.StorageClassName)
		require.Equal(t, expectedReleaseName, actualPVs[i].Spec.ClaimRef.Name)
		require.Equal(t, "default", actualPVs[i].Spec.ClaimRef.Namespace)
		require.Equal(t, path, actualPVs[i].Spec.HostPath.Path)
		require.Equal(t, v1.HostPathType("DirectoryOrCreate"), *actualPVs[i].Spec.HostPath.Type)
	}
}
