
#
# Copyright (c) 2019-2020. TIBCO Software Inc.
# This file is subject to the license terms contained in the license file that is distributed with this file.
#

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

{{- define "configmapname.fullname" -}}
{{ .Release.Name }}-{{ .Values.configmapname }}
{{- end -}}

{{- define "azurestorageclass.fullname" -}}
{{ .Values.volumes.azure.storageClassName }}
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
        annotations:
          volume.beta.kubernetes.io/storage-class: {{ .Values.volumes.storageClass }}
      spec:
        accessModes: {{ .Values.volumes.accessModes }}
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end -}}


{{/*
Create a DB configMap environment details for store
*/}}
{{- define "store.configMap" -}}
{{- $mapName  :=  include "configmapname.fullname" . -}}
{{- if and (eq .Values.bsType "store" ) (eq .Values.storeType "RDBMS" ) }}
{{- range $key,$val := .Values.database }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
{{- if eq .Values.storeType "Cassandra"  }}
{{- range $key,$val := .Values.cassdatabase }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if eq .Values.storeType "AS4"  }}
{{- range $key,$val := .Values.as4database }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}     
{{- end }}
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
{{- define "configmap.data" -}}
data:
  {{- $mysqlenabled := .Values.mysql.enabled }}
  {{- if and (eq .Values.bsType "store" ) (eq .Values.storeType "RDBMS" ) }}
  {{- if eq $mysqlenabled true }}
  dburl: "jdbc:mysql://{{ .Release.Name }}-mysql:3306/{{ .Values.mysql.mysqlDatabase }}" #db service url generated from release name
  {{- end }}
  {{- range $key, $val := $.Values.configmap }}
  {{- if eq $mysqlenabled true }}
  {{- if ne "dburl" $key }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- else }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end }}
  {{- end -}}
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

{{- define "beimagepullsecret.fullname" }}
{{- if .Values.imageCredentials.registry }}
{{- .Release.Name }}-beimagepullsecret
{{- end }}
{{- end }}

{{- define "imagePullSecret" }}
{{- with .Values.imageCredentials }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}
