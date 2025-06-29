{{/*
Expand the name of the chart.
*/}}
{{- define "refmd.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "refmd.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "refmd.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "refmd.labels" -}}
helm.sh/chart: {{ include "refmd.chart" . }}
{{ include "refmd.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "refmd.selectorLabels" -}}
app.kubernetes.io/name: {{ include "refmd.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
API specific labels
*/}}
{{- define "refmd.api.labels" -}}
{{ include "refmd.labels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
API selector labels
*/}}
{{- define "refmd.api.selectorLabels" -}}
{{ include "refmd.selectorLabels" . }}
app.kubernetes.io/component: api
{{- end }}

{{/*
App specific labels
*/}}
{{- define "refmd.app.labels" -}}
{{ include "refmd.labels" . }}
app.kubernetes.io/component: app
{{- end }}

{{/*
App selector labels
*/}}
{{- define "refmd.app.selectorLabels" -}}
{{ include "refmd.selectorLabels" . }}
app.kubernetes.io/component: app
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "refmd.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "refmd.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
PostgreSQL host name
*/}}
{{- define "refmd.postgresqlHost" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "refmd.fullname" .) }}
{{- else }}
{{- .Values.externalDatabase.host }}
{{- end }}
{{- end }}

{{/*
PostgreSQL port
*/}}
{{- define "refmd.postgresqlPort" -}}
{{- if .Values.postgresql.enabled }}
5432
{{- else }}
{{- .Values.externalDatabase.port }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret name for password
*/}}
{{- define "refmd.postgresqlSecretName" -}}
{{- if .Values.postgresql.enabled }}
{{- printf "%s-postgresql" (include "refmd.fullname" .) }}
{{- else }}
{{- .Values.externalDatabase.existingSecret }}
{{- end }}
{{- end }}

{{/*
PostgreSQL secret key for password
*/}}
{{- define "refmd.postgresqlPasswordKey" -}}
{{- if .Values.postgresql.enabled }}
postgres-password
{{- else }}
{{- .Values.externalDatabase.existingSecretPasswordKey }}
{{- end }}
{{- end }}

{{/*
PostgreSQL username
*/}}
{{- define "refmd.postgresqlUsername" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.username }}
{{- else }}
{{- .Values.externalDatabase.username }}
{{- end }}
{{- end }}

{{/*
PostgreSQL database name
*/}}
{{- define "refmd.postgresqlDatabase" -}}
{{- if .Values.postgresql.enabled }}
{{- .Values.postgresql.auth.database }}
{{- else }}
{{- .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
Database connection string (used only for external databases with static password)
*/}}
{{- define "refmd.databaseUrl" -}}
{{- if and (not .Values.postgresql.enabled) (not .Values.externalDatabase.existingSecret) }}
{{- printf "postgresql://%s:%s@%s:%d/%s" .Values.externalDatabase.username .Values.externalDatabase.password .Values.externalDatabase.host (.Values.externalDatabase.port | int) .Values.externalDatabase.database }}
{{- end }}
{{- end }}

{{/*
API URL for app
*/}}
{{- define "refmd.apiUrl" -}}
{{- if .Values.ingress.enabled }}
{{- $host := (first .Values.ingress.hosts).host }}
{{- printf "http://%s/api" $host }}
{{- else }}
{{- printf "http://%s-api:%d/api" (include "refmd.fullname" .) (.Values.service.api.port | int) }}
{{- end }}
{{- end }}

{{/*
Socket URL for app
*/}}
{{- define "refmd.socketUrl" -}}
{{- if .Values.ingress.enabled }}
{{- $host := (first .Values.ingress.hosts).host }}
{{- printf "http://%s" $host }}
{{- else }}
{{- printf "http://%s-api:%d" (include "refmd.fullname" .) (.Values.service.api.port | int) }}
{{- end }}
{{- end }}

{{/*
Site URL for app
*/}}
{{- define "refmd.siteUrl" -}}
{{- if .Values.ingress.enabled }}
{{- $host := (first .Values.ingress.hosts).host }}
{{- printf "http://%s" $host }}
{{- else }}
{{- .Values.refmd.app.siteUrl }}
{{- end }}
{{- end }}