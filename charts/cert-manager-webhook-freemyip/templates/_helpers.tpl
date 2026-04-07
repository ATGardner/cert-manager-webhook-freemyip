{{/* vim: set filetype=mustache: */}}

{{- define "cert-manager-webhook-freemyip.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.fullname" -}}
{{- if .Values.fullnameOverride -}}
  {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
  {{- $name := default .Chart.Name .Values.nameOverride -}}
  {{- if contains $name .Release.Name -}}
    {{- .Release.Name | trunc 63 | trimSuffix "-" -}}
  {{- else -}}
    {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.labels" -}}
app.kubernetes.io/name: {{ include "cert-manager-webhook-freemyip.name" . }}
helm.sh/chart: {{ include "cert-manager-webhook-freemyip.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.selfSignedIssuer" -}}
{{ printf "%s-selfsign" (include "cert-manager-webhook-freemyip.fullname" .) }}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.rootCAIssuer" -}}
{{ printf "%s-ca" (include "cert-manager-webhook-freemyip.fullname" .) }}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.rootCACertificate" -}}
{{ printf "%s-ca" (include "cert-manager-webhook-freemyip.fullname" .) }}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.servingCertificate" -}}
{{ printf "%s-webhook-tls" (include "cert-manager-webhook-freemyip.fullname" .) }}
{{- end -}}

{{- define "cert-manager-webhook-freemyip.secretName" -}}
{{- default (include "cert-manager-webhook-freemyip.fullname" .) (.Values.secret.existingSecretName) -}}
{{- end -}}
