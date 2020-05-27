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

{{- define "bediscoverynode.fullname" -}}
{{ .Release.Name }}-{{- .Values.discoverynode.name -}}
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
s
{{- define "commonconfigmap.fullname" -}}
{{ .Release.Name }}-{{ .Values.configmap.name }}
{{- end -}}

{{- define "nosqlconfigmap.fullname" -}}
{{ .Release.Name }}-{{ .Values.nosqlconfigmap.name }}
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
- name: {{ .Values.database.drivername }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.driverval }}
- name: {{ .Values.database.urlname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.urlval }}
- name: {{ .Values.database.username }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.userval }}
- name: {{ .Values.database.pwdname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.pwdval }}
- name: {{ .Values.database.poolsizename }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.poolsizeval }}
- name: {{ .Values.database.logintimeoutname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "commonconfigmap.fullname" . }}
      key: {{ .Values.database.logintimeoutval }}
{{- end }}
{{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
{{- if eq .Values.storeType "Cassandra"  }}
- name: {{ .Values.cassdatabase.drivername }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.cassdatabase.driverval }}
- name: {{ .Values.cassdatabase.portname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.cassdatabase.portval }}
- name: {{ .Values.cassdatabase.keyspacename }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.cassdatabase.keyspaceval }}
- name: {{ .Values.cassdatabase.username }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.cassdatabase.userval }}
- name: {{ .Values.cassdatabase.pwdname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.cassdatabase.pwdval }}
{{- end }}
{{- if eq .Values.storeType "AS4"  }}
- name: {{ .Values.as4database.realmname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.realmval }}
- name: {{ .Values.as4database.secrealmurlname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.secrealmurlval }}
- name: {{ .Values.as4database.gridname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.gridval }}
- name: {{ .Values.as4database.storetimeoutname }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.storetimeoutval }}
- name: {{ .Values.as4database.storewaittimename }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.storewaittimeval }}
- name: {{ .Values.as4database.poolsizename }}
  valueFrom:
    configMapKeyRef:
      name: {{ include "nosqlconfigmap.fullname" . }}
      key: {{ .Values.as4database.poolsizeval }}      
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

{{/*
Create a common DB configMap data details for store
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
Create a common DB configMap data details for store
*/}}
{{- define "nosqlconfigmap.data" -}}
data:
  {{- if or (eq .Values.bsType "store" ) (eq .Values.omType "store" ) }}
  {{- if eq .Values.storeType "Cassandra"  }}
  db_cass_server_hostname: "{{ .Values.cassconfigmap.cass_server_hostname }}"
  db_cass_server_port: "{{ .Values.cassconfigmap.cass_server_port }}"
  db_cass_keyspace_name: "{{ .Values.cassconfigmap.cass_keyspace_name }}"
  db_cass_username: "{{ .Values.cassconfigmap.cass_username }}"
  db_cass_password: "{{ .Values.cassconfigmap.cass_password }}"
  {{- end -}}
  {{- if eq .Values.storeType "AS4" }}
  db_realm_url: "{{ .Values.as4configmap.realm_url }}"
  db_sec_realm_url: "{{ .Values.as4configmap.sec_realm_url }}"
  db_grid_name: "{{ .Values.as4configmap.grid_name }}"
  db_store_timeout: "{{ .Values.as4configmap.store_timeout }}"
  db_store_waittime: "{{ .Values.as4configmap.store_waittime }}"
  db_store_poolsize: "{{ .Values.as4configmap.store_poolsize }}"
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
