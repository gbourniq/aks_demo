{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "aks-demo.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name, <release-name>-<chart-name>
This is also used to prefix all resources names within this deployment
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "aks-demo.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "aks-demo.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "aks-demo.labels" -}}
helm.sh/chart: {{ include "aks-demo.chart" . }}
{{ include "aks-demo.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "aks-demo.selectorLabels" -}}
app.kubernetes.io/name: {{ include "aks-demo.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "aks-demo.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ include "aks-demo.fullname" . }}-{{ .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Generate pod security context to use (global takes precedence)
*/}}
{{- define "aks-demo.podSecurityContext" -}}
{{- if .Values.podSecurityContext -}}
{{- toYaml .Values.podSecurityContext }}
{{- end }}
{{- end -}}

{{/*
Generate security context to use (global takes precedence)
*/}}
{{- define "aks-demo.securityContext" -}}
{{- if .Values.securityContext -}}
{{- toYaml .Values.securityContext }}
{{- end }}
{{- end -}}


{{/*
Generate configMapRef data to be injected into deployment 
*/}}
{{- define "aks-demo.env" -}}
{{- $aksDemoAppFullname := include "aks-demo.fullname" . -}}
{{- range .Values.global.aks_demo_env }}
- configMapRef:
    name: {{ $aksDemoAppFullname }}-{{ .name }}
{{- end }}
{{- end -}}


{{/*
Generate secretRef data to be injected into deployment 
*/}}
{{- define "aks-demo.secrets" -}}
{{- $aksDemoAppFullname := include "aks-demo.fullname" . -}}
{{- range .Values.global.aks_demo_secret }}
- secretRef:
    name: {{ $aksDemoAppFullname }}-{{ .name }}
{{- end }}
{{- end -}}


{{/*
Generate a list of volumes to be injected into deployment
*/}} 
{{- define "aks-demo.volumes" -}}

{{- $aksDemoAppFullname := include "aks-demo.fullname" . -}}

{{- range .Values.global.aks_demo_file_mounts }}
- name: {{ .name }}
  configMap:
    name: {{ $aksDemoAppFullname }}-{{ .name }}
{{- end }}

{{- end -}}


{{/*
Generate a list of volumes mounts for the aks-demo container
*/}}
{{- define "aks-demo.volMounts" -}}

{{- range .Values.global.aks_demo_file_mounts }}
- name: {{ .name }}
  mountPath: {{ tpl .mountPath $ }}
  subPath: {{ tpl .subPath $ }}
  readOnly: {{ .readOnly | default false }}
{{- end }}

{{- end -}}

{{/*
Generate livenessProbe data to be injected into deployment 
*/}}
{{- define "aks-demo.liveness-probe" -}}
httpGet:
  path: "/"
{{- range .Values.service.ports }}
  port: {{ .port }}
{{- end }}
initialDelaySeconds: {{ .Values.initialDelaySeconds }}
{{- with .Values.livenessProbe }}
periodSeconds: {{ .periodSeconds }}
timeoutSeconds: {{ .timeoutSeconds }}
successThreshold: {{ .successThreshold }}
failureThreshold: {{ .failureThreshold }}
{{- end }}
{{- end -}}

{{/*
Generate readinessProbe data to be injected into deployment 
*/}}
{{- define "aks-demo.readiness-probe" -}}
httpGet:
  path: "/"
{{- range .Values.service.ports }}
  port: {{ .port }}
{{- end }}
initialDelaySeconds: {{ .Values.initialDelaySeconds }}
{{- with .Values.readinessProbe }}
periodSeconds: {{ .periodSeconds }}
timeoutSeconds: {{ .timeoutSeconds }}
successThreshold: {{ .successThreshold }}
failureThreshold: {{ .failureThreshold }}
{{- end }}
{{- end -}}