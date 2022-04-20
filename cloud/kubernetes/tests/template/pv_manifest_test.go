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

func TestPVManifest(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPVManifest"
	require.NoError(t, err)

	// TC: empty PVs
	values := map[string]string{}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NotNil(t, err)

	// TC: aws, sharedNothing, static PV provisioning
	values = map[string]string{
		"cpType":                   "aws",
		"bsType":                   "sharednothing",
		"persistence.storageClass": "-",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
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
	require.Equal(t, 1, len(actualPVs))
	expectedReleaseName := fmt.Sprintf("%s-%s", releaseName, "data-store")
	volumeHandle := fmt.Sprintf("fs-beec7f0a:/volume1/%s", "data-store")
	require.Equal(t, expectedReleaseName, actualPVs[0].ObjectMeta.Name)
	actualMemQty := actualPVs[0].Spec.Capacity["storage"]
	require.Equal(t, "512Mi", actualMemQty.String())
	require.Equal(t, "", actualPVs[0].Spec.StorageClassName)
	require.Equal(t, expectedReleaseName, actualPVs[0].Spec.ClaimRef.Name)
	require.Equal(t, "efs.csi.aws.com", actualPVs[0].Spec.CSI.Driver)
	require.Equal(t, volumeHandle, actualPVs[0].Spec.CSI.VolumeHandle)

	// TC: aws, sharedNothing, persitence enbled (for logs, rms) and static PV provisioning
	values = map[string]string{
		"cpType":                   "aws",
		"bsType":                   "sharednothing",
		"rmsDeployment":            "true",
		"persistence.logs":         "true",
		"persistence.rmsWebstudio": "true",
		"persistence.storageClass": "-",
	}
	options = &helm.Options{
		SetValues: values,
	}
	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NoError(t, err)
	rawPVs = strings.Split(output, "---")
	actualPVs = []v1.PersistentVolume{}
	for _, rawPV := range rawPVs {
		if strings.Trim(rawPV, "") == "" {
			continue
		}
		var PV v1.PersistentVolume
		helm.UnmarshalK8SYaml(t, rawPV, &PV)
		actualPVs = append(actualPVs, PV)
	}
	expectedPVsMap := map[string]map[string]interface{}{
		"TestPVManifest-data-store": {
			"releaseName":  "TestPVManifest-data-store",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifest-data-store",
			"csidriver":    "efs.csi.aws.com",
			"volume":       fmt.Sprintf("fs-beec7f0a:/volume1/%s", "data-store"),
		},
		"TestPVManifest-rms-shared": {
			"releaseName":  "TestPVManifest-rms-shared",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifest-rms-shared",
			"csidriver":    "efs.csi.aws.com",
			"volume":       fmt.Sprintf("fs-beec7f0a:/volume1/%s", "rms-shared"),
		},
		"TestPVManifest-rms-security": {
			"releaseName":  "TestPVManifest-rms-security",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifest-rms-security",
			"csidriver":    "efs.csi.aws.com",
			"volume":       fmt.Sprintf("fs-beec7f0a:/volume1/%s", "rms-security"),
		},
		"TestPVManifest-rms-webstudio": {
			"releaseName":  "TestPVManifest-rms-webstudio",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifest-rms-webstudio",
			"csidriver":    "efs.csi.aws.com",
			"volume":       fmt.Sprintf("fs-beec7f0a:/volume1/%s", "rms-webstudio"),
		},
		"TestPVManifest-logs": {
			"releaseName":  "TestPVManifest-logs",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifest-logs",
			"csidriver":    "efs.csi.aws.com",
			"volume":       fmt.Sprintf("fs-beec7f0a:/volume1/%s", "logs"),
		},
	}
	require.Equal(t, 5, len(actualPVs))

	for _, actualPV := range actualPVs {
		actualPVName := actualPV.ObjectMeta.Name
		expectedPV, found := expectedPVsMap[actualPVName]
		require.Truef(t, found, fmt.Sprintf("PV name[%s] is not expected", actualPVName))
		require.Equal(t, expectedPV["releaseName"], actualPV.ObjectMeta.Name)
		actualMemQty = actualPV.Spec.Capacity["storage"]
		require.Equal(t, expectedPV["memoryQty"], actualMemQty.String())
		require.Equal(t, expectedPV["scName"], actualPV.Spec.StorageClassName)
		require.Equal(t, expectedPV["claimRefName"], actualPV.Spec.ClaimRef.Name)
		require.Equal(t, expectedPV["csidriver"], actualPV.Spec.CSI.Driver)
		require.Equal(t, expectedPV["volume"], actualPV.Spec.CSI.VolumeHandle)
	}
}

func TestPVManifestMinikube(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPVManifestMinikube"
	require.NoError(t, err)

	// TC: minikube, sharedNothing, static PV provisioning
	values := map[string]string{
		"cpType":                   "minikube",
		"bsType":                   "sharednothing",
		"persistence.storageClass": "-",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NoError(t, err)
	rawPVs := strings.Split(output, "---")
	actualPVs := []v1.PersistentVolume{}
	for _, rawPV := range rawPVs {
		if strings.Trim(rawPV, "") == "" {
			continue
		}
		var PV v1.PersistentVolume
		helm.UnmarshalK8SYaml(t, rawPV, &PV)
		actualPVs = append(actualPVs, PV)
	}
	require.Equal(t, 1, len(actualPVs))
	expectedReleaseName := fmt.Sprintf("%s-%s", releaseName, "data-store")
	require.Equal(t, expectedReleaseName, actualPVs[0].ObjectMeta.Name)
	actualMemQty := actualPVs[0].Spec.Capacity["storage"]
	require.Equal(t, "512Mi", actualMemQty.String())
	require.Equal(t, "", actualPVs[0].Spec.StorageClassName)
	require.Equal(t, expectedReleaseName, actualPVs[0].Spec.ClaimRef.Name)
	require.Equal(t, v1.HostPathType("DirectoryOrCreate"), *actualPVs[0].Spec.HostPath.Type)
	require.Equal(t, "/volume1/data-store", actualPVs[0].Spec.HostPath.Path)
}

func TestPVManifestSNLogs(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPVManifestSNLogs"
	require.NoError(t, err)

	// TC: minikube, sharedNothing, persitence enbled (for logs)
	values := map[string]string{
		"bsType":                   "sharednothing",
		"persistence.logs":         "true",
		"persistence.storageClass": "-",
	}
	options := &helm.Options{
		SetValues: values,
	}
	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pv-manifest.yaml"})
	require.NoError(t, err)
	rawPVs := strings.Split(output, "---")
	actualPVs := []v1.PersistentVolume{}
	for _, rawPV := range rawPVs {
		if strings.Trim(rawPV, "") == "" {
			continue
		}
		var PV v1.PersistentVolume
		helm.UnmarshalK8SYaml(t, rawPV, &PV)
		actualPVs = append(actualPVs, PV)
	}
	expectedPVsMap := map[string]map[string]interface{}{
		"TestPVManifestSNLogs-data-store": {
			"releaseName":  "TestPVManifestSNLogs-data-store",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifestSNLogs-data-store",
			"path":         "/volume1/data-store",
			"type":         "DirectoryOrCreate",
		},
		"TestPVManifestSNLogs-logs": {
			"releaseName":  "TestPVManifestSNLogs-logs",
			"memoryQty":    "512Mi",
			"scName":       "",
			"claimRefName": "TestPVManifestSNLogs-logs",
			"path":         "/volume1/logs",
			"type":         "DirectoryOrCreate",
		},
	}
	require.Equal(t, 2, len(actualPVs))

	for _, actualPV := range actualPVs {
		actualPVName := actualPV.ObjectMeta.Name
		expectedPV, found := expectedPVsMap[actualPVName]
		require.Truef(t, found, fmt.Sprintf("PV name[%s] is not expected", actualPVName))
		require.Equal(t, expectedPV["releaseName"], actualPV.ObjectMeta.Name)
		actualMemQty := actualPV.Spec.Capacity["storage"]
		require.Equal(t, expectedPV["memoryQty"], actualMemQty.String())
		require.Equal(t, expectedPV["scName"], actualPV.Spec.StorageClassName)
		require.Equal(t, expectedPV["claimRefName"], actualPV.Spec.ClaimRef.Name)
		require.Equal(t, v1.HostPathType(fmt.Sprintf("%s", expectedPV["type"])), *actualPV.Spec.HostPath.Type)
		require.Equal(t, expectedPV["path"], actualPV.Spec.HostPath.Path)
	}
}
