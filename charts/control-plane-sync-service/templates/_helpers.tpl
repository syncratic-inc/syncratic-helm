{{- define "control-plane-sync-service.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "control-plane-sync-service.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "control-plane-sync-service.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "control-plane-sync-service.labels" -}}
app.kubernetes.io/name: {{ include "control-plane-sync-service.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "control-plane-sync-service.selectorLabels" -}}
app.kubernetes.io/name: {{ include "control-plane-sync-service.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
