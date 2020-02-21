{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "helmm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "beinferenceagent.fullname" -}}
{{- .Values.inferencenode.metadata.name -}}
{{- end -}}

{{- define "becacheagent.fullname" -}}
{{- .Values.cachenode.metadata.name -}}
{{- end -}}

{{- define "bediscoverynode.fullname" -}}
{{- .Values.discoverynode.metadata.name -}}
{{- end -}}

{{- define "mysql.fullname" -}}
{{- .Values.mysql.metadata.name -}}
{{- end -}}

{{- define "beservice.fullname" -}}
{{ .Values.beservice.metadata.name }}
{{- end -}}

{{- define "discoveryservice.fullname" -}}
{{ .Values.discoveryservice.metadata.name }}
{{- end -}}

{{- define "jmxservice.fullname" -}}
{{ .Values.jmxservice.metadata.name }}
{{- end -}}

{{- define "mysqlservice.fullname" -}}
{{ .Values.mysqlservice.metadata.name }}
{{- end -}}

{{- define "commonconfigmap.fullname" -}}
{{ .Values.configmap.name }}
{{- end -}}

{{- define "eksconfigmap.fullname" -}}
{{ .Values.persistentvolumes.eks.configmap.name }}
{{- end -}}

{{- define "azurestorageclass.fullname" -}}
{{ .Values.volumes.azure.storageClassName }}
{{- end -}}

{{- define "eksstorageclass.fullname" -}}
{{ .Values.persistentvolumes.eks.storageclass.name }}
{{- end -}}

{{- define "eksdeployment.fullname" -}}
{{ .Values.persistentvolumes.eks.deployment.name }}
{{- end -}}

{{- define "openshiftPV.fullname" -}}
{{ .Values.persistentvolumes.openshift.volume.metadata.name }}
{{- end -}}

{{- define "sharedNothing.first" -}}
{{- if eq .Values.isType "sharedNothing" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.mountPath }}
    name: {{ .Values.volumes.name }}
{{- end }}
{{- end -}}

{{- define "sharedNothing.cachesecond" -}}
{{- if eq .Values.isType "sharedNothing" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.name }}
        {{- if ne .Values.cloudProvider "openshift" }}
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.storageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        {{- else }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        volumeName: {{ .Values.volumes.snVolume1 }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end -}}

{{- define "sharedNothing.inferencesecond" -}}
{{- if eq .Values.isType "sharedNothing" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.name }}
        {{- if ne .Values.cloudProvider "openshift" }}
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.storageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        {{- else }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        volumeName: {{ .Values.volumes.snVolume2 }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end -}}

{{- define "sharedAll.first" -}}
{{- if eq .Values.isType "sharedAll" }}
- name: {{ .Values.database.envname1 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value1 }}
- name: {{ .Values.database.envname2 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value2 }}
- name: {{ .Values.database.envname3 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value3 }}
- name: {{ .Values.database.envname4 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value4 }}
- name: {{ .Values.database.envname5 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value5 }}
- name: {{ .Values.database.envname6 }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.value6 }}
{{- end }}
{{- end -}}

{{- define "sharedAll.second" -}}
{{- if eq .Values.isType "sharedAll" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.samountPath }}
    name: {{ .Values.volumes.saname }}
{{- end }}
{{- end -}}

{{- define "sharedAll.third" -}}
{{- if eq .Values.isType "sharedAll" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.saname }}
        {{- if ne .Values.cloudProvider "openshift" }}
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.sastorageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        {{- else }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        volumeName: {{ .Values.volumes.saVolume }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.volumes.sastorage }}
{{- end }}
{{- end -}}

{{- define "commonconfigmap.data" -}}
data:
  db_driver: "{{ .Values.configmap.dbdriver }}"
  db_url: "{{ .Values.configmap.dburl }}"
  db_username: "{{ .Values.configmap.dbusername }}"
  db_pwd: "{{ .Values.configmap.dbpwd }}"
  db_pool_size: "{{ .Values.configmap.dbpoolsize }}"
  db_login_timeout: "{{ .Values.configmap.dblogintimeout }}"
{{- end -}}

{{- define "eksconfigmap.data" -}}
data:
  file.system.id: {{ .Values.persistentvolumes.eks.configmap.filesystemid }}
  aws.region: {{ .Values.persistentvolumes.eks.configmap.awsregion }}
  provisioner.name: {{ .Values.persistentvolumes.eks.configmap.provisionername }}
{{- end -}}

{{- define "openshiftPV.details" -}}
  capacity:
    storage: {{ .Values.persistentvolumes.openshift.volume.spec.capacity.storage }}
  accessModes:
    - {{ .Values.persistentvolumes.openshift.volume.spec.accessModes }}
  persistentVolumeReclaimPolicy: {{ .Values.persistentvolumes.openshift.volume.spec.persistentVolumeReclaimPolicy }}
{{- end -}}

{{- define "openshiftNFSsharedNothing.first" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.path1 }}
{{- end -}}

{{- define "openshiftNFSsharedNothing.second" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.path2 }}
{{- end -}}

{{- define "openshiftNFSsharedAll.first" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.spec.nfs.path3 }}
{{- end -}}
