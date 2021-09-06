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

func TestPVC(t *testing.T) {
	helmChartPath, err := filepath.Abs("../../helm")
	releaseName := "TestPVC"

	require.NoError(t, err)

	// TC: PVC for logs + enableRMS true
	values := map[string]string{
		"persistence.logs": "true",
		"enableRMS":        "true",
	}

	options := &helm.Options{
		SetValues: values,
	}

	output, err := helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pvc.yaml"})
	require.NoError(t, err)
	var PVC v1.PersistentVolumeClaim
	helm.UnmarshalK8SYaml(t, output, &PVC)
	require.Equal(t, "TestPVC-logs", PVC.ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), PVC.Spec.AccessModes)
	require.Equal(t, "standard", *PVC.Spec.StorageClassName)
	actualMemQty := PVC.Spec.Resources.Requests["storage"]
	require.Equal(t, "512Mi", actualMemQty.String())

	// TC: PVC for sharednothing
	values = map[string]string{
		"bsType": "sharednothing",
	}

	options = &helm.Options{
		SetValues: values,
	}

	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pvc.yaml"})
	require.NoError(t, err)
	var PVCSN v1.PersistentVolumeClaim
	helm.UnmarshalK8SYaml(t, output, &PVCSN)
	require.Equal(t, "TestPVC-data-store", PVCSN.ObjectMeta.Name)
	require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), PVCSN.Spec.AccessModes)
	require.Equal(t, "standard", *PVCSN.Spec.StorageClassName)
	actualMemQty = PVC.Spec.Resources.Requests["storage"]
	require.Equal(t, "512Mi", actualMemQty.String())

	// TC: PVC for rms+sharednothing+logs
	values = map[string]string{
		"persistence.logs":                    "true",
		"persistence.rmsWebstudio":            "true",
		"rmsDeployment":                       "true",
		"persistence.scSupportsReadWriteMany": "true",
		"bsType":                              "sharednothing",
	}

	options = &helm.Options{
		SetValues: values,
	}

	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pvc.yaml"})
	require.NoError(t, err)
	rawPVCs := strings.Split(output, "---")
	var actualPVCs []v1.PersistentVolumeClaim
	for _, rawPVC := range rawPVCs {
		if strings.Trim(rawPVC, "") == "" {
			continue
		}
		var PVC v1.PersistentVolumeClaim
		helm.UnmarshalK8SYaml(t, rawPVC, &PVC)
		actualPVCs = append(actualPVCs, PVC)
	}

	expectedPVCsMap := map[string]map[string]interface{}{
		"TestPVC-data-store": {
			"releaseName":      "TestPVC-data-store",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-logs": {
			"releaseName":      "TestPVC-logs",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-rms-shared": {
			"releaseName":      "TestPVC-rms-shared",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-rms-security": {
			"releaseName":      "TestPVC-rms-security",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-rms-webstudio": {
			"releaseName":      "TestPVC-rms-webstudio",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
	}

	require.Equal(t, 5, len(actualPVCs))

	for _, actualPVC := range actualPVCs {
		actualPVCName := actualPVC.ObjectMeta.Name
		expectedPVC, found := expectedPVCsMap[actualPVCName]
		require.Truef(t, found, fmt.Sprintf("PVC name[%s] is not expected", actualPVCName))
		require.Equal(t, expectedPVC["releaseName"], actualPVC.ObjectMeta.Name)
		require.Equal(t, "default", actualPVC.ObjectMeta.Namespace)
		require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), actualPVC.Spec.AccessModes)
		require.Equal(t, expectedPVC["storageClassName"], *actualPVC.Spec.StorageClassName)
		actualMemQty := PVC.Spec.Resources.Requests["storage"]
		require.Equal(t, expectedPVC["memory"], actualMemQty.String())
	}

	// TC: PVC for rmsDeployment
	values = map[string]string{
		"persistence.rmsWebstudio":            "true",
		"rmsDeployment":                       "true",
		"persistence.scSupportsReadWriteMany": "true",
	}

	options = &helm.Options{
		SetValues: values,
	}

	output, err = helm.RenderTemplateE(t, options, helmChartPath, releaseName, []string{"templates/pvc.yaml"})
	require.NoError(t, err)
	rawRMSPVCs := strings.Split(output, "---")
	var actualRMSPVCs []v1.PersistentVolumeClaim
	for _, rawRMSPVCs := range rawRMSPVCs {
		if strings.Trim(rawRMSPVCs, "") == "" {
			continue
		}
		var PVC v1.PersistentVolumeClaim
		helm.UnmarshalK8SYaml(t, rawRMSPVCs, &PVC)
		actualRMSPVCs = append(actualRMSPVCs, PVC)
	}

	expectedRMSPVCsMap := map[string]map[string]interface{}{
		"TestPVC-rms-shared": {
			"releaseName":      "TestPVC-rms-shared",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-rms-security": {
			"releaseName":      "TestPVC-rms-security",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
		"TestPVC-rms-webstudio": {
			"releaseName":      "TestPVC-rms-webstudio",
			"accessModes":      "ReadWriteMany",
			"storageClassName": "standard",
			"memory":           "512Mi",
		},
	}

	require.Equal(t, 3, len(actualRMSPVCs))

	for _, actualRMSPVC := range actualRMSPVCs {
		actualRMSPVCName := actualRMSPVC.ObjectMeta.Name
		expectedPVC, found := expectedRMSPVCsMap[actualRMSPVCName]
		require.Truef(t, found, fmt.Sprintf("PVC name[%s] is not expected", actualRMSPVCName))
		require.Equal(t, expectedPVC["releaseName"], actualRMSPVC.ObjectMeta.Name)
		require.Equal(t, []v1.PersistentVolumeAccessMode([]v1.PersistentVolumeAccessMode{"ReadWriteMany"}), actualRMSPVC.Spec.AccessModes)
		require.Equal(t, expectedPVC["storageClassName"], *actualRMSPVC.Spec.StorageClassName)
		actualMemQty := PVC.Spec.Resources.Requests["storage"]
		require.Equal(t, expectedPVC["memory"], actualMemQty.String())
	}

}
