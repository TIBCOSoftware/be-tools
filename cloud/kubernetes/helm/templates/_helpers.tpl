
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}

{{- define "helm.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "bechart.discoveryservice.name" -}}
{{ .Release.Name }}-discovery-service
{{- end -}}

{{- define "azurestorageclass.fullname" -}}
{{ .Values.volumes.azure.storageClassName }}
{{- end -}}

{{- define "ignitesaname" -}}
{{- if and (eq .Values.omType "cache" ) (eq .Values.cmType "ignite" ) }}
serviceAccount: "{{ .Release.Name }}-{{ .Values.ignite.serviceaccount }}"
{{- end }}
{{- end -}} 

{{- define "bechart.volumeMounts" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment }}
volumeMounts:
{{- end }}
{{- if eq .Values.bsType "sharednothing" }}
- name: data-store
  mountPath: "/mnt/tibco/be/data-store"
{{- end }}
{{- if .Values.persistence.logs }}
- name: logs
  mountPath: "/mnt/tibco/be/logs"
{{- end }}
{{- if or .Values.enableRMS .Values.rmsDeployment }}
- name: rms-shared
  mountPath: "/opt/tibco/be/latest/rms/shared"
{{- end }}
{{- if .Values.rmsDeployment }}
{{- if .Values.persistence.rmsSecurity }}
- name: rms-security
  mountPath: "/opt/tibco/be/latest/rms/config/security"
{{- end }}
{{- if .Values.persistence.rmsWebstudio }}
- name: rms-webstudio
  mountPath: "/opt/tibco/be/latest/examples/standard/WebStudio"
{{- end }}
{{- end }}
{{- end }}

{{- define "bechart.volumes" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment }}
volumes:
{{- end }}
{{- range $i, $vName := tuple "data-store" "logs" "rms-shared" "rms-security" "rms-webstudio" }}
{{- if or (and (eq $vName "data-store") (eq $.Values.bsType "sharednothing")) (and (eq $vName "logs") $.Values.persistence.logs) (and (eq $vName "rms-shared") (or $.Values.enableRMS $.Values.rmsDeployment)) (and (eq $vName "rms-security") $.Values.persistence.rmsSecurity $.Values.rmsDeployment) (and (eq $vName "rms-webstudio") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) }}
- name: {{ $vName }}
  persistentVolumeClaim:
{{- if and (eq $vName "rms-shared") $.Values.enableRMS }}
    claimName: {{ $.Values.persistence.rmsSharedPVC }}
{{- else }}
    claimName: {{ $.Release.Name }}-{{ $vName }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}

{{- define "bechart.volumeClaimTemplates" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment }}
volumeClaimTemplates:
{{- end }}
{{- range $i, $vName := tuple "data-store" "logs" "rms-shared" "rms-security" "rms-webstudio" }}
{{- if or (and (eq $vName "data-store") (eq $.Values.bsType "sharednothing")) (and (eq $vName "logs") $.Values.persistence.logs) (and (eq $vName "rms-shared") (or $.Values.enableRMS $.Values.rmsDeployment)) (and (eq $vName "rms-security") $.Values.persistence.rmsSecurity $.Values.rmsDeployment) (and (eq $vName "rms-webstudio") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) }}
- metadata:
    name: {{ $vName }}
  spec:
    accessModes: [ "ReadWriteOnce" ]
    storageClassName: {{ $.Values.persistence.storageClass | quote }}
    resources:
      requests:
        storage: {{ $.Values.persistence.size }}
{{- end }}
{{- end }}
{{- end }}

{{- define "bechart.storageclass" }}
{{- if empty .Values.persistence.storageClass }}
storageClassName:
{{- else if eq .Values.persistence.storageClass "-" }}
storageClassName: ""
{{- else }}
storageClassName: {{ .Values.persistence.storageClass }}
{{- end }}
{{- end }}

{{- define "bechart.resourceLimits" }}
resources:
  requests:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
  limits:
    memory: "{{ .Values.resources.memory }}"
    cpu: "{{ .Values.resources.cpu }}"
{{- end }}


{{- define "ftl.data" -}}
{{- range $key, $val := $.Values.ftl }}
        - name: {{ $key }}
          value: {{ $val }}
{{- end }}
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


{{- define "discovery_url" -}}
{{- if and (eq .Values.omType "cache" ) (eq .Values.cmType "as2" ) }}  
- name: AS_DISCOVER_URL
  value: tcp://
{{- range $i, $agent := $.Values.agents -}}
{{- range $j, $e := until (int $agent.discoverableReplicas) -}}
{{ $.Release.Name }}-{{ $agent.name }}-{{ $j }}.{{ include "bechart.discoveryservice.name" $ }}:50000;
{{- end -}}
{{- end }}
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
  value: "{{ include "bechart.discoveryservice.name" $ }}"
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

{{- define "bechart.affinity" }}
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
              - "{{ . }}"
          topologyKey: "kubernetes.io/hostname"
{{- end }}