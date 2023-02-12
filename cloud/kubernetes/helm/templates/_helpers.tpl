
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


{{- define "bechart.volumeMounts" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment $.Values.certificatesFromSecrets }}
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
  mountPath: "/opt/tibco/be/{{ .Values.beShortVersion }}/rms/shared"
{{- end }}
{{- if .Values.rmsDeployment }}
{{- if .Values.persistence.rmsWebstudio }}
- name: rms-security
  mountPath: "/opt/tibco/be/{{ .Values.beShortVersion }}/rms/config/security"
- name: rms-webstudio
  mountPath: "/opt/tibco/be/{{ .Values.beShortVersion }}/examples/standard/WebStudio"
{{- end }}
{{- end }}
{{- if $.Values.certificatesFromSecrets }}
{{- range $j, $value := $.Values.certificatesFromSecrets }}
- name: "{{ $value.secretName }}"
  mountPath: "/opt/tibco/certs/{{ $value.secretName }}"
{{- end }}
{{- end }}
{{- end }}

{{- define "bechart.volumes" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment $.Values.certificatesFromSecrets }}
volumes:
{{- end }}
{{- range $i, $vName := tuple "data-store" "logs" "rms-shared" "rms-security" "rms-webstudio" }}
{{- if or (and (eq $vName "data-store") (eq $.Values.bsType "sharednothing")) (and (eq $vName "logs") $.Values.persistence.logs) (and (eq $vName "rms-shared") (or $.Values.enableRMS $.Values.rmsDeployment)) (and (eq $vName "rms-security") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) (and (eq $vName "rms-webstudio") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) }}
- name: {{ $vName }}
  persistentVolumeClaim:
{{- if and (eq $vName "rms-shared") $.Values.enableRMS }}
    claimName: {{ $.Values.persistence.rmsSharedPVC }}
{{- else }}
    claimName: {{ $.Release.Name }}-{{ $vName }}
{{- end }}
{{- end }}
{{- end }}
{{- if $.Values.certificatesFromSecrets }}
{{- range $j, $value := $.Values.certificatesFromSecrets }}
- name: {{ $value.secretName }}
  secret:
    secretName: "{{ $value.secretName }}"
{{- end }}
{{- end }}
{{- end }}

{{- define "bechart.volumeClaimTemplates" }}
{{- if or (eq $.Values.bsType "sharednothing") $.Values.persistence.logs $.Values.enableRMS $.Values.rmsDeployment }}
volumeClaimTemplates:
{{- end }}
{{- range $i, $vName := tuple "data-store" "logs" "rms-shared" "rms-security" "rms-webstudio" }}
{{- if or (and (eq $vName "data-store") (eq $.Values.bsType "sharednothing")) (and (eq $vName "logs") $.Values.persistence.logs) (and (eq $vName "rms-shared") (or $.Values.enableRMS $.Values.rmsDeployment)) (and (eq $vName "rms-security") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) (and (eq $vName "rms-webstudio") $.Values.persistence.rmsWebstudio $.Values.rmsDeployment) }}
- metadata:
    name: {{ $vName }}
  spec:
    accessModes: [ "ReadWriteOnce" ]
{{- include "bechart.storageclass" $ | indent 4 }}
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
    memory: "{{ .resources.memoryRequest }}"
    cpu: "{{ .resources.cpuRequest }}"
  limits:
    memory: "{{ .resources.memoryLimit }}"
    cpu: "{{ .resources.cpuLimit }}"
{{- end }}

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

{{- define "bechart.discovery.env" }}
{{- if eq .Values.cmType "as2" }}
- name: AS_DISCOVER_URL
  value: tcp://
{{- range $i, $agent := $.Values.agents -}}
{{- range $j, $e := until (int $agent.discoverableReplicas) -}}
{{ $.Release.Name }}-{{ $agent.name }}-{{ $j }}.{{ include "bechart.discoveryservice.name" $ }}:50000;
{{- end }}
{{- end }}
{{- else if eq .Values.cmType "ignite" }}
- name: "tra.tibco.env.CUSTOM_EXT_APPEND_CP"
  value: "/opt/tibco/be/latest/lib/ext/tpcl/apache/ignite/optional/ignite-kubernetes"
- name: "tra.be.ignite.k8s.service.name"
  value: "{{ include "bechart.discoveryservice.name" $ }}"
- name: "tra.be.ignite.discovery.type"
  value: "k8s"
- name: "tra.be.ignite.k8s.namespace"
  value: "{{ .Release.Namespace }}"
{{- end }}
{{- end }}

{{- define "healthcheck" -}}
{{- if eq .Values.healthcheck.enabled true }}
livenessProbe:
  tcpSocket:
    port: {{ .Values.healthcheck.livenessProbe.port | default (.Values.apispecservice.port | default 8180) }}
  initialDelaySeconds: {{ .Values.healthcheck.livenessProbe.initialDelaySeconds }}
  periodSeconds: {{ .Values.healthcheck.livenessProbe.periodSeconds }} 
readinessProbe:
  tcpSocket:
    port: {{ .Values.healthcheck.readinessProbe.port | default (.Values.apispecservice.port | default 8180) }}
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

{{- define "becharts.antiaffinity" }}
{{- if eq .podAntiAffinity.enabled true }}
  podAntiAffinity:    
    preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: {{ .podAntiAffinity.labelKey }}
              operator: In
              values:
              - {{ .podAntiAffinity.labelvalue | quote}}
          topologyKey: {{ .podAntiAffinity.topologyKey | quote}}    
{{- end }}
{{- end }}

{{- define "becharts.affinity" }}
{{- if eq .podAffinity.enabled true }}
podAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: {{ .podAffinity.labelKey }}
        operator: In
        values:
        - {{ .podAffinity.labelvalue | quote}}
    topologyKey: {{ .podAffinity.topologyKey | quote}}
{{- end }}
{{- end }}

{{- define "becharts.labels" }}
{{- if eq (.podAntiAffinity).enabled true }}
{{ .podAntiAffinity.labelKey}}: {{ .podAntiAffinity.labelvalue }}
{{- end }}
{{- if and (eq (.podAffinity).enabled true) (eq .podAffinity.removelabel true) }}
{{ .podAffinity.labelKey}}: {{ .podAffinity.labelvalue }}
{{- end }}
{{- end }}