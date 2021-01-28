
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

{{- define "ignitesaname" -}}
{{- if and (eq .Values.omType "cache" ) (eq .Values.cmType "ignite" ) }}
serviceAccount: "{{ .Release.Name }}-{{ .Values.ignite.serviceaccount }}"
{{- end }}
{{- end -}} 

{{/*
Create a volume mount and volume claim template for sharednothing
*/}}
{{- define "sharednothing.volumeMount" -}}
{{- if eq .Values.bsType "sharednothing" }}
volumeMounts:
  - mountPath: {{ .Values.volumes.snmountPath }}
    name: {{ .Values.volumes.snmountVolume }}
{{- end }}
{{- end -}}

{{- define "sharednothing.volumeClaim" -}}
{{- if eq .Values.bsType "sharednothing" }}
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

{{- define "fargate-resource-memory" -}}
{{- if eq .Values.cpType "awsfargate" }}
resources:
  requests:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
  limits:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
{{- end -}}
{{- end -}}

{{/*
Create a DB configMap environment details for store
*/}}
{{- define "store.configMap" -}}
{{- $mapName  :=  include "configmapname.fullname" . -}}
{{- if and (eq .Values.bsType "store" ) (eq .Values.storeType "rdbms" ) }}
{{- range $key,$val := .Values.database }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
{{- if eq .Values.storeType "cassandra"  }}
{{- range $key,$val := .Values.cassdatabase }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if eq .Values.storeType "as4"  }}
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
  {{- if and (eq .Values.bsType "store" ) (eq .Values.storeType "rdbms" ) }}
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
  {{- if eq .Values.storeType "cassandra"  }}
  {{- range $key, $val := $.Values.cassconfigmap }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end -}}
  {{- if eq .Values.storeType "as4" }}
  {{- range $key, $val := $.Values.as4configmap }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end -}}
  {{- end -}}
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

# metrics configmap metadata name
{{- define "metricsname.fullname" -}}
{{ .Release.Name }}-{{ .Values.metricsType }}
{{- end -}}

# influx and grafana configmaps
{{- define "metrics-configmap.data" -}}
data:
  {{- if eq .Values.metricsType "influx" }}
  {{- $metrics := .Values.influxdb.enabled }}
  {{- if eq $metrics true }}
  dburl: "http://{{ .Release.Name }}-influxdb:8086"
  {{- end }}
  {{- range $key, $val := $.Values.influxconfigmap }}
  {{- if eq $metrics true }}
  {{- if ne "dburl" $key }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- else }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
  {{- end }}
  {{- end }}
  {{- if eq .Values.metricsType "liveview" }}
  {{- range $key, $val := $.Values.sbconfigmap }}
  {{ $key }}: {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end -}}

# influx and grafana env for agent yaml files
{{- define "influx-grafana.data" -}}
{{- $mapName  :=  include "metricsname.fullname" . -}}
{{- if eq .Values.metricsType "influx" }}
{{- range $key,$val := .Values.influxdatabase }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if eq .Values.metricsType "liveview" }}
{{- range $key, $val := $.Values.streambase }}
- name: {{ $key }}
  valueFrom:
    configMapKeyRef:
      name: {{ $mapName }}
      key: {{ $val }}
{{- end }}
{{- end }}
{{- if eq .Values.metricsType "custom" }}
{{- range $key, $val := $.Values.metricdetails }}
- name: {{ $key }}
  value: {{ $val }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "discovery_url" -}}
{{- if and (eq .Values.omType "cache" ) (eq .Values.cmType "as2" ) }}  
- name: AS_DISCOVER_URL
  value: tcp://{{range $i, $e := until (int .Values.cachenode.discoveryCount)}}{{ include "becacheagent.fullname" $ }}-{{$i}}.{{ include "cacheservice.fullname" $ }}:50000;{{end}}
{{- end }}
{{- if or (eq .Values.omType "cache" ) (eq .Values.omType "store" ) }}   
{{- if eq .Values.cmType "ftl" }}
{{- range $key, $val := $.Values.ftl }}
- name: {{ $key }}
  value: {{ $val }}
{{- end }}
{{- end }}
{{- end }}
{{- if and (eq .Values.omType "cache" ) (eq .Values.cmType "ignite" ) }}  
- name: "tra.be.ignite.k8s.service.name"
  value: "{{ include "cacheservice.fullname" . }}"
{{- range $key, $val := $.Values.ignite_gv }}
- name: {{ $key }}
  value: {{ $val }}
{{- end }}  
{{- end }}
{{- end -}}        

{{- define "healthcheck" -}}
{{- if eq .Values.healthcheck.enabled true }}
livenessProbe:
  tcpSocket:
    port: {{ .Values.healthcheck.livenessProbe.port }}
  initialDelaySeconds: {{ .Values.healthcheck.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.healthcheck.livenessProbe.periodSeconds }} 
readinessProbe:
  tcpSocket:
    port: {{ .Values.healthcheck.readinessProbe.port }}
  initialDelaySeconds: {{ .Values.healthcheck.readinessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.healthcheck.readinessProbe.periodSeconds }} 
{{- end }}
{{- end -}}

{{- define "gvproviders" -}}
{{- range $key,$val := .Values.env }}
- name: {{ $key }}
  value: {{ $val }}
{{- end}}
{{- end -}}

{{- define "pullsecrets" -}}
{{- if or (.Values.imagepullsecret) (.Values.imageCredentials.registry) }}
imagePullSecrets:
  {{- if .Values.imagepullsecret }}
  - name: {{ .Values.imagepullsecret }}
  {{- else  }}
  - name: {{ include "beimagepullsecret.fullname" . }}
  {{- end  }}
{{- end}}  
{{- end -}}