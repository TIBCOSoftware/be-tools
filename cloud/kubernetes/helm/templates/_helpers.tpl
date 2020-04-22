{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified name for deployment, services, configMap, volumes, etc.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "beinferenceagent.fullname" -}}
{{- .Values.inferencenode.name -}}
{{- end -}}

{{- define "becacheagent.fullname" -}}
{{- .Values.cachenode.name -}}
{{- end -}}

{{- define "bediscoverynode.fullname" -}}
{{- .Values.discoverynode.name -}}
{{- end -}}

{{- define "beservice.fullname" -}}
{{ .Values.beservice.name }}
{{- end -}}

{{- define "discoveryservice.fullname" -}}
{{ .Values.discoveryservice.name }}
{{- end -}}

{{- define "jmxservice.fullname" -}}
{{ .Values.jmxservice.name }}
{{- end -}}

{{- define "mysqlservice.fullname" -}}
{{ .Values.mysqlservice.name }}
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
{{ .Values.persistentvolumes.openshift.volume.name }}
{{- end -}}

{{/*
Create a volume mount and volume claim template for sharedNothing
*/}}
{{- define "sharedNothing.volumeMount" -}}
{{- if eq .Values.persistentType "sharedNothing" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.snmountPath }}
    name: {{ .Values.volumes.snmountVolume }}
{{- end }}
{{- end -}}

{{- define "sharedNothing.volumeClaim" -}}
{{- if eq .Values.persistentType "sharedNothing" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.snmountVolume }}
        {{- if ne .Values.cloudProvider "openshift" }}
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.storageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        {{- else }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        volumeName: {{ .Values.volumes.snclaimVolume }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end -}}


{{/*
Create a DB configMap environment details for sharedAll
*/}}
{{- define "sharedAll.configMap" -}}
{{- if eq .Values.persistentType "sharedAll" }}
- name: {{ .Values.database.drivername }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.driverval }}
- name: {{ .Values.database.urlname }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.urlval }}
- name: {{ .Values.database.username }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.userval }}
- name: {{ .Values.database.pwdname }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.pwdval }}
- name: {{ .Values.database.poolsizename }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.poolsizeval }}
- name: {{ .Values.database.logintimeoutname }}
  valueFrom:
    configMapKeyRef:
      name: {{ .Values.database.name }}
      key: {{ .Values.database.logintimeoutval }}
{{- end }}
{{- end -}}


{{/*
Create a volume mount and volume claim template for sharedAll
*/}}
{{- define "sharedAll.volumeMount" -}}
{{- if eq .Values.persistentType "sharedAll" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.samountPath }}
    name: {{ .Values.volumes.samountVolume }}
{{- end }}
{{- end -}}

{{- define "sharedAll.volumeClaim" -}}
{{- if eq .Values.persistentType "sharedAll" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.samountVolume }}
        {{- if ne .Values.cloudProvider "openshift" }}
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.storageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        {{- else }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        volumeName: {{ .Values.volumes.saclaimVolume }}
        {{- end }}
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end -}}

{{/*
Create a common DB configMap data details for sharedAll
*/}}
{{- define "commonconfigmap.data" -}}
data:
  db_driver: "{{ .Values.configmap.dbdriver }}"
  {{- if eq .Values.mysql.enabled true }}
  db_url: "jdbc:mysql://{{ .Release.Name }}-mysql:3306/{{ .Values.mysql.mysqlDatabase }}" #db service url generated from release name
  {{- else }}
  db_url: "{{ .Values.configmap.dburl }}"
  {{- end }}
  db_username: "{{ .Values.configmap.dbusername }}"
  db_pwd: "{{ .Values.configmap.dbpwd }}"
  db_pool_size: "{{ .Values.configmap.dbpoolsize }}"
  db_login_timeout: "{{ .Values.configmap.dblogintimeout }}"
{{- end -}}

{{/*
Create a EKS DB configMap data details
*/}}
{{- define "eksconfigmap.data" -}}
data:
  file.system.id: {{ .Values.persistentvolumes.eks.configmap.filesystemid }}
  aws.region: {{ .Values.persistentvolumes.eks.configmap.awsregion }}
  provisioner.name: {{ .Values.persistentvolumes.eks.configmap.provisionername }}
{{- end -}}

{{/*
Create a openshift persistent volume details
*/}}
{{- define "openshiftPV.details" -}}
  capacity:
    storage: {{ .Values.persistentvolumes.openshift.volume.storage }}
  accessModes:
    - {{ .Values.persistentvolumes.openshift.volume.accessModes }}
  persistentVolumeReclaimPolicy: {{ .Values.persistentvolumes.openshift.volume.persistentVolumeReclaimPolicy }}
{{- end -}}

{{/*
Create a openshift NFS path details for sharedNothing and sharedAll
*/}}
{{- define "openshiftNFSsharedNothing.path" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.nfs.snpath }}
{{- end -}}

{{- define "openshiftNFSsharedAll.path" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.nfs.sapath }}
{{- end -}}
