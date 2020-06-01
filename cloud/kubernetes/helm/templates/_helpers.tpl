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
{{ .Release.Name }}-{{- .Values.inferencenode.name -}}
{{- end -}}

{{- define "becacheagent.fullname" -}}
{{ .Release.Name }}-{{- .Values.cachenode.name -}}
{{- end -}}

{{- define "beservice.fullname" -}}
{{ .Release.Name }}-{{ .Values.beservice.name }}
{{- end -}}

{{- define "cacheservice.fullname" -}}
{{ .Release.Name }}-{{ .Values.cacheservice.name }}
{{- end -}}

{{- define "jmxservice.fullname" -}}
{{ .Release.Name }}-{{ .Values.jmxservice.name }}
{{- end -}}

{{- define "sqlconfigmap.fullname" -}}
{{ .Release.Name }}-{{ .Values.sqlconfigmap.name }}
{{- end -}}

{{- define "storeconfigmap.fullname" -}}
{{ .Release.Name }}-{{ .Values.storeconfigmap.name }}
{{- end -}}

{{- define "azurestorageclass.fullname" -}}
{{ .Values.volumes.azure.storageClassName }}
{{- end -}}

{{- define "openshiftPV.fullname" -}}
{{ .Values.persistentvolumes.openshift.volume.name }}
{{- end -}}

{{/*
Create a volume mount and volume claim template for sharedNothing
*/}}
{{- define "sharedNothing.volumeMount" -}}
{{- if eq .Values.bsType "sharedNothing" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.snmountPath }}
    name: {{ .Values.volumes.snmountVolume }}
{{- end }}
{{- end -}}

{{- define "sharedNothing.volumeClaim" -}}
{{- if eq .Values.bsType "sharedNothing" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.snmountVolume }}
        {{- if ne .Values.cpType "openshift" }}
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
Create a DB configMap environment details for store
*/}}
{{- define "store.configMap" -}}
{{- if and (eq .Values.bsType "store" ) (eq .Values.storeType "RDBMS" ) }}
{{- $sql  :=  include "sqlconfigmap.fullname" . -}}
{{- range $key,$val := .Values.database }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $sql }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
{{- $store  :=  include "storeconfigmap.fullname" . -}}
{{- if eq .Values.storeType "Cassandra"  }}
{{- range $key,$val := .Values.cassdatabase }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $store }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if eq .Values.storeType "AS4"  }}
{{- range $key,$val := .Values.as4database }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $store }}
      key: {{ $val }}
{{- end }}     
{{- end }}
{{- end }}
{{- end -}}


{{/*
Create a volume mount and volume claim template for store
*/}}
{{- define "store.volumeMount" -}}
{{- if eq .Values.bsType "store" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.samountPath }}
    name: {{ .Values.volumes.samountVolume }}
{{- end }}
{{- end -}}

{{- define "store.volumeClaim" -}}
{{- if eq .Values.bsType "store" }}
  volumeClaimTemplates:
    - metadata:
        name: {{ .Values.volumes.samountVolume }}
        {{- if ne .Values.cpType "openshift" }}
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


{{- define "ftl.data" -}}
{{- range $key, $val := $.Values.ftl }}
        - name: {{ $key }}
          value: {{ $val }}
{{- end }}
{{- end -}}
{{/*
Create a common DB configMap data details for store
*/}}
{{- define "sqlconfigmap.data" -}}
data:
  dbdriver: "{{ .Values.configmap.dbdriver }}"
  {{- if eq .Values.mysql.enabled true }}
  dburl: "jdbc:mysql://{{ .Release.Name }}-mysql:3306/{{ .Values.mysql.mysqlDatabase }}" #db service url generated from release name
  {{- else }}
  dburl: "{{ .Values.configmap.dburl }}"
  {{- end }}
  dbusername: "{{ .Values.configmap.dbusername }}"
  dbpwd: "{{ .Values.configmap.dbpwd }}"
  dbpoolsize: "{{ .Values.configmap.dbpoolsize }}"
  dblogintimeout: "{{ .Values.configmap.dblogintimeout }}"
{{- end -}}


{{/*
Create a common DB configMap data details for store
*/}}
{{- define "nosqlconfigmap.data" -}}
data:
  {{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
  {{- if eq .Values.storeType "Cassandra"  }}
  {{- range $key, $val := $.Values.cassconfigmap }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end -}}
  {{- if eq .Values.storeType "AS4" }}
  {{- range $key, $val := $.Values.as4configmap }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end -}}
  {{- end -}}
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
Create a openshift NFS path details for sharedNothing and store
*/}}
{{- define "openshiftNFSsharedNothing.path" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.nfs.snpath }}
{{- end -}}

{{- define "openshiftNFSstore.path" -}}
  nfs:
    server: {{ .Values.persistentvolumes.openshift.volume.nfs.server }}
    path: {{ .Values.persistentvolumes.openshift.volume.nfs.sapath }}
{{- end -}}
