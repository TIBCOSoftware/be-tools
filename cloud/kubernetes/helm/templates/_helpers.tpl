
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

{{- define "rmsmounts" -}}
{{- if eq .Values.rms.enabled true }}
  - mountPath: "/opt/tibco/be/{{ .Values.rms.beVersion }}/rms/shared/"
    name: shared
  - mountPath: "/opt/tibco/be/{{ .Values.rms.beVersion }}/rms/config/security/"
    name: security
  - mountPath: "/opt/tibco/be/{{ .Values.rms.beVersion }}/examples/standard/WebStudio/"
    name: webstudio
  - mountPath: "/opt/tibco/be/{{ .Values.rms.beVersion }}/rms/config/notify/"
    name: notify
{{- end }}
{{- end -}}

{{/*
Create a volume mount and volume claim template for sharednothing
*/}}
{{- define "volumeMount" -}}
{{- if or (eq .Values.mountLogs true) (eq .Values.bsType "sharednothing") (eq .Values.rms.enabled true) }}
volumeMounts:
{{- if eq .Values.bsType "sharednothing" }}
  - mountPath: {{ .Values.volumes.snmountPath }}
    name: {{ .Values.volumes.snmountVolume }}
{{- end }}
{{- if eq .Values.mountLogs true }}
  - mountPath: {{ .Values.volumes.logmountPath }}
    name: {{ .Values.volumes.logmountVolume }}
{{- end }}
{{- include "rmsmounts" . }}
{{- end }}
{{- end -}}


{{- define "rmsvolumeMount" -}}
{{- if or (eq .Values.mountLogs true) (eq .Values.rms.enabled true) }}
volumeMounts:
{{- include "rmsmounts" . }}
{{- if eq .Values.rms.persistenceType "sharednothing" }}
  - mountPath: {{ .Values.volumes.snmountPath }}
    name: {{ .Values.volumes.snmountVolume }}
{{- end }}
{{- if eq .Values.mountLogs true }}
  - mountPath: {{ .Values.volumes.logmountPath }}
    name: {{ .Values.volumes.logmountVolume }}
{{- end }}
{{- end }}
{{- end -}} 

{{- define "volumes" -}}
{{- if eq .Values.rms.enabled true }}
volumes:
  - name: shared
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-shared
  - name: security
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-security
  - name: webstudio
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-webstudio
  - name: notify
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-notify
{{- end }}
{{- end -}}

{{- define "rmsvolumes" -}}
{{- if eq .Values.rms.enabled true }}
{{- include "volumes" . }}
{{- if eq .Values.rms.persistenceType "sharednothing"}}      
  - name: {{ .Values.volumes.snmountVolume }}
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-{{ .Values.volumes.snmountVolume }}
{{- end }}
{{- if eq .Values.mountLogs true }}      
  - name: {{ .Values.volumes.logmountVolume }}
    persistentVolumeClaim:
      claimName: {{ .Release.Name }}-rms-pvc-{{ .Values.volumes.logmountVolume }}
{{- end }}
{{- end }}
{{- end -}}

{{- define "volumeClaim" -}}
{{- if or (eq .Values.mountLogs true) (eq .Values.bsType "sharednothing") }}
{{- if eq .Values.volumes.pvProvisioningMode "dynamic" }}
  volumeClaimTemplates:
{{- if eq .Values.bsType "sharednothing" }}  
    - metadata:
        name: {{ .Values.volumes.snmountVolume }}
        annotations:
          volume.beta.kubernetes.io/storage-class: "{{ include "storageclass" . | trim }}"
      spec:
        accessModes: ["{{ .Values.volumes.accessModes }}"]
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- if eq .Values.mountLogs true }}
    - metadata:
        name: {{ .Values.volumes.logmountVolume }}
        annotations:
          volume.beta.kubernetes.io/storage-class: "{{ include "storageclass" . | trim }}"
      spec:
        accessModes: ["{{ .Values.volumes.accessModes }}"]
        resources:
          requests:
            storage: {{ .Values.volumes.storage }}
{{- end }}
{{- end }}
{{- if eq .Values.volumes.pvProvisioningMode "static" }}
{{- if eq .Values.rms.enabled false }}      
      volumes:
{{- end }}
        - name: {{ .Values.volumes.snmountVolume }}
          persistentVolumeClaim:
            claimName: {{ .Release.Name }}-be-pvc-{{ .Values.volumes.snmountVolume }}
        - name: {{ .Values.volumes.logmountVolume }}
          persistentVolumeClaim:
            claimName: {{ .Release.Name }}-be-pvc-{{ .Values.volumes.logmountVolume }}        
{{- end }}
{{- end }}
{{- end -}}

{{- define "inf-resource-memory" -}}
resources:
  requests:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
  limits:
    memory: "{{ .Values.inferencenode.resources.limits.memory }}"
    cpu: "{{ .Values.inferencenode.resources.limits.cpu }}"
{{- end -}}

{{- define "cache-resource-memory" -}}
resources:
  requests:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
  limits:
    memory: "{{ .Values.cachenode.resources.limits.memory }}"
    cpu: "{{ .Values.cachenode.resources.limits.cpu }}"
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
  dburl: "jdbc:mysql://{{ .Release.Name }}-mysql:3306/{{ .Values.mysql.auth.database }}" #db service url generated from release name
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

{{- define "cachepodAntiAffinity" -}}
{{- if eq .Values.podAntiAffinity true }}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: name
              operator: In
              values:
              - "{{ include "becacheagent.fullname" . }}"
          topologyKey: "kubernetes.io/hostname"
{{- end }}          
{{- end -}}

{{- define "infpodAntiAffinity" -}}
{{- if eq .Values.podAntiAffinity true }}
affinity:
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 90
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: name
              operator: In
              values:
              - "{{ include "beinferenceagent.fullname" . }}"
          topologyKey: "kubernetes.io/hostname"
{{- end }}
{{- end -}}

{{- define "rmsgvs" }}
{{- range $key,$val := .Values.rms.env }}
- name: {{ $key }}
  value: {{ $val }}
{{- end}}
{{- end -}}


{{- define "berms.fullname" -}}
{{ .Release.Name }}-{{- .Values.rms.name -}}
{{- end -}}

{{- define "bermsservice.fullname" -}}
{{ .Release.Name }}-{{ .Values.rms.service.name }}
{{- end -}}

{{- define "betea.fullname" -}}
{{ .Release.Name }}-{{- .Values.tea.name -}}
{{- end -}}

{{- define "beteaservice.fullname" -}}
{{ .Release.Name }}-{{ .Values.tea.service.name }}
{{- end -}}

{{- define "teagvs" }}
{{- range $key,$val := .Values.tea.env }}
- name: {{ $key }}
  value: {{ $val }}
{{- end}}
{{- end -}}

{{- define "custom-sc" -}}
{{ .Release.Name }}-be-sc
{{- end -}}

{{- define "storageclass" -}}
{{- if eq .Values.volumes.pvProvisioningMode "static" }}  

{{- end}}
{{- if and (eq .Values.volumes.pvProvisioningMode "dynamic") (eq .Values.cpType "aws") }}
{{ .Values.volumes.storageClass | default (printf (include "custom-sc" .)) }}
{{- else if eq .Values.volumes.pvProvisioningMode "dynamic" }}  
{{ .Values.volumes.storageClass }}
{{- end}}
{{- end -}} 